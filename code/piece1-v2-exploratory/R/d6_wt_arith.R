# d6: identify the package's weighted arithmetic. Step 1: do my weighted rc
# per-cell estimates match at$att under weightsname? Step 2: invert the implied
# aggregation weights from aggte calendar (years with exactly 2 contributing
# groups give one ratio each) and compare to candidate group quantities.
suppressMessages({ library(data.table); library(did) })
stopifnot(identical(paste(R.version$major, R.version$minor, sep = "."), "4.5.1"))
home <- Sys.getenv("USERPROFILE")
xdir <- file.path(home, "Dropbox", "Effect of Centralization",
                  "explorations", "2026-08-31_did_college_outcomes")
cls <- setDT(readRDS(file.path(xdir, "output", "class_college_allgrades_panel.rds")))[arm == "pub"]
cls[, cell_id := as.integer(factor(paste(rbd, cod_nivel, sep = "|")))]
say <- function(...) cat(sprintf(...), "\n")
y <- "grad_ontime"
d <- cls[, .(cell_id, proc, G = fifelse(G > 2026L, 0L, G), region, y = get(y), w = n_ent)]
at <- suppressWarnings(att_gt(yname = "y", tname = "proc", idname = "cell_id",
                              gname = "G", data = d, control_group = "notyettreated",
                              panel = TRUE, allow_unbalanced_panel = TRUE,
                              base_period = "universal", weightsname = "w",
                              bstrap = FALSE, cband = FALSE, print_details = FALSE))
ca <- suppressWarnings(aggte(at, type = "calendar", na.rm = TRUE))
s  <- suppressWarnings(aggte(at, type = "simple", na.rm = TRUE))
PK <- data.table(g = at$group, t = at$t, att_pkg = at$att)[t >= g]

Wy <- dcast(d, cell_id + G ~ proc, value.var = "y")
Ww <- dcast(d, cell_id + G ~ proc, value.var = "w")
yrs <- as.integer(setdiff(names(Wy), c("cell_id", "G")))
M <- as.matrix(Wy[, as.character(yrs), with = FALSE])
WT <- as.matrix(Ww[, as.character(yrs), with = FALSE])
G <- Wy$G; G[G == 0L] <- Inf
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

# implied aggregation weight ratios per calendar year with exactly 2 groups
say("\nimplied weight ratios from aggte calendar (w_g2 / w_g1):")
for (j in seq_along(ca$egt)) {
  t0 <- ca$egt[j]
  S <- PK[t == t0 & !is.na(att_pkg)][order(g)]
  if (nrow(S) != 2L) next
  a <- ca$att.egt[j]
  # a = (w1 x1 + w2 x2)/(w1+w2)  ->  w2/w1 = (x1 - a)/(a - x2)
  r <- (S$att_pkg[1] - a) / (a - S$att_pkg[2])
  cand <- sapply(S$g, function(gg) {
    tr <- G == gg
    bi <- match(gg - 1L, yrs); ti <- match(t0, yrs)
    c(totw   = sum(WT[tr, ], na.rm = TRUE),
      w_at_t = sum(WT[tr & !is.na(M[, ti]), ti]),
      w_base = sum(WT[tr & !is.na(M[, bi]), bi]),
      cells  = sum(tr),
      w_mean_per_cell = sum(WT[tr, ], na.rm = TRUE) / sum(tr))
  })
  say("t %d groups %s: implied %.4f | totw %.4f | w_at_t %.4f | w_base %.4f | cells %.4f",
      t0, paste(S$g, collapse = ","), r,
      cand["totw", 2] / cand["totw", 1],
      cand["w_at_t", 2] / cand["w_at_t", 1],
      cand["w_base", 2] / cand["w_base", 1],
      cand["cells", 2] / cand["cells", 1])
}

say("\nextended candidates for t=2021 (groups 2020, 2021), implied ratio above:")
for (gg in c(2020L, 2021L)) {
  tr <- G == gg
  ti <- match(2021L, yrs); bi <- match(gg - 1L, yrs)
  gi <- match(gg, yrs)
  v <- c(
    w_sum_t_plus_base = sum(WT[tr & !is.na(M[, ti]), ti]) + sum(WT[tr & !is.na(M[, bi]), bi]),
    w_at_own_g        = sum(WT[tr & !is.na(M[, gi]), gi]),
    w_percell_mean    = sum(rowMeans(WT[tr, , drop = FALSE], na.rm = TRUE)),
    w_first_obs       = sum(apply(WT[tr, , drop = FALSE], 1, function(r) r[which(!is.na(r))[1]])),
    w_min_tb          = sum(pmin(WT[tr & !is.na(M[, ti]) & !is.na(M[, bi]), ti],
                                 WT[tr & !is.na(M[, ti]) & !is.na(M[, bi]), bi]))
  )
  say("g %d: %s", gg, paste(sprintf("%s=%.1f", names(v), v), collapse = "  "))
}
