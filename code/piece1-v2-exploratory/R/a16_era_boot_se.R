# a16: DID-V2-CONSISTENCY-2026-09-01 item 1 — region-clustered bootstrap SEs
# for the era pools, via the influence-function combination. The era pool is a
# fixed-weight average of the calendar-year cells, so its influence function is
# the same weighted average of their influence functions; the SE comes from the
# identical multiplier bootstrap (did:::mboot) used for every other SE.
# GATE: before any era SE is trusted, the same pipeline must reproduce the
# package's own per-year calendar SEs from their influence functions.
# Streams: version x rule x four college outcomes. Args: <A|B> <1|2>.
suppressMessages({ library(data.table); library(did) })
t0 <- proc.time()
stopifnot(identical(paste(R.version$major, R.version$minor, sep = "."), "4.5.1"),
          identical(as.character(packageVersion("did")), "2.1.2"))
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 2)
VER <- args[1]; RULE <- args[2]
SEED <- 20260831; BITERS <- 10000L
home <- Sys.getenv("USERPROFILE")
xdir <- file.path(home, "Dropbox", "Effect of Centralization",
                  "explorations", "2026-08-31_did_college_outcomes")
say <- function(...) { cat(sprintf(...), "\n"); flush.console() }

pf <- file.path(xdir, "output", "class_college_allgrades_panel.rds")
stopifnot(identical(unname(tools::md5sum(pf)), "9b2a5f80a0dc3a1400cc12195665a382"))
cls <- setDT(readRDS(pf))
cls[, cell_id := as.integer(factor(paste(rbd, cod_nivel, sep = "|")))]
cls[, is_priv := as.integer(arm == "priv")]
if (RULE == "2") cls[, w_ent := mean(n_ent), by = cell_id] else if (RULE == "1") cls[, w_ent := as.numeric(n_ent)] else cls[, w_ent := 1]
D <- if (VER == "A") cls[is_priv == 0L] else cls

RES <- list()
for (y in c("grad_ontime", "applied", "assigned", "enrolled")) {
  d <- D[, .(cell_id, tt = proc, G = fifelse(is_priv == 1L | G > 2026L, 0L, G),
             region, y = get(y), w = w_ent)]
  set.seed(SEED)
  at <- att_gt(yname = "y", tname = "tt", idname = "cell_id", gname = "G",
               data = d, control_group = "notyettreated", panel = TRUE,
               allow_unbalanced_panel = TRUE, base_period = "universal",
               weightsname = "w", bstrap = TRUE, biters = BITERS,
               clustervars = "region", print_details = FALSE)
  ca <- suppressWarnings(aggte(at, type = "calendar", na.rm = TRUE))
  IF <- ca$inf.function
  stopifnot("aggte must return calendar influence functions" = !is.null(IF))
  # locate the per-year IF matrix (structure introspection, then hard checks)
  M <- NULL
  for (nm in names(IF)) {
    x <- IF[[nm]]
    if (is.matrix(x) && ncol(x) == length(ca$egt)) { M <- x; break }
  }
  stopifnot("per-year IF matrix (one column per calendar year) must exist" = !is.null(M))
  # GATE 1 (pipeline correctness, Monte Carlo tolerance): the package's
  # per-year SEs are themselves one 10,000-draw bootstrap realization; an
  # independent 10,000-draw run of the same quantity differs by Monte Carlo
  # noise, so agreement is required at 5% relative, not machine precision.
  set.seed(SEED)
  bo <- did:::mboot(M, at$DIDparams)
  gap <- max(abs(bo$se / ca$se.egt - 1), na.rm = TRUE)
  say("[%s R%s | %s] gate 1: per-year SEs, IF pipeline vs package, max rel gap %.2e",
      VER, RULE, y, gap)
  stopifnot("IF pipeline must reproduce the package calendar SEs within Monte Carlo tolerance" =
              gap < 0.05)
  # era weights: per-year aggregation weight = sum over groups of the group
  # weight at usable (g,t) cells — recovered from the package's own pg-based
  # weighting by inverting the calendar average is unnecessary: the era pool
  # was defined with the same per-year weights used in the record runs
  # (yr_den). Recompute them exactly as the record scoring did.
  dpp <- at$DIDparams
  pd <- as.data.table(as.data.frame(dpp$data))
  if (isTRUE(dpp$panel)) {
    UW <- pd[get(dpp$tname) == dpp$tlist[1], .(cell_id = get(dpp$idname), uw = .w)]
  } else UW <- pd[, .(uw = mean(.w)), by = .(cell_id = get(dpp$idname))]
  PK <- data.table(g = at$group, t = at$t, att = at$att)[t >= g & !is.na(att)]
  gw <- pd[, .(cell_id = get(dpp$idname), G = get(dpp$gname))][UW, on = "cell_id"]
  gw <- unique(gw)[, .(gsum = sum(uw)), by = G]
  PK <- gw[PK, on = c(G = "g")]
  yr_den <- PK[, .(den = sum(gsum)), keyby = t]
  for (era in list(c("era_old", 2020, 2022), c("era_new", 2023, 2026))) {
    keep <- ca$egt >= as.integer(era[2]) & ca$egt <= as.integer(era[3])
    if (!any(keep)) next
    wts <- yr_den[match(ca$egt[keep], t), den]
    wts <- wts / sum(wts)
    if_era <- as.numeric(M[, keep, drop = FALSE] %*% wts)
    est <- sum(ca$att.egt[keep] * wts)
    # GATE 2 (implementation exactness): one shared multiplier stream scores
    # the per-year columns and the era column together; the per-year SEs from
    # this joint call must equal gate 1's per-year SEs at machine precision
    # (same seed, same draws), proving the era column rides the identical
    # bootstrap rather than a differently-coded one.
    set.seed(SEED)
    bo2 <- did:::mboot(cbind(M, if_era), at$DIDparams)
    stopifnot("joint call must reproduce gate 1's per-year SEs exactly" =
                max(abs(bo2$se[seq_len(ncol(M))] - bo$se), na.rm = TRUE) < 1e-10)
    se <- bo2$se[ncol(M) + 1L]
    RES[[paste(y, era[1])]] <- data.table(version = VER, rule = RULE, outcome = y,
                                          cell = era[1], att = est, se_boot = se)
    say("[%s R%s | %s] %s: %+.4f (boot SE %.4f)", VER, RULE, y, era[1], est, se)
  }
}
fwrite(rbindlist(RES), file.path(xdir, "output",
       sprintf("era_boot_se_%s_rule%s.csv", VER, RULE)))
say("done | %.1f min", (proc.time() - t0)[["elapsed"]] / 60)
