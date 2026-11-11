#!/usr/bin/env Rscript
# Survey-lottery project, step 5: the rest of family D (mistakes and strategic reports).
#
# Offer effects on listing the top true program, on applications that do not meet requirements, and on the
# risk of no assignment, for the children of application year 2018. Definitions are in the entry of
# 11 November 2026, 21:23 UTC, of specification_log.md.
# Reads the paper's mechanisms panel, the 2023 baseline export, the public registration file, the three
# public files of applications of the 2023 process, and two files of admission probabilities of the
# Mistakes project. Data stay where they are.
# Writes aggregates only, and no statistic from fewer than MIN_CELL children in a cell.
#
# Run from the repository root:
#   Rscript code/survey_lottery_2023/05_application_outcomes.R

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
source(file.path(here, "estimators.R"))

home <- path.expand("~")
panel_path <- file.path(Sys.getenv("SAE_MECHANISMS_DATA",
  file.path(home, "Dropbox", "Effect SAE on SUA", "data", "finalized_design_v1", "mechanisms")),
  "mechanisms_panel.rds")
package <- Sys.getenv("MISTAKES_PACKAGE", file.path(home, "Dropbox", "mistakes_replication", "replication_package"))
apps_dir <- Sys.getenv("MISTAKES_2023_INPUT", file.path(home, "Dropbox", "Mistakes Structural", "Data", "2023", "input"))
paths <- c(
  survey = file.path(package, "Data", "qualtrics_exports", "Baseline survey mistakes 2023_January 3, 2023_09.csv"),
  registration = file.path(package, "Data", "survey_2023", "A_INSCRITOS_PUNTAJES_PAES_2023_PUB_MRUN.csv"),
  regular = file.path(apps_dir, "ABCD", "C_POSTULANTES_SELECCION_PAES_2023_PUB_MRUN.csv"),
  bea = file.path(apps_dir, "ABCD", "C_POSTULANTES_SELECCION_PAES_CUPOS_SUPERNUMERADOS_2023_PUB_MRUN.csv"),
  pace = file.path(apps_dir, "ABCD", "C_POSTULANTES_SELECCION_PAES_CUPOS_PACE_2023_PUB_MRUN.csv"),
  jan4 = file.path(apps_dir, "applications_and_probs_20230104_1800.csv"),
  final = file.path(apps_dir, "applications_and_probs_final.csv"))
names_path <- file.path(package, "Data", "survey_2023", "names_codes.csv")

sha256 <- function(p) sub(" .*", "", system2("sha256sum", shQuote(p), stdout = TRUE))
expected <- c(
  survey = "594ef6c268a43bdcad359c02b4d3fd1db78a831493ab8179166ac53cbce8cd44",
  registration = "64adf9a1bd76624253b8939578e0764ac34eb8a69fe99500e69d3edef5161d8d",
  regular = "c6a366030f1ff74ba618eb3505b3f3da515f089244a783836c322c0be8ef7415",
  bea = "68b4972bac351a3de5f252ba0986684e0f142ca81b16db38bbf0f46362e261ea",
  pace = "8a823eeed511a4669cbccaef17a3ad9066c9220b64dc156b457cce455372d958",
  jan4 = "2e3bac473e5e9edf149c44caf9669b8ed6e3907199c093152bbeff5e13030630",
  final = "f9b4a6ab462e28c9ea5d788e8db0ef2746f6cb3a6dfeec2ffc260d43a2e65f31")
found <- vapply(paths, sha256, character(1))
stopifnot(identical(found[names(expected)], expected))
manifest <- read.csv("code/finalized_design_v1/mechanisms/data_manifest.csv")
stopifnot(identical(unname(tools::md5sum(panel_path)), manifest$md5[manifest$file == "mechanisms_panel.rds"]))

as_key <- function(x) suppressWarnings(as.numeric(as.character(x)))
num <- function(x) suppressWarnings(as.numeric(gsub(",", ".", trimws(as.character(x)), fixed = TRUE)))
read_public <- function(p, ...) as.data.frame(data.table::fread(p, sep = ";", showProgress = FALSE, ...))

# ---- Data -------------------------------------------------------------------------------------------
est <- readRDS(panel_path) %>% drop_na(all_of(controls)) %>%
  mutate(KEY = as_key(MRUN), HAS_SCORE_OT = as.numeric(!is.na(SCORE_LM_OT)),
         APPLIED_OT = as.numeric(!is.na(LIST_PROGRAMS_OT)))
registered_keys <- as_key(read_public(paths[["registration"]], select = "MRUN")$MRUN)

# Public file of regular applications: one row per applicant, up to 20 preferences.
reg <- read_public(paths[["regular"]])
names(reg)[1] <- "MRUN"
reg <- reg[!duplicated(reg$MRUN), ]   # one student of the country is listed twice; the first row is kept
stopifnot(!anyDuplicated(reg$MRUN))
code_cols <- grep("^COD_CARRERA_PREF_", names(reg), value = TRUE); status_cols <- grep("^ESTADO_PREF_", names(reg), value = TRUE)
stopifnot(length(code_cols) == 20, length(status_cols) == 20)
code_m <- as.matrix(reg[, code_cols]); status_m <- as.matrix(reg[, status_cols])
listed <- code_m > 0; valid <- status_m >= 24 & status_m <= 26
stopifnot(all(listed == (status_m != 0)), all(rowSums(listed) > 0))
n_listed <- rowSums(listed); n_valid <- rowSums(valid)
stopifnot(all((n_valid == 0) == (reg$SITUACION_POSTULANTE == "C")))
selected_in <- function(p) {
  x <- read_public(p); x$MRUN[rowSums(as.matrix(x[, grep("^ESTADO_PREF_", names(x))]) == 24) > 0]
}
selected_keys <- unique(c(reg$MRUN[rowSums(status_m == 24) > 0], selected_in(paths[["bea"]]), selected_in(paths[["pace"]])))
app <- data.frame(KEY = as_key(reg$MRUN), APPLIED = 1,
                  any_invalid = as.numeric(n_listed > n_valid), share_invalid = (n_listed - n_valid) / n_listed,
                  all_invalid = as.numeric(n_valid == 0), not_assigned = as.numeric(!(reg$MRUN %in% selected_keys)))
app_codes <- code_m; app_keys <- app$KEY
file_totals <- c(applicants = nrow(app), any_invalid = mean(app$any_invalid), all_invalid = mean(app$all_invalid),
                 not_assigned = mean(app$not_assigned))
rm(reg, code_m, status_m, listed, valid)

# Admission probabilities of the Mistakes project: final list, and list on file on 4 January 18:00.
fin <- read_public(paths[["final"]], select = c("MRUN", "overall", "risk_label")) %>%
  transmute(KEY = as_key(MRUN), overall_fin = num(overall), risk_fin = risk_label) %>% distinct(KEY, .keep_all = TRUE)
jan4 <- read_public(paths[["jan4"]], select = c("MRUN", "risk_label")) %>%
  transmute(KEY = as_key(MRUN), risk_jan4 = risk_label) %>% distinct(KEY, .keep_all = TRUE)
stopifnot(all(fin$risk_fin %in% 1:3), all(jan4$risk_jan4 %in% 1:3),
          all(fin$overall_fin[fin$risk_fin == 1] <= 0.01), all(fin$overall_fin[fin$risk_fin == 3] >= 0.99))
file_totals <- c(file_totals, final_rows = nrow(fin), final_rows_applicants = sum(fin$KEY %in% app$KEY), jan4_rows = nrow(jan4))

# Baseline survey: top true program, planned first preference, and Q61.
codes <- read.csv(names_path, header = FALSE, col.names = c("uni", "name", "code"))
codes$name[codes$name == "NUTRICION Y DIETETICA  | CASA CENTRAL (CONDELL)"] <- "NUTRICION Y DIETETICA | CASA CENTRAL (CONDELL)"
codes <- distinct(codes, uni, name, .keep_all = TRUE)
survey <- read.csv(paths[["survey"]], sep = ";") %>%
  filter(Q17 == "Acepto") %>%
  mutate(START = mdy_hm(StartDate), KEY = as_key(mrun), PROGRESS = as_key(Progress)) %>%
  filter(START > mdy_hm("12/27/2022 10:00"), !is.na(KEY)) %>%
  arrange(KEY, desc(PROGRESS), START) %>%
  distinct(KEY, .keep_all = TRUE)
txt <- function(name) trimws(as.character(survey[[name]]))
code_of <- function(uni, name) codes$code[match(paste(uni, name, sep = "||"), paste(codes$uni, codes$name, sep = "||"))]
named_true <- txt("Q8_2") != ""; named_first <- txt("Q19_2") != ""
same_first <- named_true & named_first & txt("Q8_2") == txt("Q19_2") & txt("Q8_1") == txt("Q19_1")
q61 <- num(survey[["Q61_1"]])
sv <- data.frame(KEY = survey$KEY, STARTED = 1,
                 code_true = ifelse(named_true, code_of(txt("Q8_1"), txt("Q8_2")), NA),
                 differs = ifelse(named_true & named_first, as.numeric(!same_first), NA),
                 prob_admitted = ifelse(!is.na(q61) & q61 >= 0 & q61 <= 100, q61, NA))
# Position of the top true program in the final list (NA when it is not listed or the child did not apply).
row_in_app <- match(sv$KEY, app_keys)
sv$true_listed <- NA_real_; sv$true_first <- NA_real_
has <- !is.na(row_in_app) & !is.na(sv$code_true)
sv$true_listed[has] <- as.numeric(rowSums(app_codes[row_in_app[has], , drop = FALSE] == sv$code_true[has]) > 0)
sv$true_first[has] <- as.numeric(app_codes[row_in_app[has], 1] == sv$code_true[has])
# Check: the same indicator from the list in long form (one student-program pair per listed preference).
pairs <- paste(rep(app_keys, times = ncol(app_codes)), as.vector(app_codes))
stopifnot(identical(as.numeric(paste(sv$KEY[has], sv$code_true[has]) %in% pairs), sv$true_listed[has]))
rm(pairs)
rm(survey, app_codes)

d <- est %>% filter(YEAR == 2018) %>%
  left_join(sv, by = "KEY") %>% left_join(app, by = "KEY") %>% left_join(fin, by = "KEY") %>% left_join(jan4, by = "KEY") %>%
  mutate(STARTED = replace_na(STARTED, 0), APPLIED = replace_na(APPLIED, 0),
         REGISTERED = as.numeric(KEY %in% registered_keys),
         HAS_TRUE = as.numeric(STARTED == 1 & !is.na(code_true)),
         HAS_FINAL = as.numeric(APPLIED == 1 & !is.na(overall_fin)), ON_FILE_JAN4 = as.numeric(!is.na(risk_jan4)))
only <- function(cond, v) ifelse(cond, v, NA_real_)
# Administrative outcomes, whole cohort (prefix c_) and children who started the baseline (prefix s_).
d$c_any_invalid_all <- ifelse(d$APPLIED == 1, d$any_invalid, 0)
d$c_any_invalid <- only(d$APPLIED == 1, d$any_invalid)
d$c_share_invalid <- only(d$APPLIED == 1, d$share_invalid)
d$c_all_invalid <- only(d$APPLIED == 1, d$all_invalid)
d$c_adm_prob_all <- ifelse(d$APPLIED == 0, 0, d$overall_fin)
d$c_risk_final <- only(d$HAS_FINAL == 1, 1 - d$overall_fin)
d$c_high_risk_final <- only(d$HAS_FINAL == 1, as.numeric(d$risk_fin == 1))
d$c_high_risk_jan4 <- only(d$ON_FILE_JAN4 == 1, as.numeric(d$risk_jan4 == 1))
d$c_not_assigned <- only(d$APPLIED == 1, d$not_assigned)
admin <- c("any_invalid_all", "any_invalid", "share_invalid", "all_invalid", "adm_prob_all", "risk_final",
           "high_risk_final", "high_risk_jan4", "not_assigned")
for (v in admin) d[[paste0("s_", v)]] <- only(d$STARTED == 1, d[[paste0("c_", v)]])
# Survey-linked outcomes.
d$t_listed_all <- only(d$HAS_TRUE == 1, ifelse(d$APPLIED == 1, d$true_listed, 0))
d$t_first_all <- only(d$HAS_TRUE == 1, ifelse(d$APPLIED == 1, d$true_first, 0))
d$t_listed <- only(d$HAS_TRUE == 1 & d$APPLIED == 1, d$true_listed)
d$t_first <- only(d$HAS_TRUE == 1 & d$APPLIED == 1, d$true_first)
d$s_differs <- only(d$STARTED == 1, d$differs)
d$s_belief_gap <- only(d$STARTED == 1 & d$HAS_FINAL == 1, d$prob_admitted - 100 * d$overall_fin)
d$s_abs_belief_gap <- abs(d$s_belief_gap)

# ---- Outcome lists ----------------------------------------------------------------------------------
admin_labels <- c(
  any_invalid_all = "Applied with at least one inadmissible application (0 without an application)",
  any_invalid = "At least one inadmissible application, applicants",
  share_invalid = "Share of listed preferences that are inadmissible, applicants",
  all_invalid = "Every listed preference inadmissible, applicants",
  adm_prob_all = "Probability of admission of the final list (0 without an application)",
  risk_final = "Risk of no assignment (one minus the probability of admission), applicants",
  high_risk_final = "Probability of admission below 0.01, final list, applicants",
  high_risk_jan4 = "Probability of admission below 0.01, list on file on 4 January 18:00",
  not_assigned = "Not selected in any preference (regular, BEA and PACE seats), applicants")
outcomes_s <- rbind(
  o("D", "s_differs", "Planned first preference differs from the top true program (main outcome of step 3)"),
  o("D", "t_listed_all", "Top true program in the final list (0 without an application)"),
  o("D", "t_first_all", "Top true program listed first (0 without an application)"),
  o("D", "t_listed", "Top true program in the final list, applicants"),
  o("D", "t_first", "Top true program listed first, applicants"),
  do.call(rbind, lapply(admin, function(v) o("D", paste0("s_", v), paste0(admin_labels[[v]], ", children who started")))),
  o("D", "s_belief_gap", "Q61 minus 100 times the probability of admission of the final list"),
  o("D", "s_abs_belief_gap", "Absolute difference, Q61 and the probability of admission of the final list"))
outcomes_c <- do.call(rbind, lapply(admin, function(v)
  o("D", paste0("c_", v), paste0(admin_labels[[v]], ", whole cohort"), adjust = FALSE, rw = FALSE)))

# Disclosure: an indicator with fewer than MIN_CELL children in a cell of offer by value is not estimated.
cells_ok <- function(v) {
  y <- d[[v]]; if (!all(y[!is.na(y)] %in% 0:1)) return(TRUE)
  min(table(factor(d$OFFER[!is.na(y)], 0:1), factor(y[!is.na(y)], 0:1))) >= MIN_CELL
}
small_s <- outcomes_s$label[!vapply(outcomes_s$var, cells_ok, logical(1))]
small_c <- outcomes_c$label[!vapply(outcomes_c$var, cells_ok, logical(1))]
outcomes_s <- outcomes_s[!(outcomes_s$label %in% small_s), ]; outcomes_c <- outcomes_c[!(outcomes_c$label %in% small_c), ]

res_s <- estimate_all(d, outcomes_s, bounds = TRUE)
res_c <- estimate_all(d, outcomes_c, bounds = TRUE)

# Stages: offer effect on reaching each sample.
stage_row <- function(label, y, cond) {
  sub <- d[cond, ]; sub$y <- y[cond]
  cells <- table(factor(sub$OFFER, 0:1), factor(sub$y, 0:1))
  if (min(cells) < MIN_CELL) return(data.frame(label, shown = FALSE))
  m <- feols(y ~ OFFER + .[controls] | CHANCE_GROUP, sub)
  data.frame(label, shown = TRUE, n_offer = sum(sub$OFFER == 1), n_no_offer = sum(sub$OFFER == 0),
             yes_offer = cells["1", "1"], yes_no_offer = cells["0", "1"], mean_no_offer = mean(sub$y[sub$OFFER == 0]),
             itt = coef(m)[["OFFER"]], itt_se = se(m)[["OFFER"]])
}
every <- rep(TRUE, nrow(d))
stages <- bind_rows(
  stage_row("Applied to the 2023 process (public file), whole cohort", d$APPLIED, every),
  stage_row("Applied, registered children", d$APPLIED, d$REGISTERED == 1),
  stage_row("Applied, children who started the baseline", d$APPLIED, d$STARTED == 1),
  stage_row("Applied, children who named a matched top true program", d$APPLIED, d$HAS_TRUE == 1),
  stage_row("List on file on 4 January 18:00, whole cohort", d$ON_FILE_JAN4, every),
  stage_row("List on file on 4 January 18:00, children who started the baseline", d$ON_FILE_JAN4, d$STARTED == 1),
  stage_row("Row in the file of final probabilities, applicants of the cohort", d$HAS_FINAL, d$APPLIED == 1))
concordance <- table(panel = d$APPLIED_OT, public = d$APPLIED)

# ---- Output ------------------------------------------------------------------------------------------
out_path <- file.path(here, "output", "application_outcomes.md")
con <- file(out_path, "w")
w_ <- function(...) writeLines(paste0(...), con)
cell <- function(n) if (n < MIN_CELL) paste("fewer than", MIN_CELL) else format(n, big.mark = ",")
w_("# Applications of the 2023 process: offer effects in the lottery sample (family D)")
w_("")
w_("Written by `code/survey_lottery_2023/05_application_outcomes.R`. Exploratory. Definitions are in the entry of 11 November 2026, 21:23 UTC, of `specification_log.md`.")
w_("Rows with fewer than ", MIN_EST, " children in either offer group show counts and no estimate. An indicator with fewer than ", MIN_CELL, " children in a cell of offer by value is not estimated.")
if (length(c(small_s, small_c))) w_("Not estimated for that reason: ", paste(c(small_s, small_c), collapse = "; "), ".")
w_("")
w_("## 1. Files and checks")
w_("")
w_("| Quantity | Value |")
w_("|---|---|")
w_("| Applicants in the public file of regular applications | ", format(file_totals[["applicants"]], big.mark = ","), " |")
w_("| Share with at least one inadmissible application | ", f(file_totals[["any_invalid"]]), " |")
w_("| Share with every listed preference inadmissible | ", f(file_totals[["all_invalid"]]), " |")
w_("| Share not selected in any preference (regular, BEA and PACE seats) | ", f(file_totals[["not_assigned"]]), " |")
w_("| Students in the file of final probabilities | ", format(file_totals[["final_rows"]], big.mark = ","), " |")
w_("| Of them, in the public file | ", format(file_totals[["final_rows_applicants"]], big.mark = ","), " |")
w_("| Students in the file of 4 January 18:00 | ", format(file_totals[["jan4_rows"]], big.mark = ","), " |")
w_("| Children of application year 2018 with every control | ", format(nrow(d), big.mark = ","), " |")
w_("| Of them, in the public file of regular applications | ", format(sum(d$APPLIED), big.mark = ","), " |")
w_("| Of them, with a row in the file of final probabilities | ", format(sum(d$HAS_FINAL), big.mark = ","), " |")
w_("| Children of the cohort with a list on file on 4 January 18:00 | ", format(sum(d$ON_FILE_JAN4), big.mark = ","), " |")
w_("| Children who started the baseline | ", format(sum(d$STARTED), big.mark = ","), " |")
w_("| Of them, in the public file | ", format(sum(d$STARTED == 1 & d$APPLIED == 1), big.mark = ","), " |")
w_("| Children who named a matched top true program | ", format(sum(d$HAS_TRUE), big.mark = ","), " |")
w_("| Of them, in the public file | ", format(sum(d$HAS_TRUE == 1 & d$APPLIED == 1), big.mark = ","), " |")
w_("")
w_("Application on time in the paper's panel (`LIST_PROGRAMS_OT` observed) against a row in the public file, children of the cohort:")
w_("")
w_("| | Not in the public file | In the public file |")
w_("|---|---|---|")
w_("| No application on time in the panel | ", cell(concordance["0", "0"]), " | ", cell(concordance["0", "1"]), " |")
w_("| Application on time in the panel | ", cell(concordance["1", "0"]), " | ", cell(concordance["1", "1"]), " |")
w_("")
w_("## 2. Stages: offer effect on reaching each sample")
w_("")
w_("Each row is one regression of the indicator on `OFFER`, the paper's controls, and chance-group effects, among the children named in the row.")
w_("")
w_("| Stage | Children with offer | Without offer | Yes, with offer | Yes, without offer | Share without offer | Offer effect | SE |")
w_("|---|---|---|---|---|---|---|---|")
for (i in seq_len(nrow(stages))) with(stages[i, ], {
  if (!shown) w_("| ", label, " | suppressed | | | | | | |")
  else w_("| ", label, " | ", n_offer, " | ", n_no_offer, " | ", yes_offer, " | ", yes_no_offer, " | ", f(mean_no_offer), " | ", f(itt, 4), " | ", f(itt_se, 4), " |")
})
w_("")
print_effects(w_, res_s, "3. Survey-linked rows: offer effects",
  "Each row is one regression: outcome on `OFFER`, the paper's controls, and chance-group effects, robust standard errors. Rows on the top true program use children who named a program that matches a program code. Rows that end in \"children who started\" use every child who started the baseline. A row marked \"applicants\" uses the children of its sample with a row in the public file of regular applications. The q-values adjust over the rows of this table. The Holm p-value of the main outcome is in `baseline_offer_effects.md`.")
w_("## 4. Survey-linked rows: precision")
w_("")
w_("The minimum detectable effect is 2.80 standard errors (80 percent power in a two-sided test at 5 percent).")
w_("")
print_precision(w_, res_s)
w_("## 5. Survey-linked rows: selection, bounds, and reweighting")
w_("")
w_("The stage effect is the offer effect on being in the sample of the row, in the whole cohort. The trimming bounds (Lee 2009), their interval (Imbens and Manski 2004, ", BOOT, " bootstrap draws of children), and the reweighted effect are those of `baseline_offer_effects.md`, Section 2.")
w_("")
print_selection(w_, res_s)
print_effects(w_, res_c, "6. Whole cohort, no survey: offer effects",
  "The same administrative outcomes for every child of application year 2018. These rows are outside the adjusted set. A row with \"0 without an application\" is defined for every child of the cohort.")
w_("## 7. Whole cohort: precision")
w_("")
print_precision(w_, res_c)
w_("## 8. Whole cohort: selection and bounds")
w_("")
w_("An outcome defined for every child has no stage, and its bounds equal the weighted difference. The reweighted effect is not computed for these rows.")
w_("")
print_selection(w_, res_c)
w_("## 9. Attendance effects (IV)")
w_("")
w_("An attendance effect is shown only when the 95 percent interval of the stage effect includes zero and both trimming bounds have the same sign (specification log, Section 6). An outcome defined for every child of the cohort has no stage. Its attendance effect rests on the paper's exclusion restriction for college outcomes.")
w_("")
print_iv(w_, bind_rows(res_s, res_c))
close(con)

lc <- file(file.path(here, "logs", "05_application_outcomes.txt"), "w")
writeLines(c(
  paste("run_time_utc:", format(Sys.time(), tz = "UTC", usetz = TRUE)),
  paste("git_head:", system("git rev-parse HEAD", intern = TRUE)),
  paste("r_version:", R.version.string),
  paste("fixest:", as.character(packageVersion("fixest"))),
  paste("seed: 20261111; bootstrap draws:", BOOT),
  paste("panel_md5:", unname(tools::md5sum(panel_path))),
  paste0(names(found), "_sha256: ", found),
  paste("names_codes_md5:", unname(tools::md5sum(names_path))),
  paste("estimators_md5:", unname(tools::md5sum(file.path(here, "estimators.R")))),
  paste("specification_log_md5:", unname(tools::md5sum(file.path(here, "specification_log.md")))),
  paste("cohort_2018_children:", nrow(d), "; started:", sum(d$STARTED), "; in the public file:", sum(d$APPLIED)),
  paste("rows: survey-linked", nrow(res_s), "; whole cohort", nrow(res_c), "; not estimated for small cells:", length(c(small_s, small_c))),
  paste("output_md5:", unname(tools::md5sum(out_path)))
), lc)
close(lc)
cat("Wrote", out_path, "\n")
