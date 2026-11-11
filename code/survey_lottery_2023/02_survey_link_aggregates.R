#!/usr/bin/env Rscript
# Survey-lottery project, step 2: linkage coverage, overlap with the lottery sample, and response by offer.
#
# It links the 2023 baseline survey and the public registration file of the 2023 process to the paper's
# lottery sample, by MINEDUC's masked student identifier.
#
# It computes no effect on any survey answer. It reports the stages of observation of the specification
# log (Section 2) and how many children answered each main item. It writes aggregates only, and no count
# below MIN_CELL. All data stay where they are; nothing row-level is written.
#
# Run from the repository root:
#   Rscript code/survey_lottery_2023/02_survey_link_aggregates.R

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
stopifnot(file.exists(file.path(here, "specification_log.md")))
dir.create(file.path(here, "output"), showWarnings = FALSE)
dir.create(file.path(here, "logs"), showWarnings = FALSE)

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
answered <- function(x) !is.na(x) & trimws(as.character(x)) != ""

# Lottery sample, as in the paper.
est <- readRDS(panel_path) %>% drop_na(all_of(controls)) %>% mutate(KEY = as_key(MRUN))

# Public registration file of the 2023 process (key MRUN, as the Mistakes code reads it).
registration <- data.table::fread(registration_path, sep = ";", select = "MRUN", showProgress = FALSE)
n_registration_rows <- nrow(registration)
registered <- unique(as_key(registration$MRUN))
rm(registration)

# Baseline survey: the filters of R/survey_2023/Cleaning_baseline.R, then one response per student.
items <- c(expected_math = "Q5_1", expected_reading = "Q5_3", expected_nem = "Q41_1", expected_ranking = "Q41_2",
           prob_apply = "Q60_1", prob_admitted = "Q61_1", top_true = "Q8_2", first_planned = "Q19_2",
           prob_first_planned = "Q63_2", cutoff_first_planned = "Q64_2")
group_items <- list(income = c("Q186_2", "Q74_2", "Q78_2"), graduate = c("Q47_2", "Q112_2", "Q119_2"))
survey <- read.csv(survey_path, sep = ";")
missing_columns <- setdiff(c("mrun", "Q17", "StartDate", "Progress", "Finished", items, unlist(group_items)),
                           names(survey))
survey <- survey %>%
  filter(Q17 == "Acepto") %>%
  mutate(START = mdy_hm(StartDate), KEY = as_key(mrun), PROGRESS = as_key(Progress)) %>%
  filter(START > mdy_hm("12/27/2022 10:00"))
n_responses <- nrow(survey)
n_without_key <- sum(is.na(survey$KEY))
survey <- survey %>%
  filter(!is.na(KEY)) %>%
  arrange(KEY, desc(PROGRESS), START) %>%
  distinct(KEY, .keep_all = TRUE)
n_students <- nrow(survey)

has <- function(col) if (col %in% names(survey)) answered(survey[[col]]) else rep(NA, nrow(survey))
any_of_cols <- function(cols) Reduce(`|`, lapply(cols, function(col) {v <- has(col); ifelse(is.na(v), FALSE, v)}))
flags <- data.frame(KEY = survey$KEY, STARTED = 1,
                    FINISHED = as.numeric(toupper(as.character(survey$Finished)) %in% c("TRUE", "1")))
for (k in names(items)) flags[[paste0("ANS_", k)]] <- as.numeric(has(items[[k]]))
for (k in names(group_items)) flags[[paste0("ANS_", k)]] <- as.numeric(any_of_cols(group_items[[k]]))
for (k in c("regular", "bea", "pace")) {
  flags[[paste0("MODULE_", k)]] <- if (k %in% names(survey)) as.numeric(as_key(survey[[k]]) %in% 1) else NA
}
if ("Q60_1" %in% names(survey) && "Q8_2" %in% names(survey)) {
  flags$REACHED_PROGRAMS <- as.numeric(as_key(survey$Q60_1) > 0 & answered(survey$Q8_2))
  flags$REACHED_PROGRAMS[is.na(flags$REACHED_PROGRAMS)] <- 0
}
rm(survey)

# Coverage of the key.
coverage <- data.frame(
  quantity = c("Rows of the registration file", "Students in the registration file",
               "Consenting responses after the start date", "Responses without a numeric key",
               "Students with a response", "Students with a response found in the registration file",
               "Students with a response found in the lottery sample",
               "Lottery children found in the registration file"),
  n = c(n_registration_rows, length(registered), n_responses, n_without_key, n_students,
        sum(flags$KEY %in% registered), sum(flags$KEY %in% est$KEY), sum(est$KEY %in% registered)))

# Stage indicators on the lottery sample; a child without a response has 0 at every survey stage.
est <- est %>%
  mutate(REGISTERED_2023 = as.numeric(KEY %in% registered)) %>%
  left_join(flags, by = "KEY") %>%
  mutate(across(any_of(setdiff(names(flags), "KEY")), ~ replace_na(.x, 0)))
stage_vars <- c("GRAD_OT", "REGISTERED_2023", setdiff(names(flags), "KEY"))

guard <- function(n) ifelse(n < MIN_CELL, NA_integer_, as.integer(n))
fmt <- function(x, d = 4) ifelse(is.na(x), "suppressed", formatC(x, format = "f", digits = d, big.mark = ","))
fmt_n <- function(x) ifelse(is.na(x), "suppressed", formatC(x, format = "d", big.mark = ","))

stage_rows <- lapply(sort(unique(est$YEAR)), function(y) {
  d <- filter(est, YEAR == y)
  lapply(stage_vars, function(v) {
    n1 <- sum(d[[v]] == 1 & d$OFFER == 1); n0 <- sum(d[[v]] == 1 & d$OFFER == 0)
    if (min(n1, n0) < MIN_CELL) {
      return(data.frame(YEAR = y, stage = v, children = nrow(d), yes_offer = NA, yes_no_offer = NA,
                        effect = NA, se = NA, effect_no_controls = NA, se_no_controls = NA))
    }
    m <- feols(as.formula(paste(v, "~ OFFER + .[controls] | CHANCE_GROUP")), d)
    m0 <- feols(as.formula(paste(v, "~ OFFER | CHANCE_GROUP")), d)
    data.frame(YEAR = y, stage = v, children = nrow(d), yes_offer = n1, yes_no_offer = n0,
               effect = coef(m)[["OFFER"]], se = se(m)[["OFFER"]],
               effect_no_controls = coef(m0)[["OFFER"]], se_no_controls = se(m0)[["OFFER"]])
  }) %>% bind_rows()
}) %>% bind_rows()

# Among children of the 2018 application year with a response: first stage, offer variation, balance.
resp <- filter(est, YEAR == 2018, STARTED == 1)
resp_rows <- NULL
if (min(sum(resp$OFFER == 1), sum(resp$OFFER == 0)) >= MIN_CELL) {
  fs <- feols(D_OD ~ OFFER + .[controls] | CHANCE_GROUP, resp)
  off <- feols(OFFER ~ .[controls] | CHANCE_GROUP, resp)
  resp_rows <- data.frame(quantity = c("First stage among children with a response", "Residual SD of offer"),
                          estimate = c(coef(fs)[["OFFER"]], sd(resid(off))), se = c(se(fs)[["OFFER"]], NA))
  for (v in controls) {
    b <- feols(as.formula(paste(v, "~ OFFER | CHANCE_GROUP")), resp)
    resp_rows <- rbind(resp_rows, data.frame(quantity = paste("Balance:", v), estimate = coef(b)[["OFFER"]],
                                             se = se(b)[["OFFER"]]))
  }
}

out_path <- file.path(here, "output", "survey_link_aggregates.md")
con <- file(out_path, "w")
w <- function(...) writeLines(paste0(...), con)
w("# 2023 baseline survey and the lottery sample: coverage, overlap, and response by offer")
w("")
w("Written by `code/survey_lottery_2023/02_survey_link_aggregates.R`. Counts below ", MIN_CELL, " are suppressed.")
if (length(missing_columns)) w("Expected columns absent from the export: ", paste(missing_columns, collapse = ", "), ".")
w("")
w("## 1. Coverage of the key")
w("")
w("| Quantity | Number |"); w("|---|---|")
for (i in seq_len(nrow(coverage))) w("| ", coverage$quantity[i], " | ", fmt_n(guard(coverage$n[i])), " |")
w("")
w("## 2. Stages of observation by application year")
w("")
w("| Application year | Stage | Children | Yes, with offer | Yes, without offer | Offer effect | SE | Offer effect, no controls | SE |")
w("|---|---|---|---|---|---|---|---|---|")
for (i in seq_len(nrow(stage_rows))) with(stage_rows[i, ], w(
  "| ", YEAR, " | ", stage, " | ", fmt_n(guard(children)), " | ", fmt_n(yes_offer), " | ", fmt_n(yes_no_offer), " | ",
  fmt(effect), " | ", fmt(se), " | ", fmt(effect_no_controls), " | ", fmt(se_no_controls), " |"))
w("")
w("## 3. Children of the 2018 application year with a response")
w("")
if (is.null(resp_rows)) w("Suppressed: fewer than ", MIN_CELL, " children in one offer group.") else {
  w("| Quantity | Estimate | SE |"); w("|---|---|---|")
  for (i in seq_len(nrow(resp_rows))) w("| ", resp_rows$quantity[i], " | ", fmt(resp_rows$estimate[i]), " | ",
                                        fmt(resp_rows$se[i]), " |")
}
close(con)

lc <- file(file.path(here, "logs", "02_survey_link_aggregates.txt"), "w")
writeLines(c(
  paste("run_time_utc:", format(Sys.time(), tz = "UTC", usetz = TRUE)),
  paste("git_head:", system("git rev-parse HEAD", intern = TRUE)),
  paste("r_version:", R.version.string),
  paste("fixest:", as.character(packageVersion("fixest"))),
  paste("panel_md5:", unname(tools::md5sum(panel_path))),
  paste("survey_sha256:", found[["survey"]]),
  paste("registration_sha256:", found[["registration"]]),
  paste("specification_log_md5:", unname(tools::md5sum(file.path(here, "specification_log.md")))),
  paste("output_md5:", unname(tools::md5sum(out_path)))
), lc)
close(lc)
cat("Wrote", out_path, "\n")
