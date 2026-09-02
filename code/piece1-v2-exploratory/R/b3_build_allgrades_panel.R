# b3: class panel for DID-COLLEGE-ALLG-PUB/PRIV-2026-08-31 — entering classes
# at ALL grades of the always-over-demanded schools (certified cell list) and of
# the private paid schools (ALLOC-PRIV school set), aligned by the class's
# on-time college process year.
#   entrant   = certified Stage 4 census definition (enrolled in t, not enrolled
#               at that school in t-1, SAE-mappable streams)
#   grade g   = cod_nivel (1..12; PreK/K = -1/0)
#   proc      = t + 13 - g   (on-time college process)
#   grad_ontime = promoted out of 12th (SIT_FIN_R P) in proc - 1, else 0
#   applied/assigned/enrolled = flags at proc from college_outcomes, no row = 0
#   window: entering cohorts 2012-2023, proc 2018-2026
suppressMessages(library(data.table))
t0 <- proc.time()
stopifnot("R must be 4.5.1" = identical(paste(R.version$major, R.version$minor, sep = "."), "4.5.1"))
setDTthreads(4)
home <- Sys.getenv("USERPROFILE")
dp   <- file.path(home, "Dropbox", "Effect SAE on SUA", "data")
xdir <- file.path(home, "Dropbox", "Effect of Centralization",
                  "explorations", "2026-08-31_did_college_outcomes")
say <- function(...) { cat(sprintf(...), "\n"); flush.console() }
YRS <- 2012:2023

# certified over-demanded cells (all grades) with door/region/is_entry
epf <- file.path(dp, "entrant_composition_panel.rds")
stopifnot(identical(unname(tools::md5sum(epf)), "8ccec73b5955b723485195d5085b669d"))
EP <- setDT(readRDS(epf))
CELLS <- unique(EP[, .(rbd, cod_nivel, region, is_entry, door)])
stopifnot(!anyDuplicated(CELLS, by = c("rbd", "cod_nivel")))
rm(EP); invisible(gc())

# private school set (as built for ALLOC-PRIV; region constant per school)
pvf <- file.path(xdir, "output", "private_entrant_cells.rds")
stopifnot(identical(unname(tools::md5sum(pvf)), "e43faa7be42d02cfe190fad6924ce6a2"))
PRIV <- unique(setDT(readRDS(pvf))[, .(rbd, region)])
PRIV <- PRIV[!rbd %in% CELLS$rbd]
say("cells: %s over-demanded (all grades) | %s private schools",
    format(nrow(CELLS), big.mark = ","), format(nrow(PRIV), big.mark = ","))

# grade map, as certified
SD <- as.data.table(readRDS(file.path(dp, "sae_data_2016_2023.rds")))
SD <- SD[!is.na(NIVEL) & !is.na(COD_ENSE) & !is.na(COD_GRADO)]
MAP <- unique(SD[, .(COD_ENSE, COD_GRADO, cod_nivel = NIVEL)])
stopifnot(!nrow(MAP[, .N, by = .(COD_ENSE, COD_GRADO)][N > 1L]))
rm(SD); invisible(gc())

# 12th-grade promotion set 2017-2025 (as RUN-348: student panel + supplement)
media <- c(310, 410, 510, 610, 710, 810)
df <- setDT(readRDS(file.path(dp, "panel_9-12_2010_2021.rds")))
G12 <- unique(df[COD_ENSE %in% media & COD_GRADO == 4 & SIT_FIN_R == "P",
                 .(mrun = as.character(MRUN), agno = AGNO)])
rm(df); invisible(gc())
RND <- setDT(readRDS(file.path(dp, "rendimiento_2024_2025.rds")))
G12 <- unique(rbind(G12, RND[COD_ENSE %in% media & COD_GRADO == 4 & SIT_FIN_R == "P",
                             .(mrun = as.character(MRUN), agno)]))
rm(RND); invisible(gc())
setkey(G12, mrun, agno)
stopifnot(all(2017:2025 %in% unique(G12$agno)))

# entrants year by year (certified Stage 4 check), student lists kept
MATC <- readRDS(file.path(dp, "matricula_2011_2023.rds"))
setDT(MATC)
prev <- NULL
ELIST <- list()
for (t in (min(YRS) - 1L):max(YRS)) {
  M <- MATC[agno == t, .(MRUN, RBD, COD_ENSE, COD_GRADO)]
  stopifnot(nrow(M) > 0)
  M <- merge(M, MAP, by = c("COD_ENSE", "COD_GRADO"))
  M <- unique(M[, .(mrun = as.character(MRUN), rbd = RBD, cod_nivel)],
              by = c("mrun", "rbd", "cod_nivel"))
  if (t >= min(YRS) && !is.null(prev)) {
    curp <- merge(M, CELLS[, .(rbd, cod_nivel)], by = c("rbd", "cod_nivel"))
    curp[, arm := "pub"]
    curv <- merge(M, PRIV[, .(rbd)], by = "rbd")
    curv[, arm := "priv"]
    cur <- rbind(curp, curv)
    cur[, in_prev := !is.na(prev[cur, on = c("mrun", "rbd"), which = TRUE])]
    E <- cur[in_prev == FALSE][, .(mrun, rbd, cod_nivel, arm)]
    E[, entry := t]
    ELIST[[as.character(t)]] <- E
    say("year %d | entrants pub %s priv %s | %.1f min", t,
        format(E[arm == "pub", .N], big.mark = ","),
        format(E[arm == "priv", .N], big.mark = ","),
        (proc.time() - t0)[["elapsed"]] / 60)
    rm(curp, curv, cur, E); invisible(gc())
  }
  prev <- unique(M[, .(mrun, rbd)]); setkey(prev, mrun, rbd)
  rm(M); invisible(gc())
}
STU <- rbindlist(ELIST); rm(ELIST, prev, MATC); invisible(gc())

# on-time process and window
STU[, g := cod_nivel]                       # -1..12; proc = entry + 13 - g
STU[, proc := entry + 13L - g]
STU <- STU[proc >= 2018L & proc <= 2026L]
say("class-member rows in the process window: %s (pub %s / priv %s)",
    format(nrow(STU), big.mark = ","), format(STU[arm == "pub", .N], big.mark = ","),
    format(STU[arm == "priv", .N], big.mark = ","))

# outcomes
STU[, grad_ontime := as.integer(!is.na(G12[STU[, .(mrun, agno = proc - 1L)],
                                            on = .(mrun, agno), which = TRUE]))]
rm(G12); invisible(gc())
CO <- setDT(readRDS(file.path(dp, "college_outcomes_2018_2026.rds")))
CO <- CO[, .(mrun = as.character(mrun), proc, applied, assigned, enrolled)]
stopifnot(!anyDuplicated(CO, by = c("mrun", "proc")))
STU <- merge(STU, CO, by = c("mrun", "proc"), all.x = TRUE)
for (v in c("applied", "assigned", "enrolled")) STU[is.na(get(v)), (v) := 0]
rm(CO); invisible(gc())
stopifnot(STU[, all(unlist(lapply(.SD, function(x) all(x %in% 0:1)))),
              .SDcols = c("grad_ontime", "applied", "assigned", "enrolled")])

# class panel: cell x process year
cls <- STU[, c(.(n_ent = .N), lapply(.SD, mean)),
           by = .(rbd, cod_nivel, arm, proc),
           .SDcols = c("grad_ontime", "applied", "assigned", "enrolled")]
cls <- merge(cls, rbind(CELLS[, .(rbd, cod_nivel, region, is_entry, door)],
                        data.table(rbd = PRIV$rbd, cod_nivel = NA_integer_,
                                   region = as.integer(PRIV$region),
                                   is_entry = NA_integer_, door = NA_integer_)[0]),
             by = c("rbd", "cod_nivel"), all.x = TRUE)
# privates: region from the school set, no door
cls <- merge(cls, PRIV[, .(rbd, region_priv = as.integer(region))], by = "rbd", all.x = TRUE)
cls[arm == "priv", region := region_priv]
cls[, region_priv := NULL]
# treatment on the process clock
cls[arm == "pub",  G := (door + 1L) + 13L - cod_nivel]
cls[arm == "priv", G := 0L]
stopifnot(!anyNA(cls$G), !anyNA(cls$region),
          cls[, uniqueN(region), by = rbd][, all(V1 == 1L)])

say("class panel: %s cell-procs (pub %s / priv %s) | %s cells | G (pub) range %d-%d",
    format(nrow(cls), big.mark = ","), format(cls[arm == "pub", .N], big.mark = ","),
    format(cls[arm == "priv", .N], big.mark = ","),
    format(uniqueN(cls[, paste(rbd, cod_nivel)]), big.mark = ","),
    cls[arm == "pub", min(G)], cls[arm == "pub", max(G)])
say("pub class-years by process year:")
print(cls[arm == "pub", .(cells = .N, treated = sum(proc >= G),
                          grad = weighted.mean(grad_ontime, n_ent),
                          applied = weighted.mean(applied, n_ent)), keyby = proc])

outf <- file.path(xdir, "output", "class_college_allgrades_panel.rds")
saveRDS(cls, outf)
say("wrote %s | MD5 %s | %.1f min", outf, unname(tools::md5sum(outf)),
    (proc.time() - t0)[["elapsed"]] / 60)
