# =============================================================================
# 88_mech_panel_validation.R -- full-population validation of every NEW column
# in lottery_panel_mech.rds against its source files, with INDEPENDENT
# re-derivations (different code paths than the build wherever the construction
# allows one). Pattern of Piece 2's checks/86_panel_validation.R.
#
# Run from the Piece 3 folder: the panel and supplement are found next to the
# code (or in the shared data folder), the shared inputs through the standard
# chain, and the raw Rendimiento csvs at RAW_DIR (repoint to your copies).
# Prints one PASS/FAIL line per check; any FAIL stops the script at the end
# with a non-zero exit. No sampling: every check runs over all 395,950 rows.
# =============================================================================
suppressPackageStartupMessages({ library(data.table); library(tools) })
setDTthreads(4); options(warn = 1)
stopifnot("R 4.5.1 required (piece standard)" = getRversion() == "4.5.1")
t0 <- proc.time()
home <- ifelse(Sys.getenv("USERPROFILE") != "", Sys.getenv("USERPROFILE"), path.expand("~"))
ROOT <- file.path(home, "Dropbox", "Effect of Centralization")
PIECE <- file.path(ROOT, "Updated Paper Spine", "Piece 3")
RAW_DIR <- file.path(ROOT, "explorations", "2026-08-03_grade7_door", "downloads", "extracted")
data_path <- function(f) {
  for (p in c(file.path(PIECE, f),
              file.path(home, "Dropbox", "Effect SAE on SUA", "data", f),
              file.path(ROOT, "code", "data", f),
              file.path(ROOT, "Updated Paper Spine", "Piece 2", f),
              file.path(ROOT, "Updated Paper Spine", "Piece 1", "data", f)))
    if (file.exists(p)) return(p)
  stop(sprintf("input file not found in any data location: %s", f))
}
say <- function(...) { cat(sprintf(...), "\n"); flush.console() }
RES <- list()
chk <- function(name, ok, detail = "") {
  RES[[length(RES) + 1L]] <<- data.table(check = name, pass = ok, detail = detail)
  say("%-52s %s %s", name, ifelse(ok, "PASS", "FAIL"), detail)
}
YM <- c(310L, 410L, 510L, 610L, 710L, 810L, 910L)

MP <- as.data.table(readRDS(data_path("lottery_panel_mech.rds")))
N  <- nrow(MP)

## V1 -- the stamped columns are byte-identical to the stamped panel ----------
fp <- data_path("lottery_panel.rds")
chk("V1a stamped panel MD5", unname(md5sum(fp)) == "acb5b2fff844f8692f234442273ab4c8")
P0 <- as.data.table(readRDS(fp))
same <- vapply(names(P0), function(cn) identical(P0[[cn]], MP[[cn]]), logical(1))
chk("V1b stamped columns identical, row order preserved", all(same) && nrow(P0) == N,
    paste("cols equal:", sum(same), "of", length(same)))
NEWC <- c("gpa9", "gpa9_z", "pct9", "has_g9", "gpa4", "gpa4_z", "has_4yr", "pct12",
          "rank_hist_z", "hist_n", "in_room9", "peer_n", "peer_cov", "peer_gpa8_z",
          "exam_lm", "nem", "ranking", "exam_z", "nem_z", "ranking_z", "exam_z_floor",
          "has_exam")
chk("V1c column set = 27 stamped + exactly the 22 new (both directions)",
    length(setdiff(names(MP), c(names(P0), NEWC))) == 0L &&
      length(setdiff(c(names(P0), NEWC), names(MP))) == 0L &&
      ncol(MP) == ncol(P0) + length(NEWC))
rm(P0); invisible(gc())

## V2 -- the grades supplement equals an independent read of the raw csvs -----
SUP <- as.data.table(readRDS(data_path("rendimiento_grades_2024_2025.rds")))
raw_files <- c(`2024` = file.path(RAW_DIR, "20250212_Rendimiento_2024_20250131_WEB.csv"),
               `2025` = file.path(RAW_DIR, "20260210_Rendimiento_2025_20260202_WEB.csv"))
# V2 re-reads the two raw public releases the supplement was packed from. They
# are large csvs and are NOT shipped in the package; set RAW_DIR (top of this
# file) to the folder holding your copies. Stop here with an actionable message
# rather than failing deep inside the first fread.
if (!all(file.exists(raw_files)))
  stop(sprintf(paste0("raw Rendimiento releases not found -- set RAW_DIR at the top of this ",
                      "script to the folder holding %s and %s (currently RAW_DIR = %s)"),
               basename(raw_files[["2024"]]), basename(raw_files[["2025"]]), RAW_DIR))
for (y in c("2024", "2025")) {
  R <- fread(raw_files[[y]], sep = ";", encoding = "Latin-1", showProgress = FALSE,
             na.strings = c("", "NA"),
             select = c("MRUN", "AGNO", "RBD", "COD_ENSE", "COD_GRADO", "PROM_GRAL", "SIT_FIN_R"))
  if (is.character(R$PROM_GRAL)) R[, PROM_GRAL := as.numeric(sub(",", ".", PROM_GRAL, fixed = TRUE))]
  R <- R[, .(MRUN = as.integer(MRUN), AGNO = as.integer(AGNO), RBD = as.integer(RBD),
             COD_ENSE = as.integer(COD_ENSE), COD_GRADO = as.integer(COD_GRADO),
             PROM_GRAL = as.numeric(PROM_GRAL), SIT_FIN_R = as.character(SIT_FIN_R))]
  S <- SUP[AGNO == as.integer(y)]
  setorderv(R, names(R)); setorderv(S, names(S))
  chk(sprintf("V2 supplement %s equals raw csv (all rows, all cols)", y),
      isTRUE(all.equal(as.data.frame(R), as.data.frame(S), check.attributes = FALSE)),
      sprintf("raw %s vs packed %s rows", format(nrow(R), big.mark = ","), format(nrow(S), big.mark = ",")))
  rm(R, S); invisible(gc())
}

chk("V2c supplement carries ONLY years 2024-2025",
    SUP[!AGNO %in% 2024:2025, .N] == 0L && !anyNA(SUP$AGNO))

## Rebuild the graded base fresh (shared by V3-V10) ---------------------------
# Anchor the two unpinned canonical inputs: record their MD5s in the output so
# the validated state is tied to specific file bytes, and floor their coverage
# so a truncated or swapped source fails loudly instead of passing vacuously.
fpp <- data_path("panel_performance_2002_2023.rds")
say("input anchor: panel_performance_2002_2023.rds MD5 %s", unname(md5sum(fpp)))
fpm <- data_path("matricula_2011_2023.rds")
say("input anchor: matricula_2011_2023.rds MD5 %s", unname(md5sum(fpm)))
PF <- as.data.table(readRDS(fpp))
G8F <- PF[COD_GRADO == 8L & COD_ENSE == 110L & AGNO %in% 2016:2021 &
            !is.na(PROM_GRAL) & PROM_GRAL >= 1 & PROM_GRAL <= 7,
          .(gpa8 = mean(PROM_GRAL)), by = .(MRUN, AGNO)]
G8F[, z := (gpa8 - mean(gpa8)) / sd(gpa8), by = AGNO]
G8Y <- G8F[, .N, by = AGNO]
chk("V2d 8th-grade z base: years 2016-2021 present, >= 150k students each",
    G8Y[, .N] == 6L && all(2016:2021 %in% G8Y$AGNO) && G8Y[, all(N >= 150000L)])
MEDv <- PF[COD_ENSE %in% YM & COD_GRADO %in% 1:4 & AGNO %in% 2014:2023 &
             !is.na(PROM_GRAL) & PROM_GRAL >= 1 & PROM_GRAL <= 7,
           .(MRUN, AGNO, RBD, COD_GRADO, PROM_GRAL, sit = SIT_FIN_R)]
rm(PF); invisible(gc())
MEDv <- rbind(MEDv, SUP[COD_ENSE %in% YM & COD_GRADO %in% 1:4 &
                          !is.na(PROM_GRAL) & PROM_GRAL >= 1 & PROM_GRAL <= 7,
                        .(MRUN, AGNO, RBD, COD_GRADO, PROM_GRAL, sit = SIT_FIN_R)])
MEDY <- MEDv[, .N, by = AGNO]
chk("V2e media base: years 2014-2025 present, >= 500k graded rows each",
    MEDY[, .N] == 12L && all(2014:2025 %in% MEDY$AGNO) && MEDY[, all(N >= 500000L)])
# duplicate-key conflicts, made visible and bounded before the dedup:
# a (student, year, school, grade) key carrying two different grades or two
# different exit statuses is resolved keep-first identically in build and
# validation, so it is invisible to the value comparisons. Assert no
# conflicting-GRADE key can reach any output: none on a panel child's on-time
# cells, and none belonging to a promoted 12th grader of the history class
# years (the two routes into the mechanism columns).
DUPK <- MEDv[, .(ng = uniqueN(PROM_GRAL), ns = uniqueN(sit), n = .N),
             by = .(MRUN, AGNO, RBD, COD_GRADO)][n > 1L]
say("duplicate keys pre-dedup: %d | conflicting grade: %d | conflicting status: %d",
    nrow(DUPK), DUPK[ng > 1L, .N], DUPK[ns > 1L, .N])
GK <- DUPK[ng > 1L, .(MRUN, AGNO, COD_GRADO)]
cells <- rbindlist(lapply(1:4, function(k)
  data.table(MRUN = MP$MRUN, AGNO = MP$proc + k, COD_GRADO = k)))
chk("V2f no conflicting-grade key on a panel child's on-time cell",
    nrow(GK[unique(cells), on = .(MRUN, AGNO, COD_GRADO), nomatch = 0L]) == 0L)
H12 <- unique(MEDv[COD_GRADO == 4L & sit == "P" & AGNO %in% 2017:2024, .(MRUN)])
chk("V2g no conflicting-grade key belongs to a history-class member",
    nrow(GK[H12, on = .(MRUN), nomatch = 0L]) == 0L)
DUPKsav <- copy(DUPK)   # kept for the V13 conflict-resolution checks at the end
rm(G8Y, MEDY, DUPK, GK, cells, H12)
# promoted-12th set captured BEFORE dedup (any record of the key says P),
# mirroring the build's order-invariant membership convention
P12Fv <- unique(MEDv[COD_GRADO == 4L & sit == "P", .(MRUN, AGNO, RBD)])
MEDv <- unique(MEDv, by = c("MRUN", "AGNO", "RBD", "COD_GRADO"))
MCv <- MEDv[, .(v = mean(PROM_GRAL)), by = .(MRUN, AGNO, COD_GRADO)]
rm(SUP); invisible(gc())

cmp_num <- function(a, b, tol) {
  na_ok <- !any(is.na(a) != is.na(b))
  d <- suppressWarnings(max(abs(a - b), na.rm = TRUE))
  list(ok = na_ok && (is.infinite(d) || d < tol), d = d, na_ok = na_ok)
}

## V3/V4 -- own 9th-grade GPA and national z ----------------------------------
GV <- MCv[COD_GRADO == 1L & AGNO %in% 2017:2022]
GV[, z := (v - mean(v)) / sd(v), by = AGNO]
q1 <- data.table(MRUN = MP$MRUN, AGNO = MP$proc + 1L)
v9 <- GV[q1, on = .(MRUN, AGNO), x.v]; z9 <- GV[q1, on = .(MRUN, AGNO), x.z]
r <- cmp_num(MP$gpa9, v9, 1e-12)
chk("V3 gpa9 re-derivation (values + NA pattern)", r$ok, sprintf("maxdiff %.2e", r$d))
r <- cmp_num(MP$gpa9_z, z9, 1e-10)
chk("V4 gpa9_z re-derivation", r$ok, sprintf("maxdiff %.2e", r$d))
rm(GV, v9, z9)

## V5 -- pct9 via the counting formula (nless + neq/2)/N ----------------------
pct_count <- function(D) {
  # D: MRUN, AGNO, RBD, PROM_GRAL rows; percentile per record, then per-student mean
  CT <- D[, .(n = .N), by = .(RBD, AGNO, PROM_GRAL)]
  setorder(CT, RBD, AGNO, PROM_GRAL)
  CT[, nless := cumsum(shift(n, fill = 0L)), by = .(RBD, AGNO)]
  CT[, Ntot := sum(n), by = .(RBD, AGNO)]
  CT[, p := (nless + n / 2) / Ntot]
  D2 <- merge(D, CT[, .(RBD, AGNO, PROM_GRAL, p)], by = c("RBD", "AGNO", "PROM_GRAL"))
  D2[, .(pct = mean(p)), by = .(MRUN, AGNO)]
}
PC9 <- pct_count(MEDv[COD_GRADO == 1L & AGNO %in% 2017:2022,
                      .(MRUN, AGNO, RBD, PROM_GRAL)])
p9 <- PC9[q1, on = .(MRUN, AGNO), x.pct]
r <- cmp_num(MP$pct9, p9, 1e-10)
chk("V5 pct9 via independent counting formula", r$ok, sprintf("maxdiff %.2e", r$d))
rm(PC9, p9)

## V6/V7 -- 4-year GPA via long-format on-time bucketing ----------------------
LG <- MCv[(AGNO - COD_GRADO + 1L) %in% 2017:2022]
LG[, e := AGNO - COD_GRADO + 1L]
G4V <- LG[, .(n_gr = uniqueN(COD_GRADO), gpa4v = mean(v)), by = .(MRUN, e)]
G4V <- G4V[n_gr == 4L]
qe <- data.table(MRUN = MP$MRUN, e = MP$proc + 1L)
v4 <- G4V[qe, on = .(MRUN, e), x.gpa4v]
r <- cmp_num(MP$gpa4, v4, 1e-12)
chk("V6 gpa4 via long-format on-time bucketing", r$ok, sprintf("maxdiff %.2e", r$d))
# national z: same complete-cases population (grade-1-in-e is implied by n_gr==4)
G4V[, z4 := (gpa4v - mean(gpa4v)) / sd(gpa4v), by = e]
z4 <- G4V[qe, on = .(MRUN, e), x.z4]
r <- cmp_num(MP$gpa4_z, z4, 1e-10)
chk("V7 gpa4_z national-cohort z", r$ok, sprintf("maxdiff %.2e", r$d))
rm(LG, v4, z4)

## V8 -- pct12 via the counting formula ---------------------------------------
PC12 <- pct_count(MEDv[COD_GRADO == 4L & AGNO %in% 2020:2025,
                       .(MRUN, AGNO, RBD, PROM_GRAL)])
q4 <- data.table(MRUN = MP$MRUN, AGNO = MP$proc + 4L)
p12 <- PC12[q4, on = .(MRUN, AGNO), x.pct]
r <- cmp_num(MP$pct12, p12, 1e-10)
chk("V8 pct12 via independent counting formula", r$ok, sprintf("maxdiff %.2e", r$d))
rm(PC12, p12)

## V9 -- rank_hist_z via per-class sufficient statistics ----------------------
R12v <- MEDv[COD_GRADO == 4L]
CH12 <- R12v[AGNO %in% 2020:2025, .(nsch = uniqueN(RBD), RBD = RBD[1L]), by = .(MRUN, AGNO)]
CHv <- data.table(MRUN = MP$MRUN, g = MP$proc + 4L)
CHv[, RBD := CH12[nsch == 1L][CHv, on = .(MRUN, AGNO = g), x.RBD]]
HSv <- unique(CHv[!is.na(RBD), .(RBD, g)])
MEv <- unique(R12v[P12Fv, on = .(MRUN, AGNO, RBD), nomatch = 0L][
  RBD %in% HSv$RBD & AGNO %in% 2017:2024, .(MRUN, gy = AGNO, RBD)])
# member media average, independent route: merge then filter window, aggregate
MW <- merge(MEv, MCv[, .(MRUN, AGNO, v)], by = "MRUN", allow.cartesian = TRUE)
MW <- MW[AGNO >= gy - 3L & AGNO <= gy][, .(m = mean(v)), by = .(MRUN, gy, RBD)]
# per-class sufficient stats, pooled over the three class years by sums
CLS <- MW[, .(n = .N, s = sum(m), ss = sum(m^2)), by = .(RBD, gy)]
HXv <- HSv[rep(seq_len(nrow(HSv)), each = 3L)]
HXv[, gy := g - rep(1:3, times = nrow(HSv))]
PLD <- merge(HXv, CLS, by = c("RBD", "gy"))[
  , .(n = sum(n), s = sum(s), ss = sum(ss), yrs = uniqueN(gy)), by = .(RBD, g)]
PLD[, `:=`(mu = s / n, sd = sqrt(pmax(ss - s^2 / n, 0) / (n - 1L)))]
PLD <- PLD[yrs == 3L & n >= 5L & sd > 0]
CHv[, mu := PLD[CHv, on = .(RBD, g), x.mu]]
CHv[, sdv := PLD[CHv, on = .(RBD, g), x.sd]]
CHv[, nn := PLD[CHv, on = .(RBD, g), x.n]]
rk <- (MP$gpa4 - CHv$mu) / CHv$sdv
r <- cmp_num(MP$rank_hist_z, rk, 1e-8)
chk("V9a rank_hist_z via sufficient statistics", r$ok, sprintf("maxdiff %.2e", r$d))
r <- cmp_num(as.numeric(MP$hist_n), as.numeric(CHv$nn), 0.5)
chk("V9b hist_n matches", r$ok)
HGY <- unique(HXv[, .(RBD, gy)])          # used history class-year cells (for V13a)
C12C <- copy(HSv)                          # panel children's 12th-grade cohorts (for V13b)
MEsav <- copy(MEv[, .(MRUN, gy, RBD)])     # re-derived member set (for V13a)
rm(R12v, CH12, CHv, HSv, MEv, MW, CLS, HXv, PLD, rk); invisible(gc())

## V10 -- peer measure via cohort means (algebraic leave-one-out) -------------
MATC <- readRDS(data_path("matricula_2011_2023.rds"))
C9v <- unique(MATC[COD_ENSE %in% YM & COD_GRADO == 1L & agno %in% 2017:2022,
                   .(agno, MRUN = as.integer(MRUN), RBD = as.integer(RBD))])
rm(MATC); invisible(gc())
C9Y <- C9v[, .N, by = agno]
chk("V10e census 9th-grade base: years 2017-2022 present, >= 150k rows each",
    C9Y[, .N] == 6L && all(2017:2022 %in% C9Y$agno) && C9Y[, all(N >= 150000L)])
rm(C9Y)
C9v[, agno8 := agno - 1L]
C9v[, z8 := G8F[C9v, on = .(MRUN, AGNO = agno8), x.z]]
CSv <- C9v[, .(mz = mean(z8, na.rm = TRUE), K = sum(!is.na(z8)), Ntot = .N), by = .(RBD, agno)]
CCv <- C9v[, .(nsch = uniqueN(RBD), RBD = RBD[1L], z8 = z8[1L]), by = .(MRUN, agno)]
CCv <- CCv[nsch == 1L]
Qv <- data.table(MRUN = MP$MRUN, agno = MP$proc + 1L)
Qv[, RBD := CCv[Qv, on = .(MRUN, agno), x.RBD]]
Qv[, z8  := CCv[Qv, on = .(MRUN, agno), x.z8]]
Qv[, mz := CSv[Qv, on = .(RBD, agno), x.mz]]
Qv[, K  := CSv[Qv, on = .(RBD, agno), x.K]]
Qv[, Ntot := CSv[Qv, on = .(RBD, agno), x.Ntot]]
Qv[, own := as.integer(!is.na(z8))]
peer_v <- with(Qv, fifelse(is.na(RBD) | (K - own) < 1L, NA_real_,
                           fifelse(own == 1L, (K * mz - z8) / (K - 1L), mz)))
r <- cmp_num(MP$peer_gpa8_z, peer_v, 1e-9)
chk("V10a peer_gpa8_z via cohort-mean algebra", r$ok, sprintf("maxdiff %.2e", r$d))
pn <- with(Qv, fifelse(is.na(RBD) | Ntot - 1L < 1L, NA_integer_, Ntot - 1L))
chk("V10b peer_n matches", identical(MP$peer_n, pn))
pc <- with(Qv, fifelse(is.na(RBD) | Ntot - 1L < 1L, NA_real_, (K - own) / (Ntot - 1L)))
r <- cmp_num(MP$peer_cov, pc, 1e-12)
chk("V10c peer_cov matches", r$ok)
chk("V10d in_room9 = census presence", identical(MP$in_room9, as.integer(!is.na(Qv$RBD))))
C9C <- unique(Qv[!is.na(RBD), .(RBD, agno)])   # children's 9th-grade cohorts (for V13b)
rm(C9v, CSv, CCv, Qv, peer_v, pn, pc, G8F); invisible(gc())

## V11 -- exam / nem / ranking straight from the stamped outcome table --------
fc <- data_path("college_outcomes_2018_2026.rds")
chk("V11a outcome table MD5", unname(md5sum(fc)) == "28dd1874092a0835bbcb11839ff2e57c")
CO <- as.data.table(readRDS(fc))
qc <- data.table(mrun = MP$MRUN, proc = MP$proc + 5L)
oc <- CO[qc, on = .(mrun, proc)]
chk("V11b exam_lm identical to outcome table", identical(MP$exam_lm, oc$exam_lm))
chk("V11c nem identical",     identical(MP$nem, oc$nem))
chk("V11d ranking identical", identical(MP$ranking, oc$ranking))
chk("V11e exam_lm never 0 (NA for non-takers, no zero scores)",
    MP[!is.na(exam_lm) & exam_lm <= 0, .N] == 0L)
# z columns re-derived from the fresh CO read (national within-process, scored rows)
for (sc in c("exam_lm", "nem", "ranking")) {
  zc <- c(exam_lm = "exam_z", nem = "nem_z", ranking = "ranking_z")[[sc]]
  CO[, zz := NA_real_]
  CO[!is.na(get(sc)), zz := (get(sc) - mean(get(sc))) / sd(get(sc)), by = proc]
  zv <- CO[qc, on = .(mrun, proc), x.zz]
  r <- cmp_num(MP[[zc]], zv, 1e-10)
  chk(sprintf("V11f %s national within-process z re-derived", zc), r$ok,
      sprintf("maxdiff %.2e", r$d))
}
chk("V11g z NA patterns mirror the raw scores",
    !any(is.na(MP$exam_z) != is.na(MP$exam_lm)) &&
      !any(is.na(MP$nem_z) != is.na(MP$nem)) &&
      !any(is.na(MP$ranking_z) != is.na(MP$ranking)))
# floor-imputed exam column: re-derive the per-process floor z independently
FLv <- CO[!is.na(exam_lm),
          .(mn = min(exam_lm), mu = mean(exam_lm), sdv = sd(exam_lm)), by = proc]
FLv[, fz := (mn - mu) / sdv]
fzv <- FLv[data.table(proc = MP$proc + 5L), on = .(proc), x.fz]
efv <- fifelse(!is.na(MP$exam_z), MP$exam_z, fzv)
r <- cmp_num(MP$exam_z_floor, efv, 1e-12)
chk("V11h exam_z_floor re-derived (score where sat, process floor z where not)",
    r$ok && !anyNA(MP$exam_z_floor), sprintf("maxdiff %.2e", r$d))
rm(FLv, fzv, efv)
rm(CO, qc, oc); invisible(gc())

## V12 -- flags and ranges ----------------------------------------------------
chk("V12a has_g9 = !is.na(gpa9)",   identical(MP$has_g9,   as.integer(!is.na(MP$gpa9))))
chk("V12b has_4yr = !is.na(gpa4)",  identical(MP$has_4yr,  as.integer(!is.na(MP$gpa4))))
chk("V12c has_exam = !is.na(exam)", identical(MP$has_exam, as.integer(!is.na(MP$exam_lm))))
chk("V12d gpa9, gpa4 inside [1,7]",
    MP[!is.na(gpa9) & (gpa9 < 1 | gpa9 > 7), .N] == 0L &&
      MP[!is.na(gpa4) & (gpa4 < 1 | gpa4 > 7), .N] == 0L)
chk("V12e pct9, pct12 inside (0,1)",
    MP[!is.na(pct9) & (pct9 <= 0 | pct9 >= 1), .N] == 0L &&
      MP[!is.na(pct12) & (pct12 <= 0 | pct12 >= 1), .N] == 0L)
chk("V12f peer_cov inside [0,1]",
    MP[!is.na(peer_cov) & (peer_cov < 0 | peer_cov > 1), .N] == 0L)
chk("V12g hist_n >= 5 wherever rank_hist_z present",
    MP[!is.na(rank_hist_z) & (is.na(hist_n) | hist_n < 5L), .N] == 0L)
chk("V12h rank/pct12 only where 12th-grade record exists",
    MP[is.na(pct12) & !is.na(rank_hist_z), .N] == 0L)
chk("V12i gpa9_z / gpa4_z / peer_gpa8_z / rank_hist_z all finite",
    MP[, sum(!is.finite(gpa9_z) & !is.na(gpa9_z)) + sum(!is.finite(gpa4_z) & !is.na(gpa4_z)) +
         sum(!is.finite(peer_gpa8_z) & !is.na(peer_gpa8_z)) +
         sum(!is.finite(rank_hist_z) & !is.na(rank_hist_z))] == 0L)

## V13 -- conflict-resolution invariance (delta re-review F1/F2) ---------------
# Keep-first dedup can only matter where a duplicate key carries conflicting
# values AND sits where the mechanism columns read it. V2f/V2g covered a panel
# child's own cells and history membership by student; these two close the
# remaining routes: promotion-status conflicts deciding membership in a USED
# history class, and grade conflicts inside a panel child's school cohort
# (the percentile and history-pool denominators).
# status-mixed keys can no longer flip membership: promoted = any record says P,
# decided pre-dedup. Assert that resolution held for every mixed key in a used
# class: in the member set exactly when some record of the key says P.
MIXH <- DUPKsav[ns > 1L & COD_GRADO == 4L][HGY, on = .(RBD, AGNO = gy), nomatch = 0L]
if (nrow(MIXH)) {
  MIXH[, inP  := !is.na(P12Fv[MIXH, on = .(MRUN, AGNO, RBD), which = TRUE])]
  MIXH[, inME := !is.na(MEsav[MIXH, on = .(MRUN, gy = AGNO, RBD), which = TRUE])]
}
chk("V13a status-mixed keys in used history classes: membership = any-record-promoted",
    nrow(MIXH) == 0L || MIXH[inP != inME, .N] == 0L,
    sprintf("mixed keys %d, resolved order-invariantly", nrow(MIXH)))
GKR <- DUPKsav[ng > 1L, .(RBD, AGNO, COD_GRADO)]
coh <- rbind(C9C[, .(RBD, AGNO = agno, COD_GRADO = 1L)],
             C12C[, .(RBD, AGNO = g, COD_GRADO = 4L)])
GKC <- GKR[unique(coh), on = .(RBD, AGNO, COD_GRADO), nomatch = 0L]
chk("V13b no grade-conflict key inside a panel child's school cohort",
    nrow(GKC) == 0L, sprintf("hits %d", nrow(GKC)))
rm(DUPKsav, HGY, C12C, C9C, MIXH, GKR, coh, GKC, MEsav, P12Fv)

## Summary ---------------------------------------------------------------------
R <- rbindlist(RES)
say("\n%d checks | %d PASS | %d FAIL | %.1f min",
    nrow(R), R[pass == TRUE, .N], R[pass == FALSE, .N], (proc.time() - t0)[["elapsed"]] / 60)
if (R[pass == FALSE, .N] > 0L) { print(R[pass == FALSE]); quit(status = 3L) }
cat("ALL CHECKS PASS\n")
