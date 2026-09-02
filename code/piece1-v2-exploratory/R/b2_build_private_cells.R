# b2: build private-school entering-class cells for ALLOC-PRIV-2026-08-31,
# mirroring the certified Piece 1 Stage 4 (00_build_entrant_panel.Rmd) verbatim:
#   entrant = enrolled at the school-grade in t, not enrolled at that school in
#             t-1 (census check over SAE-mappable streams)
#   gpa_z   = entrant's t-1 PROM_GRAL in [1,7], z-scored nationally within year,
#             cell mean; 1st grade voided (Kinder ungraded); PreK/K carry none
#   sh_prio = share designated SEP-prioritario in the enrolment year
#             (roster rule through 2015, PRIORITARIO_ALU flag from 2016)
# Private = modal cod_depe 4 over 2012-2023. All grades, no over-demand screen.
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
ENTRY <- c(-1L, 0L, 1L, 7L, 9L)

# school -> region and dependency (modal over the window; constant per school)
ee <- as.data.table(readRDS(file.path(dp, "panel_ee_2004_2025_homogenized.rds")))
modal <- function(x) { x <- x[!is.na(x)]; if (!length(x)) return(NA_real_)
  as.numeric(names(which.max(table(x)))) }
SCH <- ee[year %in% YRS, .(region = modal(cod_reg_rbd), depe = modal(cod_depe)), by = rbd]
PRIV <- SCH[depe == 4 & !is.na(region), .(rbd, region = as.integer(region))]
say("private paid schools (modal cod_depe 4): %s", format(nrow(PRIV), big.mark = ","))
rm(ee); invisible(gc())

# (COD_ENSE, COD_GRADO) -> SAE level map, as certified
SD <- as.data.table(readRDS(file.path(dp, "sae_data_2016_2023.rds")))
SD <- SD[!is.na(NIVEL) & !is.na(COD_ENSE) & !is.na(COD_GRADO)]
MAP <- unique(SD[, .(COD_ENSE, COD_GRADO, cod_nivel = NIVEL)])
stopifnot("grade map must be a function" =
            !nrow(MAP[, .N, by = .(COD_ENSE, COD_GRADO)][N > 1L]))
rm(SD); invisible(gc())

# prior-GPA lookup, as certified
PF <- as.data.table(readRDS(file.path(dp, "panel_performance_2002_2023.rds")))
PF <- PF[AGNO %in% (min(YRS) - 1L):2023L, .(MRUN, AGNO, PROM_GRAL)]
PF <- PF[!is.na(PROM_GRAL) & PROM_GRAL >= 1 & PROM_GRAL <= 7]
PF[, z := (PROM_GRAL - mean(PROM_GRAL)) / sd(PROM_GRAL), by = AGNO]
GPA <- PF[, .(mrun = as.character(MRUN), agno = AGNO, z)]; rm(PF); invisible(gc())
GPA <- GPA[, .(z = mean(z)), by = .(mrun, agno)]
setkey(GPA, mrun, agno)

# SEP prioritario set per year, as certified
SEPD <- readRDS(file.path(dp, "alumnos_sep_2012_2023.rds"))
prio_set <- function(y) {
  D <- SEPD[agno == y]
  stopifnot("Alumnos-SEP year must be in the packed file" = nrow(D) > 0)
  if (any(!is.na(D$PRIORITARIO_ALU)))
    as.character(unique(D[PRIORITARIO_ALU == 1L & !is.na(RBD), MRUN]))
  else as.character(unique(D[!is.na(CRITERIO_SEP) & CRITERIO_SEP != 0, MRUN]))
}

# entrants year by year from the census, as certified Stage 4
MATC <- readRDS(file.path(dp, "matricula_2011_2023.rds"))
setDT(MATC)
prev <- NULL
RES <- list()
for (t in (min(YRS) - 1L):max(YRS)) {
  M <- MATC[agno == t, .(MRUN, RBD, COD_ENSE, COD_GRADO)]
  stopifnot("matricula year must be in the packed file" = nrow(M) > 0)
  M <- merge(M, MAP, by = c("COD_ENSE", "COD_GRADO"))
  M <- unique(M[, .(mrun = as.character(MRUN), rbd = RBD, cod_nivel)],
              by = c("mrun", "rbd", "cod_nivel"))
  if (t >= min(YRS) && !is.null(prev)) {
    cur <- merge(M, PRIV, by = "rbd")
    cur[, in_prev := !is.na(prev[cur, on = c("mrun", "rbd"), which = TRUE])]
    E <- cur[in_prev == FALSE]
    ps <- prio_set(t)
    E[, prio := as.integer(mrun %chin% ps)]
    E[, agno_prev := t - 1L]
    E[, z := GPA[E, on = .(mrun, agno = agno_prev), x.z]]
    cell <- E[, .(n_ent = .N, sh_prio = mean(prio), gpa_z = mean(z, na.rm = TRUE),
                  n_gpa = sum(!is.na(z))),
              by = .(rbd, region, cod_nivel)]
    cell[, yr := t]
    RES[[as.character(t)]] <- cell
    say("year %d | private entrant cells %s | entrants %s | entrant sh_prio %.4f | %.1f min",
        t, format(nrow(cell), big.mark = ","), format(nrow(E), big.mark = ","),
        E[, mean(prio)], (proc.time() - t0)[["elapsed"]] / 60)
    rm(cur, E); invisible(gc())
  }
  prev <- unique(M[, .(mrun, rbd)]); setkey(prev, mrun, rbd)
  rm(M); invisible(gc())
}
P <- rbindlist(RES); rm(RES, prev, GPA, MATC, SEPD); invisible(gc())

# certified 1st-grade GPA void; entry flag; never-treated bookkeeping
P[cod_nivel == 1L, `:=`(gpa_z = NA_real_, n_gpa = 0L)]
P[is.nan(gpa_z), gpa_z := NA_real_]
P[, `:=`(is_entry = as.integer(cod_nivel %in% ENTRY), door = NA_integer_, G = 0L)]
stopifnot("one region per school" = P[, uniqueN(region), by = rbd][, all(V1 == 1L)])

say("\nverification print 1 — private entrant prioritario share by year:")
print(P[, .(sh_prio = weighted.mean(sh_prio, n_ent)), keyby = yr])
say("verification print 2 — private prior-GPA coverage by grade (grades 2-12):")
print(P[cod_nivel >= 2, .(coverage = sum(n_gpa) / sum(n_ent)), keyby = cod_nivel])

outf <- file.path(xdir, "output", "private_entrant_cells.rds")
saveRDS(P, outf)
say("wrote %s | %s cell-years | %s schools | MD5 %s | %.1f min", outf,
    format(nrow(P), big.mark = ","), format(uniqueN(P$rbd), big.mark = ","),
    unname(tools::md5sum(outf)), (proc.time() - t0)[["elapsed"]] / 60)
