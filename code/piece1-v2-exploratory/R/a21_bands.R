# a21: DID-V2-CONSISTENCY / literature-convention display — 95% simultaneous
# confidence bands for every event-study panel: aggte(dynamic, cband=TRUE),
# region-clustered multiplier bootstrap, per panel-outcome. Guard: the dynamic
# estimates must reproduce the scored event-study CSVs' att values at 1e-8.
# Args: <version A|B> <rule 0|1|2>.
suppressMessages({ library(data.table); library(did) })
t0 <- proc.time()
stopifnot(identical(paste(R.version$major, R.version$minor, sep = "."), "4.5.1"),
          identical(as.character(packageVersion("did")), "2.1.2"))
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 2)
VER <- args[1]; RULE <- args[2]
stopifnot(VER %in% c("A", "B"), RULE %in% c("0", "1", "2"))
SEED <- 20260831; BITERS <- 10000L
home <- Sys.getenv("USERPROFILE")
dp   <- file.path(home, "Dropbox", "Effect SAE on SUA", "data")
xdir <- file.path(home, "Dropbox", "Effect of Centralization",
                  "explorations", "2026-08-31_did_college_outcomes")
say <- function(...) { cat(sprintf(...), "\n"); flush.console() }

epf <- file.path(dp, "entrant_composition_panel.rds")
stopifnot(identical(unname(tools::md5sum(epf)), "8ccec73b5955b723485195d5085b669d"))
EP <- setDT(readRDS(epf)); EP[, `:=`(G = door + 1L, is_priv = 0L)]
pvf <- file.path(xdir, "output", "private_entrant_cells.rds")
stopifnot(identical(unname(tools::md5sum(pvf)), "e43faa7be42d02cfe190fad6924ce6a2"))
PV <- setDT(readRDS(pvf)); PV[, `:=`(G = 0L, is_priv = 1L)]
cols <- c("rbd", "cod_nivel", "yr", "region", "G", "is_priv", "n_ent", "gpa_z", "sh_prio")
CP <- rbind(EP[, ..cols], PV[, ..cols])
CP[, cell_id := as.integer(factor(paste(rbd, cod_nivel, sep = "|")))]
if (RULE == "2") CP[, w_ent := mean(n_ent), by = cell_id] else if (RULE == "1") CP[, w_ent := as.numeric(n_ent)] else CP[, w_ent := 1]
pf <- file.path(xdir, "output", "class_college_allgrades_panel.rds")
stopifnot(identical(unname(tools::md5sum(pf)), "9b2a5f80a0dc3a1400cc12195665a382"))
cls <- setDT(readRDS(pf))
cls[, cell_id := as.integer(factor(paste(rbd, cod_nivel, sep = "|")))]
cls[, is_priv := as.integer(arm == "priv")]
if (RULE == "2") cls[, w_ent := mean(n_ent), by = cell_id] else if (RULE == "1") cls[, w_ent := as.numeric(n_ent)] else cls[, w_ent := 1]

SC <- fread(file.path(xdir, "output", sprintf("es_stud_cells_%s_rule%s.csv", VER, RULE)))
RES <- list()
for (job in list(list(part = "comp", y = "gpa_z"), list(part = "comp", y = "sh_prio"),
                 list(part = "col", y = "grad_ontime"), list(part = "col", y = "applied"),
                 list(part = "col", y = "assigned"), list(part = "col", y = "enrolled"))) {
  if (job$part == "comp") {
    D <- if (VER == "A") CP[is_priv == 0L] else CP
    d <- D[!is.na(get(job$y)), .(cell_id, tt = yr, G = fifelse(is_priv == 1L, 0L, G),
                                 region, y = get(job$y), w = w_ent)]
  } else {
    D <- if (VER == "A") cls[is_priv == 0L] else cls
    d <- D[, .(cell_id, tt = proc, G = fifelse(is_priv == 1L | G > 2026L, 0L, G),
               region, y = get(job$y), w = w_ent)]
  }
  set.seed(SEED)
  at <- att_gt(yname = "y", tname = "tt", idname = "cell_id", gname = "G",
               data = d, control_group = "notyettreated", panel = TRUE,
               allow_unbalanced_panel = TRUE, base_period = "universal",
               weightsname = "w", bstrap = TRUE, biters = BITERS,
               clustervars = "region", cband = TRUE, print_details = FALSE)
  ed <- suppressWarnings(aggte(at, type = "dynamic", na.rm = TRUE, cband = TRUE))
  ref <- SC[outcome == job$y]
  chk <- merge(data.table(e = ed$egt, att = ed$att.egt),
               ref[, .(e = as.integer(e), att_scored = att)], by = "e")
  gap <- chk[, max(abs(att - att_scored))]
  stopifnot("band-run estimates must reproduce the scored event-study values" = gap < 1e-8)
  RES[[job$y]] <- data.table(version = VER, rule = RULE, outcome = job$y,
                             e = ed$egt, att = ed$att.egt, se = ed$se.egt,
                             crit = ed$crit.val.egt)
  say("[%s R%s | %s] bands done (crit %.3f, gap %.1e) | %.1f min", VER, RULE, job$y,
      ed$crit.val.egt[1], gap, (proc.time() - t0)[["elapsed"]] / 60)
}
R <- rbindlist(RES)
R[, outside := is.finite(crit) & !is.na(se) & abs(att) > crit * se]
fwrite(R, file.path(xdir, "output", sprintf("es_bands_%s_rule%s.csv", VER, RULE)))
say("panel %s rule %s complete | %.1f min", VER, RULE, (proc.time() - t0)[["elapsed"]] / 60)
