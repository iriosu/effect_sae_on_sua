# d5: identify the package's exact dynamic-path arithmetic on this panel.
# Step 1: per-(g,t) — compare my rc estimates to at$att for ALL cells including
#         pre-periods, under two candidate pre-period control conditions.
# Step 2: per-event-time — reconstruct aggte dynamic att.egt from the package's
#         own att(g,t) under candidate weights, find the exact one.
suppressMessages({ library(data.table); library(did) })
stopifnot(identical(paste(R.version$major, R.version$minor, sep = "."), "4.5.1"))
home <- Sys.getenv("USERPROFILE")
xdir <- file.path(home, "Dropbox", "Effect of Centralization",
                  "explorations", "2026-08-31_did_college_outcomes")
cls <- setDT(readRDS(file.path(xdir, "output", "class_college_allgrades_panel.rds")))
cls[, cell_id := as.integer(factor(paste(rbd, cod_nivel, sep = "|")))]
cls <- cls[arm == "pub"]
say <- function(...) cat(sprintf(...), "\n")

y <- "grad_ontime"
d <- cls[, .(cell_id, proc, G = fifelse(G > 2026L, 0L, G), region, y = get(y))]
at <- suppressWarnings(att_gt(yname = "y", tname = "proc", idname = "cell_id",
                              gname = "G", data = d, control_group = "notyettreated",
                              panel = TRUE, allow_unbalanced_panel = TRUE,
                              base_period = "universal", bstrap = FALSE,
                              cband = FALSE, print_details = FALSE))
ed <- suppressWarnings(aggte(at, type = "dynamic", na.rm = TRUE))
PK <- data.table(g = at$group, t = at$t, att_pkg = at$att)

Wd <- dcast(d, cell_id + G ~ proc, value.var = "y")
yrs <- as.integer(setdiff(names(Wd), c("cell_id", "G")))
M <- as.matrix(Wd[, as.character(yrs), with = FALSE]); G <- Wd$G
G[G == 0L] <- Inf   # recoded never-in-window
rc_cell <- function(g, t, ctl) {
  bi <- match(g - 1L, yrs); ti <- match(t, yrs)
  if (is.na(bi) || is.na(ti)) return(NA_real_)
  tr <- G == g
  cc <- if (ctl == "gt_t") (G > t) else (G > max(t, g - 1L))
  tr_t <- tr & !is.na(M[, ti]); tr_b <- tr & !is.na(M[, bi])
  ct_t <- cc & !is.na(M[, ti]); ct_b <- cc & !is.na(M[, bi])
  if (!any(tr_t) || !any(tr_b) || !any(ct_t) || !any(ct_b)) return(NA_real_)
  (mean(M[tr_t, ti]) - mean(M[tr_b, bi])) - (mean(M[ct_t, ti]) - mean(M[ct_b, bi]))
}
for (ctl in c("gt_t", "gt_max")) {
  PK[, mine := mapply(rc_cell, g, t, MoreArgs = list(ctl = ctl))]
  say("pre  cells (t<g):  control %s  max|diff| %.2e (n %d)", ctl,
      PK[t < g & !is.na(att_pkg) & !is.na(mine), max(abs(att_pkg - mine))],
      PK[t < g & !is.na(att_pkg) & !is.na(mine), .N])
  say("post cells (t>=g): control %s  max|diff| %.2e (n %d)", ctl,
      PK[t >= g & !is.na(att_pkg) & !is.na(mine), max(abs(att_pkg - mine))],
      PK[t >= g & !is.na(att_pkg) & !is.na(mine), .N])
}

# Step 2: weights. Reconstruct att.egt from the package's own att(g,t).
PK[, e := t - g]
NG <- Wd[, .N, by = G][, setNames(N, as.character(G))]
PK[, n_grp := NG[as.character(g)]]
say("\ndynamic reconstruction (per event time e, package att.egt vs candidates):")
for (j in seq_along(ed$egt)) {
  e0 <- ed$egt[j]
  S <- PK[e == e0 & !is.na(att_pkg)]
  w1 <- S[, sum(att_pkg * n_grp) / sum(n_grp)]                       # group cell count
  say("e %+d : pkg %+.5f | grp-count %+.5f (gap %.1e) | unweighted %+.5f (gap %.1e)",
      e0, ed$att.egt[j], w1, abs(w1 - ed$att.egt[j]),
      S[, mean(att_pkg)], abs(S[, mean(att_pkg)] - ed$att.egt[j]))
}

say("\npre-period control candidates, extended:")
rc_cell2 <- function(g, t, cond) {
  bi <- match(g - 1L, yrs); ti <- match(t, yrs)
  if (is.na(bi) || is.na(ti)) return(NA_real_)
  tr <- G == g
  cc <- switch(cond,
    gt_g  = G > g,
    gt_t1 = G > t + 1L)
  tr_t <- tr & !is.na(M[, ti]); tr_b <- tr & !is.na(M[, bi])
  ct_t <- cc & !is.na(M[, ti]); ct_b <- cc & !is.na(M[, bi])
  if (!any(tr_t) || !any(tr_b) || !any(ct_t) || !any(ct_b)) return(NA_real_)
  (mean(M[tr_t, ti]) - mean(M[tr_b, bi])) - (mean(M[ct_t, ti]) - mean(M[ct_b, bi]))
}
for (cond in c("gt_g", "gt_t1")) {
  PK[, mine2 := mapply(rc_cell2, g, t, MoreArgs = list(cond = cond))]
  say("pre cells: control %-6s max|diff| %.2e (n %d)", cond,
      PK[t < g & !is.na(att_pkg) & !is.na(mine2), max(abs(att_pkg - mine2))],
      PK[t < g & !is.na(att_pkg) & !is.na(mine2), .N])
}
