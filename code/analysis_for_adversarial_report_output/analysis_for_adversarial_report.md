---
title: "Analyses for the adversarial report"
subtitle: "F20 lottery diagnostics and F02.4 ninth-grade composition and population comparisons"
output:
  html_document:
    toc: true
    toc_depth: 2
    code_folding: hide
    self_contained: true
    keep_md: true
---

## Scope and reproduction

This notebook estimates the reduced-form effects of admission offers using the
finalized Section 3 data and specification documented in `../HANDOFF.md` and
`finalized_design_v1/section3/Section3_IV.Rmd`. It reestimates the corresponding
first stages and 2SLS coefficients on exactly the same outcome-specific samples.
The F02.4 extension uses the finalized Section 2 entrant panel to estimate
ninth-grade composition effects and compare entrants, applicants, and complier
profiles over the available regions and cohorts.
All analysis code is in this file. It does not edit or export files to the paper.

From the repository's `code/` directory, run:

```bash
Rscript -e 'rmarkdown::render("analysis_for_adversarial_report.Rmd", output_dir = "analysis_for_adversarial_report_output", envir = new.env())'
```

F02.4 requires `did` 2.1.2, as in the handoff. If an isolated library is needed,
install that version and its dependencies there, then set `R_LIBS_USER`
to that library before starting R (so dependencies are loaded consistently).
`SAE_ADVERSARIAL_R_LIB` additionally prepends an existing library during setup.
The preparation run used
`/private/tmp/sae-adversarial-r-library`; this temporary directory is not an input
distributed with the repository. No packages are installed by the notebook.

The notebook first looks for `SAE_ADVERSARIAL_PANEL`, if set, then the shared
Dropbox panel, then a downloaded copy at
`analysis_for_adversarial_report_output/input/section3_panel.rds`.
It verifies the selected file against the tracked data manifest before using it.
The local Dropbox placeholder was empty when this analysis was prepared; the
cached copy was downloaded from the connected Dropbox account. No raw records
are printed or exported by this notebook. Output CSVs contain aggregate results.


``` r
knitr::opts_chunk$set(error = FALSE, warning = TRUE, message = FALSE,
                     echo = TRUE, cache = FALSE)
extra_library <- Sys.getenv("SAE_ADVERSARIAL_R_LIB")
if (nzchar(extra_library)) .libPaths(c(path.expand(extra_library), .libPaths()))
required <- c("fixest", "knitr")
missing_packages <- required[!vapply(required, requireNamespace, logical(1),
                                    quietly = TRUE)]
if (length(missing_packages)) stop("Missing packages: ", paste(missing_packages, collapse = ", "))
if (packageVersion("fixest") < "0.13.0") stop("fixest >= 0.13.0 is required.")
library(fixest)
setFixest_vcov(all = "hetero")
setFixest_estimation(fixef.rm = "none")
setFixest_nthreads(1)

# Knitr evaluates chunks relative to the Rmd, which resides in code/.
stopifnot(file.exists("../HANDOFF.md"),
          file.exists("finalized_design_v1/section3/Section3_IV.Rmd"))
output_dir <- "analysis_for_adversarial_report_output"
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
task_home <- if (nzchar(Sys.getenv("USERPROFILE"))) Sys.getenv("USERPROFILE") else path.expand("~")
manifest <- read.csv("finalized_design_v1/data_manifest.csv", stringsAsFactors = FALSE)
manifest_row <- manifest[endsWith(manifest$path_in_dropbox, "/section3/section3_panel.rds"), ]
stopifnot(nrow(manifest_row) == 1L)
override <- Sys.getenv("SAE_ADVERSARIAL_PANEL")
candidates <- if (nzchar(override)) path.expand(override) else c(
  file.path(task_home, "Dropbox", manifest_row$path_in_dropbox),
  file.path(output_dir, "input", "section3_panel.rds")
)
available <- candidates[file.exists(candidates) & !is.na(file.info(candidates)$size) &
                          file.info(candidates)$size > 0]
if (!length(available)) stop("No readable panel. Download the shared panel or set SAE_ADVERSARIAL_PANEL.")
panel_file <- normalizePath(available[1], mustWork = TRUE)
actual_md5 <- unname(tools::md5sum(panel_file))
stopifnot(identical(actual_md5, manifest_row$md5),
          file.info(panel_file)$size == manifest_row$bytes)
panel <- readRDS(panel_file)
source_file <- "finalized_design_v1/section3/Section3_IV.Rmd"
provenance <- data.frame(
  item = c("Panel", "Panel MD5", "Panel bytes", "Reference notebook MD5", "Run time"),
  value = c(panel_file, actual_md5, file.info(panel_file)$size,
            unname(tools::md5sum(source_file)), format(Sys.time(), tz = "America/Indiana/Indianapolis", usetz = TRUE))
)
write.csv(provenance, file.path(output_dir, "provenance.csv"), row.names = FALSE)
knitr::kable(provenance)
```



|item                   |value                                                                                                               |
|:----------------------|:-------------------------------------------------------------------------------------------------------------------|
|Panel                  |/Users/iriosu/Dropbox/Effect SAE on SUA - repo/code/analysis_for_adversarial_report_output/input/section3_panel.rds |
|Panel MD5              |3390a0487374564a5350a98be299f1a2                                                                                    |
|Panel bytes            |6753877                                                                                                             |
|Reference notebook MD5 |b86f278c82a9a4defefef43694b1b4a4                                                                                    |
|Run time               |2026-10-18 06:06:19 EDT                                                                                             |

## Sample, specification, and inference

The sample, outcome definitions, and controls are unchanged from the finalized
design. We retain `LOTTERY_SAMPLE` and require observed eighth-grade GPA, gender,
low-income status, top-20-percent status, and origin-school classification.
Admission-score regressions additionally require that particular score.

For each outcome, the reduced form regresses the outcome on `OFFER`, the five
controls, application-year indicators, and hundredth propensity-score-group fixed
effects. The first stage replaces the outcome with `D_OD`. The 2SLS regression
instruments `D_OD` with `OFFER`, holding the same controls and fixed effects fixed.

We preserve the handoff's inference conventions: heteroskedasticity-robust OLS
standard errors with the N/(N-K) correction and t(N-K) inference; 2SLS robust
standard errors without that correction and normal inference. All intervals are
two-sided 95% intervals. They are pointwise, without multiplicity adjustment.
Offer-effect standard errors are estimated directly, not obtained by multiplying
the IV standard error by the first-stage coefficient.


``` r
controls <- c("GPA8_Z", "ES_MUJER", "PRIORITARIO", "ALTO", "ORIGIN_OD")
college_labels <- c(
  GRAD = "Regular-secondary graduation",
  APPLIED = "Applied through SUA",
  ASSIGNED = "Assigned a seat through SUA",
  INSUA = "First enrollment through SUA",
  OUTSIDE = "First enrollment outside SUA"
)
score_labels <- c(LM_Z_MAX = "Reading-mathematics mean",
                  NEM_Z_LATEST = "NEM score", RANK_Z_LATEST = "Ranking score")
binary_vars <- c(paste0(names(college_labels), "_OT"), paste0(names(college_labels), "_EVER"))
all_vars <- c(binary_vars, names(score_labels))
needed <- c("MRUN", "LOTTERY_SAMPLE", "YEAR", "CHANCE_GROUP", "OFFER", "D_OD", controls, all_vars)
stopifnot(all(needed %in% names(panel)), !anyNA(panel$LOTTERY_SAMPLE),
          !anyDuplicated(panel$MRUN))
lottery <- panel[panel$LOTTERY_SAMPLE, , drop = FALSE]
sample_main <- lottery[complete.cases(lottery[, controls]), , drop = FALSE]
stopifnot(all(sample_main$OFFER %in% 0:1), all(sample_main$D_OD %in% 0:1),
          !anyNA(sample_main[, c("OFFER", "D_OD", "CHANCE_GROUP", "YEAR", binary_vars)]),
          all(unlist(sample_main[, binary_vars]) %in% 0:1))
sample_counts <- data.frame(
  Sample = c("Finalized panel", "Lottery sample", "Complete controls", "With an offer (complete controls)",
             "Without an offer (complete controls)"),
  N = c(nrow(panel), nrow(lottery), nrow(sample_main),
        sum(sample_main$OFFER == 1), sum(sample_main$OFFER == 0))
)
write.csv(sample_counts, file.path(output_dir, "sample_counts.csv"), row.names = FALSE)
knitr::kable(sample_counts, format.args = list(big.mark = ","))
```



|Sample                               |       N|
|:------------------------------------|-------:|
|Finalized panel                      | 304,547|
|Lottery sample                       | 176,321|
|Complete controls                    | 175,869|
|With an offer (complete controls)    |  63,073|
|Without an offer (complete controls) | 112,796|

On-time graduation means completion by the scheduled graduation year. On-time
college outcomes use the admission process five years after application. The
longer window uses school records through 2025 and college records through 2026;
follow-up differs across application cohorts. Graduation excludes adult-education
completion. Enrollment outcomes are mutually exclusive first-observed routes,
with same-year ties assigned to SUA; they are not independent measures of ever
attending each sector.


``` r
rhs <- paste(c(controls, "i(YEAR, ref = 2016)"), collapse = " + ")
ols_formula <- function(y) as.formula(paste(y, "~ OFFER +", rhs, "| CHANCE_GROUP"))
iv_formula <- function(y) as.formula(paste(y, "~", rhs, "| CHANCE_GROUP | D_OD ~ OFFER"))
ols_ssc <- ssc(K.adj = TRUE)
iv_ssc <- ssc(K.adj = FALSE)

extract_effect <- function(model, term, iv = FALSE) {
  estimate <- unname(coef(model)[term])
  std_error <- unname(se(model)[term])
  df <- if (iv) Inf else degrees_freedom(model, type = "t")
  statistic <- estimate / std_error
  p <- if (iv) 2 * pnorm(-abs(statistic)) else 2 * pt(-abs(statistic), df)
  critical <- if (iv) qnorm(.975) else qt(.975, df)
  c(estimate = estimate, se = std_error, p = p,
    lower = estimate - critical * std_error, upper = estimate + critical * std_error,
    df = df, n = nobs(model))
}

fits <- setNames(vector("list", length(all_vars)), all_vars)
result_list <- check_list <- vector("list", length(all_vars))
for (j in seq_along(all_vars)) {
  y <- all_vars[j]
  d <- sample_main[!is.na(sample_main[[y]]), , drop = FALSE]
  fs <- feols(ols_formula("D_OD"), d, vcov = "hetero", ssc = ols_ssc, fixef.rm = "none")
  rf <- feols(ols_formula(y), d, vcov = "hetero", ssc = ols_ssc, fixef.rm = "none")
  iv <- feols(iv_formula(y), d, vcov = "hetero", ssc = iv_ssc, fixef.rm = "none")
  stopifnot(nobs(fs) == nrow(d), nobs(rf) == nrow(d), nobs(iv) == nrow(d))
  fs_e <- extract_effect(fs, "OFFER")
  rf_e <- extract_effect(rf, "OFFER")
  iv_e <- extract_effect(iv, "fit_D_OD", iv = TRUE)
  # Independent FWL calculation checks both point estimates and OLS HC1 SEs.
  z_model <- feols(as.formula(paste("OFFER ~", rhs, "| CHANCE_GROUP")), d,
                   fixef.rm = "none")
  z_resid <- resid(z_model)
  fwl_rf <- sum(z_resid * d[[y]]) / sum(z_resid^2)
  fwl_fs <- sum(z_resid * d$D_OD) / sum(z_resid^2)
  fwl_hc1 <- sqrt(sum(z_resid^2 * resid(rf)^2) / sum(z_resid^2)^2 *
                   nrow(d) / (nrow(d) - rf$nparams))
  check_list[[j]] <- data.frame(
    variable = y, ratio_error = unname(rf_e["estimate"] / fs_e["estimate"] - iv_e["estimate"]),
    rf_fwl_error = unname(rf_e["estimate"] - fwl_rf),
    fs_fwl_error = unname(fs_e["estimate"] - fwl_fs),
    rf_se_hc1_error = unname(rf_e["se"] - fwl_hc1)
  )
  is_score <- y %in% names(score_labels)
  base_name <- sub("_(OT|EVER)$", "", y)
  result_list[[j]] <- data.frame(
    variable = y,
    outcome = if (is_score) unname(score_labels[y]) else unname(college_labels[base_name]),
    horizon = if (is_score) "Observed score" else if (endsWith(y, "_OT")) "On time" else "Through latest records",
    unit = if (is_score) "SD" else "pp", scale = if (is_score) 1 else 100,
    mean_without_offer = mean(d[[y]][d$OFFER == 0]),
    n_without_offer = sum(d$OFFER == 0), n_with_offer = sum(d$OFFER == 1),
    as.list(setNames(rf_e, paste0("rf_", names(rf_e)))),
    as.list(setNames(fs_e, paste0("fs_", names(fs_e)))),
    as.list(setNames(iv_e, paste0("iv_", names(iv_e))))
  )
  fits[[y]] <- list(first_stage = fs, reduced_form = rf, iv = iv)
}
results <- do.call(rbind, result_list)
checks <- do.call(rbind, check_list)
stopifnot(all(abs(as.matrix(checks[, -1])) < 1e-7))
write.csv(results, file.path(output_dir, "offer_and_attendance_effects.csv"), row.names = FALSE)
write.csv(checks, file.path(output_dir, "estimator_identity_checks.csv"), row.names = FALSE)
```

## Offer effects on graduation and college outcomes

Entries below are percentage points. The comparison uses
175,869 applicants with complete controls.
An offer increases entry-year attendance at an over-demanded school by
62.57 percentage points
(SE 0.25).


``` r
fmt <- function(x, digits = 2) sprintf(paste0("%.", digits, "f"), x)
fmt_p <- function(x) ifelse(x < .001, "<0.001", sprintf("%.3f", x))
display_table <- function(r, digits = 2) {
  data.frame(
    Outcome = r$outcome,
    `No-offer mean` = fmt(r$scale * r$mean_without_offer, digits),
    `Offer effect` = fmt(r$scale * r$rf_estimate, digits),
    `Robust SE` = fmt(r$scale * r$rf_se, digits),
    `95% CI` = paste0("[", fmt(r$scale * r$rf_lower, digits), ", ", fmt(r$scale * r$rf_upper, digits), "]"),
    `p-value` = fmt_p(r$rf_p),
    `Attendance effect (2SLS)` = fmt(r$scale * r$iv_estimate, digits),
    check.names = FALSE
  )
}
for (h in c("On time", "Through latest records")) {
  cat("\n### ", h, "\n\n", sep = "")
  print(knitr::kable(display_table(results[results$horizon == h, ]), align = c("l", rep("r", 6))))
  cat("\n\n")
}
```


### On time



|Outcome                      | No-offer mean| Offer effect| Robust SE|         95% CI| p-value| Attendance effect (2SLS)|
|:----------------------------|-------------:|------------:|---------:|--------------:|-------:|------------------------:|
|Regular-secondary graduation |         81.08|        -1.95|      0.23| [-2.41, -1.50]|  <0.001|                    -3.12|
|Applied through SUA          |         39.65|        -0.86|      0.28| [-1.41, -0.32]|   0.002|                    -1.38|
|Assigned a seat through SUA  |         30.10|        -1.40|      0.26| [-1.90, -0.89]|  <0.001|                    -2.23|
|First enrollment through SUA |         25.80|        -1.47|      0.25| [-1.97, -0.98]|  <0.001|                    -2.36|
|First enrollment outside SUA |         21.19|        -0.34|      0.25|  [-0.83, 0.15]|   0.178|                    -0.54|



### Through latest records



|Outcome                      | No-offer mean| Offer effect| Robust SE|         95% CI| p-value| Attendance effect (2SLS)|
|:----------------------------|-------------:|------------:|---------:|--------------:|-------:|------------------------:|
|Regular-secondary graduation |         85.53|        -0.87|      0.21| [-1.28, -0.46]|  <0.001|                    -1.39|
|Applied through SUA          |         46.76|        -0.32|      0.28|  [-0.87, 0.23]|   0.256|                    -0.51|
|Assigned a seat through SUA  |         38.35|        -0.65|      0.27| [-1.18, -0.11]|   0.017|                    -1.04|
|First enrollment through SUA |         35.81|        -0.84|      0.27| [-1.36, -0.31]|   0.002|                    -1.33|
|First enrollment outside SUA |         32.12|         0.27|      0.28|  [-0.29, 0.82]|   0.349|                     0.43|

The full-precision CSV retains confidence intervals, standard errors and p-values
for all three regressions, sample counts, and unscaled coefficients. Multiply
binary-outcome coefficients by 100 to obtain percentage points; the display tables
perform that conversion. For example, the on-time SUA enrollment estimate is
-1.474
percentage points per offer, compared with
-2.355
percentage points per offer-induced attendance change under the IV assumptions.

Offers reduce on-time regular-secondary graduation, application, assignment and
enrollment through SUA. Through the latest available records, the negative
graduation, assignment and SUA enrollment estimates remain statistically
significant at 5%; the application estimate does not. The outside-SUA enrollment
estimates are not statistically significant at either horizon. Their confidence
intervals do not rule out some substitution toward outside-SUA institutions.
The smaller estimates in the longer window are consistent with partial catch-up,
but this notebook does not test differences between the two horizons, and the
longer window does not measure lifetime attainment.

## Admission scores among students with observed scores

These regressions use each score's original observed-score sample. The first
stage is reestimated on that same sample, rather than borrowed from the main
binary-outcome sample. Score availability can itself respond to the offer, so
these conditional estimates do not have the same unconditional causal
interpretation as the complete-sample binary-outcome reduced forms.


``` r
score_results <- results[results$unit == "SD", ]
knitr::kable(display_table(score_results, digits = 3))
```



|Outcome                  |No-offer mean |Offer effect |Robust SE |95% CI           |p-value |Attendance effect (2SLS) |
|:------------------------|:-------------|:------------|:---------|:----------------|:-------|:------------------------|
|Reading-mathematics mean |-0.272        |0.020        |0.006     |[0.009, 0.031]   |<0.001  |0.033                    |
|NEM score                |-0.099        |-0.112       |0.005     |[-0.123, -0.101] |<0.001  |-0.180                   |
|Ranking score            |-0.075        |-0.141       |0.006     |[-0.152, -0.130] |<0.001  |-0.227                   |

``` r
knitr::kable(data.frame(
  Outcome = score_results$outcome,
  N = score_results$rf_n,
  `First stage (pp)` = 100 * score_results$fs_estimate,
  `First-stage SE (pp)` = 100 * score_results$fs_se,
  check.names = FALSE
), digits = 3)
```



|Outcome                  |      N| First stage (pp)| First-stage SE (pp)|
|:------------------------|------:|----------------:|-------------------:|
|Reading-mathematics mean | 117668|           61.477|               0.300|
|NEM score                | 137480|           62.316|               0.277|
|Ranking score            | 137480|           62.316|               0.277|

## Verification against the paper's existing tables

The following optional check reads, but never writes, the paper's existing table
files. It compares every reproduced 2SLS coefficient, SE, non-offered mean, and
sample size with the published precision of those files. Set `SAE_PAPER_ROOT` if
the manuscript is stored elsewhere. These reference values are validation targets
only; they are never used to construct an estimate or standard error.


``` r
paper_root <- Sys.getenv("SAE_PAPER_ROOT", unset = file.path(
  task_home, "Projects", "Effect of Centralized School Choice on College Admissions Outcomes"))
college_table <- file.path(paper_root, "Initial submission/tables/results/lottery_college.tex")
score_table <- file.path(paper_root, "Initial submission/tables/results/lottery_scores.tex")
reference_checks <- list()
add_check <- function(name, actual, expected, digits) {
  reference_checks[[length(reference_checks) + 1L]] <<- data.frame(
    check = name, actual = actual, reference = expected, digits = digits,
    matches = abs(round(actual, digits) - expected) < 1e-9)
}
cells_numeric <- function(line) {
  cells <- strsplit(line, "&", fixed = TRUE)[[1]][-1]
  vapply(cells, function(cell) {
    cell <- gsub(",", "", cell, fixed = TRUE)
    matched <- regmatches(cell, regexpr("-?[0-9]+(?:\\.[0-9]+)?", cell, perl = TRUE))
    if (!length(matched)) NA_real_ else as.numeric(matched)
  }, numeric(1))
}
if (file.exists(college_table) && file.exists(score_table)) {
  lines <- readLines(college_table)
  ref_labels <- c("Graduated from high school", "Applied to a college program", "Assigned a college seat",
                  "Enrolled (In SUA)", "Enrolled (Outside SUA)")
  for (k in seq_along(ref_labels)) {
    idx <- which(startsWith(trimws(lines), paste0(ref_labels[k], " &")))
    stopifnot(length(idx) == 1L)
    vals <- cells_numeric(lines[idx])
    ses <- cells_numeric(lines[idx + 1L])
    for (h in seq_along(c("OT", "EVER"))) {
      v <- paste0(names(college_labels)[k], "_", c("OT", "EVER")[h])
      r <- results[results$variable == v, ]
      add_check(paste(v, "IV"), 100 * r$iv_estimate, vals[2 * h], 2)
      add_check(paste(v, "IV SE"), 100 * r$iv_se, ses[2 * h], 2)
      add_check(paste(v, "No-offer mean"), 100 * r$mean_without_offer, vals[2 * h - 1], 2)
    }
  }
  n_line <- lines[grepl("$N$ &", lines, fixed = TRUE)]
  n_values <- cells_numeric(n_line)
  add_check("Main N", nrow(sample_main), n_values[2], 0)
  add_check("Main no-offer N", sum(sample_main$OFFER == 0), n_values[1], 0)
  sl <- readLines(score_table)
  idx <- which(startsWith(trimws(sl), "Effect of attendance &"))
  stopifnot(length(idx) == 1L)
  val <- cells_numeric(sl[idx]); serr <- cells_numeric(sl[idx + 1L])
  means <- cells_numeric(sl[startsWith(trimws(sl), "Mean (without an offer) &")])
  ns <- cells_numeric(sl[startsWith(trimws(sl), "Observations &")])
  for (k in seq_along(score_labels)) {
    r <- score_results[k, ]
    add_check(paste(r$variable, "IV"), r$iv_estimate, val[k], 3)
    add_check(paste(r$variable, "IV SE"), r$iv_se, serr[k], 3)
    add_check(paste(r$variable, "No-offer mean"), r$mean_without_offer, means[k], 3)
    add_check(paste(r$variable, "N"), r$iv_n, ns[k], 0)
  }
  reference_checks <- do.call(rbind, reference_checks)
  write.csv(reference_checks, file.path(output_dir, "paper_reproduction_checks.csv"), row.names = FALSE)
  knitr::kable(reference_checks, digits = 6)
  stopifnot(all(reference_checks$matches))
} else {
  cat("Paper table comparison not run: set SAE_PAPER_ROOT to an available manuscript checkout.\n")
}
knitr::kable(checks, digits = 12,
             caption = "Numerical differences in the ratio, FWL point estimates, and OLS HC1 SE check")
```



Table: Numerical differences in the ratio, FWL point estimates, and OLS HC1 SE check

|variable      | ratio_error| rf_fwl_error| fs_fwl_error| rf_se_hc1_error|
|:-------------|-----------:|------------:|------------:|---------------:|
|GRAD_OT       |           0|            0|            0|               0|
|APPLIED_OT    |           0|            0|            0|               0|
|ASSIGNED_OT   |           0|            0|            0|               0|
|INSUA_OT      |           0|            0|            0|               0|
|OUTSIDE_OT    |           0|            0|            0|               0|
|GRAD_EVER     |           0|            0|            0|               0|
|APPLIED_EVER  |           0|            0|            0|               0|
|ASSIGNED_EVER |           0|            0|            0|               0|
|INSUA_EVER    |           0|            0|            0|               0|
|OUTSIDE_EVER  |           0|            0|            0|               0|
|LM_Z_MAX      |           0|            0|            0|               0|
|NEM_Z_LATEST  |           0|            0|            0|               0|
|RANK_Z_LATEST |           0|            0|            0|               0|

## F20: school identity and predetermined choice-list restrictions

The reduced forms above do not establish exclusion for the pooled attendance
indicator. This section asks whether the findings persist where the submitted
choice list offers less scope for changes between over-demanded schools. The
restrictions use information recorded before the lottery; none selects students
according to their offer, realized attendance, or subsequent outcome.

The diagnostic samples, chosen before examining their outcome estimates, are (i) the main sample,
(ii) applicants listing exactly one distinct over-demanded school who did not
attend an over-demanded school in eighth grade, and (iii) the subset of (ii) listing
exactly two choices at two distinct schools, with the over-demanded school first.
The last group has one listed over-demanded school and one listed alternative
outside the set. All priorities and application years are retained. These are
exploratory sensitivity analyses of different populations, not estimates of the
same complier effect or tests that exclusion holds.
All reported intervals and significance levels are pointwise; the analysis does
not adjust for testing multiple outcomes and samples.

### Upstream records and reconciliation

`sae_admissions.rds` contains main-stage application lists (`c1`), recorded
assignments (`d1`), seats (`a1`), and applicant characteristics (`b1`). The processed
file was retrieved from `/Effect SAE on SUA/data/sae_admissions.rds`; its content
hash is pinned below. It contains actual records, not school-specific simulation
draws. We recover school identities from these records and use the finalized
catalogue to keep the original over-demanded set. All joins use application year
and student ID. Input files remain in the local, git-ignored cache.
The submitted list excludes options automatically added for continuity
(`agregada_por_continuidad == 1`). With that distinction, the number of ranked
choices, distinct over-demanded schools, first-choice status, offer indicator,
and attendance indicator must reproduce the finalized panel exactly.


``` r
if (!requireNamespace("data.table", quietly = TRUE)) stop("data.table is required for upstream records.")
data.table::setDTthreads(1)
upstream_paths <- file.path(output_dir, "input", c("sae_admissions.rds", "table_a3_panel.rds"))
if (!all(file.exists(upstream_paths))) stop("The upstream SAE records and finalized school catalogue are required in the input cache.")
expected_upstream_md5 <- c("5a55dd9eebe439b6173ac487c0398f0f", "572f4faba00263d249abc267b41146e2")
stopifnot(identical(unname(tools::md5sum(upstream_paths)), expected_upstream_md5))
upstream_provenance <- data.frame(
  file = basename(upstream_paths), bytes = file.info(upstream_paths)$size,
  md5 = unname(tools::md5sum(upstream_paths)),
  dropbox_path = c("/Effect SAE on SUA/data/sae_admissions.rds",
                   "/Effect SAE on SUA/data/finalized_design_v1/section3/table_a3_panel.rds")
)
write.csv(upstream_provenance, file.path(output_dir, "upstream_provenance.csv"), row.names = FALSE)
knitr::kable(upstream_provenance)
```



|file               |     bytes|md5                              |dropbox_path                                                            |
|:------------------|---------:|:--------------------------------|:-----------------------------------------------------------------------|
|sae_admissions.rds | 116644163|5a55dd9eebe439b6173ac487c0398f0f |/Effect SAE on SUA/data/sae_admissions.rds                              |
|table_a3_panel.rds |    252993|572f4faba00263d249abc267b41146e2 |/Effect SAE on SUA/data/finalized_design_v1/section3/table_a3_panel.rds |

``` r
school_catalogue <- readRDS(upstream_paths[2])
od_schools <- school_catalogue$RBD[school_catalogue$IS_OD]
stopifnot(!anyDuplicated(od_schools))
admissions <- readRDS(upstream_paths[1])
keys <- data.table::data.table(proc = panel$YEAR, mrun = panel$MRUN)
choices <- admissions$c1[keys, on = c("proc", "mrun"), nomatch = 0]
placements <- admissions$d1[keys, on = c("proc", "mrun"), nomatch = 0]
rm(admissions)
stopifnot(nrow(placements) == nrow(panel), !anyDuplicated(placements[, c("proc", "mrun")]),
          all(choices$cod_nivel == 9), !anyNA(choices$preferencia_postulante),
          all(placements$cod_nivel == 9))
stopifnot(all(choices$agregada_por_continuidad %in% 0:1))
choices <- choices[agregada_por_continuidad == 0]
choices[, LISTED_OD := rbd %in% od_schools]
list_summary <- choices[, list(
  RAW_N_CLASS = .N,
  N_DISTINCT_SCHOOLS = data.table::uniqueN(rbd),
  RAW_N_OD = data.table::uniqueN(rbd[LISTED_OD]),
  RAW_FC_OD = as.integer(any(LISTED_OD[preferencia_postulante == 1])),
  TARGET_RBD = if (data.table::uniqueN(rbd[LISTED_OD]) == 1) unique(rbd[LISTED_OD]) else NA_integer_,
  FALLBACK_RBD = if (data.table::uniqueN(rbd[!LISTED_OD]) == 1) unique(rbd[!LISTED_OD]) else NA_integer_
), by = c("proc", "mrun")]
diagnostic_panel <- merge(data.table::as.data.table(panel), list_summary,
                          by.x = c("YEAR", "MRUN"), by.y = c("proc", "mrun"), all.x = TRUE, sort = FALSE)
diagnostic_panel <- merge(diagnostic_panel,
                          placements[, list(proc, mrun, OFFERED_RBD = rbd_admitido)],
                          by.x = c("YEAR", "MRUN"), by.y = c("proc", "mrun"), all.x = TRUE, sort = FALSE)
stopifnot(nrow(diagnostic_panel) == nrow(panel), !anyDuplicated(diagnostic_panel$MRUN))
reconciliation <- diagnostic_panel[LOTTERY_SAMPLE == TRUE, list(
  N = .N, missing_lists = sum(is.na(RAW_N_CLASS)),
  choice_count_disagreements = sum(N_CLASS != RAW_N_CLASS, na.rm = TRUE),
  od_count_disagreements = sum(N_OD != RAW_N_OD, na.rm = TRUE),
  first_choice_disagreements = sum(FC_OD != RAW_FC_OD, na.rm = TRUE),
  offer_disagreements = sum(OFFER != as.integer(OFFERED_RBD %in% od_schools)),
  attendance_disagreements = sum(D_OD != as.integer(ENTRY_RBD %in% od_schools))
), by = YEAR]
write.csv(reconciliation, file.path(output_dir, "upstream_reconciliation.csv"), row.names = FALSE)
knitr::kable(reconciliation)
```



| YEAR|     N| missing_lists| choice_count_disagreements| od_count_disagreements| first_choice_disagreements| offer_disagreements| attendance_disagreements|
|----:|-----:|-------------:|--------------------------:|----------------------:|--------------------------:|-------------------:|------------------------:|
| 2016|   260|             0|                          0|                      0|                          0|                   0|                        0|
| 2017|  9833|             0|                          0|                      0|                          0|                   0|                        0|
| 2018| 31535|             0|                          0|                      0|                          0|                   0|                        0|
| 2019| 48382|             0|                          0|                      0|                          0|                   0|                        0|
| 2020| 42084|             0|                          0|                      0|                          0|                   0|                        0|
| 2021| 44227|             0|                          0|                      0|                          0|                   0|                        0|

``` r
stopifnot(all(as.matrix(reconciliation[, -c("YEAR", "N")]) == 0))

diagnostic_sample <- as.data.frame(diagnostic_panel[match(sample_main$MRUN, MRUN)])
stopifnot(identical(diagnostic_sample$MRUN, sample_main$MRUN),
          identical(diagnostic_sample$YEAR, sample_main$YEAR))
choice_keys <- unique(choices[, list(YEAR = proc, MRUN = mrun, ENTRY_RBD = rbd)])
choice_keys[, ENTRY_LISTED := TRUE]
diagnostic_sample <- as.data.frame(merge(data.table::as.data.table(diagnostic_sample), choice_keys,
                         by = c("YEAR", "MRUN", "ENTRY_RBD"), all.x = TRUE, sort = FALSE))
diagnostic_sample$ENTRY_LISTED[is.na(diagnostic_sample$ENTRY_LISTED)] <- FALSE
stopifnot(nrow(diagnostic_sample) == nrow(sample_main))
subset_flags <- list(
  main = rep(TRUE, nrow(diagnostic_sample)),
  single_od = with(diagnostic_sample, N_OD == 1 & ORIGIN_OD == 0),
  two_choices = with(diagnostic_sample, N_OD == 1 & ORIGIN_OD == 0 &
                      N_CLASS == 2 & N_DISTINCT_SCHOOLS == 2 & FC_OD == 1)
)
subset_labels <- c(main = "Main sample", single_od = "One OD school listed; non-OD origin",
                    two_choices = "Two choices: OD first, non-OD second; non-OD origin")
stopifnot(!anyNA(unlist(subset_flags)), all(!subset_flags$two_choices | subset_flags$single_od))
rm(diagnostic_panel, placements, choices, choice_keys)
invisible(gc())
```

### Sample support and observed school destinations

The following counts and destination shares describe observed behavior. They do
not identify always-takers, never-takers, or individual counterfactual switches.
In particular, comparisons conditional on realized attendance are not causal
effects for a principal stratum. We instead show unconditional destination shares
within offer arms and keep actual destinations out of all sample restrictions.


``` r
sample_support <- destination_list <- list()
for (s in names(subset_flags)) {
  d <- diagnostic_sample[subset_flags[[s]], , drop = FALSE]
  arm_counts <- table(d$CHANCE_GROUP, factor(d$OFFER, levels = 0:1))
  sample_support[[s]] <- data.frame(
    sample = s, description = unname(subset_labels[s]), n = nrow(d),
    share_main_pct = 100 * nrow(d) / nrow(diagnostic_sample),
    offered = sum(d$OFFER == 1), not_offered = sum(d$OFFER == 0),
    chance_groups = nrow(arm_counts), groups_with_both_arms = sum(rowSums(arm_counts > 0) == 2),
    offered_outside_single_target = if (s == "main") NA_integer_ else
      sum(d$OFFER == 1 & d$OFFERED_RBD != d$TARGET_RBD),
    mean_prior_gpa = mean(d$GPA8_Z), low_income_pct = 100 * mean(d$PRIORITARIO)
  )
  for (z in 0:1) {
    dz <- d[d$OFFER == z, , drop = FALSE]
    destination_list[[paste(s, z)]] <- data.frame(
      sample = s, offer = z, n = nrow(dz),
      attend_od_pct = 100 * mean(dz$D_OD),
      attend_offered_school_pct = if (z == 1) 100 * mean(!is.na(dz$ENTRY_RBD) & dz$ENTRY_RBD == dz$OFFERED_RBD) else NA_real_,
      attend_different_od_pct = if (z == 1) 100 * mean(dz$D_OD == 1 & dz$ENTRY_RBD != dz$OFFERED_RBD, na.rm = TRUE) else NA_real_,
      attend_listed_od_pct = 100 * mean(dz$D_OD == 1 & dz$ENTRY_LISTED),
      attend_unlisted_od_pct = 100 * mean(dz$D_OD == 1 & !dz$ENTRY_LISTED),
      attend_listed_nonod_pct = 100 * mean(dz$D_OD == 0 & dz$ENTRY_LISTED),
      attend_unlisted_nonod_pct = 100 * mean(dz$D_OD == 0 & !dz$ENTRY_LISTED & !is.na(dz$ENTRY_RBD)),
      no_record_pct = 100 * mean(is.na(dz$ENTRY_RBD))
    )
  }
}
sample_support <- do.call(rbind, sample_support)
destinations <- do.call(rbind, destination_list)
destination_columns <- c("attend_listed_od_pct", "attend_unlisted_od_pct", "attend_listed_nonod_pct",
                         "attend_unlisted_nonod_pct", "no_record_pct")
stopifnot(all(abs(rowSums(destinations[, destination_columns]) - 100) < 1e-9))
write.csv(sample_support, file.path(output_dir, "choice_sample_support.csv"), row.names = FALSE)
write.csv(destinations, file.path(output_dir, "observed_school_destinations.csv"), row.names = FALSE)
knitr::kable(sample_support, digits = 3)
```



|            |sample      |description                                         |      n| share_main_pct| offered| not_offered| chance_groups| groups_with_both_arms| offered_outside_single_target| mean_prior_gpa| low_income_pct|
|:-----------|:-----------|:---------------------------------------------------|------:|--------------:|-------:|-----------:|-------------:|---------------------:|-----------------------------:|--------------:|--------------:|
|main        |main        |Main sample                                         | 175869|        100.000|   63073|      112796|           101|                   101|                            NA|          0.090|         57.018|
|single_od   |single_od   |One OD school listed; non-OD origin                 |  39187|         22.282|   11276|       27911|           101|                    98|                             1|         -0.070|         67.392|
|two_choices |two_choices |Two choices: OD first, non-OD second; non-OD origin |  10319|          5.867|    4312|        6007|           101|                    96|                             0|         -0.075|         67.642|

``` r
knitr::kable(destinations, digits = 3)
```



|              |sample      | offer|      n| attend_od_pct| attend_offered_school_pct| attend_different_od_pct| attend_listed_od_pct| attend_unlisted_od_pct| attend_listed_nonod_pct| attend_unlisted_nonod_pct| no_record_pct|
|:-------------|:-----------|-----:|------:|-------------:|-------------------------:|-----------------------:|--------------------:|----------------------:|-----------------------:|-------------------------:|-------------:|
|main 0        |main        |     0| 112796|        14.406|                        NA|                      NA|               11.403|                  3.003|                  55.220|                    28.513|         1.862|
|main 1        |main        |     1|  63073|        86.647|                    82.948|                   3.699|               84.806|                  1.841|                   4.206|                     8.041|         1.105|
|single_od 0   |single_od   |     0|  27911|         6.858|                        NA|                      NA|                6.109|                  0.749|                  73.982|                    17.502|         1.659|
|single_od 1   |single_od   |     1|  11276|        84.063|                    83.700|                   0.364|               83.700|                  0.364|                   7.591|                     7.237|         1.109|
|two_choices 0 |two_choices |     0|   6007|        12.902|                        NA|                      NA|               11.853|                  1.049|                  63.726|                    21.142|         2.231|
|two_choices 1 |two_choices |     1|   4312|        86.990|                    86.665|                   0.325|               86.665|                  0.325|                   5.148|                     6.795|         1.067|

An unlisted destination means a school absent from the family's submitted list,
not necessarily a school unavailable to the student. It can include a continuity
option added automatically. The support table counts offers within the
over-demanded set that are not at the student's single listed over-demanded
school. We retain any such observations, since removing students based on their
realized offers would change the predetermined sample definition.


``` r
# Recheck observed balance because rounded-score conditioning is approximate,
# and balance in the full sample need not imply balance within each subset.
balance_vars <- c("N_CLASS", "N_OD", "FC_OD", controls)
balance_list <- balance_joint_list <- list()
for (s in setdiff(names(subset_flags), "main")) {
  d <- diagnostic_sample[subset_flags[[s]], , drop = FALSE]
  varying <- balance_vars[vapply(d[, balance_vars], function(v) length(unique(v)) > 1L, logical(1))]
  for (v in varying) {
    m <- feols(as.formula(paste(v, "~ OFFER + i(YEAR, ref = 2016) | CHANCE_GROUP")), d,
               vcov = "hetero", ssc = ols_ssc, fixef.rm = "none")
    e <- extract_effect(m, "OFFER")
    balance_list[[paste(s,v)]] <- data.frame(sample = s, characteristic = v, n = nobs(m),
      difference = e["estimate"], se = e["se"], p = e["p"],
      lower = e["lower"], upper = e["upper"])
  }
  joint_model <- feols(as.formula(paste("OFFER ~", paste(varying, collapse = " + "),
                                        "+ i(YEAR, ref = 2016) | CHANCE_GROUP")), d,
                        vcov = "hetero", ssc = ols_ssc, fixef.rm = "none")
  joint <- wald(joint_model, keep = paste0("^(", paste(varying, collapse = "|"), ")$"), print = FALSE)
  balance_joint_list[[s]] <- data.frame(sample = s, F = joint$stat, p = joint$p,
    df1 = joint$df1, df2 = joint$df2, characteristics = paste(varying, collapse = ", "))
}
choice_balance <- do.call(rbind, balance_list)
choice_balance_joint <- do.call(rbind, balance_joint_list)
write.csv(choice_balance, file.path(output_dir, "choice_sample_balance.csv"), row.names = FALSE)
write.csv(choice_balance_joint, file.path(output_dir, "choice_sample_balance_joint.csv"), row.names = FALSE)
knitr::kable(choice_balance, digits = 4)
```



|                        |sample      |characteristic |     n| difference|     se|      p|   lower|  upper|
|:-----------------------|:-----------|:--------------|-----:|----------:|------:|------:|-------:|------:|
|single_od N_CLASS       |single_od   |N_CLASS        | 39187|     0.0079| 0.0134| 0.5569| -0.0184| 0.0342|
|single_od FC_OD         |single_od   |FC_OD          | 39187|     0.0003| 0.0044| 0.9468| -0.0082| 0.0088|
|single_od GPA8_Z        |single_od   |GPA8_Z         | 39187|     0.0163| 0.0135| 0.2246| -0.0100| 0.0427|
|single_od ES_MUJER      |single_od   |ES_MUJER       | 39187|     0.0029| 0.0069| 0.6761| -0.0107| 0.0165|
|single_od PRIORITARIO   |single_od   |PRIORITARIO    | 39187|     0.0003| 0.0066| 0.9643| -0.0126| 0.0131|
|single_od ALTO          |single_od   |ALTO           | 39187|     0.0074| 0.0062| 0.2328| -0.0048| 0.0195|
|two_choices GPA8_Z      |two_choices |GPA8_Z         | 10319|     0.0237| 0.0235| 0.3138| -0.0224| 0.0697|
|two_choices ES_MUJER    |two_choices |ES_MUJER       | 10319|     0.0052| 0.0120| 0.6638| -0.0183| 0.0287|
|two_choices PRIORITARIO |two_choices |PRIORITARIO    | 10319|     0.0149| 0.0112| 0.1842| -0.0071| 0.0368|
|two_choices ALTO        |two_choices |ALTO           | 10319|     0.0043| 0.0108| 0.6877| -0.0168| 0.0254|

``` r
knitr::kable(choice_balance_joint, digits = 4)
```



|            |sample      |      F|      p| df1|   df2|characteristics                                     |
|:-----------|:-----------|------:|------:|---:|-----:|:---------------------------------------------------|
|single_od   |single_od   | 0.4080| 0.8742|   6| 39075|N_CLASS, FC_OD, GPA8_Z, ES_MUJER, PRIORITARIO, ALTO |
|two_choices |two_choices | 0.7834| 0.5357|   4| 10209|GPA8_Z, ES_MUJER, PRIORITARIO, ALTO                 |

### Outcomes within the predetermined samples

We retain the original hundredth-score fixed effects, year indicators, and
controls. Covariates that are constant within a restricted sample are omitted
because they are absorbed by the intercept; this does not alter fitted values.
No additional support trimming is based on observed outcomes or offer arms.
The original approximation to exact propensity-score conditioning remains an
assumption in these restricted samples. Every specification uses both offer arms
and includes students regardless of their realized school.


``` r
choice_result_list <- choice_first_stages <- list()
for (s in names(subset_flags)) {
  d <- diagnostic_sample[subset_flags[[s]], , drop = FALSE]
  varying_controls <- controls[vapply(d[, controls, drop = FALSE], function(v) length(unique(v)) > 1L, logical(1))]
  choice_rhs <- paste(c(varying_controls, "i(YEAR, ref = 2016)"), collapse = " + ")
  fs <- feols(as.formula(paste("D_OD ~ OFFER +", choice_rhs, "| CHANCE_GROUP")), d,
              vcov = "hetero", ssc = ols_ssc, fixef.rm = "none")
  f <- extract_effect(fs, "OFFER")
  choice_first_stages[[s]] <- data.frame(sample = s, n = nobs(fs),
    first_stage_pp = 100 * f["estimate"], se_pp = 100 * f["se"],
    lower_pp = 100 * f["lower"], upper_pp = 100 * f["upper"],
    omitted_constant_controls = paste(setdiff(controls, varying_controls), collapse = ", "))
  for (y in binary_vars) {
    rf <- feols(as.formula(paste(y, "~ OFFER +", choice_rhs, "| CHANCE_GROUP")), d,
                vcov = "hetero", ssc = ols_ssc, fixef.rm = "none")
    iv <- feols(as.formula(paste(y, "~", choice_rhs, "| CHANCE_GROUP | D_OD ~ OFFER")), d,
                vcov = "hetero", ssc = iv_ssc, fixef.rm = "none")
    re <- extract_effect(rf, "OFFER"); ie <- extract_effect(iv, "fit_D_OD", iv = TRUE)
    stopifnot(nobs(rf) == nrow(d), nobs(iv) == nrow(d),
              abs(re["estimate"] / f["estimate"] - ie["estimate"]) < 1e-7)
    choice_result_list[[paste(s, y)]] <- data.frame(
      sample = s, variable = y, n = nrow(d),
      no_offer_mean_pct = 100 * mean(d[[y]][d$OFFER == 0]),
      rf_pp = 100 * re["estimate"], rf_se_pp = 100 * re["se"], rf_p = re["p"],
      rf_lower_pp = 100 * re["lower"], rf_upper_pp = 100 * re["upper"],
      iv_pp = 100 * ie["estimate"], iv_se_pp = 100 * ie["se"], iv_p = ie["p"],
      iv_lower_pp = 100 * ie["lower"], iv_upper_pp = 100 * ie["upper"]
    )
  }
}
choice_results <- do.call(rbind, choice_result_list)
choice_first_stages <- do.call(rbind, choice_first_stages)
main_check <- choice_results[choice_results$sample == "main", ]
stopifnot(all(abs(main_check$rf_pp - 100 * results$rf_estimate[match(main_check$variable, results$variable)]) < 1e-7),
          all(abs(main_check$iv_pp - 100 * results$iv_estimate[match(main_check$variable, results$variable)]) < 1e-7))
write.csv(choice_results, file.path(output_dir, "choice_sample_outcomes.csv"), row.names = FALSE)
write.csv(choice_first_stages, file.path(output_dir, "choice_sample_first_stages.csv"), row.names = FALSE)
knitr::kable(choice_first_stages, digits = 3)
```



|            |sample      |      n| first_stage_pp| se_pp| lower_pp| upper_pp|omitted_constant_controls |
|:-----------|:-----------|------:|--------------:|-----:|--------:|--------:|:-------------------------|
|main        |main        | 175869|         62.572| 0.245|   62.092|   63.053|                          |
|single_od   |single_od   |  39187|         66.747| 0.553|   65.663|   67.832|ORIGIN_OD                 |
|two_choices |two_choices |  10319|         66.614| 0.929|   64.792|   68.436|ORIGIN_OD                 |


``` r
for (s in names(subset_flags)) {
  cat("\n#### ", subset_labels[s], "\n\n", sep = "")
  r <- choice_results[choice_results$sample == s, ]
  display <- data.frame(
    Outcome = paste(unname(college_labels[sub("_(OT|EVER)$", "", r$variable)]),
                    ifelse(grepl("_OT$", r$variable), "(on time)", "(ever)")),
    `Offer effect (pp)` = fmt(r$rf_pp),
    `95% CI` = paste0("[", fmt(r$rf_lower_pp), ", ", fmt(r$rf_upper_pp), "]"),
    `Offer p-value` = fmt_p(r$rf_p),
    `Attendance effect (pp)` = fmt(r$iv_pp),
    `Attendance 95% CI` = paste0("[", fmt(r$iv_lower_pp), ", ", fmt(r$iv_upper_pp), "]"),
    check.names = FALSE
  )
  print(knitr::kable(display)); cat("\n\n")
}
```


#### Main sample



|Outcome                                |Offer effect (pp) |95% CI         |Offer p-value |Attendance effect (pp) |Attendance 95% CI |
|:--------------------------------------|:-----------------|:--------------|:-------------|:----------------------|:-----------------|
|Regular-secondary graduation (on time) |-1.95             |[-2.41, -1.50] |<0.001        |-3.12                  |[-3.85, -2.39]    |
|Applied through SUA (on time)          |-0.86             |[-1.41, -0.32] |0.002         |-1.38                  |[-2.25, -0.51]    |
|Assigned a seat through SUA (on time)  |-1.40             |[-1.90, -0.89] |<0.001        |-2.23                  |[-3.04, -1.42]    |
|First enrollment through SUA (on time) |-1.47             |[-1.97, -0.98] |<0.001        |-2.36                  |[-3.14, -1.57]    |
|First enrollment outside SUA (on time) |-0.34             |[-0.83, 0.15]  |0.178         |-0.54                  |[-1.33, 0.25]     |
|Regular-secondary graduation (ever)    |-0.87             |[-1.28, -0.46] |<0.001        |-1.39                  |[-2.05, -0.74]    |
|Applied through SUA (ever)             |-0.32             |[-0.87, 0.23]  |0.256         |-0.51                  |[-1.39, 0.37]     |
|Assigned a seat through SUA (ever)     |-0.65             |[-1.18, -0.11] |0.017         |-1.04                  |[-1.89, -0.18]    |
|First enrollment through SUA (ever)    |-0.84             |[-1.36, -0.31] |0.002         |-1.33                  |[-2.18, -0.49]    |
|First enrollment outside SUA (ever)    |0.27              |[-0.29, 0.82]  |0.349         |0.43                   |[-0.46, 1.31]     |



#### One OD school listed; non-OD origin



|Outcome                                |Offer effect (pp) |95% CI         |Offer p-value |Attendance effect (pp) |Attendance 95% CI |
|:--------------------------------------|:-----------------|:--------------|:-------------|:----------------------|:-----------------|
|Regular-secondary graduation (on time) |-2.68             |[-3.81, -1.54] |<0.001        |-4.01                  |[-5.71, -2.31]    |
|Applied through SUA (on time)          |-0.58             |[-1.72, 0.56]  |0.317         |-0.87                  |[-2.57, 0.83]     |
|Assigned a seat through SUA (on time)  |-1.09             |[-2.11, -0.07] |0.036         |-1.63                  |[-3.16, -0.11]    |
|First enrollment through SUA (on time) |-1.94             |[-2.91, -0.97] |<0.001        |-2.91                  |[-4.35, -1.46]    |
|First enrollment outside SUA (on time) |-0.55             |[-1.73, 0.64]  |0.366         |-0.82                  |[-2.59, 0.96]     |
|Regular-secondary graduation (ever)    |-1.25             |[-2.29, -0.20] |0.019         |-1.87                  |[-3.43, -0.31]    |
|Applied through SUA (ever)             |-0.25             |[-1.43, 0.93]  |0.677         |-0.38                  |[-2.14, 1.39]     |
|Assigned a seat through SUA (ever)     |-0.28             |[-1.38, 0.81]  |0.612         |-0.43                  |[-2.07, 1.22]     |
|First enrollment through SUA (ever)    |-1.15             |[-2.22, -0.09] |0.034         |-1.73                  |[-3.33, -0.13]    |
|First enrollment outside SUA (ever)    |0.71              |[-0.61, 2.03]  |0.290         |1.07                   |[-0.90, 3.04]     |



#### Two choices: OD first, non-OD second; non-OD origin



|Outcome                                |Offer effect (pp) |95% CI         |Offer p-value |Attendance effect (pp) |Attendance 95% CI |
|:--------------------------------------|:-----------------|:--------------|:-------------|:----------------------|:-----------------|
|Regular-secondary graduation (on time) |-3.93             |[-5.87, -1.99] |<0.001        |-5.90                  |[-8.81, -2.99]    |
|Applied through SUA (on time)          |-1.25             |[-3.21, 0.71]  |0.212         |-1.87                  |[-4.80, 1.05]     |
|Assigned a seat through SUA (on time)  |-1.46             |[-3.21, 0.29]  |0.101         |-2.20                  |[-4.81, 0.41]     |
|First enrollment through SUA (on time) |-2.18             |[-3.84, -0.52] |0.010         |-3.27                  |[-5.75, -0.80]    |
|First enrollment outside SUA (on time) |-0.27             |[-2.32, 1.79]  |0.800         |-0.40                  |[-3.47, 2.67]     |
|Regular-secondary graduation (ever)    |-2.50             |[-4.29, -0.71] |0.006         |-3.75                  |[-6.43, -1.06]    |
|Applied through SUA (ever)             |-0.38             |[-2.41, 1.66]  |0.717         |-0.56                  |[-3.60, 2.47]     |
|Assigned a seat through SUA (ever)     |-0.52             |[-2.40, 1.36]  |0.590         |-0.78                  |[-3.58, 2.03]     |
|First enrollment through SUA (ever)    |-1.23             |[-3.04, 0.59]  |0.185         |-1.84                  |[-4.56, 0.87]     |
|First enrollment outside SUA (ever)    |0.04              |[-2.21, 2.30]  |0.969         |0.07                   |[-3.30, 3.43]     |

### Target-school attendance and departures from the listed alternatives

For the restricted samples, the single listed over-demanded school defines a
student-specific target before the lottery. We estimate offer effects on
attendance at that target, at another over-demanded school, and at destinations
outside the submitted list. This decomposes the observed first stage without
conditioning on post-offer attendance. It is not a decomposition by compliance
type and does not identify school-switching effects holding the pooled indicator
fixed. In particular, an offer-induced reduction in unlisted-school enrollment
can be an ordinary part of the effect for compliers.


``` r
destination_effect_list <- target_iv_list <- list()
for (s in setdiff(names(subset_flags), "main")) {
  d <- diagnostic_sample[subset_flags[[s]], , drop = FALSE]
  stopifnot(!anyNA(d$TARGET_RBD))
  d$D_TARGET <- as.integer(!is.na(d$ENTRY_RBD) & d$ENTRY_RBD == d$TARGET_RBD)
  d$D_OTHER_OD <- d$D_OD - d$D_TARGET
  d$D_UNLISTED_NONOD <- as.integer(d$D_OD == 0 & !d$ENTRY_LISTED & !is.na(d$ENTRY_RBD))
  d$D_NO_RECORD <- as.integer(is.na(d$ENTRY_RBD))
  d$D_LISTED_NONOD <- as.integer(d$D_OD == 0 & d$ENTRY_LISTED)
  stopifnot(all(d$D_OTHER_OD %in% 0:1),
            all(d$D_OD == d$D_TARGET + d$D_OTHER_OD),
            all(rowSums(d[, c("D_TARGET", "D_OTHER_OD", "D_UNLISTED_NONOD", "D_NO_RECORD", "D_LISTED_NONOD")]) == 1))
  varying_controls <- controls[vapply(d[, controls, drop = FALSE], function(v) length(unique(v)) > 1L, logical(1))]
  choice_rhs <- paste(c(varying_controls, "i(YEAR, ref = 2016)"), collapse = " + ")
  for (v in c("D_TARGET", "D_OTHER_OD", "D_LISTED_NONOD", "D_UNLISTED_NONOD", "D_NO_RECORD")) {
    m <- feols(as.formula(paste(v, "~ OFFER +", choice_rhs, "| CHANCE_GROUP")), d,
               vcov = "hetero", ssc = ols_ssc, fixef.rm = "none")
    e <- extract_effect(m, "OFFER")
    destination_effect_list[[paste(s,v)]] <- data.frame(sample = s, destination = v, n = nobs(m),
      mean_without_offer_pct = 100 * mean(d[[v]][d$OFFER == 0]),
      effect_pp = 100 * e["estimate"], se_pp = 100 * e["se"], p = e["p"],
      lower_pp = 100 * e["lower"], upper_pp = 100 * e["upper"])
  }
  # A school-specific treatment removes variation among treated school identities
  # for each applicant, but still requires exclusion concerning untreated options.
  for (y in binary_vars) {
    m <- feols(as.formula(paste(y, "~", choice_rhs, "| CHANCE_GROUP | D_TARGET ~ OFFER")), d,
               vcov = "hetero", ssc = iv_ssc, fixef.rm = "none")
    e <- extract_effect(m, "fit_D_TARGET", iv = TRUE)
    target_iv_list[[paste(s,y)]] <- data.frame(sample = s, variable = y, n = nobs(m),
      estimate_pp = 100 * e["estimate"], se_pp = 100 * e["se"], p = e["p"],
      lower_pp = 100 * e["lower"], upper_pp = 100 * e["upper"])
  }
}
destination_effects <- do.call(rbind, destination_effect_list)
target_iv <- do.call(rbind, target_iv_list)
for (s in unique(destination_effects$sample)) {
  r <- destination_effects[destination_effects$sample == s, ]
  expected_fs <- choice_first_stages$first_stage_pp[choice_first_stages$sample == s]
  stopifnot(abs(sum(r$effect_pp)) < 1e-7,
            abs(sum(r$effect_pp[r$destination %in% c("D_TARGET", "D_OTHER_OD")]) - expected_fs) < 1e-7)
  ti <- target_iv[target_iv$sample == s, ]
  rf <- choice_results[choice_results$sample == s, ]
  target_fs <- r$effect_pp[r$destination == "D_TARGET"] / 100
  stopifnot(all(abs(ti$estimate_pp - rf$rf_pp / target_fs) < 1e-7))
}
write.csv(destination_effects, file.path(output_dir, "target_and_alternative_offer_effects.csv"), row.names = FALSE)
write.csv(target_iv, file.path(output_dir, "target_school_attendance_effects.csv"), row.names = FALSE)
knitr::kable(destination_effects, digits = 3)
```



|                             |sample      |destination      |     n| mean_without_offer_pct| effect_pp| se_pp|     p| lower_pp| upper_pp|
|:----------------------------|:-----------|:----------------|-----:|----------------------:|---------:|-----:|-----:|--------:|--------:|
|single_od D_TARGET           |single_od   |D_TARGET         | 39187|                  6.109|    67.007| 0.553| 0.000|   65.924|   68.091|
|single_od D_OTHER_OD         |single_od   |D_OTHER_OD       | 39187|                  0.749|    -0.260| 0.101| 0.010|   -0.457|   -0.063|
|single_od D_LISTED_NONOD     |single_od   |D_LISTED_NONOD   | 39187|                 73.982|   -55.921| 0.555| 0.000|  -57.008|  -54.834|
|single_od D_UNLISTED_NONOD   |single_od   |D_UNLISTED_NONOD | 39187|                 17.502|   -10.351| 0.455| 0.000|  -11.243|   -9.458|
|single_od D_NO_RECORD        |single_od   |D_NO_RECORD      | 39187|                  1.659|    -0.475| 0.163| 0.004|   -0.796|   -0.155|
|two_choices D_TARGET         |two_choices |D_TARGET         | 10319|                 11.853|    66.852| 0.931| 0.000|   65.028|   68.676|
|two_choices D_OTHER_OD       |two_choices |D_OTHER_OD       | 10319|                  1.049|    -0.238| 0.161| 0.138|   -0.553|    0.077|
|two_choices D_LISTED_NONOD   |two_choices |D_LISTED_NONOD   | 10319|                 63.726|   -54.397| 0.924| 0.000|  -56.208|  -52.586|
|two_choices D_UNLISTED_NONOD |two_choices |D_UNLISTED_NONOD | 10319|                 21.142|   -11.591| 0.805| 0.000|  -13.169|  -10.012|
|two_choices D_NO_RECORD      |two_choices |D_NO_RECORD      | 10319|                  2.231|    -0.626| 0.282| 0.026|   -1.179|   -0.074|

``` r
knitr::kable(target_iv, digits = 3)
```



|                          |sample      |variable      |     n| estimate_pp| se_pp|     p| lower_pp| upper_pp|
|:-------------------------|:-----------|:-------------|-----:|-----------:|-----:|-----:|--------:|--------:|
|single_od GRAD_OT         |single_od   |GRAD_OT       | 39187|      -3.993| 0.863| 0.000|   -5.683|   -2.302|
|single_od APPLIED_OT      |single_od   |APPLIED_OT    | 39187|      -0.866| 0.864| 0.316|   -2.560|    0.828|
|single_od ASSIGNED_OT     |single_od   |ASSIGNED_OT   | 39187|      -1.627| 0.774| 0.036|   -3.144|   -0.110|
|single_od INSUA_OT        |single_od   |INSUA_OT      | 39187|      -2.896| 0.736| 0.000|   -4.338|   -1.454|
|single_od OUTSIDE_OT      |single_od   |OUTSIDE_OT    | 39187|      -0.816| 0.902| 0.366|   -2.583|    0.951|
|single_od GRAD_EVER       |single_od   |GRAD_EVER     | 39187|      -1.860| 0.793| 0.019|   -3.415|   -0.305|
|single_od APPLIED_EVER    |single_od   |APPLIED_EVER  | 39187|      -0.375| 0.898| 0.677|   -2.135|    1.386|
|single_od ASSIGNED_EVER   |single_od   |ASSIGNED_EVER | 39187|      -0.425| 0.836| 0.611|   -2.064|    1.213|
|single_od INSUA_EVER      |single_od   |INSUA_EVER    | 39187|      -1.723| 0.813| 0.034|   -3.316|   -0.130|
|single_od OUTSIDE_EVER    |single_od   |OUTSIDE_EVER  | 39187|       1.063| 1.002| 0.289|   -0.901|    3.028|
|two_choices GRAD_OT       |two_choices |GRAD_OT       | 10319|      -5.875| 1.479| 0.000|   -8.774|   -2.976|
|two_choices APPLIED_OT    |two_choices |APPLIED_OT    | 10319|      -1.866| 1.486| 0.209|   -4.779|    1.047|
|two_choices ASSIGNED_OT   |two_choices |ASSIGNED_OT   | 10319|      -2.190| 1.328| 0.099|   -4.792|    0.413|
|two_choices INSUA_OT      |two_choices |INSUA_OT      | 10319|      -3.263| 1.258| 0.010|   -5.729|   -0.796|
|two_choices OUTSIDE_OT    |two_choices |OUTSIDE_OT    | 10319|      -0.399| 1.562| 0.799|   -3.461|    2.664|
|two_choices GRAD_EVER     |two_choices |GRAD_EVER     | 10319|      -3.733| 1.364| 0.006|   -6.406|   -1.060|
|two_choices APPLIED_EVER  |two_choices |APPLIED_EVER  | 10319|      -0.562| 1.543| 0.716|   -3.586|    2.462|
|two_choices ASSIGNED_EVER |two_choices |ASSIGNED_EVER | 10319|      -0.773| 1.427| 0.588|   -3.569|    2.024|
|two_choices INSUA_EVER    |two_choices |INSUA_EVER    | 10319|      -1.838| 1.378| 0.182|   -4.539|    0.864|
|two_choices OUTSIDE_EVER  |two_choices |OUTSIDE_EVER  | 10319|       0.067| 1.710| 0.969|   -3.285|    3.419|

### Reading the diagnostic results



The offer effects on on-time graduation are
-2.68 pp in the single-over-demanded-school
sample and -3.93 pp in the two-choice
sample. The corresponding effects on on-time enrollment through SUA are
-1.94 and
-2.18 pp. Each is negative and
statistically significant at the pointwise 5% level. The corresponding attendance
estimates and their intervals are shown above, alongside every other binary
outcome at both horizons.

Eventual outcomes give more qualified evidence. Eventual SUA enrollment remains
negative and significant in the single-over-demanded-school sample, but its
interval includes zero in the two-choice sample. Eventual assignment is not
statistically significant in either restricted sample. The restricted samples
contain more low-income applicants and have lower prior GPA than the main sample;
their effects need not represent the same complier populations. Joint tests of
observed baseline balance yield p-values of
0.874
and 0.536,
respectively. These tests do not establish exact randomization or exclusion.

Replacing pooled attendance with attendance at each applicant's single listed
over-demanded school changes the point estimates by at most
0.021 pp. The instrument remains the original
offer indicator. In the single-over-demanded-school sample,
1
observed offer is at a different over-demanded school; there are
0
such offers in the two-choice sample. The target-attendance estimates therefore
remain sensitivity estimates under their own exclusion and monotonicity
assumptions, rather than an independent school-specific lottery design.

These analyses can establish whether the findings depend on applications to
multiple over-demanded schools and how much actual enrollment departs from the
listed alternatives. They cannot recover the school an always-taker or
never-taker would attend under the other offer state. School-specific simulated
assignments, were they available, would characterize assignment possibilities but
would still not reveal counterfactual enrollment behavior. A claim that exclusion
has been established would therefore go beyond these diagnostics. Any comparison
of restricted-sample and main effects must allow for different applicants and
complier populations. No paper edits are made by this analysis.

## LaTeX table for the outcomes appendix

The table below follows the main college-outcomes table: non-offered means and
estimated effects at both horizons, robust SEs in parentheses, significance stars,
and sample sizes. It is generated directly from the fitted reduced forms. This
notebook writes the standalone table to its own output folder; inclusion in the
manuscript is managed separately.


``` r
tex_num <- function(x, digits = 2) {
  sub("^-(0\\.0+)$", "\\1", sprintf(paste0("%.", digits, "f"), x))
}
tex_stars <- function(p) {
  ifelse(p < .01, "$^{***}$", ifelse(p < .05, "$^{**}$", ifelse(p < .1, "$^{*}$", "")))
}
tex_comma <- function(x) format(x, big.mark = ",", scientific = FALSE, trim = TRUE)
tex_row <- function(label, cells) paste0("      ", label, " & ", paste(cells, collapse = " & "), "\\\\\n")
table_labels <- c("Graduated from high school", "Applied to a college program", "Assigned a college seat",
                  "Enrolled (In SUA)", "Enrolled (Outside SUA)")
table_body <- vapply(seq_along(college_labels), function(k) {
  ot <- results[results$variable == paste0(names(college_labels)[k], "_OT"), ]
  ever <- results[results$variable == paste0(names(college_labels)[k], "_EVER"), ]
  paste0(
    tex_row(table_labels[k], c(tex_num(100 * ot$mean_without_offer),
      paste0(tex_num(100 * ot$rf_estimate), tex_stars(ot$rf_p)),
      tex_num(100 * ever$mean_without_offer),
      paste0(tex_num(100 * ever$rf_estimate), tex_stars(ever$rf_p)))),
    tex_row("", c("", paste0("(", tex_num(100 * ot$rf_se), ")"),
                  "", paste0("(", tex_num(100 * ever$rf_se), ")")))
  )
}, character(1))
table_note <- paste0(
  "Notes: The sample is the ", tex_comma(nrow(sample_main)),
  " students of the lottery sample with every characteristic of Section~\\ref{sec:lottery-data}. ",
  "Columns (2) and (4) report OLS estimates of the effect of receiving a main-stage offer at an ",
  "over-demanded school, with the same sample, chance-group and application-year fixed effects, ",
  "and characteristics as Table~\\ref{tab: lottery college}. ",
  "Columns (1) and (3) are means among students without an offer, in \\%; effects are in pp. ",
  "Heteroskedasticity-robust standard errors, with the $N/(N-K)$ correction, are in parentheses; ",
  "$p$-values use the $t(N-K)$ distribution, where $K$ counts the estimated parameters. ",
  "On time and ever are defined in Section~\\ref{sec:lottery-data}; ever uses records through ",
  "2025 for graduation and 2026 for college outcomes, with longer follow-up for earlier cohorts. ",
  "Graduation records completion of regular secondary education and excludes adult education. ",
  "Enrollment rows record the first observed route; same-year enrollment through and outside SUA ",
  "counts in the In SUA row. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$."
)
offer_tex <- paste0(
  "% Generated by code/analysis_for_adversarial_report.Rmd; do not edit numerical entries by hand.\n",
  "\\begin{table}[htbp]\\singlespacing\\renewcommand{\\arraystretch}{1.2}\n",
  "   \\caption{Effect of an Offer at an Over-Demanded School on Graduation and College Outcomes}",
  "\\label{tab: lottery college offer}\n",
  "   \\centerline{\\scalebox{0.85}{\\begin{tabular}{lcccc}\n",
  "      \\toprule\n",
  "                   & \\multicolumn{2}{c}{On time} & \\multicolumn{2}{c}{Ever}\\\\\n",
  "      \\cmidrule(lr){2-3}\\cmidrule(lr){4-5}\n",
  "                   & \\shortstack{Without an\\\\offer} & \\shortstack{Offer\\\\effect} & ",
  "\\shortstack{Without an\\\\offer} & \\shortstack{Offer\\\\effect}\\\\\n",
  "                   & mean & & mean & \\\\\n",
  "                   & (1) & (2) & (3) & (4)\\\\\n",
  "      \\midrule\n",
  paste(table_body, collapse = ""),
  "      \\midrule\n",
  tex_row("$N$", tex_comma(rep(c(sum(sample_main$OFFER == 0), nrow(sample_main)), 2))),
  "      \\bottomrule\n",
  "   \\end{tabular}}}\n",
  "   \\par\\smallskip{\\footnotesize ", table_note, "}\n",
  "\\end{table}\n"
)
table_file <- file.path(output_dir, "lottery_college_offer.tex")
writeLines(offer_tex, table_file, useBytes = TRUE)
cat(offer_tex)
```

```
## % Generated by code/analysis_for_adversarial_report.Rmd; do not edit numerical entries by hand.
## \begin{table}[htbp]\singlespacing\renewcommand{\arraystretch}{1.2}
##    \caption{Effect of an Offer at an Over-Demanded School on Graduation and College Outcomes}\label{tab: lottery college offer}
##    \centerline{\scalebox{0.85}{\begin{tabular}{lcccc}
##       \toprule
##                    & \multicolumn{2}{c}{On time} & \multicolumn{2}{c}{Ever}\\
##       \cmidrule(lr){2-3}\cmidrule(lr){4-5}
##                    & \shortstack{Without an\\offer} & \shortstack{Offer\\effect} & \shortstack{Without an\\offer} & \shortstack{Offer\\effect}\\
##                    & mean & & mean & \\
##                    & (1) & (2) & (3) & (4)\\
##       \midrule
##       Graduated from high school & 81.08 & -1.95$^{***}$ & 85.53 & -0.87$^{***}$\\
##        &  & (0.23) &  & (0.21)\\
##       Applied to a college program & 39.65 & -0.86$^{***}$ & 46.76 & -0.32\\
##        &  & (0.28) &  & (0.28)\\
##       Assigned a college seat & 30.10 & -1.40$^{***}$ & 38.35 & -0.65$^{**}$\\
##        &  & (0.26) &  & (0.27)\\
##       Enrolled (In SUA) & 25.80 & -1.47$^{***}$ & 35.81 & -0.84$^{***}$\\
##        &  & (0.25) &  & (0.27)\\
##       Enrolled (Outside SUA) & 21.19 & -0.34 & 32.12 & 0.27\\
##        &  & (0.25) &  & (0.28)\\
##       \midrule
##       $N$ & 112,796 & 175,869 & 112,796 & 175,869\\
##       \bottomrule
##    \end{tabular}}}
##    \par\smallskip{\footnotesize Notes: The sample is the 175,869 students of the lottery sample with every characteristic of Section~\ref{sec:lottery-data}. Columns (2) and (4) report OLS estimates of the effect of receiving a main-stage offer at an over-demanded school, with the same sample, chance-group and application-year fixed effects, and characteristics as Table~\ref{tab: lottery college}. Columns (1) and (3) are means among students without an offer, in \%; effects are in pp. Heteroskedasticity-robust standard errors, with the $N/(N-K)$ correction, are in parentheses; $p$-values use the $t(N-K)$ distribution, where $K$ counts the estimated parameters. On time and ever are defined in Section~\ref{sec:lottery-data}; ever uses records through 2025 for graduation and 2026 for college outcomes, with longer follow-up for earlier cohorts. Graduation records completion of regular secondary education and excludes adult education. Enrollment rows record the first observed route; same-year enrollment through and outside SUA counts in the In SUA row. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$.}
## \end{table}
```

## Interpretation and decisions for discussion

With the same sample, covariates and fixed effects, the reduced-form coefficient
equals the 2SLS coefficient times the first-stage coefficient, up to numerical
precision. The offer effects therefore reveal the same underlying variation;
they are not an independent robustness check of the attendance estimates.

The offer effect describes the consequences of receiving a main-stage offer at
any school in the fixed over-demanded set. Its causal interpretation relies on
the validity of the conditional lottery comparison, including the approximation
to exact offer probabilities, the control timing, and the relevant interference
assumptions. It does not require exclusion or monotonicity for the pooled binary
attendance treatment. The present exercise preserves, rather than independently
validates, the handoff's inference and covariate choices.

Interpreting the ratio as an attendance LATE additionally requires the IV
assumptions. School changes within the over-demanded set, or outside it, may affect
outcomes without changing the pooled attendance indicator. Reporting the reduced
form does not resolve that concern. Conditioning on realized attendance would not
identify always-takers or isolate a causal within-set switching effect.

The finalized panel does not contain offered-school identities, ranked school
lists, or school-specific assignment draws. The upstream records recovered here
supply observed offers and lists, but not simulation draws or counterfactual
enrollment. This notebook does not infer individual counterfactual switches from
cross-sectional differences in realized destinations.

The generated appendix table reports the reduced forms with SEs and significance
stars, matching the existing paper tables; confidence intervals remain available
in this report and the CSV. A short reference in Section V could explain the
findings and the distinct assumptions for offer and attendance effects. That
discussion remains subject to author review. The conditional score results are
kept separate. This notebook does not edit manuscript prose or appendix inputs.

## F02.4: ninth-grade composition and the lottery population

This extension preserves the finalized composition outcomes, school-grade
classification, unbalanced-panel estimator, universal base period, and
not-yet-treated comparisons. Its primary change is to restrict the composition
sample to ninth grade. Regions first adopt ninth grade in entering-class years
2017, 2018, 2019, or 2020. Consequently only the first three waves have supported
post-adoption comparisons, through 2019; the Metropolitan Region is a comparison
region, not a treated region with an identified post-adoption effect here.
All ninth grades are entry grades, so a comparison region has not yet adopted
SAE in any grade under the documented rollout calendar.

We report pointwise intervals from the handoff's region-clustered multiplier
bootstrap with 10,000 draws. These are **not** the paper's permutation-test
p-values. No significance stars or new rollout-randomization claims are made.
The small number of regions and uneven adoption waves remain relevant to
inference (F13–F14); this extension does not resolve those separate concerns.
All-grade estimates are reestimated as a numerical baseline, not substituted
for the paper's saved inference. The notebook does not change manuscript files.

### Composition inputs and specification


``` r
if (!requireNamespace("did", quietly = FALSE) || packageVersion("did") != "2.1.2")
  stop("F02.4 requires did 2.1.2. Install in an isolated library and set R_LIBS_USER before starting R if needed.")
if (getRversion() != "4.5.1") stop("F02.4 preserves the handoff's R 4.5.1 runtime.")
s2_manifest <- manifest[endsWith(manifest$path_in_dropbox, "/section2/section2_panel.rds"), ]
s2_override <- Sys.getenv("SAE_ADVERSARIAL_COMPOSITION_PANEL")
s2_candidates <- if (nzchar(s2_override)) path.expand(s2_override) else c(
  file.path(task_home, "Dropbox", s2_manifest$path_in_dropbox),
  file.path(output_dir, "input", "section2_panel.rds"))
s2_available <- s2_candidates[file.exists(s2_candidates) & !is.na(file.info(s2_candidates)$size) & file.info(s2_candidates)$size > 0]
if (!length(s2_available)) stop("No readable finalized Section 2 panel.")
s2_file <- normalizePath(s2_available[1])
stopifnot(nrow(s2_manifest) == 1L, identical(unname(tools::md5sum(s2_file)), s2_manifest$md5),
          file.info(s2_file)$size == s2_manifest$bytes)
s2 <- data.table::as.data.table(readRDS(s2_file))
stopifnot(!anyDuplicated(s2, by = c("MRUN", "AGNO")))
f02_provenance <- data.frame(file = s2_file, bytes = file.info(s2_file)$size,
  md5 = unname(tools::md5sum(s2_file)), did_version = as.character(packageVersion("did")),
  reference_notebook_md5 = unname(tools::md5sum("finalized_design_v1/section2/section2_cs_did.Rmd")),
  bootstrap_draws = 10000L, seed = 20261018L)
write.csv(f02_provenance, file.path(output_dir, "f02_provenance.csv"), row.names = FALSE)

composition_cells <- s2[, list(n_ent = .N, n_gpa = sum(!is.na(PRIOR_GPA_Z)),
  gpa_z = mean(PRIOR_GPA_Z, na.rm = TRUE), sh_prio = mean(PRIO)),
  by = list(yr = AGNO, rbd = RBD, grade = COD_NIVEL, region = REGION, G = DOOR + 1L)]
composition_cells[grade < 2L, gpa_z := NA_real_]
composition_cells[, cell_id := as.integer(factor(paste(rbd, grade, sep = "|")))]
stopifnot(data.table::uniqueN(composition_cells$cell_id) == 8891L)
region_school_map <- unique(s2[COD_NIVEL == 9L, list(RBD, REGION, G = DOOR + 1L)])
stopifnot(!anyDuplicated(region_school_map$RBD), setequal(region_school_map$RBD, od_schools))
f02_designs <- list(all_grades = composition_cells, ninth_grade = composition_cells[grade == 9L])
```

### Estimates, support, and aggregation

The estimator uses observed cells separately in each comparison year, following
the baseline's unbalanced-panel convention. We independently reconstruct every
supported post-adoption contrast from its four cell means and verify the
aggregation weights against `did::aggte(type = "simple")`. Support exports report
region identities, observed cells, entrants, GPA coverage, and the actual weight
of each post-adoption comparison. Baseline and follow-up membership can differ.


``` r
f02_fits <- f02_results <- f02_support <- f02_events <- f02_checks <- list()
for (design in names(f02_designs)) for (outcome in c("gpa_z", "sh_prio")) {
  label <- paste(design, outcome, sep = "_")
  cells <- f02_designs[[design]]
  d <- as.data.frame(cells[is.finite(get(outcome)),
    list(cell_id, yr, G, region, y = get(outcome))])
  set.seed(20261018L + match(label, c("all_grades_gpa_z", "all_grades_sh_prio", "ninth_grade_gpa_z", "ninth_grade_sh_prio")))
  fit <- did::att_gt(yname = "y", tname = "yr", idname = "cell_id", gname = "G",
    data = d, control_group = "notyettreated", panel = TRUE, allow_unbalanced_panel = TRUE,
    base_period = "universal", anticipation = 0L, bstrap = TRUE, biters = 10000L,
    clustervars = "region", cband = FALSE, print_details = FALSE)
  agg <- did::aggte(fit, type = "simple", na.rm = TRUE)
  dyn <- did::aggte(fit, type = "dynamic", na.rm = TRUE, cband = FALSE)
  f02_fits[[label]] <- list(fit = fit, aggregate = agg, dynamic = dyn)
  # Replicate the package's group-mass construction from its processed data.
  dp <- fit$DIDparams
  mass_data <- if (dp$panel) dp$data[dp$data$yr == min(dp$tlist), ] else
    stats::aggregate(dp$data, list(dp$data$cell_id), mean)[, -1]
  k <- which(fit$group <= fit$t & is.finite(fit$att))
  masses <- vapply(fit$group[k], function(g) mean(mass_data$.w * (mass_data$G == g)), numeric(1))
  weights <- masses / sum(masses)
  stopifnot(abs(sum(weights) - 1) < 1e-10,
            abs(sum(weights * fit$att[k]) - agg$overall.att) < 1e-10)
  for (j in seq_along(k)) {
    i <- k[j]; g <- fit$group[i]; t <- fit$t[i]; b <- g - 1L
    tb <- cells[G == g & yr == b & is.finite(get(outcome))]
    tt <- cells[G == g & yr == t & is.finite(get(outcome))]
    cb <- cells[G > t & yr == b & is.finite(get(outcome))]
    ct <- cells[G > t & yr == t & is.finite(get(outcome))]
    manual <- mean(tt[[outcome]]) - mean(tb[[outcome]]) - mean(ct[[outcome]]) + mean(cb[[outcome]])
    stopifnot(abs(manual - fit$att[i]) < 1e-8)
    f02_support[[paste(label,g,t)]] <- data.frame(design, outcome, adoption_year = g,
      entry_year = t, baseline_year = b, event_time = t - g,
      treated_regions = paste(sort(unique(c(tb$region,tt$region))), collapse = ","),
      control_regions = paste(sort(unique(c(cb$region,ct$region))), collapse = ","),
      n_treated_regions = length(unique(c(tb$region,tt$region))),
      n_control_regions = length(unique(c(cb$region,ct$region))),
      treated_baseline_cells = nrow(tb), treated_followup_cells = nrow(tt),
      control_baseline_cells = nrow(cb), control_followup_cells = nrow(ct),
      treated_baseline_entrants = sum(tb$n_ent), treated_followup_entrants = sum(tt$n_ent),
      control_baseline_entrants = sum(cb$n_ent), control_followup_entrants = sum(ct$n_ent),
      treated_followup_missing_gpa = sum(tt$n_ent - tt$n_gpa),
      control_followup_missing_gpa = sum(ct$n_ent - ct$n_gpa),
      estimate = fit$att[i], se = fit$se[i], weight = weights[j], reconstruction_error = manual - fit$att[i])
  }
  scale <- if (outcome == "sh_prio") 100 else 1
  f02_results[[label]] <- data.frame(design, outcome, unit = if (scale == 100) "pp" else "SD",
    estimate = scale * agg$overall.att, se = scale * agg$overall.se,
    lower = scale * (agg$overall.att - qnorm(.975) * agg$overall.se),
    upper = scale * (agg$overall.att + qnorm(.975) * agg$overall.se),
    observed_cell_years = nrow(dp$data), schools_or_cells = length(unique(dp$data$cell_id)),
    last_supported_entry_year = max(fit$t[k]), supported_post_contrasts = length(k))
  f02_events[[label]] <- data.frame(design, outcome, event_time = dyn$egt,
    estimate = scale * dyn$att.egt, se = scale * dyn$se.egt,
    lower = scale * (dyn$att.egt - qnorm(.975) * dyn$se.egt),
    upper = scale * (dyn$att.egt + qnorm(.975) * dyn$se.egt))
}
f02_results <- do.call(rbind, f02_results)
f02_support <- do.call(rbind, f02_support)
f02_events <- do.call(rbind, f02_events)
# Published point estimates are checked at their displayed precision; bootstrap
# SEs use fresh recorded seeds and are not required to be byte-identical.
f02_checks <- data.frame(outcome = c("gpa_z", "sh_prio"),
  estimate = f02_results$estimate[f02_results$design == "all_grades"] / c(1,100),
  manuscript_display = c(-.149, .035))
f02_checks$matches <- round(f02_checks$estimate, 3) == f02_checks$manuscript_display
stopifnot(all(f02_checks$matches), all(is.finite(f02_results$se)))
write.csv(f02_results, file.path(output_dir, "f02_composition_effects.csv"), row.names = FALSE)
write.csv(f02_support, file.path(output_dir, "f02_composition_support.csv"), row.names = FALSE)
write.csv(f02_events, file.path(output_dir, "f02_composition_event_times.csv"), row.names = FALSE)
write.csv(f02_checks, file.path(output_dir, "f02_baseline_reproduction.csv"), row.names = FALSE)
f02_inference_audit <- f02_support[, c("design", "outcome", "adoption_year", "entry_year",
  "n_treated_regions", "n_control_regions", "se", "weight")]
f02_inference_audit$finite_bootstrap_se <- is.finite(f02_inference_audit$se)
write.csv(f02_inference_audit, file.path(output_dir, "f02_inference_diagnostics.csv"), row.names = FALSE)
knitr::kable(f02_results, digits = 4)
```



|                    |design      |outcome |unit | estimate|     se|   lower|   upper| observed_cell_years| schools_or_cells| last_supported_entry_year| supported_post_contrasts|
|:-------------------|:-----------|:-------|:----|--------:|------:|-------:|-------:|-------------------:|----------------:|-------------------------:|------------------------:|
|all_grades_gpa_z    |all_grades  |gpa_z   |SD   |  -0.1489| 0.0320| -0.2116| -0.0862|               57269|             7054|                      2020|                       10|
|all_grades_sh_prio  |all_grades  |sh_prio |pp   |   3.5040| 0.9157|  1.7092|  5.2987|               72490|             8819|                      2020|                       10|
|ninth_grade_gpa_z   |ninth_grade |gpa_z   |SD   |  -0.1360| 0.0629| -0.2592| -0.0128|                7594|             1025|                      2019|                        6|
|ninth_grade_sh_prio |ninth_grade |sh_prio |pp   |   4.4068| 2.3436| -0.1865|  9.0001|                7607|             1025|                      2019|                        6|

``` r
knitr::kable(f02_support[f02_support$design == "ninth_grade",
  c("outcome", "adoption_year", "entry_year", "treated_regions", "control_regions",
    "treated_followup_cells", "control_followup_cells", "weight")], digits = 4)
```



|                              |outcome | adoption_year| entry_year|treated_regions         |control_regions                     | treated_followup_cells| control_followup_cells| weight|
|:-----------------------------|:-------|-------------:|----------:|:-----------------------|:-----------------------------------|----------------------:|----------------------:|------:|
|ninth_grade_gpa_z 2017 2017   |gpa_z   |          2017|       2017|12                      |1,2,3,4,5,6,7,8,9,10,11,13,14,15,16 |                      9|                    943| 0.0103|
|ninth_grade_gpa_z 2017 2018   |gpa_z   |          2017|       2018|12                      |2,3,5,7,8,9,11,13,14,15,16          |                      9|                    769| 0.0103|
|ninth_grade_gpa_z 2017 2019   |gpa_z   |          2017|       2019|12                      |13                                  |                      9|                    349| 0.0103|
|ninth_grade_gpa_z 2018 2018   |gpa_z   |          2018|       2018|1,4,6,10                |2,3,5,7,8,9,11,13,14,15,16          |                    191|                    769| 0.2250|
|ninth_grade_gpa_z 2018 2019   |gpa_z   |          2018|       2019|1,4,6,10                |13                                  |                    191|                    349| 0.2250|
|ninth_grade_gpa_z 2019 2019   |gpa_z   |          2019|       2019|2,3,5,7,8,9,11,14,15,16 |13                                  |                    435|                    349| 0.5189|
|ninth_grade_sh_prio 2017 2017 |sh_prio |          2017|       2017|12                      |1,2,3,4,5,6,7,8,9,10,11,13,14,15,16 |                      9|                    948| 0.0103|
|ninth_grade_sh_prio 2017 2018 |sh_prio |          2017|       2018|12                      |2,3,5,7,8,9,11,13,14,15,16          |                      9|                    772| 0.0103|
|ninth_grade_sh_prio 2017 2019 |sh_prio |          2017|       2019|12                      |13                                  |                      9|                    349| 0.0103|
|ninth_grade_sh_prio 2018 2018 |sh_prio |          2018|       2018|1,4,6,10                |2,3,5,7,8,9,11,13,14,15,16          |                    191|                    772| 0.2250|
|ninth_grade_sh_prio 2018 2019 |sh_prio |          2018|       2019|1,4,6,10                |13                                  |                    191|                    349| 0.2250|
|ninth_grade_sh_prio 2019 2019 |sh_prio |          2019|       2019|2,3,5,7,8,9,11,14,15,16 |13                                  |                    435|                    349| 0.5189|

The support export also flags group-time effects for which the bootstrap returns
no usable SE. In particular, the 2017 adoption wave compared with the 2019
entering class has one treated region and one comparison region. Its estimate is
retained in the baseline aggregation, but we make no separate precision claim
for that contrast. The aggregate intervals are finite; finite intervals do not
remove the few-region inference concern.

### Comparable characteristics and pre-offer geographic support

The two finalized panels use different GPA standardizations. We recover the
annual affine conversion from students linked to the same ninth-grade entry in
both panels, require its maximum residual to be below 1e-8, and express applicant
GPA on the **composition panel's national prior-year GPA scale**. This changes
units only; no outcome is used to estimate the conversion. We retain separate
labels for entrant income measured in the entry year and applicant income
measured in the application year, and export their disagreement rate in linked
records. Entrants' descriptive means weight students equally, unlike the
school-cell and group-time weights of the composition ATT.

To align geographic and cohort coverage without selecting on actual attendance,
we use all recorded pre-lottery over-demanded choices, including automatically
added continuity options. An applicant is in the supported group if she has at
least one such choice and **every** such choice is in a region whose treated
ninth-grade entry cohort contributes to the composition estimates. This is a
conservative list-based definition, not the applicant's residence. It cannot
establish that her access changed because of SAE. Actual offers and attendance
are not used to define this group.


``` r
ninth_entrants <- s2[COD_NIVEL == 9L]
profile_panel <- data.table::as.data.table(data.table::copy(panel))
profile_panel[, ENTRY_YEAR := YEAR + 1L]
linked_profiles <- merge(ninth_entrants, profile_panel,
  by.x = c("MRUN", "AGNO"), by.y = c("MRUN", "ENTRY_YEAR"))
stopifnot(all(linked_profiles$RBD == linked_profiles$ENTRY_RBD))
gpa_conversion <- linked_profiles[complete.cases(PRIOR_GPA_Z, GPA8_Z), {
  m <- lm(PRIOR_GPA_Z ~ GPA8_Z)
  list(n_linked = .N, intercept = unname(coef(m)[1]), slope = unname(coef(m)[2]),
       maximum_residual = max(abs(resid(m))))
}, by = list(ENTRY_YEAR = AGNO)]
stopifnot(all(gpa_conversion$maximum_residual < 1e-8), all(gpa_conversion$slope > 0))
profile_panel <- merge(profile_panel, gpa_conversion, by = "ENTRY_YEAR", all.x = TRUE, sort = FALSE)
stopifnot(!anyNA(profile_panel$slope))
profile_panel[, GPA_COMPOSITION := intercept + slope * GPA8_Z]
measure_alignment <- linked_profiles[, list(n_linked = .N,
  income_status_disagreements = sum(PRIO != PRIORITARIO, na.rm = TRUE),
  entrant_income_mean = mean(PRIO, na.rm = TRUE),
  applicant_income_mean = mean(PRIORITARIO, na.rm = TRUE)), by = list(ENTRY_YEAR = AGNO)]
write.csv(gpa_conversion, file.path(output_dir, "f02_gpa_scale_conversion.csv"), row.names = FALSE)
write.csv(measure_alignment, file.path(output_dir, "f02_income_measure_alignment.csv"), row.names = FALSE)

support_gt <- unique(data.table::as.data.table(f02_support)[design == "ninth_grade",
  list(G = adoption_year, ENTRY_YEAR = entry_year)])
support_region_year <- merge(unique(region_school_map[, list(REGION, G)]), support_gt, by = "G", allow.cartesian = TRUE)
stopifnot(!any(support_region_year$REGION == 13L), max(support_region_year$ENTRY_YEAR) == 2019L)
raw_choices <- readRDS(upstream_paths[1])$c1
app_keys <- profile_panel[, list(proc = YEAR, mrun = MRUN)]
raw_choices <- raw_choices[app_keys, on = c("proc", "mrun"), nomatch = 0]
od_choices <- unique(raw_choices[rbd %in% od_schools, list(MRUN = mrun, YEAR = proc, RBD = rbd)])
od_choices <- merge(od_choices, region_school_map, by = "RBD", all.x = TRUE)
od_choices[, ENTRY_YEAR := YEAR + 1L]
od_choices[, in_supported_region_year := paste(REGION, ENTRY_YEAR) %in%
  paste(support_region_year$REGION, support_region_year$ENTRY_YEAR)]
choice_support <- od_choices[, list(n_od_choices_including_continuity = .N,
  all_choices_supported = all(in_supported_region_year),
  any_choice_supported = any(in_supported_region_year),
  n_choice_regions = data.table::uniqueN(REGION)), by = list(MRUN, YEAR)]
profile_panel <- merge(profile_panel, choice_support, by = c("MRUN", "YEAR"), all.x = TRUE, sort = FALSE)
profile_panel[is.na(all_choices_supported), `:=`(all_choices_supported = FALSE, any_choice_supported = FALSE)]
lottery_support_audit <- profile_panel[LOTTERY_SAMPLE == TRUE, list(n = .N,
  supported = sum(all_choices_supported),
  mixed_support = sum(any_choice_supported & !all_choices_supported),
  no_supported_choice = sum(!any_choice_supported),
  missing_od_choice_list = sum(is.na(n_od_choices_including_continuity))), by = ENTRY_YEAR]
write.csv(lottery_support_audit, file.path(output_dir, "f02_lottery_support_audit.csv"), row.names = FALSE)
knitr::kable(lottery_support_audit)
```



| ENTRY_YEAR|     n| supported| mixed_support| no_supported_choice| missing_od_choice_list|
|----------:|-----:|---------:|-------------:|-------------------:|----------------------:|
|       2017|   260|       260|             0|                   0|                      0|
|       2018|  9833|      9833|             0|                   0|                      0|
|       2019| 31535|     31535|             0|                   0|                      0|
|       2020| 48382|         0|             0|               48382|                      0|
|       2021| 42084|         0|             0|               42084|                      0|
|       2022| 44227|         0|             0|               44227|                      0|

``` r
rm(raw_choices, od_choices, app_keys, linked_profiles)
invisible(gc())
```

### Entrant, applicant, and complier profiles

Complier characteristics are estimated anew, rather than copied from the
existing appendix table, whose upstream weighting code is not in the handoff.
For each sample and characteristic X, let q_s be the observed offer frequency
within hundredth score group s, and let pi_s be the offered-minus-nonoffered
attendance difference. We estimate the complier mean as

\[
\widehat\mu_C(X)=
\frac{\sum_s n_s\{\overline{DX}_{1s}-\overline{DX}_{0s}\}}
     {\sum_s n_s\{\overline D_{1s}-\overline D_{0s}\}}.
\]

This is the score-stratified analogue of the complier-weighting argument in
[Abdulkadiroglu et al. (2017), p. 1402](https://economics.mit.edu/sites/default/files/publications/Abdulkadiroglu%20et.%20al.%202017%20-%20Research%20design%20meet.pdf).
It uses population shares and first stages rather than weighting each stratum by
its instrument variance. It requires conditional offer validity and monotone
attendance responses; it does not identify students individually as compliers.
Rounded-score conditioning remains an approximation. Characteristics are
predetermined, and no individual is selected on realized attendance. Groups
without both offer arms are reported as unsupported and excluded from this
profile estimator only. We use each characteristic's observed sample.

The influence-function SE below accounts for estimated within-group offer
frequencies, conditional means, and empirical group masses; observations are
independent as in the lottery baseline. A weighted fixed-effect IV reconstruction
checks the point estimate. The estimator and SE are explicitly specified here;
these are not a claimed reproduction of the existing complier table. Neither
these profile weights nor the composition weights equal the main covariate-
adjusted outcome 2SLS weights in general.


``` r
f02_profile_rows <- list()
f02_profile_overlap <- list()
profile_samples <- list(full = profile_panel[LOTTERY_SAMPLE == TRUE],
                        supported = profile_panel[LOTTERY_SAMPLE == TRUE & all_choices_supported == TRUE])
for (scope in names(profile_samples)) for (v in c("GPA_COMPOSITION", "PRIORITARIO")) {
  d <- data.table::copy(profile_samples[[scope]][!is.na(get(v))])
  d[, X_PROFILE := get(v)]
  d[, DX := D_OD * X_PROFILE]
  means <- d[, list(ns = .N, q = mean(OFFER),
    d1 = mean(D_OD[OFFER == 1]), d0 = mean(D_OD[OFFER == 0]),
    dx1 = mean(DX[OFFER == 1]), dx0 = mean(DX[OFFER == 0])), by = CHANCE_GROUP]
  supported_means <- means[q > 0 & q < 1]
  f02_profile_overlap[[paste(scope,v)]] <- data.frame(scope, characteristic = v,
    chance_group = means$CHANCE_GROUP, n = means$ns, offer_frequency = means$q,
    included = means$q > 0 & means$q < 1)
  keep <- d$CHANCE_GROUP %in% supported_means$CHANCE_GROUP
  n_dropped <- sum(!keep)
  d <- merge(d[keep], supported_means, by = "CHANCE_GROUP", all.x = TRUE, sort = FALSE)
  first_stage <- sum(supported_means$ns * (supported_means$d1 - supported_means$d0)) / nrow(d)
  numerator <- sum(supported_means$ns * (supported_means$dx1 - supported_means$dx0)) / nrow(d)
  stopifnot(first_stage > 0)
  mu <- numerator / first_stage
  d[, psi_num := dx1 - dx0 + OFFER / q * (DX - dx1) - (1 - OFFER) / (1 - q) * (DX - dx0)]
  d[, psi_den := d1 - d0 + OFFER / q * (D_OD - d1) - (1 - OFFER) / (1 - q) * (D_OD - d0)]
  influence <- (d$psi_num - mu * d$psi_den) / first_stage
  se_mu <- sqrt(sum(influence^2)) / nrow(d)
  d[, iv_weight := 1 / (q * (1 - q))]
  check_iv <- feols(DX ~ 1 | CHANCE_GROUP | D_OD ~ OFFER, d,
    weights = ~iv_weight, vcov = "hetero", ssc = iv_ssc, fixef.rm = "none")
  stopifnot(abs(unname(coef(check_iv)[1]) - mu) < 1e-8, abs(mean(influence)) < 1e-8)
  scale <- if (v == "PRIORITARIO") 100 else 1
  f02_profile_rows[[paste(scope,v,"applicants")]] <- data.frame(scope, population = "Lottery applicants",
    characteristic = v, n = nrow(d), excluded_no_offer_overlap = n_dropped,
    mean = scale * mean(d$X_PROFILE), se = NA_real_, lower = NA_real_, upper = NA_real_,
    implied_complier_share = first_stage)
  f02_profile_rows[[paste(scope,v,"compliers")]] <- data.frame(scope, population = "Estimated complier profile",
    characteristic = v, n = nrow(d), excluded_no_offer_overlap = n_dropped,
    mean = scale * mu, se = scale * se_mu,
    lower = scale * (mu - qnorm(.975) * se_mu), upper = scale * (mu + qnorm(.975) * se_mu),
    implied_complier_share = first_stage)
}
entrant_sets <- list(
  full = ninth_entrants[AGNO >= DOOR + 1L & AGNO <= 2022L],
  supported = ninth_entrants[paste(REGION, AGNO) %in% paste(support_region_year$REGION, support_region_year$ENTRY_YEAR)])
for (scope in names(entrant_sets)) for (v in c("PRIOR_GPA_Z", "PRIO")) {
  x <- entrant_sets[[scope]][[v]]; x <- x[!is.na(x)]
  f02_profile_rows[[paste(scope,v,"entrants")]] <- data.frame(scope, population = "Ninth-grade entrants",
    characteristic = if (v == "PRIO") "PRIORITARIO" else "GPA_COMPOSITION", n = length(x),
    excluded_no_offer_overlap = NA_integer_, mean = mean(x) * if (v == "PRIO") 100 else 1,
    se = NA_real_, lower = NA_real_, upper = NA_real_, implied_complier_share = NA_real_)
}
f02_profiles <- do.call(rbind, f02_profile_rows)
write.csv(f02_profiles, file.path(output_dir, "f02_population_profiles.csv"), row.names = FALSE)
write.csv(do.call(rbind, f02_profile_overlap), file.path(output_dir, "f02_profile_score_support.csv"), row.names = FALSE)
knitr::kable(f02_profiles, digits = 4)
```



|                                     |scope     |population                 |characteristic  |      n| excluded_no_offer_overlap|    mean|     se|   lower|   upper| implied_complier_share|
|:------------------------------------|:---------|:--------------------------|:---------------|------:|-------------------------:|-------:|------:|-------:|-------:|----------------------:|
|full GPA_COMPOSITION applicants      |full      |Lottery applicants         |GPA_COMPOSITION | 175869|                         0| -0.1006|     NA|      NA|      NA|                 0.6078|
|full GPA_COMPOSITION compliers       |full      |Estimated complier profile |GPA_COMPOSITION | 175869|                         0| -0.0999| 0.0192| -0.1376| -0.0622|                 0.6078|
|full PRIORITARIO applicants          |full      |Lottery applicants         |PRIORITARIO     | 176321|                         0| 56.9671|     NA|      NA|      NA|                 0.6074|
|full PRIORITARIO compliers           |full      |Estimated complier profile |PRIORITARIO     | 176321|                         0| 58.9094| 1.2229| 56.5125| 61.3063|                 0.6074|
|supported GPA_COMPOSITION applicants |supported |Lottery applicants         |GPA_COMPOSITION |  41062|                       477| -0.0165|     NA|      NA|      NA|                 0.5953|
|supported GPA_COMPOSITION compliers  |supported |Estimated complier profile |GPA_COMPOSITION |  41062|                       477| -0.1118| 0.0160| -0.1431| -0.0804|                 0.5953|
|supported PRIORITARIO applicants     |supported |Lottery applicants         |PRIORITARIO     |  41147|                       481| 57.3408|     NA|      NA|      NA|                 0.5954|
|supported PRIORITARIO compliers      |supported |Estimated complier profile |PRIORITARIO     |  41147|                       481| 62.4876| 1.0453| 60.4388| 64.5363|                 0.5954|
|full PRIOR_GPA_Z entrants            |full      |Ninth-grade entrants       |GPA_COMPOSITION | 104535|                        NA| -0.0439|     NA|      NA|      NA|                     NA|
|full PRIO entrants                   |full      |Ninth-grade entrants       |PRIORITARIO     | 106627|                        NA| 53.4958|     NA|      NA|      NA|                     NA|
|supported PRIOR_GPA_Z entrants       |supported |Ninth-grade entrants       |GPA_COMPOSITION |  26064|                        NA|  0.0375|     NA|      NA|      NA|                     NA|
|supported PRIO entrants              |supported |Ninth-grade entrants       |PRIORITARIO     |  26581|                        NA| 53.3238|     NA|      NA|      NA|                     NA|

The supported entrant cohort includes all entrants, whereas lottery applicants
must satisfy the original eighth-grade enrollment and application-history rules
and have nondeterministic offers. Complier profiles are inferred under the
lottery assumptions. The composition design still measures a change in the
composition of entrants, not a change in each subgroup's admission probability.
Similarities between entrant changes and complier characteristics are descriptive
connections, not evidence that the students gaining access under SAE are lottery
compliers. No composition estimate is multiplied by an attendance LATE.

### Results and proposed interpretation



The ninth-grade composition effect is **-0.136 SD**
for prior GPA, with a pointwise 95% interval of
[-0.259, -0.013], and
**4.41 pp** for the low-income share, with an
interval of [-0.19,
9.00]. Both point estimates have the same
direction as the all-grade baseline. The low-income interval includes zero;
the restricted analysis does not reproduce the baseline's precision. It also
changes the supported regions, entry years, and aggregation weights.

There are 41,628
lottery applicants in the supported region-cohort window before profile-specific
missingness and overlap restrictions, compared with
26,581 observed ninth-grade
entrants. On the common GPA scale, the entrant mean is
0.037 SD, the
lottery-applicant mean is
-0.017 SD, and the
estimated complier mean is
-0.112 SD.
The respective low-income shares are
53.32%,
57.34%, and
62.49%.
Applicant and complier means use the same characteristic-specific overlap
sample; the score-support CSV identifies every omitted group. Income dates
differ as documented above.

These results connect the direction of the composition changes with the
observable characteristics of the lottery population. They neither identify
the reform's marginal entrants nor transport the attendance effect to them.
The author approved appendix tables reporting the ninth-grade estimates and
aligned profiles. The chunk below generates these tables for inclusion in the
access appendix. A main-text reference after the composition robustness
discussion remains under author review; no new estimand table or rollout
regression on college outcomes is proposed.

### Standalone appendix tables

The following exports contain complete table environments and follow the
manuscript's booktabs, spacing, and notes conventions. They are written here;
copying them into the manuscript is a separate, author-authorized step. The
main-text paragraph remains under discussion.


``` r
f02_num <- function(x, digits) sprintf(paste0("%.", digits, "f"), x)
f02_int <- function(x) format(x, big.mark = ",", scientific = FALSE, trim = TRUE)
f02_row <- function(label, cells) paste0(label, " & ", paste(cells, collapse = " & "), " \\\\\n")
f02_float <- function(caption, label, alignment, body, note) paste0(
  "% Generated by analysis_for_adversarial_report.Rmd; do not edit numerical cells.\n",
  "\\begin{table}[!htbp]\n\\singlespacing\\renewcommand{\\arraystretch}{1.2}\n\\centering\n",
  "\\caption{", caption, "}\\label{", label, "}\n\\small\n",
  "\\begin{tabular*}{\\textwidth}{@{\\extracolsep{\\fill}}", alignment, "@{}}\n",
  "\\toprule\n", body, "\\bottomrule\n\\end{tabular*}\n\\par\\smallskip\n",
  "\\begin{minipage}{\\textwidth}\\footnotesize\nNotes: ", note,
  "\n\\end{minipage}\n\\end{table}")
composition_body <- paste0(
  f02_row("Specification", c("\\shortstack{Prior-year GPA\\\\(SD)}", "\\shortstack{Low-income share\\\\(pp)}")),
  f02_row("", c("(1)", "(2)")), "\\midrule\n")
for (design in c("all_grades", "ninth_grade")) {
  r <- f02_results[f02_results$design == design, ]
  r <- r[match(c("gpa_z", "sh_prio"), r$outcome), ]
  digits <- c(3L, 2L)
  cells <- function(column) mapply(f02_num, r[[column]], digits, USE.NAMES = FALSE)
  composition_body <- paste0(composition_body,
    f02_row(if (design == "all_grades") "All grades" else "Ninth grade", cells("estimate")),
    f02_row("", paste0("(", cells("se"), ")")),
    f02_row("95\\% confidence interval", paste0("[", cells("lower"), ", ", cells("upper"), "]")),
    f02_row("School-grade-years", f02_int(r$observed_cell_years)),
    if (design == "all_grades") "\\midrule\n" else "")
}
composition_note <- paste0(
  "The outcomes and estimator follow Table~\\ref{tab: alloc headline}. ",
  "The ninth-grade specification restricts the sample to ninth-grade entrants. ",
  "Both specifications use not-yet-treated school-grades, a universal pre-adoption base period, ",
  "no additional covariates, and the unbalanced-panel estimator described in Appendix~\\ref{app:access}. ",
  "Within comparisons, school-grade cells receive equal weight; group-time effects are aggregated by adoption-group size. ",
  "The all-grade and ninth-grade estimates cover supported post-adoption entering classes in 2017--2020 and 2017--2019, respectively. ",
  "For ninth grade, the Metropolitan Region supplies comparisons but has no identified post-adoption effect. ",
  "Observation counts include pre-adoption years from 2012. Region-clustered SE from 10,000 multiplier-bootstrap draws ",
  "are in parentheses; brackets report pointwise 95\\% intervals. All-grade point estimates reproduce the main table; ",
  "SE are recomputed with fresh draws. No permutation-test significance stars are reported. ",
  "The small number of regions remains a limitation for inference.")
writeLines(f02_float("Entering-Class Composition at Ninth-Grade Entry", "tab: ninth grade composition",
  "p{0.46\\textwidth}cc", composition_body, composition_note),
  file.path(output_dir, "appendix_ninth_grade_composition.tex"))

profile_order <- c("Estimated complier profile", "Lottery applicants", "Ninth-grade entrants")
profile_body <- paste0(f02_row("", c("\\shortstack{Students whose\\\\attendance depends\\\\on the offer}",
  "\\shortstack{Lottery\\\\applicants}", "\\shortstack{Ninth-grade\\\\entrants}")),
  f02_row("", c("(1)", "(2)", "(3)")), "\\midrule\n")
for (v in c("GPA_COMPOSITION", "PRIORITARIO")) {
  r <- f02_profiles[f02_profiles$scope == "supported" & f02_profiles$characteristic == v, ]
  r <- r[match(profile_order, r$population), ]
  digits <- if (v == "GPA_COMPOSITION") 3L else 2L
  profile_body <- paste0(profile_body,
    f02_row(if (v == "GPA_COMPOSITION") "Prior-year GPA (SD)" else "Low-income (\\%)", f02_num(r$mean, digits)),
    f02_row("", c(paste0("(", f02_num(r$se[1], digits), ")"), "", "")))
}
profile_body <- paste0(profile_body, "\\midrule\n")
for (v in c("GPA_COMPOSITION", "PRIORITARIO")) {
  r <- f02_profiles[f02_profiles$scope == "supported" & f02_profiles$characteristic == v, ]
  r <- r[match(profile_order, r$population), ]
  profile_body <- paste0(profile_body, f02_row(if (v == "GPA_COMPOSITION") "$N$, GPA" else "$N$, low-income", f02_int(r$n)))
}
excluded_profile <- function(v) f02_profiles$excluded_no_offer_overlap[
  f02_profiles$scope == "supported" & f02_profiles$population == "Lottery applicants" & f02_profiles$characteristic == v]
profile_note <- paste0(
  "The samples cover the regions and 2017--2019 entering cohorts contributing treated observations to ",
  "Table~\\ref{tab: ninth grade composition}. Lottery applicants are retained when every over-demanded school ",
  "on their pre-lottery list, including automatic continuity options, belongs to a supported region-cohort. ",
  "No restriction uses the realized offer or school attended. Columns (1) and (2) use the same observed-characteristic ",
  "sample and retain hundredth propensity-score groups containing both offer arms; this excludes ",
  f02_int(excluded_profile("GPA_COMPOSITION")), " applicants for GPA and ",
  f02_int(excluded_profile("PRIORITARIO")), " for income after removing missing characteristics. ",
  "Column (1) uses the complier-profile estimator described in Appendix~\\ref{app:ninth-grade-composition}; ",
  "heteroskedasticity-robust influence-function SE are in parentheses. Its $N$ is the estimation sample size, ",
  "not a count of identified compliers. Columns (2) and (3) are student-weighted means. ",
  "GPA is on the composition analysis's national prior-year scale; the lottery measure is converted using exact ",
  "year-specific affine relationships in linked records. Low-income status is measured in the application year ",
  "for applicants and compliers, and the entry year for entrants. ",
  "These profiles describe different populations and do not identify the students whose access changed under SAE.")
writeLines(f02_float("Entrants and Lottery Compliers in the Supported Ninth-Grade Cohorts",
  "tab: ninth grade profiles", "p{0.30\\textwidth}ccc", profile_body, profile_note),
  file.path(output_dir, "appendix_ninth_grade_profiles.tex"))
```

## Environment

The local package versions need not match the handoff's Windows environment.
The numerical reproduction checks above establish whether the existing results
match at the precision reported in the current tables.


``` r
recorded <- read.csv("finalized_design_v1/environment/package_versions.csv", stringsAsFactors = FALSE)
runtime_versions <- data.frame(package = c("R", "fixest", "knitr", "rmarkdown", "data.table", "did", "DRDID"),
                              version = c(as.character(getRversion()),
                                          vapply(c("fixest", "knitr", "rmarkdown", "data.table", "did", "DRDID"),
                                                 function(p) as.character(packageVersion(p)), character(1))))
runtime_versions$handoff_version <- recorded$Version[match(runtime_versions$package, recorded$Package)]
write.csv(runtime_versions, file.path(output_dir, "runtime_versions.csv"), row.names = FALSE)
knitr::kable(runtime_versions)
```



|           |package    |version  |handoff_version |
|:----------|:----------|:--------|:---------------|
|           |R          |4.5.1    |NA              |
|fixest     |fixest     |0.13.2   |0.14.2          |
|knitr      |knitr      |1.50     |1.51            |
|rmarkdown  |rmarkdown  |2.30     |NA              |
|data.table |data.table |1.18.2.1 |1.18.4          |
|did        |did        |2.1.2    |2.1.2           |
|DRDID      |DRDID      |1.2.3    |1.3.0           |

``` r
sessionInfo()
```

```
## R version 4.5.1 (2025-06-13)
## Platform: aarch64-apple-darwin20
## Running under: macOS Tahoe 26.3
## 
## Matrix products: default
## BLAS:   /Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib 
## LAPACK: /Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.1
## 
## locale:
## [1] C.UTF-8/C.UTF-8/C.UTF-8/C/C.UTF-8/C.UTF-8
## 
## time zone: America/Indiana/Indianapolis
## tzcode source: internal
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] fixest_0.13.2
## 
## loaded via a namespace (and not attached):
##  [1] tidyselect_1.2.1     timeDate_4051.111    dplyr_1.2.1         
##  [4] farver_2.1.2         S7_0.2.1             fastmap_1.2.0       
##  [7] pROC_1.19.0.1        DRDID_1.2.3          caret_7.0-1         
## [10] digest_0.6.37        rpart_4.1.24         timechange_0.4.0    
## [13] lifecycle_1.0.5      dreamerr_1.5.0       survival_3.8-3      
## [16] magrittr_2.0.3       compiler_4.5.1       rlang_1.3.0         
## [19] sass_0.4.10          tools_4.5.1          yaml_2.3.10         
## [22] data.table_1.18.2.1  knitr_1.50           ggsignif_0.6.4      
## [25] plyr_1.8.9           RColorBrewer_1.1-3   abind_1.4-8         
## [28] withr_3.0.2          purrr_1.1.0          numDeriv_2016.8-1.1 
## [31] nnet_7.3-20          grid_4.5.1           stats4_4.5.1        
## [34] ggpubr_1.0.0         future_1.70.0        ggplot2_4.0.1       
## [37] BMisc_1.4.8          globals_0.19.1       scales_1.4.0        
## [40] iterators_1.0.14     MASS_7.3-65          cli_3.6.5           
## [43] rmarkdown_2.30       generics_0.1.4       bigmemory.sri_0.1.8 
## [46] future.apply_1.20.2  reshape2_1.4.5       cachem_1.1.0        
## [49] stringr_1.5.1        splines_4.5.1        parallel_4.5.1      
## [52] fastglm_0.0.4        stringmagic_1.2.0    vctrs_0.7.3         
## [55] hardhat_1.4.3        Matrix_1.7-3         sandwich_3.1-1      
## [58] carData_3.0-5        jsonlite_2.0.0       car_3.1-3           
## [61] did_2.1.2            rstatix_1.1.0        Formula_1.2-5       
## [64] listenv_0.10.1       trust_0.1-9          foreach_1.5.2       
## [67] gower_1.0.2          jquerylib_0.1.4      tidyr_1.3.2         
## [70] recipes_1.3.2        bigmemory_4.6.4      glue_1.8.0          
## [73] parallelly_1.46.1    codetools_0.2-20     lubridate_1.9.5     
## [76] stringi_1.8.7        gtable_0.3.6         tibble_3.3.0        
## [79] pillar_1.11.1        htmltools_0.5.8.1    ipred_0.9-15        
## [82] lava_1.9.0           R6_2.6.1             evaluate_1.0.4      
## [85] lattice_0.22-7       backports_1.5.0      broom_1.0.11        
## [88] bslib_0.9.0          class_7.3-23         uuid_1.2-2          
## [91] Rcpp_1.1.0           nlme_3.1-168         prodlim_2026.03.11  
## [94] xfun_0.52            zoo_1.8-14           pkgconfig_2.0.3     
## [97] ModelMetrics_1.2.2.2
```
