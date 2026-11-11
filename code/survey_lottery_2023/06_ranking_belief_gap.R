#!/usr/bin/env Rscript
# Survey-lottery project, step 6: expected against realized Ranking and NEM scores.
#
# Examination of the Ranking rows of family E, added after the first results. The rows are fixed in the
# entry of 11 November 2026, 21:23 UTC, of specification_log.md. They are descriptive and enter no adjusted set.
# Reads the paper's mechanisms panel, the 2023 baseline export, and the public registration file of the 2023
# process. Data stay where they are. Writes aggregates only.
#
# Run from the repository root:
#   Rscript code/survey_lottery_2023/06_ranking_belief_gap.R

suppressPackageStartupMessages({
  library(fixest)
  library(dplyr)
  library(tidyr)
  library(lubridate)
})
setFixest_vcov(all = "hetero")
setFixest_estimation(fixef.rm = "none")
setFixest_notes(FALSE)

MIN_CELL <- 11L
MIN_EST <- 50L
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
survey_path <- file.path(package, "Data", "qualtrics_exports", "Baseline survey mistakes 2023_January 3, 2023_09.csv")
registration_path <- file.path(package, "Data", "survey_2023", "A_INSCRITOS_PUNTAJES_PAES_2023_PUB_MRUN.csv")

sha256 <- function(p) sub(" .*", "", system2("sha256sum", shQuote(p), stdout = TRUE))
expected <- c(survey = "594ef6c268a43bdcad359c02b4d3fd1db78a831493ab8179166ac53cbce8cd44",
              registration = "64adf9a1bd76624253b8939578e0764ac34eb8a69fe99500e69d3edef5161d8d")
found <- c(survey = sha256(survey_path), registration = sha256(registration_path))
stopifnot(identical(found, expected))
manifest <- read.csv("code/finalized_design_v1/mechanisms/data_manifest.csv")
stopifnot(identical(unname(tools::md5sum(panel_path)), manifest$md5[manifest$file == "mechanisms_panel.rds"]))

as_key <- function(x) suppressWarnings(as.numeric(as.character(x)))
num <- function(x) suppressWarnings(as.numeric(gsub(",", ".", trimws(as.character(x)), fixed = TRUE)))
in_range <- function(v, lo, hi) ifelse(!is.na(v) & v >= lo & v <= hi, v, NA_real_)

# ---- Data -------------------------------------------------------------------------------------------
est <- readRDS(panel_path) %>% drop_na(all_of(controls)) %>%
  mutate(KEY = as_key(MRUN), HAS_SCORE_OT = as.numeric(!is.na(SCORE_LM_OT)),
         APPLIED_OT = as.numeric(!is.na(LIST_PROGRAMS_OT)))
scores <- as.data.frame(data.table::fread(registration_path, sep = ";", select = c("MRUN", "PTJE_NEM", "PTJE_RANKING"),
                                          showProgress = FALSE)) %>%
  transmute(KEY = as_key(MRUN), REAL_NEM = num(PTJE_NEM), REAL_RANKING = num(PTJE_RANKING)) %>%
  mutate(across(starts_with("REAL_"), ~ ifelse(.x > 0, .x, NA_real_))) %>%
  distinct(KEY, .keep_all = TRUE)
survey <- read.csv(survey_path, sep = ";") %>%
  filter(Q17 == "Acepto") %>%
  mutate(START = mdy_hm(StartDate), KEY = as_key(mrun), PROGRESS = as_key(Progress)) %>%
  filter(START > mdy_hm("12/27/2022 10:00"), !is.na(KEY)) %>%
  arrange(KEY, desc(PROGRESS), START) %>%
  distinct(KEY, .keep_all = TRUE)
sv <- data.frame(KEY = survey$KEY, STARTED = 1,
                 EXP_NEM = in_range(num(survey[["Q41_1"]]), 100, 1000), EXP_RANKING = in_range(num(survey[["Q41_2"]]), 100, 1000))
rm(survey)

d <- est %>% filter(YEAR == 2018) %>% left_join(scores, by = "KEY") %>% left_join(sv, by = "KEY") %>%
  mutate(STARTED = replace_na(STARTED, 0), REGISTERED = as.numeric(KEY %in% scores$KEY))
only <- function(cond, v) ifelse(cond, v, NA_real_)
for (k in c("RANKING", "NEM")) {
  low <- tolower(k); both <- !is.na(d[[paste0("EXP_", k)]]) & !is.na(d[[paste0("REAL_", k)]])
  d[[paste0("gap_", low)]] <- only(both, d[[paste0("EXP_", k)]] - d[[paste0("REAL_", k)]])
  d[[paste0("absgap_", low)]] <- abs(d[[paste0("gap_", low)]])
  d[[paste0("exp_", low)]] <- only(both, d[[paste0("EXP_", k)]])
  d[[paste0("real_", low)]] <- only(both, d[[paste0("REAL_", k)]])
}
d$over_ranking <- as.numeric(d$gap_ranking > 0)
d$within50_ranking <- as.numeric(d$absgap_ranking <= 50)
d$under100_ranking <- as.numeric(d$gap_ranking < -100)
four <- !is.na(d$gap_ranking) & !is.na(d$gap_nem)
d$exp_extra <- only(four, d$EXP_RANKING - d$EXP_NEM)
d$real_extra <- only(four, d$REAL_RANKING - d$REAL_NEM)
d$gap_extra <- d$exp_extra - d$real_extra
cut99 <- quantile(d$gap_ranking, c(0.01, 0.99), na.rm = TRUE)
d$gap_ranking_w <- pmin(pmax(d$gap_ranking, cut99[[1]]), cut99[[2]])
# Realized scores without the survey.
d$c_real_ranking <- d$REAL_RANKING; d$c_real_nem <- d$REAL_NEM
d$c_real_ranking_started <- only(d$STARTED == 1, d$REAL_RANKING)
d$c_real_ranking_not_started <- only(d$STARTED == 0, d$REAL_RANKING)

survey_rows <- rbind(
  o("E", "gap_ranking", "Expected minus realized Ranking score", adjust = FALSE),
  o("E", "absgap_ranking", "Absolute difference, Ranking", adjust = FALSE),
  o("E", "exp_ranking", "Expected Ranking score, same children", adjust = FALSE),
  o("E", "real_ranking", "Realized Ranking score, same children", adjust = FALSE),
  o("E", "gap_nem", "Expected minus realized NEM score", adjust = FALSE),
  o("E", "absgap_nem", "Absolute difference, NEM", adjust = FALSE),
  o("E", "exp_nem", "Expected NEM score, same children", adjust = FALSE),
  o("E", "real_nem", "Realized NEM score, same children", adjust = FALSE),
  o("E", "over_ranking", "Expected Ranking above realized Ranking", adjust = FALSE),
  o("E", "within50_ranking", "Absolute difference of 50 points or less, Ranking", adjust = FALSE),
  o("E", "under100_ranking", "Expected Ranking more than 100 points below realized", adjust = FALSE),
  o("E", "exp_extra", "Expected Ranking minus expected NEM", adjust = FALSE),
  o("E", "real_extra", "Realized Ranking minus realized NEM, same children", adjust = FALSE),
  o("E", "gap_extra", "Expected minus realized, Ranking minus NEM", adjust = FALSE),
  o("E", "gap_ranking_w", "Expected minus realized Ranking, winsorized at percentiles 1 and 99", adjust = FALSE))
cohort_rows <- rbind(
  o("E", "c_real_ranking", "Realized Ranking score, children with a score in the registration file", adjust = FALSE, rw = FALSE),
  o("E", "c_real_nem", "Realized NEM score, children with a score in the registration file", adjust = FALSE, rw = FALSE),
  o("E", "c_real_ranking_started", "Realized Ranking score, children who started the baseline", adjust = FALSE, rw = FALSE),
  o("E", "c_real_ranking_not_started", "Realized Ranking score, children who did not start the baseline", adjust = FALSE, rw = FALSE),
  o("E", "SCORE_RANKING_OT", "`SCORE_RANKING_OT` of the paper's panel", adjust = FALSE, rw = FALSE),
  o("E", "SCORE_NEM_OT", "`SCORE_NEM_OT` of the paper's panel", adjust = FALSE, rw = FALSE))
indicator_cells <- vapply(c("over_ranking", "within50_ranking", "under100_ranking"), function(v) {
  y <- d[[v]]; min(table(factor(d$OFFER[!is.na(y)], 0:1), factor(y[!is.na(y)], 0:1)))
}, numeric(1))
stopifnot(all(indicator_cells >= MIN_CELL))

res_s <- estimate_all(d, survey_rows, bounds = TRUE)
res_c <- estimate_all(d, cohort_rows, bounds = TRUE)

# Difference between the offer effects on realized Ranking of children who started and children who did not.
with_score <- d[!is.na(d$REAL_RANKING), ]
inter <- feols(REAL_RANKING ~ OFFER + STARTED + OFFER:STARTED + .[controls] | CHANCE_GROUP, with_score)

# Weighted quantiles of expected minus realized Ranking by offer group, weights of the trimming bounds.
wquant <- function(v, w, probs) {
  ord <- order(v); v <- v[ord]; cw <- cumsum(w[ord]) / sum(w)
  vapply(probs, function(p) v[which(cw >= p)[1]], numeric(1))
}
probs <- c(0.10, 0.25, 0.50, 0.75, 0.90)
quantile_rows <- function(z, g, y) {
  w <- ipw(z, g); ok <- !is.na(y) & w > 0
  q1 <- wquant(y[ok & z == 1], w[ok & z == 1], probs); q0 <- wquant(y[ok & z == 0], w[ok & z == 0], probs)
  rbind(q1, q0, q1 - q0)
}
q_point <- quantile_rows(d$OFFER, d$CHANCE_GROUP, d$gap_ranking)
q_boot <- replicate(BOOT, {
  idx <- sample.int(nrow(d), nrow(d), TRUE)
  quantile_rows(d$OFFER[idx], d$CHANCE_GROUP[idx], d$gap_ranking[idx])[3, ]
})
q_se <- apply(q_boot, 1, sd)

# ---- Output ------------------------------------------------------------------------------------------
out_path <- file.path(here, "output", "ranking_belief_gap.md")
con <- file(out_path, "w")
w_ <- function(...) writeLines(paste0(...), con)
w_("# Expected against realized Ranking and NEM scores: offer effects, application year 2018")
w_("")
w_("Written by `code/survey_lottery_2023/06_ranking_belief_gap.R`. Added after the first results. The rows were fixed in the entry of 11 November 2026, 21:23 UTC, of `specification_log.md`. They are descriptive and enter no adjusted set. The q-values of the Ranking rows are those of `baseline_offer_effects.md` (0.167).")
w_("Expected scores are the answers to `Q41` of the 2023 baseline (NEM and Ranking, 100 to 1000). Realized scores are `PTJE_NEM` and `PTJE_RANKING` of the public registration file of the 2023 process.")
w_("")
print_effects(w_, res_s, "1. Children who answered: offer effects",
  "Each row is one regression: outcome on `OFFER`, the paper's controls, and chance-group effects, robust standard errors. Expected and realized scores use the children who have both, so the effect on the difference equals the effect on the expected score minus the effect on the realized score.")
w_("## 2. Children who answered: precision")
w_("")
w_("The minimum detectable effect is 2.80 standard errors (80 percent power in a two-sided test at 5 percent).")
w_("")
print_precision(w_, res_s)
w_("## 3. Children who answered: selection, bounds, and reweighting")
w_("")
w_("Columns as in `baseline_offer_effects.md`, Section 2.")
w_("")
print_selection(w_, res_s)
w_("## 4. Quantiles of expected minus realized Ranking by offer group")
w_("")
w_("Children are weighted as in the trimming bounds (an offered child weighs one minus the offer share of the chance group, a non-offered child the offer share). Standard errors of the differences come from ", BOOT, " bootstrap draws of children. No controls.")
w_("")
w_("| Quantile | With offer | Without offer | Difference | SE |")
w_("|---|---|---|---|---|")
for (k in seq_along(probs)) w_("| ", 100 * probs[k], " | ", f(q_point[1, k], 1), " | ", f(q_point[2, k], 1), " | ", f(q_point[3, k], 1), " | ", f(q_se[k], 1), " |")
w_("")
print_effects(w_, res_c, "5. Realized scores without the survey: offer effects",
  "Realized scores of the registration file for every child of the cohort who has one, and the scores on time of the paper's panel.")
w_("## 6. Realized scores without the survey: precision")
w_("")
print_precision(w_, res_c)
w_("## 7. Realized scores without the survey: selection and bounds")
w_("")
w_("The stage effect is the offer effect on having the score. The reweighted effect is not computed for these rows.")
w_("")
print_selection(w_, res_c)
w_("## 8. Offer effect on realized Ranking by whether the child started the baseline")
w_("")
w_("One regression of realized Ranking on `OFFER`, starting the baseline, their interaction, the controls, and chance-group effects, among the ", format(nrow(with_score), big.mark = ","), " children with a score.")
w_("")
w_("| Term | Coefficient | SE | p |")
w_("|---|---|---|---|")
for (term in c("OFFER", "STARTED", "OFFER:STARTED")) w_("| `", term, "` | ", f(coef(inter)[[term]], 1), " | ", f(se(inter)[[term]], 1), " | ", f(pvalue(inter)[[term]]), " |")
w_("")
w_("## 9. Attendance effects (IV)")
w_("")
w_("Shown only under the conditions of the specification log, Section 6.")
w_("")
print_iv(w_, bind_rows(res_s, res_c))
close(con)

lc <- file(file.path(here, "logs", "06_ranking_belief_gap.txt"), "w")
writeLines(c(
  paste("run_time_utc:", format(Sys.time(), tz = "UTC", usetz = TRUE)),
  paste("git_head:", system("git rev-parse HEAD", intern = TRUE)),
  paste("r_version:", R.version.string),
  paste("fixest:", as.character(packageVersion("fixest"))),
  paste("seed: 20261111; bootstrap draws:", BOOT),
  paste("panel_md5:", unname(tools::md5sum(panel_path))),
  paste("survey_sha256:", found[["survey"]]),
  paste("registration_sha256:", found[["registration"]]),
  paste("estimators_md5:", unname(tools::md5sum(file.path(here, "estimators.R")))),
  paste("specification_log_md5:", unname(tools::md5sum(file.path(here, "specification_log.md")))),
  paste("cohort_2018_children:", nrow(d), "; with a Ranking score:", nrow(with_score), "; answered and have a Ranking score:", sum(!is.na(d$gap_ranking))),
  paste("rows: children who answered", nrow(res_s), "; without the survey", nrow(res_c)),
  paste("output_md5:", unname(tools::md5sum(out_path)))
), lc)
close(lc)
cat("Wrote", out_path, "\n")
