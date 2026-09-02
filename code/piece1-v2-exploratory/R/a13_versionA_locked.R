# a13: DID-ALLG-WT-STUD-2026-09-01, VERSION A LOCKED RUN — all six columns in
# one uninterrupted pass under the locked design (user sign-off 2026-09-01):
# w_ent weights, studentized exact RI, certified conventions. Derived from a12;
# exhibit: 12 headline cells + version A era pools. Statistic of record:
# T(w) = weighted fast ATT / sqrt(delete-one-region jackknife variance), per
# draw (the certified Piece 1- Updated rule). Same draws, same weighted
# arithmetic as a11 (package-extracted unit weights); gate: observed fast ATT
# must equal aggte simple at 1e-8; era pools recombine the gate-verified yearly
# pieces.
suppressMessages({ library(data.table); library(did); library(parallel) })
t0 <- proc.time()
stopifnot(identical(paste(R.version$major, R.version$minor, sep = "."), "4.5.1"),
          identical(as.character(packageVersion("did")), "2.1.2"))
SEED <- 20260831; B_MAIN <- 9999L; N_CORES <- 16L; BITERS <- 10000L
home <- Sys.getenv("USERPROFILE")
dp   <- file.path(home, "Dropbox", "Effect SAE on SUA", "data")
xdir <- file.path(home, "Dropbox", "Effect of Centralization",
                  "explorations", "2026-08-31_did_college_outcomes")
say <- function(...) { cat(sprintf(...), "\n"); flush.console() }
star <- function(p) ifelse(p < .01, "***", ifelse(p < .05, "**", ifelse(p < .1, "*", "")))
wmean <- function(x, w) sum(x * w) / sum(w)

# stat vector in one pass: simple (+ era pools when eras=TRUE)
stat_vec <- function(pp, wave_by_region, eras) {
  G <- wave_by_region[as.character(pp$region)] + pp$off
  G[pp$is_priv == 1L] <- Inf
  yrs <- pp$yrs; M <- pp$M; WT <- pp$WT; WU <- pp$WU
  s_num <- 0; s_den <- 0
  yn <- setNames(rep(0, length(yrs)), as.character(yrs)); yd <- yn
  for (g in sort(unique(G[is.finite(G) & G <= max(yrs)]))) {
    bi <- match(g - 1L, yrs); if (is.na(bi)) next
    tr <- G == g
    grp_w <- sum(WU[tr])
    for (t in yrs[yrs >= g]) {
      ti <- match(t, yrs)
      tr_t <- tr & !is.na(M[, ti]); tr_b <- tr & !is.na(M[, bi])
      ct_t <- (G > t) & !is.na(M[, ti]); ct_b <- (G > t) & !is.na(M[, bi])
      if (!any(tr_t) || !any(tr_b) || !any(ct_t) || !any(ct_b)) next
      att <- (wmean(M[tr_t, ti], WT[tr_t, ti]) - wmean(M[tr_b, bi], WT[tr_b, bi])) -
             (wmean(M[ct_t, ti], WT[ct_t, ti]) - wmean(M[ct_b, bi], WT[ct_b, bi]))
      s_num <- s_num + grp_w * att; s_den <- s_den + grp_w
      k <- as.character(t)
      yn[k] <- yn[k] + grp_w * att; yd[k] <- yd[k] + grp_w
    }
  }
  s <- if (s_den > 0) s_num / s_den else NA_real_
  if (!eras) return(c(simple = s))
  oi <- names(yn)[as.integer(names(yn)) %in% 2020:2022]
  ni <- names(yn)[as.integer(names(yn)) %in% 2023:2026]
  c(simple = s,
    era_old = if (sum(yd[oi]) > 0) sum(yn[oi]) / sum(yd[oi]) else NA_real_,
    era_new = if (sum(yd[ni]) > 0) sum(yn[ni]) / sum(yd[ni]) else NA_real_)
}
jk_vec <- function(pp, w, regs, idx, eras) {
  th <- stat_vec(pp, w, eras)
  L <- vapply(seq_along(regs), function(i) {
    k <- idx[[i]]
    stat_vec(list(M = pp$M[k, , drop = FALSE], WT = pp$WT[k, , drop = FALSE],
                  WU = pp$WU[k], region = pp$region[k], is_priv = pp$is_priv[k],
                  off = pp$off[k], yrs = pp$yrs), w, eras)
  }, numeric(if (eras) 3L else 1L))
  L <- matrix(L, ncol = length(regs))
  Tv <- vapply(seq_along(th), function(j) {
    lo <- L[j, ]; ok <- !is.na(lo); Rp <- sum(ok)
    v <- if (Rp >= 2L) (Rp - 1) / Rp * sum((lo[ok] - mean(lo[ok]))^2) else NA_real_
    th[j] / sqrt(v)
  }, numeric(1))
  c(th, Tv)   # first half estimates, second half studentized T
}
unit_weights <- function(at) {
  dpp <- at$DIDparams
  pd <- as.data.table(as.data.frame(dpp$data))
  if (isTRUE(dpp$panel)) {
    pd[get(dpp$tname) == dpp$tlist[1], .(cell_id = get(dpp$idname), uw = .w)]
  } else pd[, .(uw = mean(.w)), by = .(cell_id = get(dpp$idname))]
}
fitw <- function(d) {
  set.seed(SEED)
  att_gt(yname = "y", tname = "tt", idname = "cell_id", gname = "G",
         data = d, control_group = "notyettreated", panel = TRUE,
         allow_unbalanced_panel = TRUE, base_period = "universal",
         weightsname = "w", bstrap = TRUE, biters = BITERS,
         clustervars = "region", print_details = FALSE)
}
cl <- makeCluster(N_CORES)
clusterExport(cl, c("stat_vec", "jk_vec", "wmean"))
run_cell <- function(pp, eras) {
  regs <- sort(unique(pp$region))
  idx  <- lapply(regs, function(r) which(pp$region != r))
  set.seed(SEED)
  obs <- jk_vec(pp, wv, regs, idx, eras)
  regions <- as.integer(names(wv)); waves <- unname(wv)
  WPS <- vector("list", B_MAIN)
  for (b in seq_len(B_MAIN)) WPS[[b]] <- setNames(sample(waves), as.character(regions))
  clusterExport(cl, c("pp", "regs", "idx", "eras"), envir = environment())
  P <- do.call(rbind, parLapplyLB(cl, WPS,
                                  function(w) jk_vec(pp, w, regs, idx, eras),
                                  chunk.size = 64L))
  m <- if (eras) 3L else 1L
  p <- vapply(seq_len(m), function(j) {
    TT <- P[, m + j]; fin <- is.finite(TT)
    (1 + sum(abs(TT[fin]) >= abs(obs[m + j]))) / (1 + sum(fin))
  }, numeric(1))
  drop <- vapply(seq_len(m), function(j) sum(!is.finite(P[, m + j])), integer(1))
  stopifnot("non-finite draws must stay under 5%" = all(drop / B_MAIN <= 0.05))
  list(est = obs[1:m], t = obs[(m + 1):(2 * m)], p = p, drop = drop)
}

RES <- list()
# ---- composition ----
epf <- file.path(dp, "entrant_composition_panel.rds")
stopifnot(identical(unname(tools::md5sum(epf)), "8ccec73b5955b723485195d5085b669d"))
EP <- setDT(readRDS(epf)); EP[, `:=`(G = door + 1L, is_priv = 0L, off = (1L - is_entry) + 1L)]
pvf <- file.path(xdir, "output", "private_entrant_cells.rds")
stopifnot(identical(unname(tools::md5sum(pvf)), "e43faa7be42d02cfe190fad6924ce6a2"))
PV <- setDT(readRDS(pvf)); PV[, `:=`(G = 0L, is_priv = 1L, off = 0L)]
cols <- c("rbd", "cod_nivel", "yr", "region", "G", "is_priv", "off", "n_ent", "gpa_z", "sh_prio")
CP <- rbind(EP[, ..cols], PV[, ..cols])
CP[, cell_id := as.integer(factor(paste(rbd, cod_nivel, sep = "|")))]
CP[, w_ent := mean(n_ent), by = cell_id]
WMx <- unique(EP[, .(region, door, is_entry)]); WMx[, wave := door - (1L - is_entry)]
Wx <- unique(WMx[, .(region, wave)])[order(region)]
wv <- setNames(Wx$wave, as.character(Wx$region))
stopifnot(identical(as.integer(table(factor(wv, levels = 2016:2019))), c(1L, 4L, 10L, 1L)))
prep_g <- function(d, UW) {
  d <- d[cell_id %in% UW$cell_id]
  Wy <- dcast(d, cell_id + region + is_priv + off ~ tt, value.var = "y")
  Ww <- dcast(d, cell_id + region + is_priv + off ~ tt, value.var = "w")
  yrs <- as.integer(setdiff(names(Wy), c("cell_id", "region", "is_priv", "off")))
  list(M = as.matrix(Wy[, as.character(yrs), with = FALSE]),
       WT = as.matrix(Ww[, as.character(yrs), with = FALSE]),
       WU = UW$uw[match(Wy$cell_id, UW$cell_id)],
       region = Wy$region, is_priv = Wy$is_priv, off = Wy$off, yrs = yrs)
}
for (task in list(list(ver = "A", y = "gpa_z"), list(ver = "A", y = "sh_prio"))) {
  D <- if (task$ver == "A") CP[is_priv == 0L] else CP
  dd <- D[!is.na(get(task$y)), .(cell_id, region, is_priv, off, tt = yr,
                                 y = get(task$y), w = w_ent, G)]
  at <- fitw(dd[, .(cell_id, tt, G = fifelse(is_priv == 1L, 0L, G), region, y, w)])
  dd[, G := NULL]
  s <- suppressWarnings(aggte(at, type = "simple", na.rm = TRUE))
  pp <- prep_g(dd, unit_weights(at))
  r <- run_cell(pp, eras = FALSE)
  stopifnot("gate" = abs(r$est[1] - s$overall.att) < 1e-8)
  RES[[paste("comp", task$ver, task$y)]] <- data.table(
    part = "comp", version = task$ver, outcome = task$y, cell = "simple",
    att = s$overall.att, se = s$overall.se, t_stud = r$t[1], p_ri = r$p[1])
  say("[comp %s %s] %+.4f (%.4f) T %+.2f RI p %.4f %s | %.1f min", task$ver, task$y,
      s$overall.att, s$overall.se, r$t[1], r$p[1], star(r$p[1]),
      (proc.time() - t0)[["elapsed"]] / 60)
}
# ---- college ----
pf <- file.path(xdir, "output", "class_college_allgrades_panel.rds")
stopifnot(identical(unname(tools::md5sum(pf)), "9b2a5f80a0dc3a1400cc12195665a382"))
cls <- setDT(readRDS(pf))
cls[, cell_id := as.integer(factor(paste(rbd, cod_nivel, sep = "|")))]
cls[, is_priv := as.integer(arm == "priv")]
cls[is_priv == 0L, off := (1L - is_entry) + 1L + 13L - cod_nivel]
cls[is_priv == 1L, off := 0L]
cls[, w_ent := mean(n_ent), by = cell_id]
WMc <- unique(cls[is_priv == 0L, .(region, wave = door - (1L - is_entry))])
Wc <- unique(WMc[, .(region, wave)])[order(region)]
wv <- setNames(Wc$wave, as.character(Wc$region))
stopifnot(identical(as.integer(table(factor(wv, levels = 2016:2019))), c(1L, 4L, 10L, 1L)))
for (ver in c("A")) {
  D <- if (ver == "A") cls[is_priv == 0L] else cls
  for (y in c("grad_ontime", "applied", "assigned", "enrolled")) {
    dd <- D[, .(cell_id, region, is_priv, off, tt = proc, y = get(y), w = w_ent)]
    at <- fitw(D[, .(cell_id, tt = proc, G = fifelse(is_priv == 1L | G > 2026L, 0L, G),
                     region, y = get(y), w = w_ent)])
    s <- suppressWarnings(aggte(at, type = "simple", na.rm = TRUE))
    pp <- prep_g(dd, unit_weights(at))
    eras <- (ver == "A")
    r <- run_cell(pp, eras = eras)
    stopifnot("gate" = abs(r$est[1] - s$overall.att) < 1e-8)
    RES[[paste("col", ver, y)]] <- data.table(
      part = "col", version = ver, outcome = y,
      cell = if (eras) c("simple", "era_old", "era_new") else "simple",
      att = r$est, se = c(s$overall.se, rep(NA_real_, length(r$est) - 1L)),
      t_stud = r$t, p_ri = r$p)
    say("[col %s %s] %+.4f (%.4f) T %+.2f RI p %.4f %s%s | %.1f min", ver, y,
        r$est[1], s$overall.se, r$t[1], r$p[1], star(r$p[1]),
        if (eras) sprintf(" | era_old %+.4f p %.4f %s | era_new %+.4f p %.4f %s",
                          r$est[2], r$p[2], star(r$p[2]), r$est[3], r$p[3], star(r$p[3])) else "",
        (proc.time() - t0)[["elapsed"]] / 60)
  }
}
stopCluster(cl)
R <- rbindlist(RES)
fwrite(R, file.path(xdir, "output", "versionA_locked_results.csv"))
say("total %.1f min", (proc.time() - t0)[["elapsed"]] / 60)
