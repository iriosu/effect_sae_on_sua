# a19: DID-V2-CONSISTENCY-2026-09-01 items 2-4 — event studies under the one
# significance rule. For every stream (version x weighting x outcome; college
# and composition): per draw, the full event-time path AND the sixteen
# leave-one-region paths, brute force (identical jackknife computation to the
# headline scoring, no shortcuts); per-cell T = att_e / jk SE_e with exact
# two-sided p; joint pre-trend = max |T| over leads per draw (Romano-Wolf
# max-t with MacKinnon-Webb per-draw scales). Gates: the observed path must
# reproduce aggte dynamic at 1e-8 per cell; >5% non-finite draws halts.
# UNWEIGHTED runner (separate file; launched scripts are frozen).
# Args: <version A|B> <rule: always 0> <cores>.
suppressMessages({ library(data.table); library(did); library(parallel) })
t0 <- proc.time()
stopifnot(identical(paste(R.version$major, R.version$minor, sep = "."), "4.5.1"),
          identical(as.character(packageVersion("did")), "2.1.2"))
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 3)
VER <- args[1]; RULE <- args[2]; N_CORES <- as.integer(args[3])
stopifnot(VER %in% c("A", "B"), RULE == "0", N_CORES >= 1L)
SEED <- 20260831; B_MAIN <- 9999L; BITERS <- 10000L
home <- Sys.getenv("USERPROFILE")
dp   <- file.path(home, "Dropbox", "Effect SAE on SUA", "data")
xdir <- file.path(home, "Dropbox", "Effect of Centralization",
                  "explorations", "2026-08-31_did_college_outcomes")
say <- function(...) { cat(sprintf(...), "\n"); flush.console() }
star <- function(p) ifelse(p < .01, "***", ifelse(p < .05, "**", ifelse(p < .1, "*", "")))
wmean <- function(x, w) sum(x * w) / sum(w)

# event-time path, WU group weights, arithmetic as gate-verified in a11/d5:
# post cells control = untreated at the comparison year; pre cells control =
# untreated as of the group's own door; in-window groups only
dyn_path <- function(pp, wave_by_region, ES_E) {
  G <- wave_by_region[as.character(pp$region)] + pp$off
  G[pp$is_priv == 1L] <- Inf
  yrs <- pp$yrs; M <- pp$M; WT <- pp$WT; WU <- pp$WU
  out <- setNames(rep(NA_real_, length(ES_E)), as.character(ES_E))
  for (e in ES_E) {
    num <- 0; den <- 0
    for (g in sort(unique(G[is.finite(G) & G <= max(yrs)]))) {
      bi <- match(g - 1L, yrs); ti <- match(g + e, yrs)
      if (is.na(bi) || is.na(ti)) next
      tr <- G == g
      grp_w <- sum(WU[tr])
      cc <- if (e >= 0L) G > g + e else G > g
      tr_t <- tr & !is.na(M[, ti]); tr_b <- tr & !is.na(M[, bi])
      ct_t <- cc & !is.na(M[, ti]); ct_b <- cc & !is.na(M[, bi])
      if (!any(tr_t) || !any(tr_b) || !any(ct_t) || !any(ct_b)) next
      att <- (wmean(M[tr_t, ti], WT[tr_t, ti]) - wmean(M[tr_b, bi], WT[tr_b, bi])) -
             (wmean(M[ct_t, ti], WT[ct_t, ti]) - wmean(M[ct_b, bi], WT[ct_b, bi]))
      num <- num + grp_w * att; den <- den + grp_w
    }
    out[as.character(e)] <- if (den > 0) num / den else NA_real_
  }
  out
}
# per draw: path + 16 leave-one-region paths -> per-cell T (brute force)
jk_path <- function(pp, w, regs, idx, ES_E) {
  th <- dyn_path(pp, w, ES_E)
  L <- vapply(seq_along(regs), function(i) {
    k <- idx[[i]]
    dyn_path(list(M = pp$M[k, , drop = FALSE], WT = pp$WT[k, , drop = FALSE],
                  WU = pp$WU[k], region = pp$region[k], is_priv = pp$is_priv[k],
                  off = pp$off[k], yrs = pp$yrs), w, ES_E)
  }, numeric(length(ES_E)))
  L <- matrix(L, nrow = length(ES_E))
  Tv <- vapply(seq_along(th), function(j) {
    lo <- L[j, ]; ok <- !is.na(lo); Rp <- sum(ok)
    v <- if (Rp >= 2L) (Rp - 1) / Rp * sum((lo[ok] - mean(lo[ok]))^2) else NA_real_
    th[j] / sqrt(v)
  }, numeric(1))
  c(th, Tv)
}
unit_weights <- function(at) {
  dpp <- at$DIDparams
  pd <- as.data.table(as.data.frame(dpp$data))
  if (isTRUE(dpp$panel)) {
    pd[get(dpp$tname) == dpp$tlist[1], .(cell_id = get(dpp$idname), uw = .w)]
  } else pd[, .(uw = mean(.w)), by = .(cell_id = get(dpp$idname))]
}
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
fitw <- function(d) {
  set.seed(SEED)
  att_gt(yname = "y", tname = "tt", idname = "cell_id", gname = "G",
         data = d, control_group = "notyettreated", panel = TRUE,
         allow_unbalanced_panel = TRUE, base_period = "universal",
         weightsname = "w", bstrap = TRUE, biters = BITERS,
         clustervars = "region", print_details = FALSE)
}

# ---- panels ----
epf <- file.path(dp, "entrant_composition_panel.rds")
stopifnot(identical(unname(tools::md5sum(epf)), "8ccec73b5955b723485195d5085b669d"))
EP <- setDT(readRDS(epf)); EP[, `:=`(G = door + 1L, is_priv = 0L, off = (1L - is_entry) + 1L)]
pvf <- file.path(xdir, "output", "private_entrant_cells.rds")
stopifnot(identical(unname(tools::md5sum(pvf)), "e43faa7be42d02cfe190fad6924ce6a2"))
PV <- setDT(readRDS(pvf)); PV[, `:=`(G = 0L, is_priv = 1L, off = 0L)]
cols <- c("rbd", "cod_nivel", "yr", "region", "G", "is_priv", "off", "n_ent", "gpa_z", "sh_prio")
CP <- rbind(EP[, ..cols], PV[, ..cols])
CP[, cell_id := as.integer(factor(paste(rbd, cod_nivel, sep = "|")))]
CP[, w_ent := 1]   # unweighted runner: every class counts equally
WMx <- unique(EP[, .(region, door, is_entry)]); WMx[, wave := door - (1L - is_entry)]
Wx <- unique(WMx[, .(region, wave)])[order(region)]
wv <- setNames(Wx$wave, as.character(Wx$region))
stopifnot(identical(as.integer(table(factor(wv, levels = 2016:2019))), c(1L, 4L, 10L, 1L)))
pf <- file.path(xdir, "output", "class_college_allgrades_panel.rds")
stopifnot(identical(unname(tools::md5sum(pf)), "9b2a5f80a0dc3a1400cc12195665a382"))
cls <- setDT(readRDS(pf))
cls[, cell_id := as.integer(factor(paste(rbd, cod_nivel, sep = "|")))]
cls[, is_priv := as.integer(arm == "priv")]
cls[is_priv == 0L, off := (1L - is_entry) + 1L + 13L - cod_nivel]
cls[is_priv == 1L, off := 0L]
cls[, w_ent := 1]  # unweighted runner

cl <- makeCluster(N_CORES)
clusterExport(cl, c("dyn_path", "jk_path", "wmean"))

streams <- list(
  list(part = "comp", y = "gpa_z"),   list(part = "comp", y = "sh_prio"),
  list(part = "col", y = "grad_ontime"), list(part = "col", y = "applied"),
  list(part = "col", y = "assigned"),    list(part = "col", y = "enrolled"))
RES_C <- list(); RES_J <- list()
for (st in streams) {
  if (st$part == "comp") {
    D <- if (VER == "A") CP[is_priv == 0L] else CP
    dd <- D[!is.na(get(st$y)), .(cell_id, region, is_priv, off, tt = yr,
                                 y = get(st$y), w = w_ent, G)]
  } else {
    D <- if (VER == "A") cls[is_priv == 0L] else cls
    dd <- D[, .(cell_id, region, is_priv, off, tt = proc, y = get(st$y),
                w = w_ent, G)]
  }
  at <- fitw(dd[, .(cell_id, tt,
                    G = fifelse(is_priv == 1L | G > max(tt), 0L, G), region, y, w)])
  ed <- suppressWarnings(aggte(at, type = "dynamic", na.rm = TRUE))
  ES_E <- setdiff(ed$egt, -1L)
  pp <- prep_g(dd[, .(cell_id, region, is_priv, off, tt, y, w)], unit_weights(at))
  regs <- sort(unique(pp$region))
  idx  <- lapply(regs, function(r) which(pp$region != r))
  set.seed(SEED)
  obs <- jk_path(pp, wv, regs, idx, ES_E)
  m <- length(ES_E)
  pkg <- setNames(ed$att.egt, as.character(ed$egt))[as.character(ES_E)]
  gap <- max(abs(obs[1:m] - pkg), na.rm = TRUE)
  say("[%s %s R%s | %s] verify path: max |fast - package| = %.2e over %d cells",
      VER, st$part, RULE, st$y, gap, m)
  stopifnot("path must reproduce aggte dynamic at 1e-8" = gap < 1e-8)
  regions <- as.integer(names(wv)); waves <- unname(wv)
  WPS <- vector("list", B_MAIN)
  for (b in seq_len(B_MAIN)) WPS[[b]] <- setNames(sample(waves), as.character(regions))
  clusterExport(cl, c("pp", "regs", "idx", "ES_E"), envir = environment())
  P <- do.call(rbind, parLapplyLB(cl, WPS,
                                  function(w) jk_path(pp, w, regs, idx, ES_E),
                                  chunk.size = 32L))
  drop_sh <- vapply(seq_len(m), function(j) mean(!is.finite(P[, m + j])), numeric(1))
  # cells with inadequate permutation support (over 5% non-finite studentized
  # draws) are NOT scorable by randomization inference: their p is NA, they
  # carry no star, and the exclusion is printed and stored. Estimates and SEs
  # still display. Supported cells are scored normally.
  p_cell <- rep(NA_real_, m)
  for (j in seq_len(m)) {
    if (drop_sh[j] > 0.05) next
    TT <- P[, m + j]; fin <- is.finite(TT)
    p_cell[j] <- (1 + sum(abs(TT[fin]) >= abs(obs[m + j]))) / (1 + sum(fin))
  }
  if (any(drop_sh > 0.05))
    say("[%s %s R%s | %s] cells NOT scorable by RI (support < 95%%): %s", VER,
        st$part, RULE, st$y,
        paste(sprintf("e=%d (%.0f%% dropped)", ES_E[drop_sh > 0.05],
                      100 * drop_sh[drop_sh > 0.05]), collapse = ", "))
  lead_j <- which(ES_E < 0L & drop_sh <= 0.05)
  stopifnot("at least two supported leads are required for the joint test" =
              length(lead_j) >= 2L)
  Tmax <- apply(abs(P[, m + lead_j, drop = FALSE]), 1, max, na.rm = TRUE)
  p_joint <- (1 + sum(Tmax >= max(abs(obs[m + lead_j]), na.rm = TRUE), na.rm = TRUE)) /
             (1 + sum(is.finite(Tmax)))
  RES_C[[st$y]] <- data.table(version = VER, rule = RULE, part = st$part,
                              outcome = st$y, e = ES_E, att = pkg,
                              se = setNames(ed$se.egt, as.character(ed$egt))[as.character(ES_E)],
                              t_stud = obs[(m + 1):(2 * m)], p_ri = p_cell,
                              drop_share = drop_sh)
  RES_J[[st$y]] <- data.table(version = VER, rule = RULE, part = st$part,
                              outcome = st$y, p_joint_maxT = p_joint, n_leads = length(lead_j))
  say("[%s %s R%s | %s] joint max-|T| lead p = %.4f | %.1f min", VER, st$part, RULE,
      st$y, p_joint, (proc.time() - t0)[["elapsed"]] / 60)
}
stopCluster(cl)
fwrite(rbindlist(RES_C), file.path(xdir, "output",
       sprintf("es_stud_cells_%s_rule%s.csv", VER, RULE)))
fwrite(rbindlist(RES_J), file.path(xdir, "output",
       sprintf("es_stud_joint_%s_rule%s.csv", VER, RULE)))
say("stream %s rule %s complete | total %.1f min", VER, RULE,
    (proc.time() - t0)[["elapsed"]] / 60)
