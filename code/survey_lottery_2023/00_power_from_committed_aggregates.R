#!/usr/bin/env Rscript
# Survey-lottery project, step 0: expected overlap and minimum detectable effects from numbers already
# committed to this repository and from the documentation of the Mistakes package.
#
# Reads two committed aggregate tables only. Opens no student-level file.
# The committed tables come from the October vintage of the lottery sample (176,321 children). The current
# vintage has 186,440. The counts below are therefore approximations until step 1 runs.
#
# Run from the repository root:
#   Rscript code/survey_lottery_2023/00_power_from_committed_aggregates.R

here <- "code/survey_lottery_2023"
agg <- "code/analysis_for_adversarial_report_output"
dir.create(file.path(here, "output"), showWarnings = FALSE)
dir.create(file.path(here, "logs"), showWarnings = FALSE)

support <- read.csv(file.path(agg, "f02_lottery_support_audit.csv"))
effects <- read.csv(file.path(agg, "offer_and_attendance_effects.csv"))

# Lottery sample by ninth-grade entry year. The application year is the entry year minus one.
cohort <- setNames(support$n, support$ENTRY_YEAR - 1L)
stopifnot(sum(cohort) == 176321L)

# Standard error of an offer effect on an outcome in SD units, times sqrt(n), from the three committed
# estimates in SD units (reading-mathematics mean, NEM, Ranking; paper's controls and chance-group effects).
sd_rows <- effects[effects$unit == "SD", ]
k <- sd_rows$rf_se * sqrt(sd_rows$rf_n)
names(k) <- sd_rows$variable
k_mid <- mean(k)
# The paper's controls predict those three outcomes. For an outcome that the controls do not predict, the
# factor is larger. The two binary outcomes below give a lower bound for it: their residual SD is at most
# sqrt(mean x (1 - mean)).
bin_rows <- effects[effects$variable %in% c("GRAD_OT", "APPLIED_OT"), ]
k_bin <- (bin_rows$rf_se * sqrt(bin_rows$rf_n)) / sqrt(bin_rows$mean_without_offer * (1 - bin_rows$mean_without_offer))
names(k_bin) <- bin_rows$variable
k_wide <- max(k_bin)
first_stage <- effects$fs_estimate[effects$variable == "GRAD_OT"]
applied_ot <- effects$mean_without_offer[effects$variable == "APPLIED_OT"]
score_ever <- effects$rf_n[effects$variable == "LM_Z_MAX"] / effects$rf_n[effects$variable == "GRAD_OT"]

# Documented counts of the Mistakes surveys (README of the replication package; the number registered is the
# number of data rows of the public registration file).
registered_2023 <- 296812
baseline <- c(started = 39051, completed = 15726)
endline <- c(started = 19147, completed = 7926)
target_group_2023 <- 132893      # applicants in the first half of the window; total applicants are more
applicants_2022 <- 148819
survey_2022 <- c(started = 31791, completed = 15057)

# Assumption: share of the 2018 application year registered for the tests of the 2023 process.
# No committed number gives it. The two values bracket the share with a score ever observed.
registered_share <- c(low = 0.55, high = 0.70)

mde <- function(n) 2.80 * k_mid / sqrt(n)
row <- function(label, n) data.frame(sample = label, expected_children = round(n), mde_offer_sd = mde(n),
                                     mde_offer_sd_wide = 2.80 * k_wide / sqrt(n),
                                     mde_attendance_sd = mde(n) / first_stage,
                                     mde_offer_pp_binary = 100 * 0.5 * 2.80 * k_wide / sqrt(n))
rows <- rbind(
  row("2023 baseline, started, 55% registered", cohort[["2018"]] * registered_share[["low"]] * baseline[["started"]] / registered_2023),
  row("2023 baseline, started, 70% registered", cohort[["2018"]] * registered_share[["high"]] * baseline[["started"]] / registered_2023),
  row("2023 baseline, completed, 55% registered", cohort[["2018"]] * registered_share[["low"]] * baseline[["completed"]] / registered_2023),
  row("2023 baseline, completed, 70% registered", cohort[["2018"]] * registered_share[["high"]] * baseline[["completed"]] / registered_2023),
  row("2023 baseline, completed, item in 2 of 4 groups, 55% registered", 0.5 * cohort[["2018"]] * registered_share[["low"]] * baseline[["completed"]] / registered_2023),
  row("2023 baseline, completed, item in 2 of 4 groups, 70% registered", 0.5 * cohort[["2018"]] * registered_share[["high"]] * baseline[["completed"]] / registered_2023),
  row("2023 endline, started (upper bound)", cohort[["2018"]] * applied_ot * endline[["started"]] / target_group_2023),
  row("2023 endline, completed (upper bound)", cohort[["2018"]] * applied_ot * endline[["completed"]] / target_group_2023),
  row("2022 survey, started", cohort[["2017"]] * applied_ot * survey_2022[["started"]] / applicants_2022),
  row("2022 survey, completed", cohort[["2017"]] * applied_ot * survey_2022[["completed"]] / applicants_2022))

f <- function(x, d) formatC(x, format = "f", digits = d, big.mark = ",")
out_path <- file.path(here, "output", "power_from_committed_aggregates.md")
con <- file(out_path, "w")
w <- function(...) writeLines(paste0(...), con)
w("# Expected overlap and minimum detectable effects from committed aggregates")
w("")
w("Written by `code/survey_lottery_2023/00_power_from_committed_aggregates.R`. No student-level file was read.")
w("Lottery counts come from the October vintage (176,321 children). The current vintage has 186,440.")
w("")
w("## Inputs")
w("")
w("| Quantity | Value | Source |")
w("|---|---|---|")
w("| Lottery sample, application year 2018 | ", f(cohort[["2018"]], 0), " | `f02_lottery_support_audit.csv`, entry year 2019 |")
w("| Lottery sample, application year 2017 | ", f(cohort[["2017"]], 0), " | `f02_lottery_support_audit.csv`, entry year 2018 |")
w("| Lottery sample, application year 2016 | ", f(cohort[["2016"]], 0), " | `f02_lottery_support_audit.csv`, entry year 2017 |")
w("| SE of an offer effect in SD units, times sqrt(n) | ", paste(names(k), f(k, 3), collapse = "; "), "; mean ", f(k_mid, 3), " | `offer_and_attendance_effects.csv` |")
w("| The same factor for an outcome that the controls do not predict | at least ", f(k_wide, 3), " | `offer_and_attendance_effects.csv`, binary outcomes ", paste(names(k_bin), f(k_bin, 3), collapse = "; "), " |")
w("| First stage, pooled | ", f(first_stage, 4), " | `offer_and_attendance_effects.csv` (the current paper reports 0.6104) |")
w("| Applied on time, without offer, pooled | ", f(applied_ot, 4), " | `offer_and_attendance_effects.csv` |")
w("| Share with a test score ever observed, pooled | ", f(score_ever, 4), " | `offer_and_attendance_effects.csv` |")
w("| Registered for the tests of the 2023 process | ", f(registered_2023, 0), " | Data rows of the public registration file |")
w("| 2023 baseline: started, completed | ", f(baseline[["started"]], 0), ", ", f(baseline[["completed"]], 0), " | Mistakes README |")
w("| 2023 endline: started, completed | ", f(endline[["started"]], 0), ", ", f(endline[["completed"]], 0), " | Mistakes README |")
w("| 2022 survey: applicants, started, completed | ", f(applicants_2022, 0), ", ", f(survey_2022[["started"]], 0), ", ", f(survey_2022[["completed"]], 0), " | Mistakes README |")
w("| Share of the 2018 application year registered for the 2023 tests | 0.55 and 0.70 | Assumed |")
w("")
w("## Expected children and minimum detectable effects")
w("")
w("Expected children = cohort x share reaching the survey population x survey response rate of that population.")
w("The response rate is the rate of all invited students. Lottery children may respond at another rate.")
w("Minimum detectable effect = 2.80 x ", f(k_mid, 3), " / sqrt(n), at 80 percent power and a 5 percent two-sided test.")
w("The second effect column uses the factor ", f(k_wide, 3), ", for an outcome that the paper's controls do not predict.")
w("The attendance column divides the first effect column by the pooled first stage. The last column is for a binary outcome with mean 0.5 and uses the second factor.")
w("The endline rows divide by the 132,893 applicants of the first half of the window, fewer than all applicants.")
w("")
w("| Sample | Expected children | Offer effect (SD) | Offer effect (SD), controls do not predict the outcome | Attendance effect (SD) | Offer effect, binary outcome (pp) |")
w("|---|---|---|---|---|---|")
for (i in seq_len(nrow(rows))) with(rows[i, ], w("| ", sample, " | ", f(expected_children, 0), " | ", f(mde_offer_sd, 3),
                                              " | ", f(mde_offer_sd_wide, 3), " | ", f(mde_attendance_sd, 3), " | ", f(mde_offer_pp_binary, 1), " |"))
close(con)

lc <- file(file.path(here, "logs", "00_power_from_committed_aggregates.txt"), "w")
writeLines(c(
  paste("run_time_utc:", format(Sys.time(), tz = "UTC", usetz = TRUE)),
  paste("git_head:", system("git rev-parse HEAD", intern = TRUE)),
  paste("git_branch:", system("git rev-parse --abbrev-ref HEAD", intern = TRUE)),
  paste("r_version:", R.version.string),
  paste("input_md5 f02_lottery_support_audit.csv:", unname(tools::md5sum(file.path(agg, "f02_lottery_support_audit.csv")))),
  paste("input_md5 offer_and_attendance_effects.csv:", unname(tools::md5sum(file.path(agg, "offer_and_attendance_effects.csv")))),
  paste("student_level_files_read: none"),
  paste("output:", out_path),
  paste("output_md5:", unname(tools::md5sum(out_path)))
), lc)
close(lc)
cat("Wrote", out_path, "\n")
