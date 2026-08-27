# =============================================================================
# 91_count_ri.R -- DECOMP-COUNT-RI-2026-08-26 (registered addendum).
# Permutation p-values for the transcript-swap counts.
#
# Design: the eligibility facts (official GPA and rank on file; at least one
# scoreable listed program) are fixed attributes of a child. Only the
# winner/loser roles reshuffle. For each draw we precompute the full grid
# C[i, j] = 1{child i clears a cutoff at some program SHE listed when her GPA
# and rank points are replaced by child j's}, diagonal = her own clearing.
# The grid is exact by the same linearity as the record run. At the TRUE
# assignment the grid must reproduce the record counts exactly or the run
# halts. Then: 9,999 within-draw reshuffles of who wins (winner counts fixed,
# seed 20260919), the entire statistic rebuilt per reshuffle:
#   S1 plain net per 100 counted winners
#   S2 estimator-weighted net
#   S3 mirror net per 100 counted losers
# Two-sided p per statistic, plus-one convention, as in every project RI.
# =============================================================================
suppressPackageStartupMessages({ library(data.table); library(tools) })
setDTthreads(4); options(warn = 1)
B_RI <- 9999L

home <- ifelse(Sys.getenv("USERPROFILE") != "", Sys.getenv("USERPROFILE"), path.expand("~"))
ROOT <- file.path(home, "Dropbox", "Effect of Centralization")
P4   <- file.path(ROOT, "Updated Paper Spine", "Piece 4")
OUTD <- file.path(ROOT, "explorations", "2026-08-17_piece3_mechanism", "output")
say <- function(...) { cat(sprintf(...), "\n"); flush.console() }
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

## ---- frame and eligibility, exactly as the record run ----------------------
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

SC  <- as.data.table(readRDS(data_here("pref_scores_final.rds")))
CUT <- as.data.table(readRDS(data_here("panel_programs_2007_2026.rds")))[
  , .(carrera = as.integer(codigo_demre), YEAR, cutoff_reg)]
W   <- as.data.table(readRDS(data_here("program_weights_final.rds")))[
  , .(carrera, YEAR, w_nem, w_rank)]
NR  <- ST[, .(MRUN, YEAR, nem, rank)]
PP <- merge(merge(merge(SC, EF[, .(MRUN, YEAR = cyear)], by = c("MRUN", "YEAR")),
                  CUT, by = c("carrera", "YEAR"), all.x = TRUE),
            W, by = c("carrera", "YEAR"), all.x = TRUE)
UP <- PP[!is.na(score) & !is.na(cutoff_reg)]
own <- UP[, .(own_clear = as.integer(any(score >= cutoff_reg)), n_usable = .N), by = .(MRUN, YEAR)]
EF <- merge(EF, own, by.x = c("MRUN", "cyear"), by.y = c("MRUN", "YEAR"), all.x = TRUE)
EF[is.na(own_clear), own_clear := 0L][is.na(n_usable), n_usable := 0L]
EF[, `:=`(nem_o = NR[EF[, .(MRUN, YEAR = cyear)], on = .(MRUN, YEAR), x.nem],
          rank_o = NR[EF[, .(MRUN, YEAR = cyear)], on = .(MRUN, YEAR), x.rank])]
EF[, has_nr := !is.na(nem_o) & !is.na(rank_o)]
EF[, elig := as.integer(has_nr & n_usable >= 1L)]   # can be a counted child if her role allows

## ---- the all-pairs clearing grid, one delta evaluation per (recipient, donor)
say("building the per-draw clearing grids...")
REC <- EF[elig == 1L, .(MRUN, cyear, key, nem_o, rank_o)]           # possible recipients
DONP <- EF[has_nr == TRUE, .(key, dMRUN = MRUN, dnem = nem_o, drank = rank_o)]  # possible donors
RP <- UP[REC[, .(MRUN, YEAR = cyear, key)], on = .(MRUN, YEAR), nomatch = NULL]
PAIR <- merge(RP, DONP, by = "key", allow.cartesian = TRUE)
PAIR <- merge(PAIR, REC[, .(MRUN, YEAR = cyear, rnem = nem_o, rrank = rank_o)],
              by = c("MRUN", "YEAR"))
PAIR[, cf := score + w_nem * (dnem - rnem) + w_rank * (drank - rrank)]
G <- PAIR[, .(clear = as.integer(any(cf >= cutoff_reg))), by = .(key, MRUN, dMRUN)]
say("grid rows (recipient x donor): %s", format(nrow(G), big.mark = ","))

## ---- per-draw matrices: one evaluation path for observed and reshuffled ----
setorder(EF, key, MRUN)
EF[, pos := seq_len(.N), by = key]
KX <- EF[, .(i0 = .I[1], n = .N, m = sum(won)), by = key]
G2 <- merge(G, EF[, .(key, MRUN, ri = pos)], by = c("key", "MRUN"))
G2 <- merge(G2, EF[, .(key, dMRUN = MRUN, ci = pos)], by = c("key", "dMRUN"))
stopifnot("every grid cell mapped" = nrow(G2) == nrow(G))
GSL <- split(G2[, .(key, ri, ci, clear)], by = "key", keep.by = FALSE)
DR <- vector("list", nrow(KX))
for (r in seq_len(nrow(KX))) {
  rows <- KX$i0[r]:(KX$i0[r] + KX$n[r] - 1L)
  mem <- EF[rows]
  n <- KX$n[r]
  Ck <- matrix(NA_real_, n, n)
  g <- GSL[[KX$key[r]]]
  if (!is.null(g)) Ck[cbind(g$ri, g$ci)] <- g$clear
  DR[[r]] <- list(C = Ck, elig = mem$elig == 1L, nr = mem$has_nr,
                  own = mem$own_clear, won = mem$won == 1L, n = n, m = KX$m[r])
}
# diagonal must reproduce each eligible child's own clearing
for (r in seq_len(nrow(KX))) { d <- DR[[r]]
  i <- which(d$elig)
  stopifnot("grid diagonal reproduces own clearing" = all(d$C[cbind(i, i)] == d$own[i])) }

eval_assign <- function(wl) {
  # wl: list of logical winner vectors per draw. Returns the three statistics
  # and the winner-side levels (registered halt condition).
  s1 <- 0; c1 <- 0L; s2n <- 0; s2d <- 0; s3 <- 0; c3 <- 0L; s_own <- 0
  for (r in seq_along(DR)) { d <- DR[[r]]; w <- wl[[r]]
    don <- which(!w & d$nr)
    if (length(don)) {
      rec <- which(w & d$elig)
      if (length(rec)) {
        cf <- rowMeans(d$C[rec, don, drop = FALSE])
        dd <- sum(d$own[rec] - cf)
        s1 <- s1 + dd; c1 <- c1 + length(rec); s_own <- s_own + sum(d$own[rec])
        m2 <- length(rec); N2 <- length(don); om <- m2 * N2 / (m2 + N2)
        s2n <- s2n + om / m2 * dd; s2d <- s2d + om
      }
    }
    don2 <- which(w & d$nr)
    if (length(don2)) {
      rec2 <- which(!w & d$elig)
      if (length(rec2)) {
        cf2 <- rowMeans(d$C[rec2, don2, drop = FALSE])
        s3 <- s3 + sum(d$own[rec2] - cf2); c3 <- c3 + length(rec2)
      }
    }
  }
  c(plain = s1 / c1, wgt = s2n / s2d, mirror = s3 / c3, n_cw = c1, n_cl = c3,
    own_lvl = s_own / c1, cf_lvl = (s_own - s1) / c1)
}

obs <- eval_assign(lapply(DR, function(d) d$won))
say("observed: counted winners %s | plain net %+.6f | weighted net %+.6f | mirror %+.6f (losers %s)",
    format(obs["n_cw"], big.mark = ","), 100 * obs["plain"], 100 * obs["wgt"],
    100 * obs["mirror"], format(obs["n_cl"], big.mark = ","))
CV <- fread(file.path(P4, "tables", "decomp_count_values.csv"))
gv <- function(l) { v <- CV[line == l, value]; stopifnot(length(v) == 1L); v }
stopifnot("reproduces the record counted winners" = obs["n_cw"] == gv("winners counted"),
          "reproduces the record counted losers"  = obs["n_cl"] == gv("losers counted (mirror)"),
          "reproduces the record own level"    = abs(100 * obs["own_lvl"] - gv("own clears per 100")) < 1e-9,
          "reproduces the record swap level"   = abs(100 * obs["cf_lvl"] - gv("with loser transcript per 100")) < 1e-9,
          "reproduces the record plain net"    = abs(100 * obs["plain"] - gv("net plain per 100 counted winners")) < 1e-9,
          "reproduces the record weighted net" = abs(100 * obs["wgt"] - gv("net weighted per 100")) < 1e-9,
          "reproduces the record mirror net"   = abs(100 * obs["mirror"] - gv("mirror net per 100 counted losers")) < 1e-9)
say("record run reproduced exactly from the pair grid; starting the reshuffles")

## ---- the permutation -------------------------------------------------------
set.seed(20260919)
P1 <- numeric(B_RI); P2 <- numeric(B_RI); P3 <- numeric(B_RI)
for (b in seq_len(B_RI)) {
  wl <- lapply(DR, function(d) { w <- logical(d$n); w[sample.int(d$n, d$m)] <- TRUE; w })
  sb <- eval_assign(wl)
  P1[b] <- sb["plain"]; P2[b] <- sb["wgt"]; P3[b] <- sb["mirror"]
  if (b %% 500 == 0) say("  reshuffle %d of %d", b, B_RI)
}
p1 <- (1 + sum(abs(P1) >= abs(obs["plain"]) - 1e-12)) / (B_RI + 1)
p2 <- (1 + sum(abs(P2) >= abs(obs["wgt"])   - 1e-12)) / (B_RI + 1)
p3 <- (1 + sum(abs(P3) >= abs(obs["mirror"]) - 1e-12)) / (B_RI + 1)
say("permutation p (two-sided, plus-one): plain %.4f | weighted %.4f | mirror %.4f", p1, p2, p3)
plc <- gv("placebo net per 100")
say("placebo position: |placebo net| %.4f per 100; share of the %d reshuffled |plain nets| at or above it %.4f; reshuffled |plain net| min %.4f median %.4f max %.4f (per 100)",
    abs(plc), B_RI, mean(abs(100 * P1) >= abs(plc)), 100 * min(abs(P1)),
    100 * median(abs(P1)), 100 * max(abs(P1)))
fwrite(data.table(statistic = c("plain net per 100 counted winners",
                                "weighted net per 100", "mirror net per 100 counted losers"),
                  observed_per100 = c(100 * obs["plain"], 100 * obs["wgt"], 100 * obs["mirror"]),
                  ri_p = c(p1, p2, p3), B = B_RI, seed = 20260919L),
       file.path(P4, "tables", "decomp_count_ri_values.csv"))
cat("DONE\n")
