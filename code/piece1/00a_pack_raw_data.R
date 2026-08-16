# =============================================================================
# 00a_pack_raw_data.R -- read the raw MINEDUC csv files once, write three rds
# files into Piece 1/data/. After this, 00_build_entrant_panel.Rmd reads only
# the three rds files (plus the shared canonical panels).
#
#   data/sae_admissions.rds       list(a1, c1, d1): offers/seats (2016-2025),
#                                 applications (2017-2025), assignments (2017-2025)
#   data/matricula_2011_2023.rds  enrolment census: one row per student x school
#                                 x grade code x year
#   data/alumnos_sep_2012_2023.rds  prioritario roster: student, school,
#                                 prioritario columns, year
#
# Only the columns the pipeline uses are kept; every read replicates the build's
# original csv handling (case-resolved column selection, Latin-1, the course-id
# columns forced to character because 12-digit ids overflow integers from 2018).
# Repoint the three source paths below to your own copies of the public files.
# =============================================================================
suppressPackageStartupMessages({ library(data.table) })
setDTthreads(4); options(warn = 1)
t0 <- proc.time()
home <- ifelse(Sys.getenv("USERPROFILE") != "", Sys.getenv("USERPROFILE"), path.expand("~"))
ROOT <- file.path(home, "Dropbox", "Effect of Centralization")
EX   <- file.path(ROOT, "explorations", "2026-08-05_priority_quota", "downloads", "extracted")
EX2  <- file.path(ROOT, "explorations", "2026-08-03_grade7_door", "downloads", "extracted")
DL   <- file.path(ROOT, "explorations", "2026-08-06_outcome_data_pull", "downloads", "extracted")
OUTD <- file.path(ROOT, "Updated Paper Spine", "Piece 1", "data")
if (!dir.exists(OUTD)) dir.create(OUTD)
say <- function(...) { cat(sprintf(...), "\n"); flush.console() }

IDCH <- c("cod_curso", "cod_curso_admitido", "cod_curso_admitido_post_resp")
rd_sae <- function(tb, pr, dirs = c(EX, EX2)) {
  f <- unlist(lapply(dirs, function(dd)
    list.files(dd, pattern = paste0("^", tb, "_.*etapa_regular.*_", pr, "_Admisi"),
               recursive = TRUE, full.names = TRUE)))
  f <- f[!grepl("__MACOSX", f, fixed = TRUE)]
  if (!length(f)) return(NULL)
  hd <- names(fread(f[1], sep = ";", nrows = 0, encoding = "Latin-1"))
  tochar <- hd[tolower(hd) %in% IDCH]
  d <- fread(f[1], sep = ";", encoding = "Latin-1", showProgress = FALSE,
             colClasses = if (length(tochar)) list(character = tochar) else NULL,
             na.strings = c("", "NA"))
  setnames(d, tolower(names(d)))
  for (v in intersect(IDCH, names(d)))
    if (!is.character(d[[v]]))
      stop(sprintf("%s %d: %s loaded as %s -- int64 trap", tb, pr, v, class(d[[v]])[1]))
  d
}
norm_names <- function(D) { setnames(D, toupper(names(D)))
  setnames(D, sub("^﻿|^Ï»¿|^ï»¿", "", names(D))); D }
rd_csv <- function(p, sel = NULL) {
  h <- readLines(p, n = 1L, warn = FALSE)
  sp <- if (lengths(regmatches(h, gregexpr(";", h))) >= 3) ";" else ","
  if (!is.null(sel)) {
    hd <- names(fread(p, sep = sp, nrows = 0L, encoding = "Latin-1"))
    sel <- hd[match(toupper(sub("^﻿|^Ï»¿|^ï»¿", "", hd)),
                    toupper(sel), nomatch = 0L) > 0L]
    if (!length(sel)) sel <- NULL
  }
  norm_names(fread(p, sep = sp, encoding = "Latin-1", showProgress = FALSE,
                   na.strings = c("", "NA"), select = sel))
}
big_csv <- function(dirpat, y, floor = 20e6) {
  d <- list.files(DL, pattern = sprintf("^%s-%d$", dirpat, y), full.names = TRUE)
  if (!length(d)) return(NA_character_)
  f <- list.files(d, pattern = "\\.csv$", recursive = TRUE, full.names = TRUE, ignore.case = TRUE)
  f <- f[file.size(f) > floor]
  if (length(f)) f[which.max(file.size(f))] else NA_character_
}

# ---- SAE admissions: A1 2016-2025, C1/D1 2017-2025 --------------------------
say("=== SAE admissions ===")
A1 <- list(); C1 <- list(); D1 <- list()
for (pr in 2016L:2025L) {
  a <- rd_sae("A1", pr)
  stopifnot("A1 must exist for every process 2016-2025" = !is.null(a))
  # 2016 labels the grade level `nivel`; later years `cod_nivel` -- normalise.
  # 2016 also predates the course-id and capacity columns; fill them as NA
  # (the demand stage never reads process 2016; only the rollout door does).
  if (!"cod_nivel" %in% names(a)) setnames(a, "nivel", "cod_nivel")
  if (!"cod_curso" %in% names(a)) a[, cod_curso := NA_character_]
  if (!"vacantes" %in% names(a)) a[, vacantes := NA_integer_]
  if (!"cupos_totales" %in% names(a)) a[, cupos_totales := NA_integer_]
  A1[[as.character(pr)]] <- a[, .(proc = pr, rbd, cod_nivel = as.integer(cod_nivel),
                                  cod_curso, vacantes, cupos_totales)]
  if (pr >= 2017L) {
    cc <- rd_sae("C1", pr); dd <- rd_sae("D1", pr)
    stopifnot("C1 and D1 must exist for every process 2017-2025" = !is.null(cc) && !is.null(dd))
    if (!"agregada_por_continuidad" %in% names(cc)) cc[, agregada_por_continuidad := NA_integer_]
    C1[[as.character(pr)]] <- cc[, .(proc = pr, mrun, rbd, cod_nivel, cod_curso,
                                     preferencia_postulante, agregada_por_continuidad)]
    D1[[as.character(pr)]] <- dd[, .(proc = pr, mrun, cod_nivel, rbd_admitido)]
  }
  say("process %d packed | %.1f min", pr, (proc.time() - t0)[["elapsed"]] / 60)
}
SAE <- list(a1 = rbindlist(A1), c1 = rbindlist(C1), d1 = rbindlist(D1))
rm(A1, C1, D1); invisible(gc())
saveRDS(SAE, file.path(OUTD, "sae_admissions.rds"))
say("wrote sae_admissions.rds | a1 %s | c1 %s | d1 %s rows",
    format(nrow(SAE$a1), big.mark = ","), format(nrow(SAE$c1), big.mark = ","),
    format(nrow(SAE$d1), big.mark = ","))
rm(SAE); invisible(gc())

# ---- matricula census 2011-2023 ---------------------------------------------
say("=== matricula ===")
sel <- c("MRUN", "RBD", "COD_ENSE", "COD_GRADO")
MAT <- list()
for (y in 2011L:2023L) {
  f <- big_csv("Matricula-por-estudiante", y, floor = 50e6)
  stopifnot("matricula year file must exist" = !is.na(f))
  M <- rd_csv(f, sel = sel)
  stopifnot("matricula must yield the id columns after case resolution" =
              all(sel %in% names(M)))
  MAT[[as.character(y)]] <- M[, .(agno = y, MRUN, RBD, COD_ENSE, COD_GRADO)]
  rm(M); invisible(gc())
  say("matricula %d packed | %.1f min", y, (proc.time() - t0)[["elapsed"]] / 60)
}
MAT <- rbindlist(MAT)
saveRDS(MAT, file.path(OUTD, "matricula_2011_2023.rds"))
say("wrote matricula_2011_2023.rds | %s rows", format(nrow(MAT), big.mark = ","))
rm(MAT); invisible(gc())

# ---- Alumnos SEP 2012-2023 --------------------------------------------------
say("=== Alumnos SEP ===")
SEPL <- list()
for (y in 2012L:2023L) {
  f <- big_csv("Alumnos-SEP", y)
  stopifnot("Alumnos-SEP year file must exist" = !is.na(f))
  D <- rd_csv(f, sel = c("MRUN", "RBD", "PRIORITARIO_ALU", "CRITERIO_SEP"))
  if (!"PRIORITARIO_ALU" %in% names(D)) D[, PRIORITARIO_ALU := NA_integer_]
  if (!"CRITERIO_SEP"    %in% names(D)) D[, CRITERIO_SEP    := NA_integer_]
  SEPL[[as.character(y)]] <- D[, .(agno = y, MRUN, RBD, PRIORITARIO_ALU, CRITERIO_SEP)]
  rm(D); invisible(gc())
  say("SEP %d packed | %.1f min", y, (proc.time() - t0)[["elapsed"]] / 60)
}
SEPL <- rbindlist(SEPL)
saveRDS(SEPL, file.path(OUTD, "alumnos_sep_2012_2023.rds"))
say("wrote alumnos_sep_2012_2023.rds | %s rows", format(nrow(SEPL), big.mark = ","))
say("total elapsed %.1f min", (proc.time() - t0)[["elapsed"]] / 60)
cat("DONE\n")
