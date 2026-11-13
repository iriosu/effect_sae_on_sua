# i1_build.R -- GitHub issue 23 (school characteristics and heterogeneous lottery effects): the child-level frame for
# i2_estimates.R. How to run and extend: README.md.
#
# For every child of the paper's lottery sample (the shared mechanisms panel), it builds:
#   * the two school measures of each over-demanded school, fixed before SAE reached the school: value added (Table I's
#     VA_HEAD, classes of 2013 and 2015) and peer achievement (mean prior-year GPA of its ninth-grade entrants, academic years
#     2012 to g-1), and each school's type (high = above the median over the schools with the measure, each school once);
#   * the child's highest-ranked over-demanded school among the rows she entered (SAE's c1 rows without the row SAE adds for
#     her current school), the rows behind the panel's FC_OD and N_OD; "current school only" when she entered none;
#   * her chance at each over-demanded school on her list, from the one million reruns, computed as the paper's chance
#     (as in the paper: a child without a family link takes her type's mean), and by school type the chance and the
#     number of schools of that type where it is positive; checked to add up to the paper's chance groups;
#   * the school of her offer (SAE's main-stage placement), checked to reproduce the paper's offer.
# Every input is read only and checked against its MD5; the only writes are into output/.
# Run from this folder (code/issue23_school_types): Rscript R/i1_build.R
suppressPackageStartupMessages(library(data.table))
stopifnot("run from code/issue23_school_types (the folder holding R/)" = file.exists("R/i1_build.R"))

# the shared data folder: EFFECT_SAE_DATA if set, else <home>/Dropbox/Effect SAE on SUA/data (home = USERPROFILE on Windows,
# ~ elsewhere); on recent macOS Dropbox may sit at ~/Library/CloudStorage/Dropbox, so set EFFECT_SAE_DATA there
home <- ifelse(Sys.getenv("USERPROFILE") != "", Sys.getenv("USERPROFILE"), path.expand("~"))
SHARED <- Sys.getenv("EFFECT_SAE_DATA", file.path(home, "Dropbox", "Effect SAE on SUA", "data"))
FD <- file.path(SHARED, "finalized_design_v1")
MASTER <- file.path(SHARED, "issue23_school_types")   # the rerun and placement tables m08, m14, m15
OUT <- "output"
dir.create(OUT, showWarnings = FALSE)
YRS <- 2016:2021
DRAWS <- 1000000
t0 <- Sys.time()
note <- function(...) { s <- sprintf(...); message(s); s }   # prints a line and returns it for the log
LOG <- character(0)

# ---- inputs, each checked against its MD5 ----
INPUTS <- c(
  mechanisms_panel    = file.path(FD, "mechanisms", "mechanisms_panel.rds"),
  outcomes_panel      = file.path(FD, "outcomes", "outcomes_panel.rds"),
  outcomes_group      = file.path(FD, "outcomes", "outcomes_group.rds"),
  composition_schools = file.path(FD, "composition", "composition_schools.rds"),
  composition_panel   = file.path(FD, "composition", "composition_panel.rds"),
  sae_admissions      = file.path(SHARED, "sae_admissions.rds"),
  m08                 = file.path(MASTER, "m08_sae_placements.rds"),
  m14                 = file.path(MASTER, "m14_rerun_rows.rds"),
  m15                 = file.path(MASTER, "m15_ninth_grade_chance.rds"))
MD5 <- c(mechanisms_panel = "8d1b6996f18f2d678b543c4428567709", outcomes_panel = "2402d24e51204816f0346855a616a38e",
         outcomes_group = "16e3f75879c90385ffa47e7a7644039b", composition_schools = "d536e8b1cdccae6a696e4ccd01acd9b2",
         composition_panel = "062eac71b982c860ea2281850e896c9d", sae_admissions = "5a55dd9eebe439b6173ac487c0398f0f",
         m08 = "492f3f9d9d2d5e317a4d0a52b868a994", m14 = "880a5c81596c83c114d66c428cbe9fd8",
         m15 = "c4a5023a64c772bf9935a57edc59bf9f")
if (!all(file.exists(INPUTS))) stop("missing inputs (is the data folder elsewhere? set EFFECT_SAE_DATA): ",
                                    paste(INPUTS[!file.exists(INPUTS)], collapse = ", "))
found <- setNames(unname(tools::md5sum(INPUTS)), names(INPUTS))
bad <- names(INPUTS)[found != MD5[names(INPUTS)]]
if (length(bad)) stop("inputs whose MD5 differs from the expected one: ", paste(bad, collapse = ", "))
LOG <- c(LOG, note("inputs: all %d MD5s match", length(INPUTS)))

# ---- the over-demanded schools and the children ----
OD <- as.integer(readRDS(INPUTS[["outcomes_group"]])$RBD)
stopifnot(length(OD) == 1020L, !anyDuplicated(OD), !anyNA(OD))

CTRL <- c("GPA8_Z", "ES_MUJER", "PRIORITARIO", "ALTO", "ORIGIN_OD")
OUTC <- paste0(rep(c("SCORE_LM", "SCORE_NEM", "SCORE_RANKING", "PACE_GRADE", "BEA_GRADE"), each = 2), c("_OT", "_EVER"))
MP <- as.data.table(readRDS(INPUTS[["mechanisms_panel"]]))[, c("YEAR", "MRUN", "CHANCE_GROUP", "OFFER", "D_OD", "ENTRY_RBD",
                                                               CTRL, OUTC), with = FALSE]
stopifnot(nrow(MP) == 186440L, !anyDuplicated(MP, by = c("YEAR", "MRUN")), all(MP$YEAR %in% YRS))
OP_ALL <- as.data.table(readRDS(INPUTS[["outcomes_panel"]]))
stopifnot("the outcomes panel holds none of the score and eligibility outcomes" = !any(OUTC %in% names(OP_ALL)))
OP <- OP_ALL[LOTTERY_SAMPLE == TRUE, .(YEAR, MRUN, CG_OUT = CHANCE_GROUP, CHANCE_GROUP_THOUSANDTHS, OFFER_OUT = OFFER, D_OD_OUT = D_OD,
                                       N_OD, FC_OD, FIRST_CHOICE_SAMPLE, FIRST_CHOICE_OFFER, FIRST_CHOICE_LOTTERY)]
FR <- merge(MP, OP, by = c("YEAR", "MRUN"), all.x = TRUE)
stopifnot("every lottery child is in the outcomes panel's lottery sample" = nrow(FR) == nrow(MP) && !anyNA(FR$CG_OUT),
          "the two panels agree on the chance group, the offer and attendance, child by child" =
            FR[, all(CHANCE_GROUP == CG_OUT & OFFER == OFFER_OUT & D_OD == D_OD_OUT)],
          "attendance is ENTRY_RBD at one of the 1,020" = FR[, all(D_OD == as.integer(!is.na(ENTRY_RBD) & ENTRY_RBD %in% OD))])
FR[, c("CG_OUT", "OFFER_OUT", "D_OD_OUT") := NULL]
LOG <- c(LOG, note("children: %s in the lottery sample; %s with an offer", format(nrow(FR), big.mark = ","), format(sum(FR$OFFER), big.mark = ",")))

# ---- the school measures and types ----
CS <- as.data.table(readRDS(INPUTS[["composition_schools"]]))[RBD %in% OD, .(RBD = as.integer(RBD), VA = VA_HEAD, VA_N = VA_N_HEAD,
                                                                             VA_SIGMA = SIGMA_E_M_HEAD)]
EP <- as.data.table(readRDS(INPUTS[["composition_panel"]]))[COD_NIVEL == 9L]
stopifnot("one DOOR per school" = EP[, uniqueN(DOOR), by = RBD][, all(V1 == 1L)], "ninth grade at the 1,020 only" = all(EP$RBD %in% OD))
# the classes the school selected before SAE: academic years up to g - 1 = DOOR (composition.Rmd: G = DOOR + 1)
PEER <- EP[AGNO <= DOOR & !is.na(PRIOR_GPA_Z), .(PEER = mean(PRIOR_GPA_Z), PEER_N = .N, PEER_YEARS = uniqueN(AGNO),
                                                 G = DOOR[1] + 1L), by = .(RBD = as.integer(RBD))]
rm(EP); invisible(gc())
SCH <- merge(merge(data.table(RBD = OD), CS, by = "RBD", all.x = TRUE), PEER, by = "RBD", all.x = TRUE)
stopifnot(nrow(SCH) == 1020L, !anyDuplicated(SCH$RBD))
type_of <- function(x) { m <- median(x, na.rm = TRUE); fifelse(is.na(x), "none", fifelse(x > m, "high", "low")) }
stopifnot("type_of self-test" = identical(type_of(c(1, 2, 3, NA)), c("low", "low", "high", "none")))
SCH[, `:=`(VA_TYPE = type_of(VA), PEER_TYPE = type_of(PEER), VA_SE = VA_SIGMA / sqrt(VA_N))]
va_med <- median(SCH$VA, na.rm = TRUE)
LOG <- c(LOG, note("schools: value added for %d (median %.4f; %d within one SE of the median), peer achievement for %d (median %.4f); correlation over the %d with both %.3f",
                   SCH[!is.na(VA), .N], va_med, SCH[!is.na(VA) & abs(VA - va_med) <= VA_SE, .N], SCH[!is.na(PEER), .N],
                   median(SCH$PEER, na.rm = TRUE), SCH[!is.na(VA) & !is.na(PEER), .N], SCH[, cor(VA, PEER, use = "complete.obs")]))
LOG <- c(LOG, "school types (value added x peer):", capture.output(SCH[, .N, keyby = .(VA_TYPE, PEER_TYPE)]))

# a school's type: a lookup with its self-test (match, miss, NA, length)
school_type <- function(rbd, measure) {
  stopifnot(measure %in% c("VA_TYPE", "PEER_TYPE"))
  SCH[[measure]][match(as.integer(rbd), SCH$RBD)]
}
local({
  hi <- SCH[VA_TYPE == "high", RBD][1]; lo <- SCH[VA_TYPE == "low", RBD][1]; no <- SCH[VA_TYPE == "none", RBD][1]
  r <- school_type(c(hi, lo, no, NA, -5L), "VA_TYPE")
  stopifnot("school_type self-test" = identical(r, c("high", "low", "none", NA, NA)), length(r) == 5L)
})

# ---- the highest-ranked over-demanded school among the rows the child entered ----
C1 <- as.data.table(readRDS(INPUTS[["sae_admissions"]])$c1)[cod_nivel == 9L & proc %in% YRS & rbd %in% OD,
        .(YEAR = proc, MRUN = mrun, RBD = as.integer(rbd), PREF = preferencia_postulante, CONT = agregada_por_continuidad)]
invisible(gc())
stopifnot("the continuity flag is 0 or 1" = all(C1$CONT %in% 0:1))
OWN <- C1[CONT == 0L]
rm(C1); invisible(gc())
setorder(OWN, YEAR, MRUN, PREF, RBD)
TOP <- OWN[, .(TOP_RBD = RBD[1], TOP_PREF = PREF[1], TOP_TIES = sum(PREF == PREF[1] & RBD != RBD[1]), N_OWN = uniqueN(RBD)),
           by = .(YEAR, MRUN)]
rm(OWN); invisible(gc())
stopifnot("one school at the top preference" = all(TOP$TOP_TIES == 0L))
FR <- merge(FR, TOP[, .(YEAR, MRUN, TOP_RBD, TOP_PREF, N_OWN)], by = c("YEAR", "MRUN"), all.x = TRUE)
FR[is.na(N_OWN), N_OWN := 0L]
stopifnot("the over-demanded schools the child entered are the panel's N_OD" = FR[, all(N_OWN == N_OD)],
          "her highest-ranked one is her first choice exactly when FC_OD is 1" = FR[N_OWN > 0L, all((TOP_PREF == 1L) == (FC_OD == 1L))],
          "the first-choice sample's first choice is an over-demanded school she entered" = FR[FIRST_CHOICE_SAMPLE == TRUE, all(N_OWN > 0L & TOP_PREF == 1L)])
FR[, `:=`(TOP_VA_TYPE = fifelse(N_OWN == 0L, "current only", school_type(TOP_RBD, "VA_TYPE")),
          TOP_PEER_TYPE = fifelse(N_OWN == 0L, "current only", school_type(TOP_RBD, "PEER_TYPE")))]
stopifnot(!anyNA(FR$TOP_VA_TYPE), !anyNA(FR$TOP_PEER_TYPE))
LOG <- c(LOG, note("highest-ranked over-demanded school (rows she entered): %d children entered none (their only over-demanded row is their current school)",
                   FR[N_OWN == 0L, .N]))
LOG <- c(LOG, capture.output(FR[, .N, keyby = TOP_VA_TYPE]), capture.output(FR[, .N, keyby = TOP_PEER_TYPE]))

# ---- the chance at each over-demanded school, computed as the paper's chance ----
M15 <- as.data.table(readRDS(INPUTS[["m15"]]))[YEAR %in% YRS, .(YEAR, STUDENT_ID, MRUN, TYPE_ID, LINKED)]
M14 <- as.data.table(readRDS(INPUTS[["m14"]]))[YEAR %in% YRS & NIVEL == 9L, .(YEAR, STUDENT_ID, RBD, DRAWS_PLACED)]
invisible(gc())
# the paper's chance: the draws at the 1,020 per child; a child without a family link takes her type's mean
R9 <- M14[, .(draws_od = sum(DRAWS_PLACED[RBD %in% OD])), by = .(YEAR, STUDENT_ID)]
X <- merge(M15, R9, by = c("YEAR", "STUDENT_ID"), all.x = TRUE)
stopifnot("every ninth grader has engine rows" = !anyNA(X$draws_od), "one row per ninth grader" = nrow(X) == nrow(M15))
X[, `:=`(type_sum = sum(as.double(draws_od)), type_n = .N), by = .(YEAR, TYPE_ID)]
X[, p_sim := fifelse(LINKED, draws_od / DRAWS, (type_sum / type_n) / DRAWS)]
cell_at <- function(p, d) floor(p / 10^-d + 0.5)   # the paper's chance cells: p rounded to d decimals
stopifnot("cell_at self-test" = identical(cell_at(c(0.004999, 0.005, 0.0149, 1), 2L), c(0, 1, 1, 100)))

# the first-choice children outside the lottery sample: their chance
FCO <- merge(OP_ALL[FIRST_CHOICE_SAMPLE == TRUE & LOTTERY_SAMPLE == FALSE, .(YEAR, MRUN)], X[!is.na(MRUN), .(YEAR, MRUN, p_sim)],
             by = c("YEAR", "MRUN"), all.x = TRUE)
stopifnot("one row per first-choice child outside the lottery sample, each with a chance" =
            nrow(FCO) == OP_ALL[FIRST_CHOICE_SAMPLE == TRUE & LOTTERY_SAMPLE == FALSE, .N] && !anyNA(FCO$p_sim))
LOG <- c(LOG, note("first-choice children outside the lottery sample: %s, of them with a chance of exactly 1: %s, strictly between 0 and 1: %s",
                   format(nrow(FCO), big.mark = ","), format(FCO[p_sim == 1, .N], big.mark = ","), format(FCO[p_sim > 0 & p_sim < 1, .N], big.mark = ",")))
rm(OP_ALL, FCO); invisible(gc())

# the lottery children's rows of X, by (YEAR, MRUN)
K <- X[!is.na(MRUN) & paste(YEAR, MRUN) %in% FR[, paste(YEAR, MRUN)], .(YEAR, MRUN, STUDENT_ID, TYPE_ID, LINKED, type_n, p_sim)]
stopifnot("one ninth grader per MRUN and year among the lottery children" = !anyDuplicated(K, by = c("YEAR", "MRUN")))
FR <- merge(FR, K, by = c("YEAR", "MRUN"), all.x = TRUE)
stopifnot("every child has a chance" = !anyNA(FR$p_sim),
          "the recomputed chance gives the paper's hundredths group for every child" = FR[, all(cell_at(p_sim, 2L) == CHANCE_GROUP)],
          "and its thousandths group" = FR[, all(cell_at(p_sim, 3L) == CHANCE_GROUP_THOUSANDTHS)])
LOG <- c(LOG, note("chance: the recomputed chance gives the paper's hundredths and thousandths groups for all %s children", format(nrow(FR), big.mark = ",")))

# per child and over-demanded school: her own draws there (linked) or her type's draws there (unlinked), integers
S9 <- M14[RBD %in% OD, .(draws = sum(as.double(DRAWS_PLACED))), by = .(YEAR, STUDENT_ID, RBD)]
TS <- merge(S9, X[, .(YEAR, STUDENT_ID, TYPE_ID)], by = c("YEAR", "STUDENT_ID"))[, .(type_school = sum(draws)), by = .(YEAR, TYPE_ID, RBD)]
rm(M14); invisible(gc())
CS9 <- merge(FR[, .(YEAR, MRUN, STUDENT_ID, TYPE_ID, LINKED, type_n)], unique(TS[, .(YEAR, TYPE_ID, RBD)]), by = c("YEAR", "TYPE_ID"),
             allow.cartesian = TRUE)
CS9 <- merge(CS9, TS, by = c("YEAR", "TYPE_ID", "RBD"), all.x = TRUE)
CS9 <- merge(CS9, S9[, .(YEAR, STUDENT_ID, RBD, own = draws)], by = c("YEAR", "STUDENT_ID", "RBD"), all.x = TRUE)
CS9[is.na(own), own := 0]
CS9[, num := fifelse(LINKED, own, type_school)]          # the draws behind her chance at the school (integers)
CS9 <- CS9[num > 0]
CS9[, `:=`(VA_TYPE = school_type(RBD, "VA_TYPE"), PEER_TYPE = school_type(RBD, "PEER_TYPE"))]
stopifnot(!anyNA(CS9$VA_TYPE), !anyNA(CS9$PEER_TYPE))

# by school type: the chance, as the paper's (one division by the type's size, then by the draws), and the number of schools
# of that type where it is positive
chance_by_type <- function(measure) {
  pre <- sub("_TYPE", "", measure)
  tt <- CS9[, .(num = sum(num), n_pos = .N), by = c("YEAR", "MRUN", measure)]
  out <- FR[, .(YEAR, MRUN, LINKED, type_n)]
  for (k in c("high", "low", "none")) {
    part <- tt[get(measure) == k, .(YEAR, MRUN, num, n_pos)]
    out <- merge(out, part, by = c("YEAR", "MRUN"), all.x = TRUE)
    out[is.na(num), `:=`(num = 0, n_pos = 0L)]
    out[, (paste0(pre, "_P_", toupper(k))) := fifelse(LINKED, num / DRAWS, (num / type_n) / DRAWS)]
    setnames(out, "n_pos", paste0(pre, "_NPOS_", toupper(k)))
    out[, num := NULL]
  }
  out[, c("LINKED", "type_n") := NULL]
  out
}
type_notes <- character(2)
for (i in 1:2) {
  m <- c("VA_TYPE", "PEER_TYPE")[i]
  FR <- merge(FR, chance_by_type(m), by = c("YEAR", "MRUN"), all.x = TRUE)
  pre <- sub("_TYPE", "", m)
  gap <- FR[, max(abs(get(paste0(pre, "_P_HIGH")) + get(paste0(pre, "_P_LOW")) + get(paste0(pre, "_P_NONE")) - p_sim))]
  stopifnot("the chances by type add up to the paper's chance for every child (to 1e-12)" = gap < 1e-12,
            "a positive chance at a type exactly when a school of that type has one" =
              FR[, all((get(paste0(pre, "_P_HIGH")) > 0) == (get(paste0(pre, "_NPOS_HIGH")) > 0) &
                         (get(paste0(pre, "_P_LOW")) > 0) == (get(paste0(pre, "_NPOS_LOW")) > 0))])
  type_notes[i] <- note("chances by %s type add up to the chance for every child (largest gap %.1e)", pre, gap)
}
LOG <- c(LOG, type_notes)

# ---- the school of the offer: SAE's main-stage placement ----
M08 <- as.data.table(readRDS(INPUTS[["m08"]]))[COD_NIVEL == 9L & PROC %in% YRS & !is.na(MRUN), .(YEAR = PROC, MRUN, RBD_MS = RBD_MAIN_STAGE)]
invisible(gc())
stopifnot("one main-stage record per child and year" = !anyDuplicated(M08, by = c("YEAR", "MRUN")))
FR <- merge(FR, M08, by = c("YEAR", "MRUN"), all.x = TRUE)
stopifnot("the main-stage placement at one of the 1,020 is the paper's offer for every child" =
            FR[, all(OFFER == as.integer(!is.na(RBD_MS) & RBD_MS %in% OD))])
FR[, OFFER_RBD := fifelse(OFFER == 1L, as.integer(RBD_MS), NA_integer_)]
po <- merge(FR[OFFER == 1L, .(YEAR, MRUN, RBD = OFFER_RBD)], CS9[, .(YEAR, MRUN, RBD, num)], by = c("YEAR", "MRUN", "RBD"), all.x = TRUE)
stopifnot("every offered child has a positive chance at the school of her offer" = nrow(po) == sum(FR$OFFER) && po[, all(!is.na(num))])
FR[, `:=`(OFFER_VA_TYPE = school_type(OFFER_RBD, "VA_TYPE"), OFFER_PEER_TYPE = school_type(OFFER_RBD, "PEER_TYPE"),
          ENTRY_VA_TYPE = fifelse(D_OD == 1L, school_type(ENTRY_RBD, "VA_TYPE"), NA_character_),
          ENTRY_PEER_TYPE = fifelse(D_OD == 1L, school_type(ENTRY_RBD, "PEER_TYPE"), NA_character_))]
# an offer at her highest-ranked over-demanded school (row by row; 0 without an offer or without an entered school)
FR[, OFFER_AT_TOP := as.integer(OFFER == 1L & N_OWN > 0L & !is.na(OFFER_RBD) & !is.na(TOP_RBD) & OFFER_RBD == TOP_RBD)]
stopifnot("OFFER_AT_TOP is 0 or 1 and only with an offer" = FR[, all(OFFER_AT_TOP %in% 0:1) && all(OFFER_AT_TOP <= OFFER)])
LOG <- c(LOG, note("offers: %s, each at a school where the child has a positive chance; at her highest-ranked over-demanded school: %s",
                   format(sum(FR$OFFER), big.mark = ","), format(sum(FR$OFFER_AT_TOP), big.mark = ",")))

# ---- save ----
FR[, RBD_MS := NULL]
setkey(FR, YEAR, MRUN)
saveRDS(FR, file.path(OUT, "i1_frame.rds"))
fwrite(SCH, file.path(OUT, "i1_schools.csv"))
LOG <- c(LOG, note("wrote output/i1_frame.rds (%s rows, %d columns) and output/i1_schools.csv (%d schools) in %.0f s",
                   format(nrow(FR), big.mark = ","), ncol(FR), nrow(SCH), as.numeric(difftime(Sys.time(), t0, units = "secs"))))
writeLines(LOG, file.path(OUT, "i1_build_log.txt"))
