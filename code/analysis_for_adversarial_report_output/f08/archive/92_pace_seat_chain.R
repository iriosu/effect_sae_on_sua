# =============================================================================
# 92_pace_seat_chain.R -- DECOMP-PACE-SEAT-2026-08-26 (registered addendum).
# The full three-link PACE chain: school in the program -> lists the route ->
# wins a guaranteed seat. Splits the seated-through-PACE loss so the conversion
# stage (where the verified top-25% rank standard operates) gets its own
# estimate. Frame, fold flags, and school flag rebuilt verbatim from the record
# document; record ITTs must reproduce or the run halts.
# =============================================================================
suppressPackageStartupMessages({ library(data.table); library(fixest); library(tools) })
setDTthreads(4); options(warn = 1)
B_RI <- 9999L

home <- ifelse(Sys.getenv("USERPROFILE") != "", Sys.getenv("USERPROFILE"), path.expand("~"))
ROOT <- file.path(home, "Dropbox", "Effect of Centralization")
P4   <- file.path(ROOT, "Updated Paper Spine", "Piece 4")
OUTD <- file.path(ROOT, "explorations", "2026-08-17_piece3_mechanism", "output")
say <- function(...) { cat(sprintf(...), "\n"); flush.console() }
star <- function(p) ifelse(p < .01, "***", ifelse(p < .05, "**", ifelse(p < .1, "*", "")))
data_here <- function(f) {
  for (p in c(file.path(P4, "data", f),
              file.path(ROOT, "Updated Paper Spine", "Piece 3", f),
              file.path(ROOT, "Updated Paper Spine", "Piece 2", f),
              file.path(OUTD, f),
              file.path(home, "Dropbox", "Effect SAE on SUA", "data", f)))
    if (file.exists(p)) return(p)
  stop(sprintf("input not found: %s", f))
}
make_frame <- function(P, W, pur, cap, fc) {
  M <- copy(P); if (fc) M <- M[PREF == 1L]
  CU <- M[won == 1L, .(cutoff = max(loteria), n_win = .N), by = key]; M <- merge(M, CU, by = "key")[n_win >= W]
  M[, viol := won == 0L & loteria < cutoff]
  PU <- M[won == 0L, .(n_los = .N, n_viol = sum(viol)), by = key]
  M <- merge(M, PU, by = "key")[n_los >= 1L][n_viol / n_los <= pur]
  L <- M[won == 0L & loteria >= cutoff]
  if (cap) { setorder(L, key, loteria); L[, rk := seq_len(.N), by = key]; L <- L[rk <= n_win] }
  rbind(M[won == 1L], L, fill = TRUE)
}
core <- function(DT, y) {
  DT <- DT[!is.na(get(y))]; setorder(DT, key)
  KX <- DT[, .(i0 = .I[1], n = .N, m = sum(won)), by = key][m > 0L & m < n]
  DT <- DT[key %in% KX$key]; setorder(DT, key)
  KX <- DT[, .(i0 = .I[1], n = .N, m = sum(won)), by = key]
  denom <- KX[, sum(m * (n - m) / n)]; yv <- as.numeric(DT[[y]])
  base <- DT[, .(b = mean(get(y)) * sum(won)), by = key]$b
  obs <- (sum(yv * DT$won) - sum(base)) / denom
  pn <- numeric(B_RI)
  for (r in seq_len(nrow(KX))) { i0 <- KX$i0[r]; n <- KX$n[r]; m <- KX$m[r]
    yk <- yv[i0:(i0 + n - 1L)]; pn <- pn + .colSums(yk[replicate(B_RI, sample.int(n, m))], m, B_RI) }
  perm <- (pn - sum(base)) / denom
  fit <- feols(as.formula(paste0(y, " ~ won | key")), data = DT, cluster = ~sch_year, fixef.rm = "none")
  ct <- summary(fit)$coeftable
  stopifnot("closed form must equal the regression point" = abs(unname(ct["won", 1]) - obs) < 1e-8)
  data.table(itt = obs, se = ct["won", 2],
             ri_p = (1 + sum(abs(perm) >= abs(obs) - 1e-12)) / (B_RI + 1),
             n = nrow(DT), k = uniqueN(DT$key),
             lm = DT[won == 0L, mean(get(y))], win_mean = DT[won == 1L, mean(get(y))])
}
chain_run <- function(A, G) {
  A <- copy(A); setorder(A, key)
  KX <- A[, .(i0 = .I[1], n = .N, m = sum(won)), by = key]
  stopifnot("all strata mixed" = KX[, all(m > 0L & m < n)])
  om <- KX[, m * (n - m) / n]; Som <- sum(om)
  YM <- as.matrix(A[, ..G]) * 1.0
  grp <- rep.int(seq_len(nrow(KX)), KX$n)
  TOT <- rowsum(YM, group = grp, reorder = FALSE)
  Sob <- rowsum(YM * A$won, group = grp, reorder = FALSE)
  cw <- om / KX$m; cl <- om / (KX$n - KX$m)
  lev <- function(S) list(w = colSums(cw * S) / Som, l = colSums(cl * (TOT - S)) / Som)
  splitk <- function(w, l) {
    rw <- w / c(1, head(w, -1)); rl <- l / c(1, head(l, -1))
    list(rw = rw, rl = rl, d = vapply(seq_along(rw), function(k)
      prod(rw[seq_len(k - 1L)]) * (rw[k] - rl[k]) * prod(rl[-seq_len(k)]), numeric(1)))
  }
  LO <- lev(Sob); DO <- splitk(LO$w, LO$l); d_obs <- DO$d
  set.seed(20260919)
  WA <- matrix(0, length(G), B_RI); LA <- matrix(0, length(G), B_RI)
  for (r in seq_len(nrow(KX))) {
    i0 <- KX$i0[r]; n <- KX$n[r]; m <- KX$m[r]
    idx <- replicate(B_RI, sample.int(n, m))
    blk <- YM[i0:(i0 + n - 1L), , drop = FALSE]
    for (g in seq_along(G)) {
      s <- .colSums(blk[idx, g], m, B_RI)
      WA[g, ] <- WA[g, ] + cw[r] * s
      LA[g, ] <- LA[g, ] + cl[r] * (TOT[r, g] - s)
    }
    if (r %% 400 == 0) say("  reshuffles: stratum %d of %d", r, nrow(KX))
  }
  WA <- WA / Som; LA <- LA / Som
  DPERM <- vapply(seq_len(B_RI), function(b) splitk(WA[, b], LA[, b])$d, numeric(length(G)))
  ri_p <- vapply(seq_along(G), function(g)
    (1 + sum(abs(DPERM[g, ]) >= abs(d_obs[g]) - 1e-12)) / (B_RI + 1), numeric(1))
  list(d = d_obs, p = ri_p, DO = DO, LO = LO, tot = sum(d_obs))
}

## ---- frame, fold flags, school flag: verbatim from the record document -----
stopifnot(unname(md5sum(data_here("lottery_panel_mech.rds"))) == "6296a6de9feb98a18b5fc850e7b3a275")
Pm <- as.data.table(readRDS(data_here("lottery_panel_mech.rds")))
A  <- make_frame(copy(Pm)[, key := paste(key, prioritario)], 5L, 0.10, TRUE, TRUE)
stopifnot(nrow(A) == 45123L && uniqueN(A$key) == 1215L)
A[, cyear := proc + 5L]
ST <- as.data.table(readRDS(data_here("score_students.rds")))
qi <- A[, .(MRUN, YEAR = cyear)]
A[, `:=`(raw_grad = fifelse(is.na(grad_ontime), 0L, as.integer(grad_ontime)), raw_reg = 0L, raw_both = 0L)]
A[!is.na(ST[qi, on = .(MRUN, YEAR), which = TRUE]), raw_reg := 1L]
A[which(ST[qi, on = .(MRUN, YEAR), !is.na(x.clec) & !is.na(x.mate1)]), raw_both := 1L]
A[, g3 := as.integer(raw_grad == 1L & raw_reg == 1L & raw_both == 1L & applied == 1L)]
AP <- A[g3 == 1L]
stopifnot(nrow(AP) == 15906L)
KXa <- AP[, .(n = .N, m = sum(won)), by = key][m > 0L & m < n]
EF <- AP[key %in% KXa$key]
stopifnot(nrow(EF) == 15392L && uniqueN(EF$key) == 1069L)

PALL <- as.data.table(readRDS(data_here("score_prefs.rds")))
kap <- EF[, .(MRUN, YEAR = cyear)]
PQ <- merge(PALL, kap, by = c("MRUN", "YEAR"))
PQ2 <- PQ[, .(l_pace = as.integer(any(tipo == "PACE")),
              s_pace = as.integer(any(tipo == "PACE" & estado == 24L))), by = .(MRUN, YEAR)]
EF <- merge(EF, PQ2, by.x = c("MRUN", "cyear"), by.y = c("MRUN", "YEAR"), all.x = TRUE)
for (v in c("l_pace", "s_pace")) EF[is.na(get(v)), (v) := 0L]
read_route <- function(f) {
  X <- fread(data_here(f), sep = ";", encoding = "UTF-8")
  ec <- grep("^ESTADO_PREF", names(X), value = TRUE)
  X[, .(MRUN = as.integer(MRUN), YEAR = as.integer(ANYO_PROCESO),
        sel = as.integer(rowSums(as.matrix(.SD) == 24L, na.rm = TRUE) > 0)), .SDcols = ec][
    , .(sel = max(sel)), by = .(MRUN, YEAR)]
}
PACEF <- rbind(read_route("C_POSTULANTES_SELECCION_PDT_CUPOS_PACE_2021_PUB_MRUN.csv"),
               read_route("C_POSTULANTES_SELECCION_PDT_CUPOS_PACE_2022_PUB_MRUN.csv"),
               read_route("C_POSTULACIONES_SELECCION_CUPOS_PACE_2023_PAES_MRUN.csv"))
stopifnot(!anyDuplicated(PACEF, by = c("MRUN", "YEAR")))
EF[, `:=`(fl_pace = 0L, fs_pace = 0L)]
EF[!is.na(PACEF[EF, on = .(MRUN, YEAR = cyear), which = TRUE]), fl_pace := 1L]
EF[PACEF[EF, on = .(MRUN, YEAR = cyear), x.sel] %in% 1L, fs_pace := 1L]
EF[, L_PACE := as.integer(l_pace == 1L | fl_pace == 1L)]
EF[, S_PACE := as.integer(s_pace == 1L | fs_pace == 1L)]

YM <- c(310L, 410L, 510L, 610L, 710L, 810L, 910L)
PF <- as.data.table(readRDS(data_here("panel_performance_2002_2023.rds")))
R12 <- PF[COD_ENSE %in% YM & COD_GRADO == 4L & AGNO %in% 2020:2023 & !is.na(MRUN) &
            !is.na(PROM_GRAL) & PROM_GRAL >= 1 & PROM_GRAL <= 7,
          .(MRUN = as.integer(MRUN), AGNO = as.integer(AGNO), RBD = as.integer(RBD))]
RS <- as.data.table(readRDS(data_here("rendimiento_grades_2024_2025.rds")))
R12 <- unique(rbind(R12, RS[COD_ENSE %in% YM & COD_GRADO == 4L & !is.na(MRUN) &
                              !is.na(PROM_GRAL) & PROM_GRAL >= 1 & PROM_GRAL <= 7,
                            .(MRUN = as.integer(MRUN), AGNO = as.integer(AGNO), RBD = as.integer(RBD))]))
S12 <- R12[, .(nsch = uniqueN(RBD), RBD = RBD[1L]), by = .(MRUN, AGNO)]
S12s <- S12[nsch == 1L]
LIST_PACE <- unique(rbind(
  read_route("C_POSTULANTES_SELECCION_PDT_CUPOS_PACE_2021_PUB_MRUN.csv")[, .(MRUN, YEAR)],
  read_route("C_POSTULANTES_SELECCION_PDT_CUPOS_PACE_2022_PUB_MRUN.csv")[, .(MRUN, YEAR)],
  read_route("C_POSTULACIONES_SELECCION_CUPOS_PACE_2023_PAES_MRUN.csv")[, .(MRUN, YEAR)],
  unique(PALL[tipo == "PACE", .(MRUN, YEAR)])))
LIST_PACE[, AGNO := YEAR - 1L]
FLAG <- unique(merge(LIST_PACE, S12s, by = c("MRUN", "AGNO"))[, .(RBD, YEAR)])
EF[, AGNO12 := cyear - 1L]
EF[, sch12 := S12s[EF, on = .(MRUN, AGNO = AGNO12), x.RBD]]
EF[, S_raw := as.integer(!is.na(sch12) &
                           !is.na(FLAG[EF, on = .(RBD = sch12, YEAR = cyear), which = TRUE]))]
EF[, S := as.integer(S_raw == 1L | L_PACE == 1L)]

## ---- nesting and record reproduction (halting) -----------------------------
stopifnot("seat nests in the route" = EF[, all(S_PACE <= L_PACE)],
          "route nests in the school gate" = EF[, all(L_PACE <= S)])
RV <- fread(file.path(P4, "tables", "decomp_routes_values.csv"))
set.seed(20260919); seat <- core(EF, "S_PACE")
set.seed(20260919); door <- core(EF, "L_PACE")
stopifnot("seat ITT reproduces the record" = abs(seat$itt - RV[outcome == "S_PACE", itt]) < 1e-10,
          "route ITT reproduces the record" = abs(door$itt - RV[outcome == "L_PACE", itt]) < 1e-10)
say("record reproduced: seated through PACE %+.4f | route line %+.4f", 100 * seat$itt, 100 * door$itt)

## ---- the three-gate chain ---------------------------------------------------
R <- chain_run(EF, c("S", "L_PACE", "S_PACE"))
stopifnot("pieces add to the seat ITT" = abs(R$tot - seat$itt) < 1e-9)
# anchor the school gate to the record's arm rates (guards the whole S build)
PV <- fread(file.path(P4, "tables", "decomp_pace_values.csv"))
pr <- PV[flag == "arm rates" & piece %like% "^school in PACE"]
stopifnot("school-gate arm rates reproduce the record" =
            nrow(pr) == 1L && abs(100 * R$LO$w[1] - pr$per100) < 1e-9 &&
            abs(100 * R$LO$l[1] - pr$loser_rate) < 1e-9)
LBL <- c("her school is not in the PACE program",
         "she does not list the route, at a PACE school",
         "she lists and is not seated (conversion)")
say("\nconditional pass rates:                          winners    losers")
say("  school in PACE (of 100 applicants)              %7.2f   %7.2f", 100 * R$DO$rw[1], 100 * R$DO$rl[1])
say("  lists the route (of 100 at a PACE school)       %7.2f   %7.2f", 100 * R$DO$rw[2], 100 * R$DO$rl[2])
say("  seated through PACE (of 100 route-listers)      %7.2f   %7.2f", 100 * R$DO$rw[3], 100 * R$DO$rl[3])
say("\nthe seat loss %+.4f (SE %.4f) splits into:", 100 * seat$itt, 100 * seat$se)
for (k in 1:3)
  say("  %-46s %+9.4f %-3s  RI p %.4f", LBL[k], 100 * R$d[k], star(R$p[k]), R$p[k])
say("  adds to %+9.4f", 100 * R$tot)
fwrite(rbind(data.table(piece = LBL, per100 = 100 * R$d, ri_p = R$p, stars = star(R$p),
                        w_rate = 100 * R$DO$rw, l_rate = 100 * R$DO$rl,
                        se = NA_real_, n = NA_integer_, k = NA_integer_),
             data.table(piece = "TOTAL seated through PACE", per100 = 100 * seat$itt,
                        ri_p = seat$ri_p, stars = star(seat$ri_p),
                        w_rate = NA_real_, l_rate = NA_real_,
                        se = 100 * seat$se, n = seat$n, k = seat$k)),
       file.path(P4, "tables", "decomp_pace_seat_values.csv"))
cat("\nDONE\n")
