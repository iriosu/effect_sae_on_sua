#!/usr/bin/env Rscript
# Survey-lottery project, step 1: aggregates of the paper's lottery sample by application year.
#
# Reads only the paper's mechanisms panel (the input of code/finalized_design_v1/mechanisms/mechanisms.Rmd).
# Opens no survey file and links no record to any other source.
# Writes aggregates only: counts, shares, coefficients, standard errors. No count below MIN_CELL is printed.
#
# Run from the repository root:
#   Rscript code/survey_lottery_2023/01_lottery_cohort_aggregates.R
# Output: code/survey_lottery_2023/output/lottery_cohort_aggregates.md
# Log:    code/survey_lottery_2023/logs/01_lottery_cohort_aggregates.txt

suppressPackageStartupMessages({
  library(fixest)
  library(dplyr)
  library(tidyr)
})

setFixest_vcov(all = "hetero")            # as the paper's notebooks
setFixest_estimation(fixef.rm = "none")   # keep chance groups that hold a single child
setFixest_notes(FALSE)

MIN_CELL <- 11L
controls <- c("GPA8_Z", "ES_MUJER", "PRIORITARIO", "ALTO", "ORIGIN_OD")

here <- "code/survey_lottery_2023"
stopifnot(file.exists(file.path(here, "specification_log.md")))   # the log precedes every estimate
dir.create(file.path(here, "output"), showWarnings = FALSE)
dir.create(file.path(here, "logs"), showWarnings = FALSE)

data_dir <- Sys.getenv("SAE_MECHANISMS_DATA",
                       file.path(path.expand("~"), "Dropbox", "Effect SAE on SUA", "data",
                                 "finalized_design_v1", "mechanisms"))
panel_path <- file.path(data_dir, "mechanisms_panel.rds")
manifest <- read.csv("code/finalized_design_v1/mechanisms/data_manifest.csv")
expected_md5 <- manifest$md5[manifest$file == "mechanisms_panel.rds"]
found_md5 <- unname(tools::md5sum(panel_path))
stopifnot(identical(found_md5, expected_md5))

panel <- readRDS(panel_path)
stopifnot(nrow(panel) == 186440L, !anyDuplicated(panel[c("MRUN", "YEAR")]))
est <- drop_na(panel, all_of(controls))

# Stage indicators that the paper's data hold (specification log, Section 2, stages 1 to 3).
est <- est %>%
  mutate(HAS_SCORE_OT = as.numeric(!is.na(SCORE_LM_OT)),
         APPLIED_OT   = as.numeric(!is.na(LIST_PROGRAMS_OT)))
stages <- c(GRAD_OT = "Graduated on time",
            HAS_SCORE_OT = "Has a test score on time",
            APPLIED_OT = "Applied on time (a list on file)")

guard <- function(n) ifelse(n < MIN_CELL, NA_integer_, as.integer(n))
fmt <- function(x, d = 2) ifelse(is.na(x), "suppressed", formatC(x, format = "f", digits = d, big.mark = ","))
fmt_n <- function(x) ifelse(is.na(x), "suppressed", formatC(x, format = "d", big.mark = ","))

# 1. Counts by application year.
counts <- est %>%
  group_by(YEAR) %>%
  summarise(children = n(), offered = sum(OFFER == 1), not_offered = sum(OFFER == 0),
            chance_groups = n_distinct(CHANCE_GROUP),
            groups_both = {g <- tapply(OFFER, CHANCE_GROUP, function(v) any(v == 1) && any(v == 0)); sum(g)},
            .groups = "drop") %>%
  mutate(scheduled_process = YEAR + 5L)

# 2. By application year: first stage, the residual standard deviation of OFFER, and stage effects.
by_year <- lapply(sort(unique(est$YEAR)), function(y) {
  d <- filter(est, YEAR == y)
  fs <- feols(D_OD ~ OFFER + .[controls] | CHANCE_GROUP, d)
  off <- feols(OFFER ~ .[controls] | CHANCE_GROUP, d)
  out <- data.frame(YEAR = y, outcome = "First stage (attendance at an over-demanded school)",
                    mean_no_offer = mean(d$D_OD[d$OFFER == 0]), estimate = coef(fs)[["OFFER"]],
                    se = se(fs)[["OFFER"]], n = nobs(fs), resid_sd_offer = sd(resid(off)))
  for (v in names(stages)) {
    m <- feols(as.formula(paste(v, "~ OFFER + .[controls] | CHANCE_GROUP")), d)
    out <- rbind(out, data.frame(YEAR = y, outcome = stages[[v]],
                                 mean_no_offer = mean(d[[v]][d$OFFER == 0]), estimate = coef(m)[["OFFER"]],
                                 se = se(m)[["OFFER"]], n = nobs(m), resid_sd_offer = sd(resid(off))))
  }
  out
}) %>% bind_rows()

# 3. Standard error of an offer effect on an outcome in SD units, among n responding children, if the
#    offer varied among them as in the 2018 cohort and the controls explained none of the outcome.
#    Minimum detectable effect at 80 percent power and a 5 percent two-sided test: 2.80 standard errors.
sd_offer_2018 <- by_year$resid_sd_offer[by_year$YEAR == 2018][1]
fs_2018 <- by_year$estimate[by_year$YEAR == 2018 & grepl("^First stage", by_year$outcome)]
grid <- data.frame(n = c(250, 500, 750, 1000, 1500, 2000, 3000, 4000)) %>%
  mutate(se_sd = 1 / (sqrt(n) * sd_offer_2018),
         mde_offer_sd = 2.80 * se_sd,
         mde_attendance_sd = mde_offer_sd / fs_2018)

# Write the output.
out_path <- file.path(here, "output", "lottery_cohort_aggregates.md")
con <- file(out_path, "w")
w <- function(...) writeLines(paste0(...), con)
w("# Lottery sample by application year: aggregates")
w("")
w("Written by `code/survey_lottery_2023/01_lottery_cohort_aggregates.R`. Source: `mechanisms_panel.rds`, MD5 `",
  found_md5, "`. Children with every control: ", fmt_n(nrow(est)), " of ", fmt_n(nrow(panel)), ".")
w("No survey file was read. Counts below ", MIN_CELL, " are suppressed.")
w("")
w("## 1. Counts")
w("")
w("| Application year | Scheduled college process | Children | With offer | Without offer | Chance groups | Chance groups with both |")
w("|---|---|---|---|---|---|---|")
for (i in seq_len(nrow(counts))) with(counts[i, ], w(
  "| ", YEAR, " | ", scheduled_process, " | ", fmt_n(guard(children)), " | ", fmt_n(guard(offered)), " | ",
  fmt_n(guard(not_offered)), " | ", chance_groups, " | ", groups_both, " |"))
w("")
w("## 2. First stage and offer effects on the stages of observation, by application year")
w("")
w("Each row is one regression on the children of one application year: outcome on `OFFER`, the paper's controls, ",
  "and chance-group effects, with robust standard errors. Units are shares (0 to 1).")
w("")
w("| Application year | Outcome | Mean without offer | Offer effect | SE | Children | Residual SD of offer |")
w("|---|---|---|---|---|---|---|")
for (i in seq_len(nrow(by_year))) with(by_year[i, ], w(
  "| ", YEAR, " | ", outcome, " | ", fmt(mean_no_offer, 4), " | ", fmt(estimate, 4), " | ", fmt(se, 4), " | ",
  fmt_n(guard(n)), " | ", fmt(resid_sd_offer, 4), " |"))
w("")
w("## 3. Minimum detectable effects by number of responding children (application year 2018)")
w("")
w("The standard error is 1 / (sqrt(n) x residual SD of offer), for an outcome with unit standard deviation. ",
  "The residual SD of offer is that of the 2018 cohort (", fmt(sd_offer_2018, 4), "). ",
  "The minimum detectable effect is 2.80 standard errors. ",
  "The attendance column divides by the 2018 first stage (", fmt(fs_2018, 4), "). ",
  "Both columns assume that respondents resemble the cohort in offer variation and first stage. ",
  "Neither assumption has been tested.")
w("")
w("| Responding children | SE (SD units) | Minimum detectable offer effect (SD) | Minimum detectable attendance effect (SD) |")
w("|---|---|---|---|")
for (i in seq_len(nrow(grid))) with(grid[i, ], w(
  "| ", fmt_n(as.integer(n)), " | ", fmt(se_sd, 3), " | ", fmt(mde_offer_sd, 3), " | ", fmt(mde_attendance_sd, 3), " |"))
close(con)

# Log: versions, source, and checks. No row-level value is written.
log_path <- file.path(here, "logs", "01_lottery_cohort_aggregates.txt")
lc <- file(log_path, "w")
writeLines(c(
  paste("run_time_utc:", format(Sys.time(), tz = "UTC", usetz = TRUE)),
  paste("git_head:", system("git rev-parse HEAD", intern = TRUE)),
  paste("git_branch:", system("git rev-parse --abbrev-ref HEAD", intern = TRUE)),
  paste("r_version:", R.version.string),
  paste("fixest:", as.character(packageVersion("fixest"))),
  paste("dplyr:", as.character(packageVersion("dplyr"))),
  paste("source:", sub(path.expand("~"), "~", panel_path, fixed = TRUE)),
  paste("source_bytes:", file.size(panel_path)),
  paste("source_md5:", found_md5, "(matches code/finalized_design_v1/mechanisms/data_manifest.csv)"),
  paste("rows_read:", nrow(panel)),
  paste("rows_with_every_control:", nrow(est)),
  paste("specification_log_md5:", unname(tools::md5sum(file.path(here, "specification_log.md")))),
  paste("outcome_inventory_md5:", unname(tools::md5sum(file.path(here, "outcome_inventory.md")))),
  paste("check_pooled_first_stage:",
        formatC(coef(feols(D_OD ~ OFFER + .[controls] + i(YEAR, ref = 2016) | CHANCE_GROUP, est))[["OFFER"]],
                format = "f", digits = 4), "(the paper reports 0.6104)"),
  paste("smallest_printed_count:", min(c(counts$children, counts$offered, counts$not_offered))),
  paste("output:", out_path),
  paste("output_md5:", unname(tools::md5sum(out_path)))
), lc)
close(lc)
cat("Wrote", out_path, "and", log_path, "\n")
