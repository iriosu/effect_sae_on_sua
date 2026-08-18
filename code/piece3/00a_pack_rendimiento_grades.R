# =============================================================================
# 00a_pack_rendimiento_grades.R -- Piece 3's grades supplement for academic
# years 2024-2025.
#
# The canonical graded panel ends 2023 and Piece 2's rendimiento pack kept
# promotion status only (no PROM_GRAL, no RBD). Piece 3's 12th-grade outcomes
# (4-year GPA, 12th-grade percentile, rank vs school history) need grades and
# the school id for 2024-2025. This packs them from the same two raw public
# releases, resolved by CONTENT, never by filename (the 2026-08-06 gate rule).
# The certified packs and the canonical panel are untouched; this writes a NEW
# file into the working directory (run it from the Piece 3 folder):
#
#   rendimiento_grades_2024_2025.rds
#   columns: MRUN, AGNO, RBD, COD_ENSE, COD_GRADO, PROM_GRAL (numeric,
#   comma-decimal converted, 0 = no final grade kept as 0), SIT_FIN_R
#
# Repoint SRC_DIRS to your own copies of the public releases to repack
# (20250212_Rendimiento_2024_20250131_WEB.csv, 20260210_Rendimiento_2025_20260202_WEB.csv).
# =============================================================================
suppressPackageStartupMessages({ library(data.table) })
setDTthreads(4); options(warn = 1)
t0 <- proc.time()
home <- ifelse(Sys.getenv("USERPROFILE") != "", Sys.getenv("USERPROFILE"), path.expand("~"))
ROOT <- file.path(home, "Dropbox", "Effect of Centralization")
SRC_DIRS <- c(file.path(ROOT, "explorations", "2026-08-03_grade7_door", "downloads", "extracted"),
              file.path(ROOT, "explorations", "2026-08-06_outcome_data_pull", "downloads", "extracted"))
say <- function(...) { cat(sprintf(...), "\n"); flush.console() }

SEL <- c("MRUN", "AGNO", "RBD", "COD_ENSE", "COD_GRADO", "PROM_GRAL", "SIT_FIN_R")

norm_names <- function(D) { setnames(D, toupper(names(D)))
  setnames(D, sub("^﻿|^Ï»¿|^ï»¿", "", names(D))); D }
rd_csv <- function(p, sel) {
  h <- readLines(p, n = 1L, warn = FALSE)
  sp <- if (lengths(regmatches(h, gregexpr(";", h))) >= 3) ";" else ","
  hd <- names(fread(p, sep = sp, nrows = 0L, encoding = "Latin-1"))
  sel_raw <- hd[match(toupper(sub("^[^A-Za-z0-9_]+", "", hd)), toupper(sel), nomatch = 0L) > 0L]
  norm_names(fread(p, sep = sp, encoding = "Latin-1", showProgress = FALSE,
                   na.strings = c("", "NA"), select = sel_raw))
}
find_rend <- function(yr) {
  cand <- unlist(lapply(SRC_DIRS[dir.exists(SRC_DIRS)], function(d)
    list.files(d, pattern = "\\.csv$", recursive = TRUE, full.names = TRUE, ignore.case = TRUE)))
  cand <- cand[grepl("rendimiento", cand, ignore.case = TRUE) &
                 !grepl("__MACOSX", cand, fixed = TRUE) & file.size(cand) > 20e6]
  hit <- character(0)
  for (p in cand) {
    h <- readLines(p, n = 1L, warn = FALSE)
    s <- if (lengths(regmatches(h, gregexpr(";", h))) >= 3) ";" else ","
    nm <- names(fread(p, sep = s, nrows = 0, encoding = "Latin-1"))
    ac <- nm[match("AGNO", toupper(sub("^[^A-Za-z0-9_]+", "", nm)))]
    if (is.na(ac)) next
    pk <- fread(p, sep = s, nrows = 50000L, encoding = "Latin-1", select = ac)
    if (as.integer(names(sort(table(pk[[1]]), decreasing = TRUE))[1]) == yr) hit <- c(hit, p)
  }
  stopifnot("exactly one Rendimiento file must contain that year" = length(hit) == 1L)
  say("Rendimiento %d resolved by content: %s", yr, basename(hit)); hit
}

L <- list()
for (y in 2024L:2025L) {
  D <- rd_csv(find_rend(y), sel = SEL)
  stopifnot("all seven columns must resolve" = all(SEL %in% names(D)),
            "file must carry exactly its own year" = uniqueN(D$AGNO) == 1L && D$AGNO[1] == y)
  if (is.character(D$PROM_GRAL))
    D[, PROM_GRAL := as.numeric(sub(",", ".", PROM_GRAL, fixed = TRUE))]
  D <- D[, .(MRUN = as.integer(MRUN), AGNO = as.integer(AGNO), RBD = as.integer(RBD),
             COD_ENSE = as.integer(COD_ENSE), COD_GRADO = as.integer(COD_GRADO),
             PROM_GRAL = as.numeric(PROM_GRAL), SIT_FIN_R = as.character(SIT_FIN_R))]
  stopifnot("PROM_GRAL must be 0 or inside [1,7]" =
              D[!is.na(PROM_GRAL) & PROM_GRAL != 0 & (PROM_GRAL < 1 | PROM_GRAL > 7), .N] == 0L)
  say("year %d: %s rows | graded [1,7] %.4f | zero %.4f | NA %.4f | promoted (P) %.4f",
      y, format(nrow(D), big.mark = ","),
      D[, mean(!is.na(PROM_GRAL) & PROM_GRAL >= 1 & PROM_GRAL <= 7)],
      D[, mean(!is.na(PROM_GRAL) & PROM_GRAL == 0)], D[, mean(is.na(PROM_GRAL))],
      D[, mean(SIT_FIN_R == "P", na.rm = TRUE)])
  L[[as.character(y)]] <- D
  rm(D); invisible(gc())
}
OUT <- rbindlist(L)
saveRDS(OUT, "rendimiento_grades_2024_2025.rds")
say("wrote rendimiento_grades_2024_2025.rds | %s rows | %.1f min",
    format(nrow(OUT), big.mark = ","), (proc.time() - t0)[["elapsed"]] / 60)
cat("DONE\n")
