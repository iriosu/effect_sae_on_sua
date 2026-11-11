#!/usr/bin/env Rscript
# Survey-lottery project, step 4: overlap of the 2023 endline survey with the lottery sample, and
# response by offer. No effect on any survey answer is computed.
#
# Reads the paper's mechanisms panel and the two endline exports of the Mistakes package, with the
# filters of R/survey_2023/Cleaning_endline.R (consent, start times). Writes aggregates only.
#
# Run from the repository root:
#   Rscript code/survey_lottery_2023/04_endline_overlap.R

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
controls <- c("GPA8_Z", "ES_MUJER", "PRIORITARIO", "ALTO", "ORIGIN_OD")
here <- "code/survey_lottery_2023"
home <- path.expand("~")
panel_path <- file.path(Sys.getenv("SAE_MECHANISMS_DATA",
  file.path(home, "Dropbox", "Effect SAE on SUA", "data", "finalized_design_v1", "mechanisms")),
  "mechanisms_panel.rds")
package <- Sys.getenv("MISTAKES_PACKAGE", file.path(home, "Dropbox", "mistakes_replication", "replication_package"))
exports <- file.path(package, "Data", "qualtrics_exports")
end_path <- file.path(exports, "Endline survey mistakes 2023_January 17, 2023_17.05.csv")
fix_path <- file.path(exports, "Endline survey mistakes 2023 - Fixings_January 17, 2023_17.10.csv")
base_path <- file.path(exports, "Baseline survey mistakes 2023_January 3, 2023_09.csv")
manifest <- read.csv("code/finalized_design_v1/mechanisms/data_manifest.csv")
stopifnot(identical(unname(tools::md5sum(panel_path)), manifest$md5[manifest$file == "mechanisms_panel.rds"]))

as_key <- function(x) suppressWarnings(as.numeric(as.character(x)))
finished <- function(x) toupper(as.character(x)) %in% c("TRUE", "1")

load_endline <- function(path, start) {
  read.csv(path) %>%
    filter(QID17 == "Acepto") %>%
    mutate(START = ymd_hms(StartDate), KEY = as_key(mrun), FIN = finished(Finished)) %>%
    filter(START > ymd_hms(start), !is.na(KEY)) %>%
    group_by(KEY) %>% summarise(FIN = any(FIN), .groups = "drop")
}
endline <- bind_rows(load_endline(end_path, "2023-01-13 12:00:00"), load_endline(fix_path, "2023-01-16 11:52:00")) %>%
  group_by(KEY) %>% summarise(FINISHED_ENDLINE = as.numeric(any(FIN)), .groups = "drop") %>%
  mutate(STARTED_ENDLINE = 1)
baseline_keys <- read.csv(base_path, sep = ";") %>%
  filter(Q17 == "Acepto") %>%
  mutate(START = mdy_hm(StartDate), KEY = as_key(mrun)) %>%
  filter(START > mdy_hm("12/27/2022 10:00"), !is.na(KEY)) %>% pull(KEY) %>% unique()

est <- readRDS(panel_path) %>% drop_na(all_of(controls)) %>%
  mutate(KEY = as_key(MRUN), APPLIED_OT = as.numeric(!is.na(LIST_PROGRAMS_OT))) %>%
  left_join(endline, by = "KEY") %>%
  mutate(across(c(STARTED_ENDLINE, FINISHED_ENDLINE), ~ replace_na(.x, 0)),
         BOTH_SURVEYS = as.numeric(STARTED_ENDLINE == 1 & KEY %in% baseline_keys))

stage_vars <- c("APPLIED_OT", "STARTED_ENDLINE", "FINISHED_ENDLINE", "BOTH_SURVEYS")
fmt <- function(x, d = 4) ifelse(is.na(x), "suppressed", formatC(x, format = "f", digits = d, big.mark = ","))
rows <- lapply(c(2017, 2018), function(y) {
  d <- filter(est, YEAR == y)
  lapply(stage_vars, function(v) {
    n1 <- sum(d[[v]] == 1 & d$OFFER == 1); n0 <- sum(d[[v]] == 1 & d$OFFER == 0)
    if (min(n1, n0) < MIN_CELL) return(data.frame(YEAR = y, stage = v, children = nrow(d), yes_offer = NA, yes_no_offer = NA, effect = NA, se = NA))
    m <- feols(as.formula(paste(v, "~ OFFER + .[controls] | CHANCE_GROUP")), d)
    data.frame(YEAR = y, stage = v, children = nrow(d), yes_offer = n1, yes_no_offer = n0,
               effect = coef(m)[["OFFER"]], se = se(m)[["OFFER"]])
  }) %>% bind_rows()
}) %>% bind_rows()

out_path <- file.path(here, "output", "endline_overlap.md")
con <- file(out_path, "w")
w <- function(...) writeLines(paste0(...), con)
w("# 2023 endline survey and the lottery sample: overlap and response by offer")
w("")
w("Written by `code/survey_lottery_2023/04_endline_overlap.R`. Counts below ", MIN_CELL, " are suppressed.")
w("Students with an endline response (either form): ", formatC(nrow(endline), format = "d", big.mark = ","),
  ". Found in the lottery sample: ", formatC(sum(endline$KEY %in% est$KEY), format = "d", big.mark = ","), ".")
w("")
w("| Application year | Stage | Children | Yes, with offer | Yes, without offer | Offer effect | SE |")
w("|---|---|---|---|---|---|---|")
for (i in seq_len(nrow(rows))) with(rows[i, ], w("| ", YEAR, " | ", stage, " | ", formatC(children, format = "d", big.mark = ","), " | ",
  ifelse(is.na(yes_offer), "suppressed", yes_offer), " | ", ifelse(is.na(yes_no_offer), "suppressed", yes_no_offer), " | ", fmt(effect), " | ", fmt(se), " |"))
close(con)
lc <- file(file.path(here, "logs", "04_endline_overlap.txt"), "w")
writeLines(c(
  paste("run_time_utc:", format(Sys.time(), tz = "UTC", usetz = TRUE)),
  paste("git_head:", system("git rev-parse HEAD", intern = TRUE)),
  paste("r_version:", R.version.string),
  paste("panel_md5:", unname(tools::md5sum(panel_path))),
  paste("endline_md5:", unname(tools::md5sum(end_path))),
  paste("endline_second_form_md5:", unname(tools::md5sum(fix_path))),
  paste("output_md5:", unname(tools::md5sum(out_path)))
), lc)
close(lc)
cat("Wrote", out_path, "\n")
