# d3: make the fast statistic exact. Step 1: check my rc formula reproduces the
# package's per-comparison estimates ATT(g,t) cell by cell. Step 2: using the
# package's own ATT(g,t) values, find the aggregation weights that reproduce
# aggte(type="simple") to machine precision. Both steps are arithmetic against
# one att_gt fit per column — no reimplementation guesswork.
suppressMessages({ library(data.table); library(did) })
stopifnot(identical(paste(R.version$major, R.version$minor, sep = "."), "4.5.1"),
          identical(as.character(packageVersion("did")), "2.1.2"))
home <- Sys.getenv("USERPROFILE")
xdir <- file.path(home, "Dropbox", "Effect of Centralization",
                  "explorations", "2026-08-31_did_college_outcomes")
pf <- file.path(xdir, "output", "class_college_allgrades_panel.rds")
stopifnot(identical(unname(tools::md5sum(pf)), "9b2a5f80a0dc3a1400cc12195665a382"))
cls <- setDT(readRDS(pf))
cls[, cell_id := as.integer(factor(paste(rbd, cod_nivel, sep = "|")))]
cls[, is_priv := as.integer(arm == "priv")]
say <- function(...) cat(sprintf(...), "\n")

rc_grid <- function(DD, yvar) {
  d <- DD[, .(cell_id, is_priv, G = fifelse(is_priv == 1L, Inf, as.numeric(G)),
              proc, y = get(yvar))]
  Wd <- dcast(d, cell_id + G ~ proc, value.var = "y")
  yrs <- as.integer(setdiff(names(Wd), c("cell_id", "G")))
  M <- as.matrix(Wd[, as.character(yrs), with = FALSE]); G <- Wd$G
  out <- list()
  for (g in sort(unique(G[is.finite(G) & G <= max(yrs)]))) {
    bi <- match(g - 1, yrs); if (is.na(bi)) next
    tr <- G == g
    for (t in yrs[yrs >= g]) {
      ti <- match(t, yrs)
      tr_t <- tr & !is.na(M[, ti]); tr_b <- tr & !is.na(M[, bi])
      ct_t <- (G > t) & !is.na(M[, ti]); ct_b <- (G > t) & !is.na(M[, bi])
      if (!any(tr_t) || !any(tr_b) || !any(ct_t) || !any(ct_b)) next
      out[[paste(g, t)]] <- data.table(
        g = g, t = t,
        att = (mean(M[tr_t, ti]) - mean(M[tr_b, bi])) -
              (mean(M[ct_t, ti]) - mean(M[ct_b, bi])),
        n_t = sum(tr_t), n_b = sum(tr_b), n_grp = sum(tr))
    }
  }
  rbindlist(out)
}

for (ver in c("A_pub", "B_priv")) {
  D <- if (ver == "A_pub") cls[is_priv == 0L] else cls
  for (y in c("grad_ontime", "applied")) {
    d <- D[, .(cell_id, proc, G = fifelse(G > 2026L, 0L, G), region, y = get(y))]
    at <- suppressWarnings(att_gt(yname = "y", tname = "proc", idname = "cell_id",
                                  gname = "G", data = d,
                                  control_group = "notyettreated", panel = TRUE,
                                  allow_unbalanced_panel = TRUE,
                                  base_period = "universal", bstrap = FALSE,
                                  cband = FALSE, print_details = FALSE))
    s <- suppressWarnings(aggte(at, type = "simple", na.rm = TRUE))
    PK <- data.table(g = at$group, t = at$t, att_pkg = at$att)[t >= g]
    H  <- rc_grid(D, y)
    CH <- merge(PK, H, by = c("g", "t"), all = TRUE)
    say("%s %-12s | package (g,t) cells %d, mine %d | max |diff| %.2e",
        ver, y, nrow(PK[!is.na(att_pkg)]), nrow(H),
        CH[!is.na(att_pkg) & !is.na(att), max(abs(att_pkg - att))])
    # candidate aggregation weights against the package's own att(g,t)
    CH2 <- CH[!is.na(att_pkg)]
    cand <- list(
      usable_t   = CH2$n_t,
      base_b     = CH2$n_b,
      group_size = CH2$n_grp,
      min_tb     = pmin(CH2$n_t, CH2$n_b))
    for (nm in names(cand)) {
      w <- cand[[nm]]
      say("   weights %-10s -> %+.6f (aggte simple %+.6f, gap %.2e)",
          nm, sum(w * CH2$att_pkg) / sum(w), s$overall.att,
          abs(sum(w * CH2$att_pkg) / sum(w) - s$overall.att))
    }
  }
}
