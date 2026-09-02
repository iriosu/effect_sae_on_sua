# d7: identify the weighted arithmetic on the COMPOSITION panel (w_ent weights,
# publics only, gpa_z). Per-(g,t) weighted rc vs at$att; then weight inversion
# per calendar year against aggte calendar.
suppressMessages({ library(data.table); library(did) })
stopifnot(identical(paste(R.version$major, R.version$minor, sep = "."), "4.5.1"))
home <- Sys.getenv("USERPROFILE")
dp <- file.path(home, "Dropbox", "Effect SAE on SUA", "data")
EP <- setDT(readRDS(file.path(dp, "entrant_composition_panel.rds")))
EP[, G := door + 1L]
EP[, cell_id := as.integer(factor(paste(rbd, cod_nivel, sep = "|")))]
EP[, w_ent := mean(n_ent), by = cell_id]
say <- function(...) cat(sprintf(...), "\n")
d <- EP[!is.na(gpa_z), .(cell_id, tt = yr, G, region, y = gpa_z, w = w_ent)]
at <- suppressWarnings(att_gt(yname = "y", tname = "tt", idname = "cell_id",
                              gname = "G", data = d, control_group = "notyettreated",
                              panel = TRUE, allow_unbalanced_panel = TRUE,
                              base_period = "universal", weightsname = "w",
                              bstrap = FALSE, cband = FALSE, print_details = FALSE))
s  <- suppressWarnings(aggte(at, type = "simple", na.rm = TRUE))
ca <- suppressWarnings(aggte(at, type = "calendar", na.rm = TRUE))
PK <- data.table(g = at$group, t = at$t, att_pkg = at$att)[t >= g]

Wy <- dcast(d, cell_id + G ~ tt, value.var = "y")
Ww <- dcast(d, cell_id + G ~ tt, value.var = "w")
yrs <- as.integer(setdiff(names(Wy), c("cell_id", "G")))
M <- as.matrix(Wy[, as.character(yrs), with = FALSE])
WT <- as.matrix(Ww[, as.character(yrs), with = FALSE])
G <- Wy$G
wmean <- function(x, w) sum(x * w) / sum(w)
wcell <- function(g, t) {
  bi <- match(g - 1L, yrs); ti <- match(t, yrs)
  if (is.na(bi) || is.na(ti)) return(NA_real_)
  tr <- G == g
  tr_t <- tr & !is.na(M[, ti]); tr_b <- tr & !is.na(M[, bi])
  ct_t <- (G > t) & !is.na(M[, ti]); ct_b <- (G > t) & !is.na(M[, bi])
  if (!any(tr_t) || !any(tr_b) || !any(ct_t) || !any(ct_b)) return(NA_real_)
  (wmean(M[tr_t, ti], WT[tr_t, ti]) - wmean(M[tr_b, bi], WT[tr_b, bi])) -
    (wmean(M[ct_t, ti], WT[ct_t, ti]) - wmean(M[ct_b, bi], WT[ct_b, bi]))
}
PK[, mine := mapply(wcell, g, t)]
say("per-cell weighted rc vs package: max |diff| %.2e over %d cells",
    PK[!is.na(att_pkg) & !is.na(mine), max(abs(att_pkg - mine))],
    PK[!is.na(att_pkg) & !is.na(mine), .N])

say("\nimplied vs candidate weight ratios per calendar year (2-group years):")
PK[, e := t - g]
for (j in seq_along(ca$egt)) {
  t0 <- ca$egt[j]
  S <- PK[t == t0 & !is.na(att_pkg)][order(g)]
  if (nrow(S) != 2L) next
  a <- ca$att.egt[j]
  r <- (S$att_pkg[1] - a) / (a - S$att_pkg[2])
  cand <- sapply(S$g, function(gg) {
    tr <- G == gg
    ti <- match(t0, yrs); bi <- match(gg - 1L, yrs)
    c(w_all   = sum(rowMeans(WT[tr, , drop = FALSE], na.rm = TRUE)),
      w_at_t  = sum(WT[tr & !is.na(M[, ti]), ti]),
      w_at_b  = sum(WT[tr & !is.na(M[, bi]), bi]),
      w_obs_tb= sum(rowMeans(WT[tr & !is.na(M[, ti]) & !is.na(M[, bi]), c(ti, bi), drop = FALSE])))
  })
  say("t %d groups %s: implied %.4f | w_all %.4f | w_at_t %.4f | w_at_b %.4f | w_obs_tb %.4f",
      t0, paste(S$g, collapse = ","), r,
      cand["w_all", 2] / cand["w_all", 1], cand["w_at_t", 2] / cand["w_at_t", 1],
      cand["w_at_b", 2] / cand["w_at_b", 1], cand["w_obs_tb", 2] / cand["w_obs_tb", 1])
}

say("\nsolving for the package's group weights (least squares over calendar equations):")
GS <- sort(unique(PK[!is.na(att_pkg), g]))
A <- matrix(0, 0, length(GS)); bvec <- numeric(0)
for (j in seq_along(ca$egt)) {
  t0 <- ca$egt[j]; S <- PK[t == t0 & !is.na(att_pkg)]
  if (nrow(S) < 2L) next
  row <- setNames(rep(0, length(GS)), as.character(GS))
  row[as.character(S$g)] <- S$att_pkg - ca$att.egt[j]
  A <- rbind(A, row); bvec <- c(bvec, 0)
}
# normalize first group's weight to 1: move its column to the rhs
x1 <- 1
rhs <- -A[, 1] * x1
fit <- qr.solve(A[, -1, drop = FALSE], rhs)
xg <- c(x1, fit); names(xg) <- as.character(GS)
say("fitted relative group weights: %s",
    paste(sprintf("g%s=%.4f", names(xg), xg / xg[1]), collapse = "  "))
say("residual max: %.2e", max(abs(A %*% xg)))
for (gg in GS) {
  tr <- G == gg
  bi <- match(gg - 1L, yrs)
  say("g %d: cells %d | w_all %.1f | w_rows_total %.1f | w_at_own_base %.1f | w_first_yr %.1f",
      gg, sum(tr), sum(rowMeans(WT[tr, , drop = FALSE], na.rm = TRUE)),
      sum(WT[tr, ], na.rm = TRUE),
      if (!is.na(bi)) sum(WT[tr & !is.na(M[, bi]), bi]) else NA_real_,
      sum(WT[tr, 1L], na.rm = TRUE))
}

say("\ncandidate: per-cell mean weight, cells with >= 2 observed years only:")
nobs <- rowSums(!is.na(M))
w2 <- sapply(GS, function(gg) sum(rowMeans(WT[G == gg & nobs >= 2L, , drop = FALSE], na.rm = TRUE)))
say("ratios: %s (fitted: 1, 41.1659, 138.0181, 159.6739)",
    paste(sprintf("%.4f", w2 / w2[1]), collapse = ", "))
