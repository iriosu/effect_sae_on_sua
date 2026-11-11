#!/usr/bin/env Rscript
# Survey-lottery project, step 3: offer effects on the outcomes of the 2023 baseline survey.
#
# Follows specification_log.md: offer effects (ITT) first, with selection into response, trimming bounds,
# a reweighted version, and attendance effects (IV) only where Section 6 of the log allows.
# Reads the paper's mechanisms panel, the 2023 baseline export, the public registration file of the 2023
# process, and three program-level files of the Mistakes package. Data stay where they are.
# Writes aggregates only, and no statistic from fewer than MIN_CELL students in either offer group.
#
# Run from the repository root:
#   Rscript code/survey_lottery_2023/03_baseline_offer_effects.R

suppressPackageStartupMessages({
  library(fixest)
  library(dplyr)
  library(tidyr)
  library(lubridate)
})
setFixest_vcov(all = "hetero")
setFixest_estimation(fixef.rm = "none")
setFixest_notes(FALSE)

MIN_CELL <- 11L     # no count or statistic below this number of children
MIN_EST <- 50L      # no regression with fewer answering children than this in either offer group
BOOT <- 300L
set.seed(20261111)
controls <- c("GPA8_Z", "ES_MUJER", "PRIORITARIO", "ALTO", "ORIGIN_OD")
here <- "code/survey_lottery_2023"
stopifnot(file.exists(file.path(here, "specification_log.md")))
source(file.path(here, "estimators.R"))   # estimators and table writers shared with steps 5 and 6
dir.create(file.path(here, "output"), showWarnings = FALSE)
dir.create(file.path(here, "logs"), showWarnings = FALSE)

home <- path.expand("~")
panel_path <- file.path(Sys.getenv("SAE_MECHANISMS_DATA",
  file.path(home, "Dropbox", "Effect SAE on SUA", "data", "finalized_design_v1", "mechanisms")),
  "mechanisms_panel.rds")
package <- Sys.getenv("MISTAKES_PACKAGE", file.path(home, "Dropbox", "mistakes_replication", "replication_package"))
survey_path <- file.path(package, "Data", "qualtrics_exports", "Baseline survey mistakes 2023_January 3, 2023_09.csv")
registration_path <- file.path(package, "Data", "survey_2023", "A_INSCRITOS_PUNTAJES_PAES_2023_PUB_MRUN.csv")
cutoff_path <- file.path(package, "Data", "survey_2023", "cutoffs_and_extras_official_2023.csv")
names_path <- file.path(package, "Data", "survey_2023", "names_codes.csv")
programs_path <- file.path(package, "Data", "survey_2023", "carreras.csv")

sha256 <- function(p) sub(" .*", "", system2("sha256sum", shQuote(p), stdout = TRUE))
expected <- c(survey = "594ef6c268a43bdcad359c02b4d3fd1db78a831493ab8179166ac53cbce8cd44",
              registration = "64adf9a1bd76624253b8939578e0764ac34eb8a69fe99500e69d3edef5161d8d")
found <- c(survey = sha256(survey_path), registration = sha256(registration_path))
stopifnot(identical(found, expected))
manifest <- read.csv("code/finalized_design_v1/mechanisms/data_manifest.csv")
stopifnot(identical(unname(tools::md5sum(panel_path)), manifest$md5[manifest$file == "mechanisms_panel.rds"]))

as_key <- function(x) suppressWarnings(as.numeric(as.character(x)))
num <- function(x) suppressWarnings(as.numeric(gsub(",", ".", trimws(as.character(x)), fixed = TRUE)))
answered <- function(x) !is.na(x) & trimws(as.character(x)) != ""

# ---- Data -------------------------------------------------------------------------------------------
est <- readRDS(panel_path) %>% drop_na(all_of(controls)) %>%
  mutate(KEY = as_key(MRUN), HAS_SCORE_OT = as.numeric(!is.na(SCORE_LM_OT)),
         APPLIED_OT = as.numeric(!is.na(LIST_PROGRAMS_OT)))

score_cols <- c("MRUN", "PTJE_NEM", "PTJE_RANKING", "MATE1_REG_ACTUAL", "CLEC_REG_ACTUAL")
scores <- as.data.frame(data.table::fread(registration_path, sep = ";", select = score_cols, showProgress = FALSE))
scores <- scores %>% transmute(KEY = as_key(MRUN), REAL_NEM = num(PTJE_NEM), REAL_RANKING = num(PTJE_RANKING),
                               REAL_MATH = num(MATE1_REG_ACTUAL), REAL_READING = num(CLEC_REG_ACTUAL)) %>%
  mutate(across(starts_with("REAL_"), ~ ifelse(.x > 0, .x, NA_real_))) %>%
  distinct(KEY, .keep_all = TRUE)

# Program-level files: code of each named program, and its cutoff of the 2023 regular process.
codes <- read.csv(names_path, header = FALSE, col.names = c("uni", "name", "code"))
codes$name[codes$name == "NUTRICION Y DIETETICA  | CASA CENTRAL (CONDELL)"] <- "NUTRICION Y DIETETICA | CASA CENTRAL (CONDELL)"
codes <- distinct(codes, uni, name, .keep_all = TRUE)
cutoffs <- read.csv(cutoff_path)
programs <- read.csv(programs_path)
cutoffs <- cutoffs %>%
  left_join(select(programs, codigo_carrera = CODIGO, min_score = PTJE_POND_MIN), by = "codigo_carrera") %>%
  mutate(cutoff = ifelse(full_reg == 1, num(cutoff_reg), num(min_score)),
         cutoff = ifelse(cutoff > 0, cutoff, NA_real_),
         pct = 100 * ecdf(cutoff)(cutoff)) %>%
  select(code = codigo_carrera, cutoff, pct)

survey <- read.csv(survey_path, sep = ";") %>%
  filter(Q17 == "Acepto") %>%
  mutate(START = mdy_hm(StartDate), KEY = as_key(mrun), PROGRESS = as_key(Progress)) %>%
  filter(START > mdy_hm("12/27/2022 10:00"), !is.na(KEY)) %>%
  arrange(KEY, desc(PROGRESS), START) %>%
  distinct(KEY, .keep_all = TRUE)

absent <- character(0)
col <- function(name) {
  if (name %in% names(survey)) num(survey[[name]]) else {absent <<- union(absent, name); rep(NA_real_, nrow(survey))}
}
txt <- function(name) if (name %in% names(survey)) trimws(as.character(survey[[name]])) else rep("", nrow(survey))
in_range <- function(v, lo, hi) ifelse(!is.na(v) & v >= lo & v <= hi, v, NA_real_)
code_of <- function(uni, name) codes$code[match(paste(uni, name, sep = "||"), paste(codes$uni, codes$name, sep = "||"))]

named_true <- txt("Q8_2") != ""; named_first <- txt("Q19_2") != ""; named_last <- txt("Q20_2") != ""
same_first <- named_true & named_first & txt("Q8_2") == txt("Q19_2") & txt("Q8_1") == txt("Q19_1")
# Answer for the planned first preference: its own row when shown, the top true row when the programs coincide.
first_row <- function(tag) {
  r1 <- col(paste0(tag, "_1")); r2 <- col(paste0(tag, "_2"))
  ifelse(!is.na(r2), r2, ifelse(same_first, r1, NA_real_))
}
# Items asked in several random groups of questions: the answer, and the group that holds it.
across_groups <- function(tags, fun) {
  vals <- lapply(tags, fun)
  value <- Reduce(function(a, b) ifelse(is.na(a), b, a), vals)
  group <- Reduce(function(a, b) ifelse(is.na(a), b, a),
                  Map(function(v, k) ifelse(is.na(v), NA_integer_, k), vals, seq_along(vals)))
  list(value = value, group = group)
}
top_true_row <- function(tag) col(paste0(tag, "_1"))

code_true <- code_of(txt("Q8_1"), txt("Q8_2")); code_first <- code_of(txt("Q19_1"), txt("Q19_2"))
code_last <- code_of(txt("Q20_1"), txt("Q20_2"))
match_rate <- c(top_true = mean(!is.na(code_true[named_true])), first = mean(!is.na(code_first[named_first])),
                last = mean(!is.na(code_last[named_last])))
pct_of <- function(code) cutoffs$pct[match(code, cutoffs$code)]
cut_of <- function(code) cutoffs$cutoff[match(code, cutoffs$code)]

sv <- data.frame(KEY = survey$KEY)
sv <- left_join(sv, scores, by = "KEY")
# Family E: admission and cutoff beliefs.
sv$exp_math <- in_range(col("Q5_1"), 100, 1000); sv$exp_reading <- in_range(col("Q5_3"), 100, 1000)
sv$exp_nem <- in_range(col("Q41_1"), 100, 1000); sv$exp_ranking <- in_range(col("Q41_2"), 100, 1000)
sv$bias_math <- sv$exp_math - sv$REAL_MATH; sv$bias_reading <- sv$exp_reading - sv$REAL_READING
sv$bias_nem <- sv$exp_nem - sv$REAL_NEM; sv$bias_ranking <- sv$exp_ranking - sv$REAL_RANKING
for (k in c("math", "reading", "nem", "ranking")) sv[[paste0("absbias_", k)]] <- abs(sv[[paste0("bias_", k)]])
sv$real_math <- ifelse(is.na(sv$bias_math), NA, sv$REAL_MATH); sv$real_reading <- ifelse(is.na(sv$bias_reading), NA, sv$REAL_READING)
sv$real_nem <- ifelse(is.na(sv$bias_nem), NA, sv$REAL_NEM); sv$real_ranking <- ifelse(is.na(sv$bias_ranking), NA, sv$REAL_RANKING)
sv$prob_adm_first <- first_row("Q63"); sv$cutoff_belief_first <- first_row("Q64"); sv$prob_above_first <- first_row("Q65")
sv$prob_adm_true <- top_true_row("Q63")
sv$cutoff_bias_first <- sv$cutoff_belief_first - cut_of(code_first)
sv$abs_cutoff_bias_first <- abs(sv$cutoff_bias_first)
# Family B: own probability of college attainment (items that exist).
sv$prob_admitted <- in_range(col("Q61_1"), 0, 100); sv$prob_apply <- in_range(col("Q60_1"), 0, 100)
g <- across_groups(c("Q47", "Q112", "Q119"), first_row); sv$grad_first <- g$value; sv$grp_grad_first <- g$group
# Family C: selectivity of the top true program.
sv$pct_true <- ifelse(named_true, pct_of(code_true), NA); sv$pct_first <- ifelse(named_first, pct_of(code_first), NA)
sv$pct_last <- ifelse(named_last, pct_of(code_last), NA)
# Family D: planned first preference differs from the top true program.
sv$differs <- ifelse(named_true & named_first, as.numeric(!same_first), NA)
# Family A: beliefs about earnings and progression, planned first preference and top true program.
family_a <- list(income = c("Q186", "Q74", "Q78"), payment = c("Q72"), semesters = c("Q73", "Q77", "Q71"),
                 position = c("Q95", "Q52", "Q276"), stay = c("Q100", "Q111", "Q56", "Q117"),
                 pass_all = c("Q101", "Q57", "Q118", "Q70"), employment = c("Q69", "Q76", "Q75"))
for (k in names(family_a)) {
  g <- across_groups(family_a[[k]], first_row)
  sv[[paste0(k, "_first")]] <- g$value; sv[[paste0("grp_", k, "_first")]] <- g$group
  g <- across_groups(family_a[[k]], top_true_row)
  sv[[paste0(k, "_true")]] <- g$value; sv[[paste0("grp_", k, "_true")]] <- g$group
}
g <- across_groups(c("Q47", "Q112", "Q119"), top_true_row); sv$grad_true <- g$value; sv$grp_grad_true <- g$group
sv$STARTED <- 1
registered_keys <- scores$KEY
rm(survey, scores)

d18 <- est %>% filter(YEAR == 2018) %>% left_join(sv, by = "KEY") %>%
  mutate(STARTED = replace_na(STARTED, 0), REGISTERED = as.numeric(KEY %in% registered_keys))
d17 <- est %>% filter(YEAR == 2017) %>% left_join(sv, by = "KEY") %>%
  mutate(STARTED = replace_na(STARTED, 0), REGISTERED = as.numeric(KEY %in% registered_keys))
# Family F: application choices from administrative records, among children who started the survey.
for (v in c("LIST_MAX_CUTOFF_OT", "LIST_PROGRAMS_OT", "LIST_MEAN_CUTOFF_OT", "LIST_MISSED_OT", "LIST_REACHED_OT")) {
  d18[[paste0("resp_", v)]] <- ifelse(d18$STARTED == 1, d18[[v]], NA)
  d17[[paste0("resp_", v)]] <- ifelse(d17$STARTED == 1, d17[[v]], NA)
}

# ---- Outcome list -----------------------------------------------------------------------------------
outcomes <- rbind(
  o("A", "income_first", "Expected monthly income, planned first preference (pesos)", TRUE, "grp_income_first"),
  o("A", "payment_first", "Expected annual payment, planned first preference (pesos)", FALSE, "grp_payment_first"),
  o("A", "grad_first", "Probability of graduating, planned first preference", FALSE, "grp_grad_first"),
  o("A", "semesters_first", "Semesters to graduate, planned first preference", FALSE, "grp_semesters_first"),
  o("A", "position_first", "Position among 100 peers, planned first preference", FALSE, "grp_position_first"),
  o("A", "stay_first", "Probability of staying, planned first preference", FALSE, "grp_stay_first"),
  o("A", "pass_all_first", "Probability of passing all first-year courses, planned first preference", FALSE, "grp_pass_all_first"),
  o("A", "employment_first", "Probability of employment, planned first preference", FALSE, "grp_employment_first"),
  o("A", "income_true", "Expected monthly income, top true program (pesos)", FALSE, "grp_income_true"),
  o("A", "payment_true", "Expected annual payment, top true program (pesos)", FALSE, "grp_payment_true"),
  o("A", "grad_true", "Probability of graduating, top true program", FALSE, "grp_grad_true"),
  o("A", "semesters_true", "Semesters to graduate, top true program", FALSE, "grp_semesters_true"),
  o("A", "position_true", "Position among 100 peers, top true program", FALSE, "grp_position_true"),
  o("A", "stay_true", "Probability of staying, top true program", FALSE, "grp_stay_true"),
  o("A", "pass_all_true", "Probability of passing all first-year courses, top true program", FALSE, "grp_pass_all_true"),
  o("A", "employment_true", "Probability of employment, top true program", FALSE, "grp_employment_true"),
  o("B", "prob_admitted", "Q61: probability of admission to any program of the application", TRUE, lo = 0, hi = 100),
  o("B", "prob_apply", "Q60: probability of applying"),
  o("B", "grad_first", "Probability of graduating, planned first preference", FALSE, "grp_grad_first"),
  o("C", "pct_true", "Cutoff percentile of the top true program (2023 process)", TRUE, lo = 0, hi = 100),
  o("C", "pct_first", "Cutoff percentile of the planned first preference"),
  o("C", "pct_last", "Cutoff percentile of the planned last preference"),
  o("D", "differs", "Planned first preference differs from the top true program", TRUE, lo = 0, hi = 1),
  o("E", "bias_math", "Expected minus realized Mathematics M1 score", TRUE),
  o("E", "bias_reading", "Expected minus realized Reading score"),
  o("E", "bias_nem", "Expected minus realized NEM score"),
  o("E", "bias_ranking", "Expected minus realized Ranking score"),
  o("E", "absbias_math", "Absolute difference, Mathematics M1"),
  o("E", "absbias_reading", "Absolute difference, Reading"),
  o("E", "absbias_nem", "Absolute difference, NEM"),
  o("E", "absbias_ranking", "Absolute difference, Ranking"),
  o("E", "exp_math", "Expected Mathematics M1 score"),
  o("E", "exp_reading", "Expected Reading score"),
  o("E", "exp_nem", "Expected NEM score"),
  o("E", "exp_ranking", "Expected Ranking score"),
  o("E", "prob_adm_first", "Q63: probability of admission if listed first, planned first preference"),
  o("E", "cutoff_belief_first", "Q64: cutoff belief, planned first preference"),
  o("E", "prob_above_first", "Q65: probability own score above the cutoff, planned first preference"),
  o("E", "prob_adm_true", "Q63: probability of admission if listed first, top true program"),
  o("E", "cutoff_bias_first", "Cutoff belief minus realized cutoff, planned first preference"),
  o("E", "abs_cutoff_bias_first", "Absolute difference, cutoff of the planned first preference"),
  o("E", "real_math", "Realized Mathematics M1 score, same children (companion row)", adjust = FALSE),
  o("E", "real_reading", "Realized Reading score, same children (companion row)", adjust = FALSE),
  o("E", "real_nem", "Realized NEM score, same children (companion row)", adjust = FALSE),
  o("E", "real_ranking", "Realized Ranking score, same children (companion row)", adjust = FALSE),
  o("F", "resp_LIST_MAX_CUTOFF_OT", "Highest cutoff percentile of the submitted list, on time, children who started", TRUE),
  o("F", "resp_LIST_PROGRAMS_OT", "Number of listed programs, on time, children who started"),
  o("F", "resp_LIST_MEAN_CUTOFF_OT", "Mean cutoff percentile of the list, on time, children who started"),
  o("F", "resp_LIST_MISSED_OT", "Listed cutoffs missed, on time, children who started"),
  o("F", "resp_LIST_REACHED_OT", "Reached a listed cutoff, on time, children who started"))

# ---- Estimation (functions in estimators.R) -------------------------------------------------------------
res18 <- estimate_all(d18, outcomes, bounds = TRUE)
res17 <- estimate_all(d17, outcomes, bounds = FALSE)

# Family F in the full 2018 cohort (no survey), as the paper estimates these outcomes by application year.
cohort_f <- lapply(c("LIST_MAX_CUTOFF_OT", "LIST_PROGRAMS_OT", "LIST_MEAN_CUTOFF_OT", "LIST_MISSED_OT", "LIST_REACHED_OT"), function(v) {
  sub <- d18[!is.na(d18[[v]]), ]; sub$y <- sub[[v]]
  m <- feols(y ~ OFFER + .[controls] | CHANCE_GROUP, sub)
  data.frame(var = v, n_offer = sum(sub$OFFER == 1), n_no_offer = sum(sub$OFFER == 0),
             mean_no_offer = mean(sub$y[sub$OFFER == 0]), itt = coef(m)[["OFFER"]], itt_se = se(m)[["OFFER"]])
}) %>% bind_rows()

# ---- Output ------------------------------------------------------------------------------------------
out_path <- file.path(here, "output", "baseline_offer_effects.md")
con <- file(out_path, "w")
w_ <- function(...) writeLines(paste0(...), con)
w_("# 2023 baseline survey: offer effects in the lottery sample")
w_("")
w_("Written by `code/survey_lottery_2023/03_baseline_offer_effects.R`. Exploratory. Specifications are in `specification_log.md`.")
w_("Rows with fewer than ", MIN_CELL, " answering children in either offer group are suppressed. Rows with fewer than ", MIN_EST, " in either group show counts and no estimate.")
w_("Share of named programs matched to a program code: top true ", f(match_rate[["top_true"]]), ", planned first ",
   f(match_rate[["first"]]), ", planned last ", f(match_rate[["last"]]), ".")
if (length(absent)) w_("Export columns not found: ", paste(absent, collapse = ", "), ".")
w_("")
print_effects(w_, res18, "1. Application year 2018: offer effects among children who answered each item",
  "Each row is one regression: outcome on `OFFER`, the paper's controls, and chance-group effects (plus effects for the random group of questions where the item sits in one), robust standard errors. The estimate compares offered and non-offered children who answered. It is an effect on a fixed population only if the offer does not change who answers (Section 2 below).")
w_("## 2. Application year 2018: selection into answering, bounds, and reweighting")
w_("")
w_("The stage effect is the offer effect on answering the item, in the whole cohort (34,052 children). The trimming bounds (Lee 2009) weight children so that the weighted difference in means equals the regression on `OFFER` and chance-group effects (an offered child weighs one minus the offer share of the chance group, a non-offered child the offer share). The column before the bounds is that weighted difference. The interval is that of Imbens and Manski (2004), from ", BOOT, " bootstrap draws of children. Worst-case bounds use the range of the outcome and the whole cohort. The reweighted effect weights answering children by the inverse of their estimated probability of answering among the registered children of the cohort (logit on the controls and on-time graduation, score, and application, by offer group). The last column is the largest share of the total weight held by one child.")
w_("")
print_selection(w_, res18)
w_("## 3. Application year 2018: attendance effects (IV)")
w_("")
w_("An attendance effect is shown only when the 95 percent interval of the stage effect includes zero and both trimming bounds have the same sign (specification log, Section 6). It describes compliers who answer.")
w_("")
print_iv(w_, res18)
print_effects(w_, res17, "4. Application year 2017 in the 2023 process: offer effects among children who answered",
  "These children reach the 2023 process one year after their scheduled process. Reported separately, without bounds.")
w_("## 5. Application year 2018, whole cohort: application choices on time (no survey)")
w_("")
w_("| Outcome | With offer | Without offer | Mean without offer | Offer effect | SE |")
w_("|---|---|---|---|---|---|")
for (i in seq_len(nrow(cohort_f))) with(cohort_f[i, ], w_("| ", var, " | ", n_offer, " | ", n_no_offer, " | ", f(mean_no_offer), " | ", f(itt), " | ", f(itt_se), " |"))
close(con)

lc <- file(file.path(here, "logs", "03_baseline_offer_effects.txt"), "w")
writeLines(c(
  paste("run_time_utc:", format(Sys.time(), tz = "UTC", usetz = TRUE)),
  paste("git_head:", system("git rev-parse HEAD", intern = TRUE)),
  paste("r_version:", R.version.string),
  paste("fixest:", as.character(packageVersion("fixest"))),
  paste("seed: 20261111; bootstrap draws:", BOOT),
  paste("panel_md5:", unname(tools::md5sum(panel_path))),
  paste("survey_sha256:", found[["survey"]]),
  paste("registration_sha256:", found[["registration"]]),
  paste("cutoffs_md5:", unname(tools::md5sum(cutoff_path))),
  paste("names_codes_md5:", unname(tools::md5sum(names_path))),
  paste("carreras_md5:", unname(tools::md5sum(programs_path))),
  paste("specification_log_md5:", unname(tools::md5sum(file.path(here, "specification_log.md")))),
  paste("cohort_2018_children:", nrow(d18), "; started:", sum(d18$STARTED)),
  paste("outcomes:", nrow(outcomes), "; rows not estimated (2018):", sum(pmin(res18$n_offer, res18$n_no_offer) < MIN_EST)),
  paste("output_md5:", unname(tools::md5sum(out_path)))
), lc)
close(lc)
cat("Wrote", out_path, "\n")
