# =============================================================================
# 00a_pack_raw_data.R -- read the raw public csv files once, write six rds
# files into Piece 1/data/. After this, Piece 1's 00_build_entrant_panel.Rmd and
# Piece 2's builds read only the packed rds files (plus the shared canonical
# panels).
#
#   data/sae_admissions.rds       list(a1, c1, d1, b1): offers/seats, applications,
#                                 assignments (2016-2025, with lottery/priority/
#                                 ordering columns for Piece 2), applicant register
#   data/matricula_2011_2023.rds  enrolment census: one row per student x school
#                                 x grade code x year
#   data/alumnos_sep_2012_2023.rds  prioritario roster: student, school,
#                                 prioritario columns, year
#   data/paes_2026.rds            PAES 2026 college process (registration+scores,
#                                 selection, enrolment) for Piece 2's outcome table
#   data/matricula_2024_2025.rds  census supplement for Piece 2's persistence years
#   data/rendimiento_2024_2025.rds  school-records supplement (12th-grade promotion
#                                 2024-2025) for Piece 2's grad-on-time outcome
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

# ---- SAE admissions: A1 2016-2025, C1/D1 2016-2025, B1 where present --------
# One packed file serves BOTH pieces: Piece 1 reads the seat/application/placement
# columns for the over-demand computation; Piece 2 additionally reads the lottery
# number, the priority flags, and the B1 applicant characteristics.
say("=== SAE admissions ===")
A1 <- list(); C1 <- list(); D1 <- list(); B1 <- list()
navc <- function(D, v, chr = FALSE) for (x in v) if (!x %in% names(D)) D[, (x) := if (chr) NA_character_ else NA_integer_]
for (pr in 2016L:2025L) {
  a <- rd_sae("A1", pr)
  stopifnot("A1 must exist for every process 2016-2025" = !is.null(a))
  # 2016 labels the grade level `nivel`; later years `cod_nivel` -- normalise.
  # 2016 also predates the course-id and capacity columns; fill them as NA.
  if (!"cod_nivel" %in% names(a)) setnames(a, "nivel", "cod_nivel")
  navc(a, "cod_curso", chr = TRUE); navc(a, c("vacantes", "cupos_totales"))
  A1[[as.character(pr)]] <- a[, .(proc = pr, rbd, cod_nivel = as.integer(cod_nivel),
                                  cod_curso, vacantes, cupos_totales)]
  cc <- rd_sae("C1", pr); dd <- rd_sae("D1", pr)
  stopifnot("C1 and D1 must exist for every process 2016-2025" = !is.null(cc) && !is.null(dd))
  vintage16 <- !("cod_nivel" %in% names(cc))     # 2016 schema: NIVEL, TIPO_PRIORIDAD, no COD_CURSO
  if (vintage16) setnames(cc, "nivel", "cod_nivel")
  navc(cc, "cod_curso", chr = TRUE)
  navc(cc, c("agregada_por_continuidad", "tipo_prioridad", "prioridad_matriculado",
             "prioridad_hermano", "prioridad_hijo_funcionario", "prioridad_exalumno", "es_pie"))
  navc(cc, c("loteria_original"))
  navc(cc, c("orden_alta_exigencia_transicion", "orden_pie"), chr = TRUE)
  C1[[as.character(pr)]] <- cc[, .(proc = pr, mrun, rbd, cod_nivel = as.integer(cod_nivel), cod_curso,
                                   preferencia_postulante, agregada_por_continuidad,
                                   loteria_original = as.numeric(loteria_original),
                                   tipo_prioridad, prioridad_matriculado, prioridad_hermano,
                                   prioridad_hijo_funcionario, prioridad_exalumno, es_pie,
                                   orden_alta_exigencia_transicion = as.character(orden_alta_exigencia_transicion),
                                   orden_pie = as.character(orden_pie),
                                   vintage = fifelse(vintage16, "2016", "std"))]
  if (!"cod_nivel" %in% names(dd)) setnames(dd, "nivel", "cod_nivel")
  navc(dd, "cod_curso_admitido", chr = TRUE)
  D1[[as.character(pr)]] <- dd[, .(proc = pr, mrun, cod_nivel = as.integer(cod_nivel),
                                   rbd_admitido, cod_curso_admitido)]
  b <- tryCatch(rd_sae("B1", pr), error = function(e) NULL)
  if (!is.null(b) && all(c("prioritario", "es_mujer") %in% names(b))) {
    B1[[as.character(pr)]] <- b[, .(proc = pr, mrun, prioritario, es_mujer)]
    say("process %d packed (incl. B1) | %.1f min", pr, (proc.time() - t0)[["elapsed"]] / 60)
  } else say("process %d packed (no B1 on disk) | %.1f min", pr, (proc.time() - t0)[["elapsed"]] / 60)
  rm(a, cc, dd); if (exists("b")) rm(b); invisible(gc())
}
SAE <- list(a1 = rbindlist(A1), c1 = rbindlist(C1), d1 = rbindlist(D1), b1 = rbindlist(B1))
rm(A1, C1, D1, B1); invisible(gc())
saveRDS(SAE, file.path(OUTD, "sae_admissions.rds"))
say("wrote sae_admissions.rds | a1 %s | c1 %s | d1 %s | b1 %s rows",
    format(nrow(SAE$a1), big.mark = ","), format(nrow(SAE$c1), big.mark = ","),
    format(nrow(SAE$d1), big.mark = ","), format(nrow(SAE$b1), big.mark = ","))
rm(SAE); invisible(gc())

# ---- PAES 2026 college process (A registrants+scores, C selection, D enrolment) ----
# Used by Piece 2's outcome build for the newest cohort; columns are exactly the
# ones the build reads.
say("=== PAES 2026 ===")
EXP <- file.path(ROOT, "explorations", "2026-08-03_grade7_door", "downloads", "extracted")
pa <- fread(file.path(EXP, "A_INSCRITOS_PUNTAJES_PAES_2026_PUB_MRUN.csv"), sep = ";", encoding = "Latin-1",
            select = c("MRUN", "ANYO_PROCESO", "PROMEDIO_NOTAS", "PTJE_NEM", "PTJE_RANKING",
                       "CLEC_REG_ACTUAL", "MATE1_REG_ACTUAL"), showProgress = FALSE)
setnames(pa, toupper(sub("^[^A-Z0-9_]+", "", names(pa))))
pc <- fread(file.path(EXP, "C_POSTULANTES_SELECCION_PAES_2026_PUB_MRUN.csv"), sep = ";", encoding = "Latin-1",
            select = c("MRUN", "ESTADO_PREF"), showProgress = FALSE)
setnames(pc, toupper(sub("^[^A-Z0-9_]+", "", names(pc))))
pd <- fread(file.path(EXP, "D_MATRICULA_PAES_2026_2026_PUB_MRUN.csv"), sep = ";", encoding = "Latin-1",
            select = "MRUN", showProgress = FALSE)
setnames(pd, toupper(sub("^[^A-Z0-9_]+", "", names(pd))))
PAES <- list(a = pa, c = pc, d = pd)
saveRDS(PAES, file.path(OUTD, "paes_2026.rds"))
say("wrote paes_2026.rds | a %s | c %s | d %s rows",
    format(nrow(pa), big.mark = ","), format(nrow(pc), big.mark = ","), format(nrow(pd), big.mark = ","))
rm(pa, pc, pd, PAES); invisible(gc())

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

# ---- matricula census 2024-2025 supplement ----------------------------------
# Piece 2's persistence measure needs the 12th-grade years of the last cohorts
# (entry 2021-2022 -> 12th grade 2024-2025). Kept as a supplement file so the
# certified matricula_2011_2023.rds and everything reading it stay untouched.
say("=== matricula supplement 2024-2025 ===")
MATS <- list()
for (y in 2024L:2025L) {
  f <- big_csv("Matricula-por-estudiante", y, floor = 50e6)
  stopifnot("matricula supplement year file must exist" = !is.na(f))
  M <- rd_csv(f, sel = sel)
  stopifnot(all(sel %in% names(M)))
  MATS[[as.character(y)]] <- M[, .(agno = y, MRUN, RBD, COD_ENSE, COD_GRADO)]
  rm(M); invisible(gc())
  say("matricula %d packed | %.1f min", y, (proc.time() - t0)[["elapsed"]] / 60)
}
MATS <- rbindlist(MATS)
saveRDS(MATS, file.path(OUTD, "matricula_2024_2025.rds"))
say("wrote matricula_2024_2025.rds | %s rows", format(nrow(MATS), big.mark = ","))
rm(MATS); invisible(gc())

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

# ---- rendimiento (school records) supplement 2024-2025 ----------------------
# Piece 2's grad-on-time outcome needs 12th-grade promotion status for the last
# cohorts (on-time 12th grade falls in 2024-2025). The canonical graded panel
# ends 2023; these two years are kept as a supplement file so it stays
# untouched. Files resolved by CONTENT, never by filename (2026-08-06 gate
# report, defect 1).
say("=== rendimiento supplement 2024-2025 ===")
find_rend <- function(yr) {
  cand <- unlist(lapply(c(DL, EX2)[dir.exists(c(DL, EX2))], function(d)
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
RNDL <- list()
for (y in 2024L:2025L) {
  D <- rd_csv(find_rend(y), sel = c("MRUN", "AGNO", "COD_ENSE", "COD_GRADO", "SIT_FIN_R"))
  stopifnot(all(c("MRUN", "AGNO", "COD_ENSE", "COD_GRADO", "SIT_FIN_R") %in% names(D)),
            "file must carry exactly its own year" = uniqueN(D$AGNO) == 1L && D$AGNO[1] == y)
  RNDL[[as.character(y)]] <- D[, .(agno = y, MRUN, COD_ENSE, COD_GRADO, SIT_FIN_R)]
  rm(D); invisible(gc())
  say("rendimiento %d packed | %.1f min", y, (proc.time() - t0)[["elapsed"]] / 60)
}
RNDL <- rbindlist(RNDL)
saveRDS(RNDL, file.path(OUTD, "rendimiento_2024_2025.rds"))
say("wrote rendimiento_2024_2025.rds | %s rows", format(nrow(RNDL), big.mark = ","))
rm(RNDL); invisible(gc())

say("total elapsed %.1f min", (proc.time() - t0)[["elapsed"]] / 60)
cat("DONE\n")
