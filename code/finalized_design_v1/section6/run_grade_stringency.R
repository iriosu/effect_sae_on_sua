#!/usr/bin/env Rscript
# Reproduce the historical grading index and the additional Table V, Panel C row.
# See README.md for inputs, construction, diagnostics, and publication commands.
suppressPackageStartupMessages({ library(data.table); library(fixest) })
setDTthreads(4L)
argv <- commandArgs(trailingOnly = TRUE)
option <- function(name, default) {
  hit <- argv[startsWith(argv, paste0("--", name, "="))]
  if (length(hit) > 1L) stop("Repeated option: ", name)
  if (length(hit)) substring(hit, nchar(name) + 4L) else default
}
script_arg <- grep("^--file=", commandArgs(), value = TRUE)
script_path <- gsub("~+~", " ", sub("^--file=", "", script_arg[[1L]]), fixed = TRUE)
script_dir <- dirname(normalizePath(script_path, mustWork = TRUE))
user_root <- if (nzchar(Sys.getenv("USERPROFILE"))) Sys.getenv("USERPROFILE") else path.expand("~")
data_root <- option("data-dir", file.path(user_root, "Dropbox", "Effect SAE on SUA", "data"))
panel_file <- option("panel", file.path(data_root, "finalized_design_v1", "section5", "section5_panel.rds"))
schools_file <- option("schools", file.path(data_root, "finalized_design_v1", "section5", "table_a3_panel.rds"))
cache_dir <- option("cache-dir", file.path(data_root, "finalized_design_v1", "section6", "grade_stringency"))
output_dir <- option("output-dir", file.path(script_dir, "output", "grade_stringency"))
manuscript <- option("manuscript", "")
dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
source(file.path(script_dir, "fit_grade_stringency.R"))
source(file.path(script_dir, "export_grade_stringency.R"))
controls <- c("GPA8_Z", "ES_MUJER", "PRIORITARIO", "ALTO", "ORIGIN_OD")
regular_secondary <- c(310L, 410L, 510L, 610L, 710L, 810L, 910L)
raw_files <- file.path(data_root, c("panel_simce_2m.rds", "panel_performance_2002_2023.rds"))
directory_file <- file.path(data_root, "panel_ee_2004_2025_homogenized.rds")
all_inputs <- c(raw_files, directory_file, panel_file, schools_file)
if (any(!file.exists(all_inputs)) || any(file.info(all_inputs)$size == 0)) {
  stop("Missing or online-only input. Download the source files before running: ",
       paste(all_inputs[!file.exists(all_inputs) | file.info(all_inputs)$size == 0], collapse = "; "))
}
manifest <- data.table(file = basename(all_inputs), path = normalizePath(all_inputs),
                       bytes = file.info(all_inputs)$size,
                       md5 = unname(tools::md5sum(all_inputs)))
fwrite(manifest, file.path(output_dir, "input_manifest.csv"))
# A cache is reusable only with the source hashes recorded by the preparation.
prep_manifest <- file.path(cache_dir, "input_manifest.csv")
prep_hash_file <- file.path(cache_dir, "preparation_code_md5.txt")
prep_hash <- unname(tools::md5sum(file.path(script_dir, "prepare_grade_stringency.R")))
cache_valid <- file.exists(prep_manifest) &&
  file.exists(prep_hash_file) && identical(readLines(prep_hash_file), prep_hash) &&
  all(file.exists(file.path(cache_dir, c("calibration_candidates.rds",
                                        "school_year_dependencies_2012_2023.rds", "audit.csv"))))
if (cache_valid) {
  old <- fread(prep_manifest)
  fresh <- manifest[match(old$file, file), md5]
  cache_valid <- nrow(old) == 2L && !anyNA(fresh) && identical(old$md5, fresh)
}
if (!cache_valid) {
  status <- system2(file.path(R.home("bin"), "Rscript"),
    c("--vanilla", shQuote(file.path(script_dir, "prepare_grade_stringency.R")),
      shQuote(data_root), shQuote(cache_dir)))
  if (status != 0L) stop("Historical calibration preparation failed.")
}
invisible(file.copy(file.path(cache_dir, "audit.csv"), file.path(output_dir, "merge_audit.csv"), overwrite = TRUE))
d_all <- as.data.table(readRDS(file.path(cache_dir, "calibration_candidates.rds")))
dependency <- as.data.table(readRDS(file.path(cache_dir, "school_year_dependencies_2012_2023.rds")))
directory <- as.data.table(readRDS(directory_file))
stopifnot(all(c("year", "rbd", "cod_depe") %in% names(directory)),
          all(2024:2025 %in% directory$year))
# Use both historical student records and the directory through 2025. A school
# observed as fee-paying private anywhere in 2012-2025 cannot enter this public
# school calibration, including schools that later switch funding status.
ever_private <- unique(c(dependency[COD_DEPE == 4L, RBD],
  directory[year >= 2012 & year <= 2025 & cod_depe == 4L, rbd]))
d_public <- d_all[COD_DEPE %in% c(1L, 2L, 3L, 5L, 6L) & !RBD %in% ever_private]
school_counts <- d_public[, .(n = .N, n_years = uniqueN(AGNO)), by = RBD]
school_counts[, retained := n >= 20L & n_years >= 2L]
d <- d_public[RBD %in% school_counts[retained == TRUE, RBD]]
stopifnot(nrow(d) > 0, !anyDuplicated(d, by = c("MRUN", "AGNO")),
          all(d$AGNO %in% 2014:2016), all(d$COD_GRADO == 2L))
selection <- rbindlist(list(
  data.table(stage = "Matched valid GPA and both SIMCE scores", students = nrow(d_all), schools = uniqueN(d_all$RBD)),
  data.table(stage = "Stable publicly funded schools", students = nrow(d_public), schools = uniqueN(d_public$RBD)),
  data.table(stage = "At least 20 students and two cohorts", students = nrow(d), schools = uniqueN(d$RBD))))
fwrite(selection, file.path(output_dir, "calibration_selection.csv"))
fwrite(d[, .(students = .N, schools = uniqueN(RBD), failed = sum(SIT_FIN_R == "R"),
             mean_gpa = mean(PROM_GRAL)), by = AGNO], file.path(output_dir, "calibration_by_year.csv"))
panel <- as.data.table(readRDS(panel_file))
stopifnot(!anyDuplicated(panel$MRUN), all(controls %in% names(panel)))
panel <- panel[LOTTERY_SAMPLE == TRUE & complete.cases(panel[, ..controls])]
stopifnot(nrow(panel) == 175869L, length(intersect(d$MRUN, panel$MRUN)) == 0L)
school_catalogue <- as.data.table(readRDS(schools_file))
stopifnot(!anyDuplicated(school_catalogue$RBD))
od_ids <- school_catalogue[IS_OD == TRUE, RBD]
stopifnot(length(od_ids) == 1045L)
d[, over_demanded := RBD %in% od_ids]
fwrite(d[, .(students = .N, schools = uniqueN(RBD),
  math_p05 = quantile(math, .05), math_p50 = median(math), math_p95 = quantile(math, .95),
  reading_p05 = quantile(reading, .05), reading_p50 = median(reading), reading_p95 = quantile(reading, .95)),
  by = .(AGNO, over_demanded)], file.path(output_dir, "historical_score_support.csv"))

verification <- verify_grade_stringency_covariance()
message("Estimating historical school grading effects")
baseline <- fit_grade_stringency(d)
stopifnot(baseline$metadata$largest_absolute_school_mean_residual < 1e-7,
          baseline$metadata$tau2 > 0)
saveRDS(baseline, file.path(cache_dir, "grade_stringency_fit.rds"))
fwrite(baseline$schools, file.path(output_dir, "school_stringency.csv"))
panel[baseline$schools, on = .(ENTRY_RBD = RBD),
      `:=`(GRADE_STRINGENCY = i.GRADE_STRINGENCY,
           GRADE_STRINGENCY_UNSHRUNK = i.GRADE_STRINGENCY_UNSHRUNK)]
panel[, HAS_STRINGENCY := as.integer(!is.na(GRADE_STRINGENCY))]
fwrite(panel[, .(n = .N, observed = sum(HAS_STRINGENCY), share = mean(HAS_STRINGENCY)),
             by = .(YEAR, OFFER, D_OD)], file.path(output_dir, "lottery_coverage.csv"))
fwrite(panel[, .(n = .N, observed = sum(HAS_STRINGENCY), share = mean(HAS_STRINGENCY)),
             by = ENTRY_SCHOOL_TYPE], file.path(output_dir, "coverage_by_destination_type.csv"))
iv_result <- function(variable, label, sample = panel) {
  dd <- sample[!is.na(get(variable))]
  f <- as.formula(paste(variable, "~", paste(controls, collapse = " + "),
    "+ i(YEAR, ref = 2016) | CHANCE_GROUP | D_OD ~ OFFER"))
  fit <- feols(f, dd, vcov = "hetero", ssc = ssc(K.adj = FALSE),
               fixef.rm = "none", notes = FALSE)
  stopifnot(nobs(fit) == nrow(dd))
  b <- coef(fit)[["fit_D_OD"]]; s <- se(fit)[["fit_D_OD"]]
  data.table(specification = label, mean = dd[OFFER == 0, mean(get(variable))],
    est = b, se = s, p = 2 * pnorm(-abs(b / s)), n = nrow(dd),
    n_nooffer = dd[OFFER == 0, .N], lower = b - qnorm(.975) * s,
    upper = b + qnorm(.975) * s)
}
main <- iv_result("GRADE_STRINGENCY", "Baseline: shrunk historical school effects")
estimates <- rbind(main, iv_result("GRADE_STRINGENCY_UNSHRUNK", "Unshrunk historical school effects"))
availability <- feols(HAS_STRINGENCY ~ OFFER + GPA8_Z + ES_MUJER + PRIORITARIO + ALTO +
  ORIGIN_OD + i(YEAR, ref = 2016) | CHANCE_GROUP, panel, vcov = "hetero",
  fixef.rm = "none", notes = FALSE)
availability_result <- data.table(outcome = "Stringency observed", n = nobs(availability),
  mean_nooffer = panel[OFFER == 0, mean(HAS_STRINGENCY)],
  offer_effect = coef(availability)[["OFFER"]], se = se(availability)[["OFFER"]],
  p = pvalue(availability)[["OFFER"]])
fwrite(availability_result, file.path(output_dir, "availability_effect.csv"))

message("Checking leave-one-cohort-out stability")
stability <- list()
for (excluded_year in 2014:2016) {
  dd <- d[AGNO != excluded_year]
  counts <- dd[, .N, by = RBD]
  dd <- dd[RBD %in% counts[N >= 2L, RBD]]
  fit <- fit_grade_stringency(dd)
  name <- paste0("STRINGENCY_EXCLUDING_", excluded_year)
  lookup <- fit$schools[, .(RBD, value = GRADE_STRINGENCY)]
  panel[lookup, on = .(ENTRY_RBD = RBD), (name) := i.value]
  common <- merge(baseline$schools[, .(RBD, pooled = GRADE_STRINGENCY)], lookup, by = "RBD")
  stability[[as.character(excluded_year)]] <- data.table(excluded_year, schools = nrow(common),
    pearson = cor(common$pooled, common$value), spearman = cor(common$pooled, common$value, method = "spearman"))
  saveRDS(fit, file.path(cache_dir, paste0("fit_excluding_", excluded_year, ".rds")))
}
loo_columns <- paste0("STRINGENCY_EXCLUDING_", 2014:2016)
common_panel <- panel[complete.cases(panel[, c("GRADE_STRINGENCY", loo_columns), with = FALSE])]
estimates <- rbind(estimates, iv_result("GRADE_STRINGENCY", "Baseline on common cohort-sensitivity coverage", common_panel))
for (yr in 2014:2016) estimates <- rbind(estimates,
  iv_result(paste0("STRINGENCY_EXCLUDING_", yr), paste("Exclude historical cohort", yr), common_panel))
fwrite(rbindlist(stability), file.path(output_dir, "cohort_stability.csv"))

# Refit on a score region with observations from both school groups in each
# historical year. No full-sample effect is used to select the restriction.
support <- copy(d)
support[, math_cell := pmin(5L, as.integer(ceiling(frank(math, ties.method = "average") / .N * 5))), by = AGNO]
support[, reading_cell := pmin(5L, as.integer(ceiling(frank(reading, ties.method = "average") / .N * 5))), by = AGNO]
cells <- support[, .(n = .N), by = .(AGNO, math_cell, reading_cell, over_demanded)]
keep_cells <- cells[, .(both_groups = uniqueN(over_demanded) == 2L,
                       minimum_group_n = min(n)), by = .(AGNO, math_cell, reading_cell)]
keep_cells <- keep_cells[both_groups == TRUE & minimum_group_n >= 20L]
support <- support[keep_cells, on = .(AGNO, math_cell, reading_cell), nomatch = 0]
counts <- support[, .(n = .N, n_years = uniqueN(AGNO)), by = RBD]
support <- support[RBD %in% counts[n >= 20L & n_years >= 2L, RBD]]
supported_fit <- fit_grade_stringency(support)
lookup <- supported_fit$schools[, .(RBD, value = GRADE_STRINGENCY)]
panel[lookup, on = .(ENTRY_RBD = RBD), STRINGENCY_COMMON_SUPPORT := i.value]
common_support_panel <- panel[!is.na(STRINGENCY_COMMON_SUPPORT) & !is.na(GRADE_STRINGENCY)]
estimates <- rbind(estimates,
  iv_result("GRADE_STRINGENCY", "Baseline on common-support school coverage", common_support_panel),
  iv_result("STRINGENCY_COMMON_SUPPORT", "Common math-reading support calibration", common_support_panel))
saveRDS(supported_fit, file.path(cache_dir, "fit_common_score_support.rds"))
fwrite(cells, file.path(output_dir, "score_support_cells.csv"))
fwrite(data.table(calibration_n = nrow(support), schools = uniqueN(support$RBD),
                 retained_cells = nrow(keep_cells)), file.path(output_dir, "score_support_selection.csv"))
fwrite(estimates, file.path(output_dir, "stringency_estimates.csv"))
saveRDS(panel[, c("MRUN", "YEAR", "ENTRY_RBD", "HAS_STRINGENCY", "GRADE_STRINGENCY",
                  "GRADE_STRINGENCY_UNSHRUNK", loo_columns, "STRINGENCY_COMMON_SUPPORT"), with = FALSE],
        file.path(cache_dir, "lottery_stringency_link.rds"))
saveRDS(list(historical = baseline$metadata, covariance_verification = verification,
            availability = availability_result, estimates = estimates,
            selection = selection, input_manifest = manifest), file.path(cache_dir, "analysis_metadata.rds"))

number <- function(x, digits = 0L) formatC(x, digits = digits, format = "f", big.mark = ",")
facts <- c(
  GSCalibrationN = number(nrow(d)), GSSchoolN = number(uniqueN(d$RBD)),
  GSFailureN = number(sum(d$SIT_FIN_R == "R")), GSLotteryN = number(nrow(panel)),
  GSObservedN = number(main$n), GSNoOfferN = number(main$n_nooffer),
  GSEffect = number(main$est, 3), GSSE = number(main$se, 3), GSMean = number(main$mean, 3),
  GSAvailabilityEffect = number(100 * availability_result$offer_effect, 2),
  GSAvailabilitySE = number(100 * availability_result$se, 2),
  GSAvailabilityNoOffer = number(100 * panel[OFFER == 0, mean(HAS_STRINGENCY)], 2),
  GSAvailabilityOffer = number(100 * panel[OFFER == 1, mean(HAS_STRINGENCY)], 2),
  GSLOOMin = number(min(estimates[grepl("^Exclude historical", specification), est]), 3),
  GSLOOMax = number(max(estimates[grepl("^Exclude historical", specification), est]), 3),
  GSUnshrunkEffect = number(estimates[specification == "Unshrunk historical school effects", est], 3),
  GSSupportEffect = number(estimates[specification == "Common math-reading support calibration", est], 3))
fact_lines <- c("% Generated by section6/run_grade_stringency.R; do not edit numbers manually.",
                sprintf("\\newcommand{\\%s}{%s}", names(facts), facts))
writeLines(fact_lines, file.path(output_dir, "grade_stringency_facts.tex"))
if (nzchar(manuscript)) {
  export_grade_stringency(manuscript, as.list(main))
  file.copy(file.path(output_dir, "grade_stringency_facts.tex"),
            file.path(manuscript, "tables", "grade_stringency_facts.tex"), overwrite = TRUE)
}
capture.output(sessionInfo(), file = file.path(output_dir, "session_info.txt"))
fwrite(data.table(file = c("run_grade_stringency.R", "prepare_grade_stringency.R",
                           "fit_grade_stringency.R", "export_grade_stringency.R"),
  md5 = unname(tools::md5sum(file.path(script_dir, c("run_grade_stringency.R",
    "prepare_grade_stringency.R", "fit_grade_stringency.R", "export_grade_stringency.R"))))),
  file.path(output_dir, "code_manifest.csv"))
message("Completed. Aggregate diagnostics: ", output_dir)
print(main)
print(availability_result)
