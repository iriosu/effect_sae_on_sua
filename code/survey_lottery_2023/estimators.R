# Survey-lottery project: estimators and table writers shared by steps 3, 5 and 6.
#
# Sourced by 03_baseline_offer_effects.R, 05_application_outcomes.R and 06_ranking_belief_gap.R.
# The calling script sets MIN_CELL, MIN_EST, BOOT, the seed, and `controls`, and loads fixest and dplyr.
# The functions follow specification_log.md (Sections 3, 5 and 6, and the entry of 19:55 UTC).

# Weights that reproduce the regression of an outcome on OFFER and chance-group effects: an offered child
# weighs one minus the offer share of the chance group, a non-offered child weighs the offer share.
# A chance group with one offer group only has weight zero.
ipw <- function(z, g) {
  p <- ave(z, g); ifelse(z == 1, 1 - p, p)
}
wmean <- function(v, w) sum(v * w) / sum(w)
trim_mean <- function(v, w, p, from_top) {   # weighted mean after removing the share p of the weight at one end
  ord <- order(v, decreasing = from_top); v <- v[ord]; w <- w[ord]
  cw <- cumsum(w) / sum(w); low <- c(0, head(cw, -1))
  keep <- w * pmin(1, pmax(0, (cw - p) / pmax(cw - low, 1e-12)))
  sum(v * keep) / sum(keep)
}
lee <- function(y, z, r, w) {
  ok <- w > 0
  q1 <- sum(w[ok & z == 1 & r]) / sum(w[ok & z == 1]); q0 <- sum(w[ok & z == 0 & r]) / sum(w[ok & z == 0])
  y1 <- y[ok & z == 1 & r]; w1 <- w[ok & z == 1 & r]; y0 <- y[ok & z == 0 & r]; w0 <- w[ok & z == 0 & r]
  if (length(y1) < 2 || length(y0) < 2) return(rep(NA_real_, 6))
  point <- wmean(y1, w1) - wmean(y0, w0)
  if (q1 >= q0) {
    p <- (q1 - q0) / q1
    c(trim_mean(y1, w1, p, TRUE) - wmean(y0, w0), trim_mean(y1, w1, p, FALSE) - wmean(y0, w0), p, q1, q0, point)
  } else {
    p <- (q0 - q1) / q0
    c(wmean(y1, w1) - trim_mean(y0, w0, p, FALSE), wmean(y1, w1) - trim_mean(y0, w0, p, TRUE), p, q1, q0, point)
  }
}
im_ci <- function(lo, hi, se_lo, se_hi) {   # Imbens and Manski (2004), 95 percent
  if (anyNA(c(lo, hi, se_lo, se_hi)) || max(se_lo, se_hi) <= 0) return(c(NA_real_, NA_real_))
  f <- function(cc) pnorm(cc + (hi - lo) / max(se_lo, se_hi)) - pnorm(-cc) - 0.95
  cc <- uniroot(f, c(1.0, 3.0))$root
  c(lo - cc * se_lo, hi + cc * se_hi)
}

# One row of the outcome list. `group` names the column with the random group of questions of the item.
# `adjust` puts the row in the adjusted set of its family. `lo` and `hi` give the range for worst-case bounds.
# `rw` asks for the reweighted estimate.
o <- function(family, var, label, main = FALSE, group = NA, adjust = TRUE, lo = NA, hi = NA, rw = TRUE)
  data.frame(family, var, label, main, group, adjust, lo, hi, rw)

# Offer effects for every row of `outcomes` in the cohort `d` (one row per child).
# An outcome is missing for children outside its sample. Answering means that the outcome is not missing.
estimate_all <- function(d, outcomes, bounds = TRUE) {
  z <- d$OFFER; grp <- d$CHANCE_GROUP; n_all <- nrow(d)
  w <- ipw(z, grp)
  rows <- vector("list", nrow(outcomes))
  boot_lo <- boot_hi <- matrix(NA_real_, BOOT, nrow(outcomes))
  if (bounds) for (b in seq_len(BOOT)) {
    idx <- sample.int(n_all, n_all, TRUE); zb <- z[idx]; wb <- ipw(zb, grp[idx])
    for (j in seq_len(nrow(outcomes))) {
      yb <- d[[outcomes$var[j]]][idx]; rb <- !is.na(yb)
      if (sum(rb & zb == 1) >= MIN_EST && sum(rb & zb == 0) >= MIN_EST) {
        l <- lee(yb, zb, rb, wb); boot_lo[b, j] <- l[1]; boot_hi[b, j] <- l[2]
      }
    }
  }
  for (j in seq_len(nrow(outcomes))) {
    v <- outcomes$var[j]; y <- d[[v]]; r <- !is.na(y)
    n1 <- sum(r & z == 1); n0 <- sum(r & z == 0)
    base <- data.frame(family = outcomes$family[j], label = outcomes$label[j], main = outcomes$main[j],
                       adjust = outcomes$adjust[j], n_offer = n1, n_no_offer = n0)
    if (min(n1, n0) < MIN_EST) {rows[[j]] <- base; next}
    d$y <- y; d$r <- as.numeric(r)
    sub <- d[r, ]
    fe <- if (is.na(outcomes$group[j])) "CHANCE_GROUP" else {sub$grp_item <- sub[[outcomes$group[j]]]; "CHANCE_GROUP + grp_item"}
    m <- feols(as.formula(paste("y ~ OFFER + .[controls] |", fe)), sub)
    m0 <- feols(as.formula(paste("y ~ OFFER |", fe)), sub)
    iv <- tryCatch(feols(as.formula(paste("y ~ .[controls] |", fe, "| D_OD ~ OFFER")), sub), error = function(e) NULL)
    # Stage: offer effect on answering, in the whole cohort. An outcome defined for every child has no stage.
    everyone <- all(r)
    st <- if (everyone) NULL else feols(r ~ OFFER + .[controls] | CHANCE_GROUP, d)
    stage <- if (everyone) 0 else coef(st)[["OFFER"]]
    stage_se <- if (everyone) 0 else se(st)[["OFFER"]]
    # Reweighting: inverse of the probability of answering among registered children, by offer group.
    do_rw <- is.null(outcomes$rw) || isTRUE(outcomes$rw[j])
    mw <- NULL
    if (do_rw) {
      sub$pw <- NA_real_
      for (a in 0:1) {
        da <- d[d$OFFER == a & d$REGISTERED == 1, ]
        fit <- suppressWarnings(glm(r ~ GPA8_Z + ES_MUJER + PRIORITARIO + ALTO + ORIGIN_OD + GRAD_OT + HAS_SCORE_OT + APPLIED_OT,
                                    family = binomial(), data = da))
        sub$pw[sub$OFFER == a] <- 1 / pmax(predict(fit, newdata = sub[sub$OFFER == a, ], type = "response"), 1e-3)
      }
      mw <- feols(as.formula(paste("y ~ OFFER + .[controls] |", fe)), sub, weights = ~pw)
    }
    l <- if (bounds) lee(y, z, r, w) else rep(NA_real_, 6)
    se_lo <- sd(boot_lo[, j], na.rm = TRUE); se_hi <- sd(boot_hi[, j], na.rm = TRUE)
    ci <- if (bounds) im_ci(l[1], l[2], se_lo, se_hi) else c(NA_real_, NA_real_)
    # Worst-case bounds for outcomes with a known range, full cohort as population.
    wc <- c(NA_real_, NA_real_)
    if (bounds && !is.na(outcomes$lo[j])) {
      a <- outcomes$lo[j]; bb <- outcomes$hi[j]; ok <- w > 0
      m1 <- wmean(y[ok & r & z == 1], w[ok & r & z == 1]); m0w <- wmean(y[ok & r & z == 0], w[ok & r & z == 0])
      wc <- c((l[4] * m1 + (1 - l[4]) * a) - (l[5] * m0w + (1 - l[5]) * bb),
              (l[4] * m1 + (1 - l[4]) * bb) - (l[5] * m0w + (1 - l[5]) * a))
    }
    stage_ok <- abs(stage) <= qnorm(0.975) * stage_se
    sign_ok <- bounds && !anyNA(l[1:2]) && sign(l[1]) == sign(l[2]) && l[1] != 0
    rows[[j]] <- cbind(base, data.frame(
      mean_no_offer = mean(sub$y[sub$OFFER == 0]), sd_no_offer = sd(sub$y[sub$OFFER == 0]),
      itt = coef(m)[["OFFER"]], itt_se = se(m)[["OFFER"]], itt_p = pvalue(m)[["OFFER"]],
      itt_nc = coef(m0)[["OFFER"]], itt_nc_se = se(m0)[["OFFER"]],
      stage = stage, stage_se = stage_se,
      trim_share = l[3], ipw_diff = l[6], lee_lo = l[1], lee_hi = l[2], im_lo = ci[1], im_hi = ci[2],
      wc_lo = wc[1], wc_hi = wc[2],
      itt_rw = if (is.null(mw)) NA_real_ else coef(mw)[["OFFER"]], itt_rw_se = if (is.null(mw)) NA_real_ else se(mw)[["OFFER"]],
      max_weight_share = if (is.null(mw)) NA_real_ else max(sub$pw) / sum(sub$pw),
      fs = coef(feols(as.formula(paste("D_OD ~ OFFER + .[controls] |", fe)), sub))[["OFFER"]],
      iv = if (is.null(iv)) NA_real_ else coef(iv)[["fit_D_OD"]], iv_se = if (is.null(iv)) NA_real_ else se(iv)[["fit_D_OD"]],
      everyone = everyone, iv_allowed = stage_ok && sign_ok && !is.null(iv)))
  }
  out <- bind_rows(rows)
  out$holm <- NA_real_; out$bh <- NA_real_
  if ("itt_p" %in% names(out)) {
    mains <- which(out$main & !is.na(out$itt_p)); out$holm[mains] <- p.adjust(out$itt_p[mains], "holm")
    for (f in unique(out$family)) {
      k <- which(out$family == f & out$adjust & !is.na(out$itt_p)); out$bh[k] <- p.adjust(out$itt_p[k], "BH")
    }
  }
  out
}

# ---- Table writers ------------------------------------------------------------------------------------
# `w_` is a function that writes one line to the output file.
f <- function(x, d = 3) ifelse(is.na(x), "", formatC(x, format = "f", digits = d, big.mark = ","))
digits_for <- function(m) ifelse(is.na(m), 3, ifelse(abs(m) >= 10000, 0, ifelse(abs(m) >= 100, 1, 3)))

print_effects <- function(w_, res, title, note) {
  w_("## ", title); w_(""); w_(note); w_("")
  w_("| Family | Outcome | With offer | Without offer | Mean without offer | SD without offer | Offer effect | SE | Effect in SD | p | Holm p (main outcomes) | q within family | Offer effect, no controls | SE |")
  w_("|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
  for (i in seq_len(nrow(res))) with(res[i, ], {
    if (min(n_offer, n_no_offer) < MIN_CELL) {
      w_("| ", family, " | ", label, if (main) " (main)" else "", " | suppressed | suppressed | | | | | | | | | | |")
    } else if (min(n_offer, n_no_offer) < MIN_EST) {
      w_("| ", family, " | ", label, if (main) " (main)" else "", " | ", n_offer, " | ", n_no_offer, " | not estimated | | | | | | | | | |")
    } else {
      dg <- digits_for(sd_no_offer)
      w_("| ", family, " | ", label, if (main) " (main)" else "", " | ", n_offer, " | ", n_no_offer, " | ", f(mean_no_offer, dg),
         " | ", f(sd_no_offer, dg), " | ", f(itt, dg), " | ", f(itt_se, dg), " | ", f(itt / sd_no_offer), " | ", f(itt_p),
         " | ", f(holm), " | ", f(bh), " | ", f(itt_nc, dg), " | ", f(itt_nc_se, dg), " |")
    }
  })
  w_("")
}

print_selection <- function(w_, res) {
  w_("| Family | Outcome | Stage effect | SE | Share trimmed | Weighted difference | Lower bound | Upper bound | 95% interval for the bounds | Worst-case bounds | Reweighted offer effect | SE | Largest weight share |")
  w_("|---|---|---|---|---|---|---|---|---|---|---|---|---|")
  for (i in seq_len(nrow(res))) with(res[i, ], {
    if (min(n_offer, n_no_offer) >= MIN_EST) {
      dg <- digits_for(sd_no_offer)
      w_("| ", family, " | ", label, " | ", f(stage, 4), " | ", f(stage_se, 4), " | ", f(trim_share), " | ", f(ipw_diff, dg), " | ",
         f(lee_lo, dg), " | ", f(lee_hi, dg), " | [", f(im_lo, dg), ", ", f(im_hi, dg), "] | ",
         if (is.na(wc_lo)) "" else paste0("[", f(wc_lo, dg), ", ", f(wc_hi, dg), "]"), " | ", f(itt_rw, dg), " | ", f(itt_rw_se, dg), " | ", f(max_weight_share), " |")
    }
  })
  w_("")
}

print_iv <- function(w_, res) {
  w_("| Family | Outcome | First stage among answering children | Attendance effect | SE | Shown |")
  w_("|---|---|---|---|---|---|")
  for (i in seq_len(nrow(res))) with(res[i, ], {
    if (min(n_offer, n_no_offer) >= MIN_EST) {
      dg <- digits_for(sd_no_offer)
      if (isTRUE(iv_allowed)) w_("| ", family, " | ", label, " | ", f(fs), " | ", f(iv, dg), " | ", f(iv_se, dg), " | yes |")
      else w_("| ", family, " | ", label, " | ", f(fs), " | | | no |")
    }
  })
  w_("")
}

# Precision of the offer effect: 95 percent confidence interval and minimum detectable effect
# (2.80 standard errors: 80 percent power in a two-sided test at 5 percent).
print_precision <- function(w_, res) {
  w_("| Outcome | Children | Offer effect | SE | 95% confidence interval | Minimum detectable effect | Same, in SD | p |")
  w_("|---|---|---|---|---|---|---|---|")
  for (i in seq_len(nrow(res))) with(res[i, ], {
    if (min(n_offer, n_no_offer) >= MIN_EST) {
      dg <- digits_for(sd_no_offer)
      w_("| ", label, " | ", n_offer + n_no_offer, " | ", f(itt, dg), " | ", f(itt_se, dg), " | [", f(itt - qnorm(0.975) * itt_se, dg), ", ",
         f(itt + qnorm(0.975) * itt_se, dg), "] | ", f(2.80 * itt_se, dg), " | ", f(2.80 * itt_se / sd_no_offer), " | ", f(itt_p), " |")
    }
  })
  w_("")
}
