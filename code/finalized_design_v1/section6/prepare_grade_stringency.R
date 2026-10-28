#!/usr/bin/env Rscript
# Construct historical grade-10 calibration candidates; no school eligibility
# restriction and no stringency estimation are performed here.
suppressPackageStartupMessages(library(data.table))
setDTthreads(2L)
args <- commandArgs(trailingOnly = TRUE)
user_root <- if (nzchar(Sys.getenv("USERPROFILE"))) Sys.getenv("USERPROFILE") else path.expand("~")
input_dir <- if (length(args) >= 1L) args[[1L]] else file.path(user_root, "Dropbox", "Effect SAE on SUA", "data")
output_dir <- if (length(args) >= 2L) args[[2L]] else input_dir
ownership_only <- length(args) >= 3L && identical(args[[3L]], "--ownership-only")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
performance_file <- file.path(input_dir, "panel_performance_2002_2023.rds")
simce_file <- file.path(input_dir, "panel_simce_2m.rds")
stopifnot(file.info(performance_file)$size == 467702493,
          file.info(simce_file)$size == 68433352)
audit <- list()
add <- function(stage, metric, value, stratum = "Overall") {
  audit[[length(audit) + 1L]] <<- data.table(stage, metric, stratum,
                                         value = as.numeric(value))
}
add_groups <- function(x, stage, columns) {
  z <- x[, .(n = .N), by = columns]
  for (i in seq_len(nrow(z))) {
    label <- paste(paste0(columns, "=", unlist(z[i, ..columns], use.names=FALSE)),
                   collapse = "; ")
    add(stage, "records", z$n[[i]], label)
  }
}
regular_secondary <- c(310L, 410L, 510L, 610L, 710L, 810L, 910L)
years <- 2014:2016

message("Reading annual performance source")
p <- readRDS(performance_file)
setDT(p)
setnames(p, toupper(names(p)))
needed <- c("MRUN", "AGNO", "RBD", "COD_ENSE", "COD_GRADO", "COD_DEPE",
            "PROM_GRAL", "SIT_FIN_R")
stopifnot(all(needed %in% names(p)))
fwrite(data.table(column = names(p),
                 class = vapply(p, function(z) paste(class(z), collapse="/"), character(1))),
       file.path(output_dir, "performance_source_schema.csv"))
add("performance_source", "records", nrow(p))
# Keep the ownership history before reducing to the calibration years. A
# school is a public/private switcher if either status occurs in 2012-2023;
# the calling analysis complements this export with 2024-2025 records.
dependency_years <- rbindlist(lapply(2012:2023, function(yr) {
  unique(p[AGNO == yr & !is.na(RBD) & RBD > 0, .(RBD, AGNO, COD_DEPE)])
}))
setorder(dependency_years, RBD, AGNO, COD_DEPE)
dependency_history <- dependency_years[, .(
  first_year=min(AGNO), last_year=max(AGNO),
  ever_private=any(COD_DEPE == 4L, na.rm=TRUE),
  ever_public=any(COD_DEPE %in% c(1L,2L,3L,5L,6L)),
  unknown_dependency=any(is.na(COD_DEPE) | !COD_DEPE %in% 1:6)
), by=RBD]
dependency_history[, public_private_switcher := ever_private & ever_public]
saveRDS(dependency_years, file.path(output_dir, "school_year_dependencies_2012_2023.rds"))
saveRDS(dependency_history, file.path(output_dir, "school_dependency_history_2012_2023.rds"))
fwrite(dependency_history[, .(schools=.N),
       by=.(ever_private,ever_public,public_private_switcher,unknown_dependency)],
       file.path(output_dir, "school_dependency_audit.csv"))
message("Ownership export: ", nrow(dependency_years), " school-year-dependency records; ",
        nrow(dependency_history), " schools; ", sum(dependency_history$public_private_switcher),
        " public/private switchers")
if (ownership_only) quit(save="no", status=0L)
p <- p[AGNO %in% years & COD_ENSE %in% regular_secondary & COD_GRADO == 2L,
       ..needed]
gc()
p[, PROM_GRAL := suppressWarnings(as.numeric(sub(",", ".", as.character(PROM_GRAL), fixed=TRUE)))]
p[, SIT_FIN_R := trimws(as.character(SIT_FIN_R))]
add("performance_grade10_2014_2016", "records", nrow(p))
add_groups(p, "performance_grade10_by_year_status", c("AGNO", "SIT_FIN_R"))
add_groups(p, "performance_grade10_by_year_type", c("AGNO", "COD_ENSE", "COD_DEPE"))
add("performance_grade10_2014_2016", "missing_gpa", sum(is.na(p$PROM_GRAL)))
add("performance_grade10_2014_2016", "gpa_zero", sum(p$PROM_GRAL == 0, na.rm=TRUE))
add("performance_grade10_2014_2016", "gpa_outside_1_7", sum(!between(p$PROM_GRAL, 1, 7) & !is.na(p$PROM_GRAL)))
before <- nrow(p)
p <- unique(p)
add("performance_deduplication", "exact_substantive_duplicates_removed", before - nrow(p))
invalid_id <- is.na(p$MRUN) | p$MRUN <= 0 | is.na(p$RBD) | p$RBD <= 0
add("performance_deduplication", "invalid_identifier_records", sum(invalid_id))
p <- p[!invalid_id]
ambiguous <- p[, .N, by=.(MRUN, AGNO)][N > 1L]
add("performance_deduplication", "multiple_raw_student_years_before_grade_validity", nrow(ambiguous))
add("performance_validity", "non_P_R_records_removed", sum(!p$SIT_FIN_R %in% c("P", "R")))
p <- p[SIT_FIN_R %in% c("P", "R")]
add("performance_validity", "invalid_or_missing_gpa_removed", sum(is.na(p$PROM_GRAL) | !between(p$PROM_GRAL, 1, 7)))
p <- p[between(PROM_GRAL, 1, 7)]
# A transfer/withdrawal row without an annual grade does not compete with the
# unique completed-year record. Conflicts are assessed among valid P/R grades.
ambiguous <- p[, .N, by=.(MRUN, AGNO)][N > 1L]
add("performance_deduplication", "ambiguous_graded_student_years", nrow(ambiguous))
add("performance_deduplication", "ambiguous_graded_student_year_records_removed", sum(ambiguous$N))
p <- p[!ambiguous, on=.(MRUN, AGNO)]
stopifnot(!anyDuplicated(p, by=c("MRUN", "AGNO")))
message("Performance candidate rows: ", nrow(p))

s <- readRDS(simce_file)
setDT(s)
needed_s <- c("mrun", "agno", "rbd", "idalumno", "gen_alu",
              "ptje_mate2m_alu", "ptje_lect2m_alu")
stopifnot(all(needed_s %in% names(s)))
s <- s[agno %in% years, ..needed_s]
setnames(s, c("mrun", "agno", "rbd", "ptje_mate2m_alu", "ptje_lect2m_alu"),
         c("MRUN", "AGNO", "RBD", "math", "reading"))
s[, female := fcase(gen_alu %in% c("2", "Mujeres"), 1L,
                    gen_alu %in% c("1", "Hombres"), 0L, default=NA_integer_)]
add("simce_grade10_2014_2016", "records", nrow(s))
add_groups(s, "simce_grade10_by_year", "AGNO")
add("simce_grade10_2014_2016", "missing_math", sum(is.na(s$math)))
add("simce_grade10_2014_2016", "missing_reading", sum(is.na(s$reading)))
add("simce_grade10_2014_2016", "nonpositive_nonmissing_math", sum(s$math <= 0, na.rm=TRUE))
add("simce_grade10_2014_2016", "nonpositive_nonmissing_reading", sum(s$reading <= 0, na.rm=TRUE))
add("simce_grade10_2014_2016", "above500_math", sum(s$math > 500, na.rm=TRUE))
add("simce_grade10_2014_2016", "above500_reading", sum(s$reading > 500, na.rm=TRUE))
add("simce_grade10_2014_2016", "unknown_sex", sum(is.na(s$female)))
s[, gen_alu := NULL]
before <- nrow(s)
s <- unique(s)
add("simce_deduplication", "exact_substantive_duplicates_removed", before - nrow(s))
invalid_id <- is.na(s$MRUN) | s$MRUN <= 0 | is.na(s$RBD) | s$RBD <= 0
add("simce_deduplication", "invalid_identifier_records", sum(invalid_id))
s <- s[!invalid_id]
ambiguous <- s[, .N, by=.(MRUN, AGNO)][N > 1L]
add("simce_deduplication", "ambiguous_student_years", nrow(ambiguous))
add("simce_deduplication", "ambiguous_student_year_records_removed", sum(ambiguous$N))
s <- s[!ambiguous, on=.(MRUN, AGNO)]
stopifnot(!anyDuplicated(s, by=c("MRUN", "AGNO")))

# Diagnose school discrepancies separately from absent valid performance data.
school_check <- merge(s[, .(MRUN, AGNO, simce_RBD=RBD)],
                      p[, .(MRUN, AGNO, performance_RBD=RBD)],
                      by=c("MRUN", "AGNO"), all.x=TRUE)
add("merge", "simce_without_valid_unique_performance", sum(is.na(school_check$performance_RBD)))
add("merge", "school_mismatches", sum(school_check$simce_RBD != school_check$performance_RBD, na.rm=TRUE))
joined <- merge(s, p, by=c("MRUN", "AGNO", "RBD"), all=FALSE)
add("merge", "exact_student_year_school_matches", nrow(joined))
add("merge", "matches_missing_either_score", sum(is.na(joined$math) | is.na(joined$reading)))
add("merge", "matches_invalid_nonmissing_score", sum((!is.na(joined$math) & joined$math <= 0) | (!is.na(joined$reading) & joined$reading <= 0)))
out <- joined[is.finite(math) & math > 0 & is.finite(reading) & reading > 0 & !is.na(female)]
stopifnot(!anyDuplicated(out, by=c("MRUN", "AGNO")),
          all(out$AGNO %in% years), all(out$COD_GRADO == 2),
          all(out$COD_ENSE %in% regular_secondary),
          all(out$SIT_FIN_R %in% c("P", "R")),
          all(between(out$PROM_GRAL, 1, 7)))
setorder(out, AGNO, RBD, MRUN)
add("calibration_candidates", "records", nrow(out))
add("calibration_candidates", "schools", uniqueN(out$RBD))
add("calibration_candidates", "students", uniqueN(out$MRUN))
add_groups(out, "calibration_by_year_status", c("AGNO", "SIT_FIN_R"))
add_groups(out, "calibration_by_year_type", c("AGNO", "COD_ENSE", "COD_DEPE"))
saveRDS(out, file.path(output_dir, "calibration_candidates.rds"))
fwrite(rbindlist(audit), file.path(output_dir, "audit.csv"))
fwrite(data.table(file=c(basename(performance_file),basename(simce_file)),
                 bytes=file.info(c(performance_file,simce_file))$size,
                 md5=unname(tools::md5sum(c(performance_file,simce_file)))),
       file.path(output_dir, "input_manifest.csv"))
message("Calibration candidates: ", nrow(out), " rows, ", uniqueN(out$RBD), " schools")
print(out[, .(records=.N, schools=uniqueN(RBD), failed=sum(SIT_FIN_R=="R")), by=AGNO])
script_arg <- grep("^--file=", commandArgs(), value=TRUE)[[1L]]
script_path <- gsub("~+~", " ", sub("^--file=", "", script_arg), fixed=TRUE)
writeLines(unname(tools::md5sum(script_path)), file.path(output_dir, "preparation_code_md5.txt"))
