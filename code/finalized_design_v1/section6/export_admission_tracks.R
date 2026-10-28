# Direct 2SLS effects on mutually exclusive first-assignment tracks.
# Rscript export_admission_tracks.R [projected-columns-directory] [manuscript-directory]
# With no first argument, use the existing memory-bounded reader (Python/numpy).
# Individual records remain temporary; only aggregates are exported.
suppressPackageStartupMessages({
  library(data.table)
  library(jsonlite)
  library(fixest)
})
setDTthreads(4)
setFixest_estimation(fixef.rm = "none")
args <- commandArgs(trailingOnly = TRUE)
script <- normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1L]))
repo <- normalizePath(file.path(dirname(script), "../../.."))
private <- file.path(path.expand("~"), "Dropbox/Effect SAE on SUA/data")
input <- file.path(repo, "code/analysis_for_adversarial_report_output/input/f08")
out <- file.path(dirname(script), "output/admission_tracks")
dir.create(out, recursive = TRUE, showWarnings = FALSE)
manuscript <- if (length(args) >= 2L) normalizePath(args[2L]) else
  file.path(path.expand("~"), "Projects/Effect of Centralized School Choice on College Admissions Outcomes/Initial submission")
stopifnot(dir.exists(file.path(manuscript, "tables/results")))
projection <- list("1" = "year", "2" = "mrun", "327" = "pref_seleccion_reg",
                   "328" = "pref_seleccion_bea", "329" = "pref_seleccion_pace",
                   "330" = "pref_seleccion_genero", "342" = "assigned")
if (length(args) >= 1L) {
  columns <- normalizePath(args[1L])
} else {
  columns <- tempfile("admission-track-columns-")
  dir.create(columns)
  manifest <- file.path(columns, "projection.json")
  write_json(projection, manifest, auto_unbox = TRUE)
  python <- Sys.getenv("PYTHON", if (file.exists("/opt/homebrew/bin/python3")) "/opt/homebrew/bin/python3" else "python3")
  status <- system2(python, shQuote(c(file.path(repo, "code/f08_extract_rds_columns.py"),
                                    file.path(input, "data_students_2004_2025.rds"), columns, manifest)),
                    stdout = file.path(columns, "projection.log"))
  stopifnot(status == 0L)
}
metadata <- fromJSON(file.path(columns, "metadata.json"), simplifyVector = FALSE)
attributes <- metadata$attributes
while (!identical(attributes$tag, "names")) attributes <- attributes[["next"]]
stopifnot(all(vapply(names(projection), function(i)
  identical(attributes$value[[as.integer(i) + 1L]], projection[[i]]), logical(1))))
read_column <- function(nm, index) {
  info <- metadata$value[[index + 1L]]
  x <- readBin(file.path(columns, paste0(nm, ".bin")),
               if (info$type == 14L) "double" else "integer", n = info$n, endian = "big")
  stopifnot(length(x) == info$n)
  x
}
panel_path <- file.path(private, "finalized_design_v1/section5/section5_panel.rds")
p <- as.data.table(readRDS(panel_path))
controls <- c("GPA8_Z", "ES_MUJER", "PRIORITARIO", "ALTO", "ORIGIN_OD")
p <- p[LOTTERY_SAMPLE == TRUE & complete.cases(p[, ..controls])]
stopifnot(nrow(p) == 175869L, !anyDuplicated(p$MRUN), sum(p$OFFER == 0) == 112796L)
year <- read_column("year", 1L)
take <- which(year >= 2018L & year <= 2025L)
d <- data.table(process = as.integer(year[take]), MRUN = read_column("mrun", 2L)[take])
for (r in c("reg", "bea", "pace", "genero")) {
  index <- c(reg = 327L, bea = 328L, pace = 329L, genero = 330L)[[r]]
  x <- read_column(paste0("pref_seleccion_", r), index)[take]
  d[, (r) := as.integer(!is.na(x) & x > 0)]
}
d[, assigned_raw := read_column("assigned", 342L)[take]]
d <- d[MRUN %in% p$MRUN]
# Upstream preference-selection fields identify status 24 by track, including
# the separate early BEA/PACE files. No eligibility proxies are used.
audit <- d[, .(records = .N, assigned = sum(assigned_raw),
                classified = sum(reg + bea + pace + genero),
                multiple_tracks = sum(reg + bea + pace + genero > 1L),
                assignment_mismatches = sum((reg + bea + pace + genero > 0L) != assigned_raw)), by = process]
stopifnot(all(audit$multiple_tracks == 0L), all(audit$assignment_mismatches == 0L))
raw26_path <- file.path(input, "operational_2026/C_POSTULANTES_SELECCION_PAES_2026_PUB_MRUN.csv")
raw26 <- fread(raw26_path, select = c("MRUN", "TIPO_PREF", "ESTADO_PREF"))
raw26 <- raw26[ESTADO_PREF == 24L & MRUN %in% p$MRUN]
stopifnot(all(raw26$TIPO_PREF %in% c("REGULAR", "BEA", "PACE", "GENERO")))
r26 <- raw26[, .(process = 2026L, reg = as.integer(any(TIPO_PREF == "REGULAR")),
                 bea = as.integer(any(TIPO_PREF == "BEA")), pace = as.integer(any(TIPO_PREF == "PACE")),
                 genero = as.integer(any(TIPO_PREF == "GENERO")), assigned_raw = 1L), by = MRUN]
audit <- rbind(audit, r26[, .(records = .N, assigned = sum(assigned_raw),
                              classified = sum(reg + bea + pace + genero),
                              multiple_tracks = sum(reg + bea + pace + genero > 1L),
                              assignment_mismatches = sum(reg + bea + pace + genero != assigned_raw)), by = process])
d <- rbindlist(list(d, r26), use.names = TRUE)
stopifnot(!anyDuplicated(d, by = c("MRUN", "process")))
events <- d[assigned_raw == 1L]
stopifnot(all(events$reg + events$bea + events$pace + events$genero == 1L))
setorder(events, MRUN, process)
first <- events[, .SD[1L], by = MRUN]
p <- merge(p, first[, .(MRUN, first_process = process, reg, bea, pace, genero)], by = "MRUN", all.x = TRUE, sort = FALSE)
reconciliation <- list()
for (h in c("OT", "EVER")) {
  eligible <- !is.na(p$first_process) & p$first_process <= if (h == "OT") p$YEAR + 5L else 2026L
  reconciliation[[h]] <- data.table(horizon = h, n = nrow(p),
    mismatches = sum(eligible != p[[paste0("ASSIGNED_", h)]]))
  stopifnot(reconciliation[[h]]$mismatches == 0L)
  for (r in c("reg", "bea", "pace", "genero"))
    p[, (paste0(toupper(r), "_", h)) := as.integer(eligible & get(r) %in% 1L)]
  route_columns <- paste0(c("REG", "BEA", "PACE", "GENERO"), "_", h)
  stopifnot(all(rowSums(p[, ..route_columns]) == p[[paste0("ASSIGNED_", h)]]))
}
vars <- unlist(lapply(c("OT", "EVER"), function(h) paste0(c("ASSIGNED", "REG", "BEA", "PACE", "GENERO"), "_", h)))
fit <- feols(.[vars] ~ .[controls] + i(YEAR, ref = 2016) | CHANCE_GROUP | D_OD ~ OFFER,
             p, vcov = "hetero", ssc = ssc(K.adj = FALSE))
results <- rbindlist(lapply(seq_along(vars), function(i) {
  b <- coef(fit[[i]])[["fit_D_OD"]]
  s <- se(fit[[i]])[["fit_D_OD"]]
  data.table(outcome = vars[i], no_offer_mean = 100 * mean(p[OFFER == 0][[vars[i]]]),
             estimate = 100 * b, se = 100 * s, p_value = 2 * pnorm(-abs(b / s)), n = nobs(fit[[i]]))
}))
additivity <- rbindlist(lapply(c("OT", "EVER"), function(h) {
  total <- results[outcome == paste0("ASSIGNED_", h)]
  parts <- results[outcome %in% paste0(c("REG", "BEA", "PACE", "GENERO"), "_", h)]
  data.table(horizon = h, estimate_error = sum(parts$estimate) - total$estimate,
             mean_error = sum(parts$no_offer_mean) - total$no_offer_mean)
}))
stopifnot(max(abs(additivity$estimate_error)) < 1e-9, max(abs(additivity$mean_error)) < 1e-9,
          identical(round(results[outcome %in% c("ASSIGNED_OT", "ASSIGNED_EVER"), estimate], 2), c(-2.23, -1.04)),
          all(results$n == 175869L))
fwrite(results, file.path(out, "estimates.csv"))
fwrite(audit[order(process)], file.path(out, "source_route_audit.csv"))
fwrite(rbindlist(reconciliation), file.path(out, "horizon_reconciliation.csv"))
fwrite(additivity, file.path(out, "additivity_checks.csv"))
paths <- c(panel_path, file.path(input, "data_students_2004_2025.rds"), raw26_path)
fwrite(data.table(input = basename(paths), bytes = file.info(paths)$size, md5 = unname(tools::md5sum(paths))),
       file.path(out, "input_manifest.csv"))
capture.output(sessionInfo(), file = file.path(out, "session_info.txt"))

num <- function(x) sub("^-0\\.00$", "0.00", sprintf("%.2f", x))
stars <- function(p) ifelse(p < .01, "$^{***}$", ifelse(p < .05, "$^{**}$", ifelse(p < .1, "$^{*}$", "")))
row <- function(label, cells) paste0(label, " & ", paste(cells, collapse = " & "), "\\\\")
body <- c("% Generated by code/finalized_design_v1/section6/export_admission_tracks.R.",
          "\\begin{tabular}{lcccc}", "\\toprule",
          " & \\multicolumn{2}{c}{On time} & \\multicolumn{2}{c}{Ever}\\\\",
          "\\cmidrule(lr){2-3}\\cmidrule(lr){4-5}",
          " & No offer & 2SLS & No offer & 2SLS\\\\",
          " & mean &  & mean & \\\\", " & (1) & (2) & (3) & (4)\\\\", "\\midrule")
labels <- c(ASSIGNED = "Total: assigned a college seat", REG = "Regular", BEA = "BEA", PACE = "PACE", GENERO = "Gender quota")
for (r in names(labels)) {
  ot <- results[outcome == paste0(r, "_OT")]
  ev <- results[outcome == paste0(r, "_EVER")]
  if (r == "REG") body <- c(body, "\\midrule", "\\multicolumn{5}{l}{\\textit{Admission tracks}}\\\\")
  body <- c(body,
    row(labels[[r]], c(num(ot$no_offer_mean), paste0(num(ot$estimate), stars(ot$p_value)),
                       num(ev$no_offer_mean), paste0(num(ev$estimate), stars(ev$p_value)))),
    row("", c("", paste0("(", num(ot$se), ")"), "", paste0("(", num(ev$se), ")"))))
}
body <- c(body, "\\midrule", "$N$ & 112,796 & 175,869 & 112,796 & 175,869\\\\", "\\bottomrule", "\\end{tabular}")
writeLines(body, file.path(manuscript, "tables/lottery_admission_tracks.tex"))
wrapper <- c("% Generated by code/finalized_design_v1/section6/export_admission_tracks.R.",
 "\\begin{table}[htp!]", "\\singlespacing\\renewcommand{\\arraystretch}{1.2}", "\\centering",
 "\\caption{{Effect of Attending an Over-Demanded School on College Assignment by Admission Track}}\\label{tab: lottery admission tracks}",
 "\\small", "\\input{tables/lottery_admission_tracks.tex}", "\\par\\smallskip",
 "\\begin{minipage}{\\textwidth}\\footnotesize",
 paste0("{Notes: 2SLS estimates of the effect of attending an over-demanded school, with the sample and specification of Table~\\ref{tab: lottery college}; ",
 "means among students without an offer, in \\%; effects in percentage points. The total records assignment through any track. ",
 "Each assigned student counts once, under the track of her first recorded assignment within the horizon. ",
 "The four track indicators partition total assignment, so their means and 2SLS effects add to the total before rounding. ",
 "On time and ever are defined in Section~\\ref{sec:lottery-data}. The gender quota starts with the 2024 admission process. ",
 "Heteroskedasticity-robust standard errors in parentheses. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$.}"),
 "\\end{minipage}", "\\end{table}")
writeLines(wrapper, file.path(manuscript, "tables/results/lottery_admission_tracks.tex"))
writeLines(c("Direct 2SLS effects on assignment through each track, using the same sample, instrument, controls, fixed effects and HC0 standard errors as the main assignment table.",
 "The first recorded assignment determines the exclusive track. On-time assignment ends in the process five years after the SAE application; ever ends in 2026. Both reconstructed totals agree with the finalized panel for all 175,869 students. Track effects and no-offer means add to their totals before rounding.",
 "The 2018-2025 upstream pref_seleccion_* fields are the positive positions with selection status 24. The 2026 route comes directly from TIPO_PREF for status 24. These are direct outcome effects, distinct from the archived ordered-accounting contributions.",
 "Reproduce with Rscript code/finalized_design_v1/section6/export_admission_tracks.R from the analysis repository. An optional first argument supplies an existing projection directory; an optional second argument selects the manuscript directory. No individual records are exported."),
 file.path(out, "README.md"))
print(results)
print(additivity)
cat("Wrote the table body and wrapper to", manuscript, "\n")
