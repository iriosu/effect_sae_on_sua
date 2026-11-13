# i2_estimates.R -- GitHub issue 23 (school characteristics and heterogeneous lottery effects): the estimates, from
# output/i1_frame.rds (R/i1_build.R). How to run and extend: README.md.
#
# The comparison is the mechanisms notebook's (code/finalized_design_v1/mechanisms/mechanisms.Rmd, tsls()): 2SLS of each outcome on
# attendance at an over-demanded school, the offer as the instrument, the five controls, application-year and chance-group
# fixed effects, heteroskedasticity-robust SEs without the N/(N-K) factor, p from the normal distribution.
# Checks before any group is estimated: the whole sample reproduces the paper's ten estimates, SEs and Ns (Table IX Panel A;
# Table X's two grade-rule rows), the 112,679 children without an offer and the first stage (61.04 pp); one group's SE equals
# the HC0 sandwich computed by hand; the first-choice estimator reproduces Appendix Table C.4 on its own sample.
#   Part 1: the same 2SLS inside groups fixed before the lottery, by the type of the highest-ranked over-demanded school the
#           child entered: value added (A), peer achievement (B), peer type x the child's own GPA8 (C), value-added type x
#           peer type (D); the first-choice 2SLS split by A and B. For each group, where the offers and the attendance land.
#   Part 2: attendance at a high-type and at a low-type school, instrumented by an offer at each type, one fixed effect per
#           pair of cells of the chances at the two types (a cell of its own for no chance); the 2x2 first stage, the
#           reduced forms and each first stage's Wald F.
# Reads output/i1_frame.rds, output/i1_schools.csv and the shared outcomes panel (for the Table C.4 check); writes output/i2_*.
# Run from this folder (code/issue23_school_types), after R/i1_build.R: Rscript R/i2_estimates.R
suppressPackageStartupMessages({
  library(data.table)
  library(fixest)
})
stopifnot(packageVersion("fixest") >= "0.13.0")   # earlier versions add a factor n/(n-1) to robust SEs

stopifnot("run from code/issue23_school_types (the folder holding R/)" = file.exists("R/i2_estimates.R"))
# the shared data folder as in R/i1_build.R: EFFECT_SAE_DATA if set, else <home>/Dropbox/Effect SAE on SUA/data
home <- ifelse(Sys.getenv("USERPROFILE") != "", Sys.getenv("USERPROFILE"), path.expand("~"))
FD <- file.path(Sys.getenv("EFFECT_SAE_DATA", file.path(home, "Dropbox", "Effect SAE on SUA", "data")), "finalized_design_v1")
OUT <- "output"
# the frame and school file of R/i1_build.R (checked below by reproducing the paper's numbers) and the shared outcomes
# panel, checked against its MD5
FILES <- c(frame = file.path(OUT, "i1_frame.rds"), schools = file.path(OUT, "i1_schools.csv"),
           outcomes_panel = file.path(FD, "outcomes", "outcomes_panel.rds"))
if (!all(file.exists(FILES))) stop("missing (run R/i1_build.R first?): ", paste(FILES[!file.exists(FILES)], collapse = ", "))
if (unname(tools::md5sum(FILES[["outcomes_panel"]])) != "2402d24e51204816f0346855a616a38e") stop("the shared outcomes panel's MD5 differs")
t0 <- Sys.time()

# the notebooks' settings, asserted
setFixest_vcov(all = "hetero")            # robust SEs: OLS with the N/(N-K) factor
setFixest_estimation(fixef.rm = "none")   # keep chance groups that hold a single child
setFixest_notes(FALSE)
stopifnot("robust SEs everywhere" = all(unlist(getFixest_vcov()) == "hetero"),
          "no fixed-effect group dropped" = identical(getFixest_estimation()$fixef.rm, "none"))
SSC_2SLS <- ssc(K.adj = FALSE)            # 2SLS SEs without the N/(N-K) factor, as ivreg2's robust

CTRL <- c("GPA8_Z", "ES_MUJER", "PRIORITARIO", "ALTO", "ORIGIN_OD")
BASE <- c(SCORE_LM = "Exam (math-verbal), SD", SCORE_NEM = "NEM, SD", SCORE_RANKING = "Ranking, SD",
          PACE_GRADE = "Met PACE's grade rule, pp", BEA_GRADE = "Met BEA's grade rule, pp")
OUTC <- paste0(rep(names(BASE), each = 2), c("_OT", "_EVER"))
SCALE <- setNames(ifelse(grepl("^(PACE|BEA)", OUTC), 100, 1), OUTC)   # the 0/1 rows in %, their effects in pp
DIGITS <- setNames(ifelse(SCALE == 100, 2, 3), OUTC)

note <- function(...) { s <- sprintf(...); message(s); s }
LOG <- character(0)
star <- function(p) ifelse(p < 0.01, "***", ifelse(p < 0.05, "**", ifelse(p < 0.1, "*", "")))
fmt <- function(x, d) sub("^-(0\\.0+)$", "\\1", sprintf(paste0("%.", d, "f"), x))
cell_at <- function(p, d) floor(p / 10^-d + 0.5)
pnorm2 <- function(t) 2 * pnorm(-abs(t))

FR <- readRDS(FILES[["frame"]])
ES <- FR[complete.cases(FR[, ..CTRL])]
stopifnot("the estimation sample of Tables IX and X" = nrow(ES) == 185970L)
ES[, OWN_TYPE := fifelse(GPA8_Z > median(GPA8_Z), "high", "low")]

# ---- estimators ----
# the formula pieces. The paper's year reference is 2016; a group without 2016 applicants takes its earliest year as the
# reference (the same set of year effects next to the chance-group effects, so the same estimates)
lhs_of <- function(vars) paste0("c(", paste(vars, collapse = ", "), ")")
year_term <- function(d) sprintf("i(YEAR, ref = %d)", min(d$YEAR))
rhs_of <- function(d) paste(c(CTRL, year_term(d)), collapse = " + ")
stopifnot("year_term self-test" = year_term(data.table(YEAR = c(2018L, 2017L))) == "i(YEAR, ref = 2017)")
models_of <- function(fit) if (inherits(fit, "fixest_multi")) as.list(fit) else list(fit)

# 2SLS of each outcome in vars on attendance, instrumented by the offer, inside d (the mechanisms notebook's tsls());
# first_choice: the outcomes notebook's first-choice 2SLS (the first-choice offer, one fixed effect per first-choice lottery)
tsls <- function(d, vars = OUTC, first_choice = FALSE) {
  fml <- if (first_choice) paste(lhs_of(vars), "~", paste(CTRL, collapse = " + "), "| FIRST_CHOICE_LOTTERY | D_OD ~ FIRST_CHOICE_OFFER")
         else paste(lhs_of(vars), "~", rhs_of(d), "| CHANCE_GROUP | D_OD ~ OFFER")
  models <- models_of(feols(as.formula(fml), d, ssc = SSC_2SLS))
  z <- if (first_choice) d$FIRST_CHOICE_OFFER else d$OFFER
  out <- data.table(outcome = vars,
                    est = vapply(models, function(m) coef(m)[["fit_D_OD"]], 0),
                    se = vapply(models, function(m) se(m)[["fit_D_OD"]], 0),
                    p = vapply(models, function(m) pnorm2(tstat(m)[["fit_D_OD"]]), 0),
                    n = vapply(models, nobs, 0),
                    n0 = vapply(vars, function(v) sum(z == 0L & !is.na(d[[v]])), 0),
                    mean0 = vapply(vars, function(v) mean(d[[v]][z == 0L], na.rm = TRUE), 0))
  stopifnot("2SLS SEs without the N/(N-K) factor" = all(vapply(models, function(m) isFALSE(m$summary_flags$ssc$K.adj), TRUE)),
            "every child with the outcome is used" = all(out$n == vapply(vars, function(v) sum(!is.na(d[[v]])), 0)),
            "finite estimates and SEs" = all(is.finite(c(out$est, out$se))))
  out
}
# the first stage, as the outcomes notebook's (OLS, robust SE with the N/(N-K) factor)
first_stage <- function(d, first_choice = FALSE) {
  z <- if (first_choice) "FIRST_CHOICE_OFFER" else "OFFER"
  fml <- if (first_choice) paste("D_OD ~ FIRST_CHOICE_OFFER +", paste(CTRL, collapse = " + "), "| FIRST_CHOICE_LOTTERY")
         else paste("D_OD ~ OFFER +", rhs_of(d), "| CHANCE_GROUP")
  m <- feols(as.formula(fml), d)
  data.table(fs = coef(m)[[z]], fs_se = se(m)[[z]], fs_p = pvalue(m)[[z]])
}
# the support of a group: children, offered and not, and the lottery cells holding both
support <- function(d, first_choice = FALSE) {
  z <- if (first_choice) d$FIRST_CHOICE_OFFER else d$OFFER
  g <- if (first_choice) d$FIRST_CHOICE_LOTTERY else d$CHANCE_GROUP
  v <- data.table(g, z)[, .(both = any(z == 1L) & any(z == 0L), n = .N), by = g]
  data.table(children = nrow(d), offered = sum(z == 1L), not_offered = sum(z == 0L), cells_with_both = v[both == TRUE, .N],
             children_in_those_cells = v[both == TRUE, sum(n)])
}
run_group <- function(analysis, group, d, first_choice = FALSE) {
  cbind(data.table(analysis = analysis, group = group), support(d, first_choice), first_stage(d, first_choice),
        tsls(d, OUTC, first_choice))
}

# ---- check 1: the whole sample against the paper (its tables/lottery_admission_scores.tex, tables/pace_bea_access.tex;
#      the first stage of tables/outcomes_text_macros.tex) ----
whole <- run_group("whole", "all", ES)
PAPER10 <- paste0(rep(c("SCORE_LM", "SCORE_NEM", "SCORE_RANKING", "PACE_GRADE", "BEA_GRADE"), each = 2), c("_OT", "_EVER"))
stopifnot("the paper's ten outcomes are estimated" = all(PAPER10 %in% OUTC))
pin <- data.table(outcome = PAPER10,
                  est = c("0.023", "0.023", "-0.173", "-0.175", "-0.216", "-0.215", "-9.05", "-9.09", "-4.79", "-4.93"),
                  se = c("0.009", "0.009", "0.008", "0.008", "0.008", "0.008", "0.36", "0.36", "0.26", "0.26"),
                  n = c(113062, 123108, 157648, 170357, 157648, 170357, 185970, 185970, 185970, 185970))
got <- whole[match(PAPER10, outcome), .(outcome, est = fmt(est * SCALE[outcome], DIGITS[outcome]), se = fmt(se * SCALE[outcome], DIGITS[outcome]), n)]
if (!isTRUE(all.equal(got, pin, check.attributes = FALSE))) {
  print(merge(got, pin, by = "outcome", suffixes = c("_got", "_paper")))
  stop("the whole sample does not reproduce the paper's ten estimates")
}
stopifnot("Table X's 112,679 children without an offer" = all(whole[grepl("^(PACE|BEA)", outcome), n0] == 112679),
          "the first stage of the outcomes section (61.04 pp)" = fmt(100 * whole$fs[1], 2) == "61.04")
LOG <- c(LOG, note("check 1: the whole sample reproduces the paper's ten estimates, SEs and Ns, the 112,679 without an offer and the first stage (61.04 pp)"))

# ---- check 2: one small group's SE recomputed by hand as the HC0 sandwich (no N/(N-K) factor) ----
LOG <- c(LOG, local({
  d <- ES[TOP_PEER_TYPE == "none"]
  yrs <- sort(unique(d$YEAR))[-1]
  M <- cbind(y = d$PACE_GRADE_OT, D = d$D_OD, Z = d$OFFER, as.matrix(d[, ..CTRL]),
             vapply(yrs, function(y) as.numeric(d$YEAR == y), numeric(nrow(d))))
  dm <- demean(M, f = d$CHANCE_GROUP)
  X <- dm[, -c(1, 3)]; Zm <- dm[, -c(1, 2)]
  Xh <- Zm %*% qr.solve(crossprod(Zm), crossprod(Zm, X))
  b <- qr.solve(crossprod(Xh, X), crossprod(Xh, dm[, 1]))
  u <- as.numeric(dm[, 1] - X %*% b)
  A <- qr.solve(crossprod(Xh))
  se_hand <- sqrt(diag(A %*% crossprod(Xh * u) %*% A))[1]
  r <- tsls(d, "PACE_GRADE_OT")
  stopifnot("the 2SLS SE equals the HC0 sandwich by hand" = abs(r$se / se_hand - 1) < 1e-8,
            "and the estimate" = abs(r$est - b[1]) < 1e-10)
  note("check 2: on the %d children whose highest-ranked school has no peer measure, the SE equals the HC0 sandwich by hand (%.6f)", nrow(d), se_hand)
}))

# ---- check 3: the first-choice estimator reproduces Appendix Table C.4 on its own sample ----
OP <- as.data.table(readRDS(FILES[["outcomes_panel"]]))
OP[, `:=`(ANYWHERE_OT = INSUA_OT + OUTSIDE_OT, ANYWHERE_EVER = INSUA_EVER + OUTSIDE_EVER)]
COLLEGE <- c("GRAD", "GRAD_REGULAR", "GRAD_ADULT", "APPLIED", "ASSIGNED", "ANYWHERE", "INSUA", "OUTSIDE")
CVARS <- c(paste0(COLLEGE, "_OT"), paste0(COLLEGE, "_EVER"))
FCP <- OP[FIRST_CHOICE_SAMPLE == TRUE][complete.cases(OP[FIRST_CHOICE_SAMPLE == TRUE, ..CTRL])]
rm(OP); invisible(gc())
c4 <- tsls(FCP, CVARS, first_choice = TRUE)
c4_pin <- data.table(outcome = CVARS,
  mean0 = c("85.37", "80.90", "4.47", "38.92", "29.45", "47.36", "25.30", "22.06", "92.01", "85.79", "6.22", "46.05", "37.76", "68.83", "35.30", "33.53"),
  est = c("-4.22", "-4.63", "0.41", "-2.44", "-3.24", "-4.97", "-3.41", "-1.55", "-1.37", "-2.28", "0.91", "-1.39", "-2.04", "-2.51", "-2.33", "-0.19"),
  se = c("0.48", "0.53", "0.29", "0.59", "0.55", "0.66", "0.52", "0.57", "0.37", "0.47", "0.34", "0.59", "0.57", "0.60", "0.56", "0.64"))
c4_got <- c4[, .(outcome, mean0 = fmt(100 * mean0, 2), est = fmt(100 * est, 2), se = fmt(100 * se, 2))]
if (!isTRUE(all.equal(c4_got, c4_pin, check.attributes = FALSE))) {
  print(merge(c4_got, c4_pin, by = "outcome", suffixes = c("_got", "_paper")))
  stop("the first-choice estimator does not reproduce Appendix Table C.4")
}
fs4 <- first_stage(FCP, first_choice = TRUE)
N_FCP <- nrow(FCP)                         # the first-choice sample with every control (Table C.4)
N_FCP_OUT <- FCP[LOTTERY_SAMPLE == FALSE, .N]   # of them, outside the lottery sample (counted directly)
stopifnot("Table C.4's N" = N_FCP == 114550L && all(c4$n == 114550),
          "Table C.4's 73,314 without an offer" = all(c4$n0 == 73314),
          "Table C.4's first stage 50.42 pp (0.27)" = fmt(100 * fs4$fs, 2) == "50.42" && fmt(100 * fs4$fs_se, 2) == "0.27")
LOG <- c(LOG, note("check 3: the first-choice estimator reproduces Appendix Table C.4 (16 means, estimates and SEs; N 114,550; 73,314 without an offer; first stage 50.42 (0.27))"))
rm(FCP, c4); invisible(gc())

# ---- part 1: groups fixed before the lottery ----
FC <- ES[FIRST_CHOICE_SAMPLE == TRUE]
N_FC_OUT <- N_FCP_OUT                      # first-choice children with every control outside the lottery sample
stopifnot("the two panels give the same first-choice children with every control" = N_FCP - nrow(FC) == N_FCP_OUT,
          "the first-choice school is an over-demanded school the child entered" = all(FC$TOP_VA_TYPE != "current only"),
          "a first-choice offer is an over-demanded offer at the highest-ranked school the child entered" =
            FC[FIRST_CHOICE_OFFER == 1L, all(OFFER == 1L & OFFER_RBD == TOP_RBD)])
LOG <- c(LOG, note("first-choice children inside the lottery sample with every control: %s; outside it with every control: %s (each with a chance of exactly 1; no score outcomes in the shared panels)",
                   format(nrow(FC), big.mark = ","), format(N_FC_OUT, big.mark = ",")))
TYPES4 <- c("high", "low", "none", "current only")
GR <- rbindlist(list(
  data.table(analysis = "A", group = TYPES4, by = "TOP_VA_TYPE", fc = FALSE),
  data.table(analysis = "B", group = TYPES4, by = "TOP_PEER_TYPE", fc = FALSE),
  CJ(pk = c("high", "low"), ok = c("high", "low"), sorted = FALSE)[, .(analysis = "C", group = paste0("peer ", pk, ", own ", ok), by = "C", fc = FALSE)],
  CJ(vk = c("high", "low"), pk = c("high", "low"), sorted = FALSE)[, .(analysis = "D", group = paste0("VA ", vk, ", peer ", pk), by = "D", fc = FALSE)],
  data.table(analysis = "FC", group = "all", by = "all", fc = TRUE),
  data.table(analysis = "FC_A", group = c("high", "low", "none"), by = "TOP_VA_TYPE", fc = TRUE),
  data.table(analysis = "FC_B", group = c("high", "low", "none"), by = "TOP_PEER_TYPE", fc = TRUE)))
members <- function(analysis, group, by, fc) {
  d <- if (fc) FC else ES
  if (by == "all") return(d)
  if (by == "C") {
    k <- regmatches(group, regexpr("(?<=peer )\\w+", group, perl = TRUE)); o <- regmatches(group, regexpr("(?<=own )\\w+", group, perl = TRUE))
    return(d[TOP_PEER_TYPE == k & OWN_TYPE == o])
  }
  if (by == "D") {
    v <- regmatches(group, regexpr("(?<=VA )\\w+", group, perl = TRUE)); k <- regmatches(group, regexpr("(?<=peer )\\w+", group, perl = TRUE))
    return(d[TOP_VA_TYPE == v & TOP_PEER_TYPE == k])
  }
  d[get(by) == group]
}
stopifnot("members() self-test" = nrow(members("C", "peer high, own low", "C", FALSE)) == ES[TOP_PEER_TYPE == "high" & OWN_TYPE == "low", .N] &&
            nrow(members("D", "VA low, peer high", "D", FALSE)) == ES[TOP_VA_TYPE == "low" & TOP_PEER_TYPE == "high", .N])
P1 <- rbindlist(c(list(whole), lapply(seq_len(nrow(GR)), function(i) {
  r <- GR[i]
  run_group(r$analysis, r$group, members(r$analysis, r$group, r$by, r$fc), first_choice = r$fc)
})))
# each split's groups add up, outcome by outcome
n_whole <- setNames(whole$n, whole$outcome)
for (an in c("A", "B")) {
  s <- P1[analysis == an, .(n = sum(n)), by = outcome]
  stopifnot("splits A and B add up to the whole sample for every outcome" = all(s$n == n_whole[s$outcome]))
}
for (an in c("C", "D")) {
  pool <- if (an == "C") ES[TOP_PEER_TYPE %in% c("high", "low")] else ES[TOP_VA_TYPE %in% c("high", "low") & TOP_PEER_TYPE %in% c("high", "low")]
  s <- P1[analysis == an, .(n = sum(n)), by = outcome]
  stopifnot("splits C and D add up to their pools for every outcome" = all(s$n == vapply(s$outcome, function(v) sum(!is.na(pool[[v]])), 0)))
}
n_fc <- setNames(P1[analysis == "FC", n], P1[analysis == "FC", outcome])
for (an in c("FC_A", "FC_B")) {
  s <- P1[analysis == an, .(n = sum(n)), by = outcome]
  stopifnot("the first-choice splits add up to the first-choice sample for every outcome" = all(s$n == n_fc[s$outcome]))
}

# where the offers and the attendance land, for each part-1 group: the offer-school columns
# among the children with any over-demanded offer; attendance among the offered and the non-offered (for the first-choice
# groups, offered means a first-choice offer)
landing <- function(d, fc) {
  stopifnot("landing(): a group with children and the frame's offer and attendance columns" = nrow(d) > 0L &&
              all(c("OFFER", "OFFER_AT_TOP", "D_OD", "OFFER_VA_TYPE", "ENTRY_VA_TYPE", "OFFER_PEER_TYPE", "ENTRY_PEER_TYPE",
                    if (fc) "FIRST_CHOICE_OFFER") %in% names(d)))
  z <- if (fc) d$FIRST_CHOICE_OFFER else d$OFFER
  any_od <- d$OFFER == 1L
  rbindlist(lapply(c("VA", "PEER"), function(m) {
    ot <- d[[paste0("OFFER_", m, "_TYPE")]]; et <- d[[paste0("ENTRY_", m, "_TYPE")]]
    att <- function(sel) c(high = mean(et[sel] %in% "high"), low = mean(et[sel] %in% "low"), none = mean(et[sel] %in% "none"),
                           no_od = mean(d$D_OD[sel] == 0L))
    a1 <- att(z == 1L); a0 <- att(z == 0L)
    data.table(measure = m, offered = sum(z == 1L), any_od_offer = sum(any_od),
               offer_high = mean(ot[any_od] %in% "high"), offer_low = mean(ot[any_od] %in% "low"),
               offer_none = mean(ot[any_od] %in% "none"),
               offer_at_top = if (all(d$N_OWN == 0L)) NA_real_ else mean(d$OFFER_AT_TOP[any_od]),   # NA for "current only"
               offered_attend_high = a1[["high"]], offered_attend_low = a1[["low"]], offered_attend_none = a1[["none"]], offered_attend_no_od = a1[["no_od"]],
               not_offered_attend_high = a0[["high"]], not_offered_attend_low = a0[["low"]], not_offered_attend_none = a0[["none"]],
               not_offered_attend_no_od = a0[["no_od"]])
  }))
}
LAND <- rbindlist(lapply(seq_len(nrow(GR)), function(i) {
  r <- GR[i]
  cbind(data.table(analysis = r$analysis, group = r$group), landing(members(r$analysis, r$group, r$by, r$fc), r$fc))
}))

# differences between disjoint groups (sums of group estimates in plus minus those in minus): SE from the groups' SEs
dd <- function(an, label, plus, minus) {
  rbindlist(lapply(OUTC, function(o) {
    sel <- function(g) { r <- P1[analysis == an & group == g & outcome == o]; stopifnot(nrow(r) == 1L); r }
    est <- sum(vapply(plus, function(g) sel(g)$est, 0)) - sum(vapply(minus, function(g) sel(g)$est, 0))
    se <- sqrt(sum(vapply(c(plus, minus), function(g) sel(g)$se^2, 0)))
    data.table(analysis = an, contrast = label, outcome = o, est = est, se = se, p = pnorm2(est / se))
  }))
}
D1 <- rbindlist(list(
  dd("A", "high minus low", "high", "low"),
  dd("B", "high minus low", "high", "low"),
  dd("C", "peer high minus low, own high", "peer high, own high", "peer low, own high"),
  dd("C", "peer high minus low, own low", "peer high, own low", "peer low, own low"),
  dd("C", "difference of the two", c("peer high, own high", "peer low, own low"), c("peer low, own high", "peer high, own low")),
  dd("D", "VA high minus low, peer high", "VA high, peer high", "VA low, peer high"),
  dd("D", "VA high minus low, peer low", "VA high, peer low", "VA low, peer low"),
  dd("D", "peer high minus low, VA high", "VA high, peer high", "VA high, peer low"),
  dd("D", "peer high minus low, VA low", "VA low, peer high", "VA low, peer low"),
  dd("FC_A", "high minus low", "high", "low"),
  dd("FC_B", "high minus low", "high", "low")))

# ---- part 2: offers at high-type and low-type schools ----
part2 <- function(m, both_only = FALSE) {
  d <- copy(ES)
  ot <- d[[paste0("OFFER_", m, "_TYPE")]]; et <- d[[paste0("ENTRY_", m, "_TYPE")]]
  d[, `:=`(OFFER_H = as.integer(OFFER == 1L & ot %in% "high"), OFFER_L = as.integer(OFFER == 1L & ot %in% "low"),
           OFFER_U = as.integer(OFFER == 1L & ot %in% "none"),
           D_H = as.integer(D_OD == 1L & et %in% "high"), D_L = as.integer(D_OD == 1L & et %in% "low"),
           D_U = as.integer(D_OD == 1L & et %in% "none"),
           P_H = get(paste0(m, "_P_HIGH")), P_L = get(paste0(m, "_P_LOW")),
           NPOS_H = get(paste0(m, "_NPOS_HIGH")), NPOS_L = get(paste0(m, "_NPOS_LOW")), NPOS_U = get(paste0(m, "_NPOS_NONE")))]
  stopifnot("the offers by type add up to the offer" = d[, all(OFFER_H + OFFER_L + OFFER_U == OFFER)],
            "attendance by type adds up to attendance" = d[, all(D_H + D_L + D_U == D_OD)])
  n_all <- nrow(d)
  d <- d[NPOS_U == 0L]                      # no positive chance at an over-demanded school without the measure
  n_nomeasure <- nrow(d)
  stopifnot("no offer at a school without the measure in the sample" = all(d$OFFER_U == 0L))
  if (both_only) d <- d[NPOS_H > 0L & NPOS_L > 0L]   # and a positive chance at both types
  gates <- vapply(c("OFFER_H", "OFFER_L", "D_H", "D_L"), function(v) { stopifnot(uniqueN(d[[v]]) == 2L); mean(d[[v]]) }, 0)
  # each type's cell: -1 with no chance at a school of that type, otherwise the paper's hundredths cell of the chance
  d[, `:=`(CELL_H = fifelse(NPOS_H == 0L, -1, cell_at(P_H, 2L)), CELL_L = fifelse(NPOS_L == 0L, -1, cell_at(P_L, 2L)))]
  stopifnot("cell -1 exactly with no chance" = d[, all((CELL_H == -1) == (P_H == 0) & (CELL_L == -1) == (P_L == 0))])
  rhs <- rhs_of(d)
  ivm <- models_of(feols(as.formula(paste(lhs_of(OUTC), "~", rhs, "| CELL_H^CELL_L | D_H + D_L ~ OFFER_H + OFFER_L")), d, ssc = SSC_2SLS))
  rfm <- models_of(feols(as.formula(paste(lhs_of(OUTC), "~ OFFER_H + OFFER_L +", rhs, "| CELL_H^CELL_L")), d))
  two <- function(m, a, b, pfun) {
    k <- c(a, b); bb <- coef(m)[k]; V <- vcov(m)[k, k]
    stopifnot("both coefficients estimated and finite" = all(is.finite(c(bb, V))) && length(bb) == 2L)
    s <- sqrt(diag(V)); dif <- bb[[1]] - bb[[2]]; dse <- sqrt(V[1, 1] + V[2, 2] - 2 * V[1, 2])
    list(e = unname(bb), s = unname(s), p = pfun(m, k), dif = dif, dse = dse, dp = pnorm2(dif / dse))
  }
  est <- rbindlist(lapply(seq_along(OUTC), function(j) {
    stopifnot(isFALSE(ivm[[j]]$summary_flags$ssc$K.adj),
              "every child with the outcome is used" = nobs(ivm[[j]]) == sum(!is.na(d[[OUTC[j]]])) && nobs(rfm[[j]]) == nobs(ivm[[j]]))
    iv <- two(ivm[[j]], "fit_D_H", "fit_D_L", function(m, k) pnorm2(tstat(m)[k]))
    rf <- two(rfm[[j]], "OFFER_H", "OFFER_L", function(m, k) unname(pvalue(m)[k]))
    data.table(outcome = OUTC[j], n = nobs(ivm[[j]]), mean0 = mean(d[[OUTC[j]]][d$OFFER == 0L], na.rm = TRUE),
               est_high = iv$e[1], se_high = iv$s[1], p_high = iv$p[1], est_low = iv$e[2], se_low = iv$s[2], p_low = iv$p[2],
               est_diff = iv$dif, se_diff = iv$dse, p_diff = iv$dp,
               rf_high = rf$e[1], rf_se_high = rf$s[1], rf_p_high = rf$p[1], rf_low = rf$e[2], rf_se_low = rf$s[2], rf_p_low = rf$p[2],
               rf_diff = rf$dif, rf_se_diff = rf$dse, rf_p_diff = rf$dp)
  }))
  fsm <- models_of(feols(as.formula(paste("c(D_H, D_L) ~ OFFER_H + OFFER_L +", rhs, "| CELL_H^CELL_L")), d))
  fsx <- function(mm, k) c(coef(mm)[[k]], se(mm)[[k]])
  first <- data.table(
    attend_high_on_offer_high = fsx(fsm[[1]], "OFFER_H")[1], attend_high_on_offer_high_se = fsx(fsm[[1]], "OFFER_H")[2],
    attend_high_on_offer_low = fsx(fsm[[1]], "OFFER_L")[1], attend_high_on_offer_low_se = fsx(fsm[[1]], "OFFER_L")[2],
    attend_low_on_offer_high = fsx(fsm[[2]], "OFFER_H")[1], attend_low_on_offer_high_se = fsx(fsm[[2]], "OFFER_H")[2],
    attend_low_on_offer_low = fsx(fsm[[2]], "OFFER_L")[1], attend_low_on_offer_low_se = fsx(fsm[[2]], "OFFER_L")[2],
    wald_f_attend_high = wald(fsm[[1]], keep = "^OFFER_[HL]$", print = FALSE)$stat,
    wald_f_attend_low = wald(fsm[[2]], keep = "^OFFER_[HL]$", print = FALSE)$stat)
  cells <- d[, .(vH = any(OFFER_H == 1L) & any(OFFER_H == 0L), vL = any(OFFER_L == 1L) & any(OFFER_L == 0L), n = .N), by = .(CELL_H, CELL_L)]
  sup <- data.table(measure = m, sample = if (both_only) "a positive chance at both types" else "no chance at a school without the measure",
                    children = nrow(d), left_out = n_all - nrow(d), left_out_no_measure = n_all - n_nomeasure,
                    left_out_one_type_only = n_nomeasure - nrow(d),
                    offered_high = sum(d$OFFER_H), offered_low = sum(d$OFFER_L), not_offered = sum(d$OFFER == 0L),
                    attend_high = sum(d$D_H), attend_low = sum(d$D_L), attend_school_without_measure = sum(d$D_U),
                    share_offer_high = gates[["OFFER_H"]], share_offer_low = gates[["OFFER_L"]],
                    share_attend_high = gates[["D_H"]], share_attend_low = gates[["D_L"]],
                    chance_both_positive = sum(d$NPOS_H > 0L & d$NPOS_L > 0L), pair_cells = nrow(cells),
                    pair_cells_vary_high = cells[vH == TRUE, .N], pair_cells_vary_low = cells[vL == TRUE, .N],
                    children_in_cells_vary_high = cells[vH == TRUE, sum(n)], children_in_cells_vary_low = cells[vL == TRUE, sum(n)])
  list(est = cbind(data.table(measure = m, sample = sup$sample), est), support = cbind(sup, first))
}
P2 <- lapply(list(c("VA", FALSE), c("VA", TRUE), c("PEER", FALSE), c("PEER", TRUE)), function(a) part2(a[1], as.logical(a[2])))
P2_EST <- rbindlist(lapply(P2, `[[`, "est"))
P2_SUP <- rbindlist(lapply(P2, `[[`, "support"))

# ---- the school measures: correlation and cross-tabulation over schools and over children ----
SCH <- fread(FILES[["schools"]])
XT_SCHOOLS <- SCH[, .N, keyby = .(VA_TYPE, PEER_TYPE)]
XT_CHILDREN <- ES[, .N, keyby = .(TOP_VA_TYPE, TOP_PEER_TYPE)]
cor_schools <- SCH[, cor(VA, PEER, use = "complete.obs")]
JS <- ES[N_OWN > 0L][SCH, on = .(TOP_RBD = RBD), nomatch = 0L]
stopifnot("every child with an entered school matches one school" = nrow(JS) == ES[N_OWN > 0L, .N])
cor_children <- JS[, cor(VA, PEER, use = "complete.obs")]
LOG <- c(LOG, note("correlation of value added and peer achievement: %.3f over the schools with both, %.3f over the children (their highest-ranked school)",
                   cor_schools, cor_children))

# ---- save ----
fwrite(P1, file.path(OUT, "i2_part1_estimates.csv"))
fwrite(D1, file.path(OUT, "i2_part1_differences.csv"))
fwrite(LAND, file.path(OUT, "i2_part1_where_offers_land.csv"))
fwrite(P2_EST, file.path(OUT, "i2_part2_estimates.csv"))
fwrite(P2_SUP, file.path(OUT, "i2_part2_support_first_stage.csv"))
fwrite(XT_SCHOOLS, file.path(OUT, "i2_types_schools.csv"))
fwrite(XT_CHILDREN, file.path(OUT, "i2_types_children.csv"))

# ---- the report: plain headers, one block per outcome (On time, Ever), the regression N under each block ----
cellv <- function(e, s, p, o) c(paste0(fmt(e * SCALE[[o]], DIGITS[[o]]), star(p)), paste0("(", fmt(s * SCALE[[o]], DIGITS[[o]]), ")"))
row2 <- function(label, ot, ev, o1, o2, e = "est", s = "se", p = "p") {
  a <- cellv(ot[[e]], ot[[s]], ot[[p]], o1); b <- cellv(ev[[e]], ev[[s]], ev[[p]], o2)
  c(sprintf("%-32s %11s %11s", label, a[1], b[1]), sprintf("%-32s %11s %11s", "", a[2], b[2]))
}
block <- function(title, lines, nlines = character(0)) c("```", sprintf("%-32s %11s %11s", title, "On time", "Ever"), lines, nlines, "```", "")
TITLES <- c(whole = "The whole estimation sample (the paper's Tables IX and X)",
            A = "Split A: children by the value-added type of the highest-ranked over-demanded school they entered",
            B = "Split B: children by the peer-achievement type of that school",
            C = "Split C: the peer-achievement type of that school, crossed with the child's own 8th-grade GPA (above or at-or-below its median)",
            D = "Split D: the value-added type of that school, crossed with its peer-achievement type",
            FC = "First-choice lotteries: the first-choice children inside the lottery sample",
            FC_A = "First-choice lotteries, by the value-added type of the first-choice school",
            FC_B = "First-choice lotteries, by the peer-achievement type of the first-choice school")
HEAD_LOTTERY <- sprintf("2SLS of each outcome on attendance at an over-demanded school, instrumented by an offer at one; the five controls, application-year and chance-group fixed effects. The 2SLS rows: robust SEs without the N/(N-K) factor and normal p-values (the paper's lottery convention); * p<0.10, ** p<0.05, *** p<0.01. The first stage (pp): OLS with robust SEs with the N/(N-K) factor, as the notebooks' OLS. Estimation sample %s children; each group is estimated on its own; a 'minus' row's SE is the square root of the sum of the groups' squared SEs (disjoint groups), its p normal; the scores use the children who have each score (N under each block). 'Cells': the chance groups holding offered and non-offered children.",
                        format(nrow(ES), big.mark = ","))
HEAD_FC <- sprintf("2SLS with a first-choice offer (a main-stage placement at the classroom ranked first) as the instrument and one fixed effect per first-choice lottery, the five controls (no year effects). The 2SLS rows: robust SEs without the N/(N-K) factor, normal p-values. The first stage (pp): OLS with robust SEs with the N/(N-K) factor, K counting the first-choice lotteries. A 'minus' row's SE is the square root of the sum of the two groups' squared SEs. Sample: the first-choice children inside the lottery sample with every control (%s; the %s outside it with every control have a chance of exactly 1 and no score outcomes in the shared panels). 'Cells': the first-choice lotteries holding offered and non-offered children.",
                   format(nrow(FC), big.mark = ","), format(N_FC_OUT, big.mark = ","))
part1_section <- function(an) {
  sup <- unique(P1[analysis == an, .(group, children, offered, cells_with_both, fs, fs_se)])
  ld <- LAND[analysis == an & measure == if (an %in% c("B", "C", "FC_B")) "PEER" else "VA"]
  out <- c(paste("##", TITLES[[an]]), "", if (an %in% c("FC", "FC_A", "FC_B")) HEAD_FC else HEAD_LOTTERY, "",
           "```", sprintf("%-28s %9s %8s %6s %15s", "group", "children", "offered", "cells", "first stage pp"),
           sup[, sprintf("%-28s %9s %8s %6d %15s", group, format(children, big.mark = ","), format(offered, big.mark = ","),
                         cells_with_both, paste0(fmt(100 * fs, 2), " (", fmt(100 * fs_se, 2), ")"))], "```", "")
  if (an != "whole" && nrow(ld)) {
    fc <- an %in% c("FC", "FC_A", "FC_B")
    pc <- function(x, na = rep(FALSE, length(x))) ifelse(na, "n/a", sprintf("%.1f", 100 * x))   # a share in %, n/a where na
    stopifnot("pc self-test" = identical(pc(c(0.5, 0.25)), c("50.0", "25.0")) && identical(pc(c(0.5, 0.25), c(FALSE, TRUE)), c("50.0", "n/a")))
    out <- c(out, sprintf("Where the offers and the attendance land (%s types; shares in %%):", if (ld$measure[1] == "VA") "value-added" else "peer-achievement"), "",
             "```", sprintf("%-28s %6s %6s %6s | %6s %6s %6s | %6s %6s %6s", "group", "hi", "lo", "at top", "att.hi", "att.lo", "no OD", "att.hi", "att.lo", "no OD"),
             ld[, sprintf("%-28s %6s %6s %6s | %6s %6s %6s | %6s %6s %6s", group, pc(offer_high), pc(offer_low), pc(offer_at_top, is.na(offer_at_top)),
                          pc(offered_attend_high), pc(offered_attend_low), pc(offered_attend_no_od),
                          pc(not_offered_attend_high), pc(not_offered_attend_low), pc(not_offered_attend_no_od))],
             "```", paste("The three blocks: (1) among the children with any over-demanded offer, the share offered a high-type school (hi), a low-type school (lo), and the highest-ranked over-demanded school the child entered (at top",
                          if (an %in% c("A", "B")) "; n/a for 'current only', who entered none)" else ")",
                          "; the rest of the offers are at over-demanded schools without the measure;",
                          if (fc) "(2) among the children with a first-choice offer and (3) among those without one," else "(2) among the offered and (3) among the non-offered,",
                          "the share attending (in April of the entry year) a high-type over-demanded school (att.hi), a low-type one (att.lo), or no over-demanded school (no OD); the rest attend an over-demanded school without the measure."), "")
  }
  blocks <- lapply(names(BASE), function(b) {
    o1 <- paste0(b, "_OT"); o2 <- paste0(b, "_EVER")
    lines <- unlist(lapply(unique(P1[analysis == an, group]), function(g) row2(g, P1[analysis == an & group == g & outcome == o1],
                                                                                    P1[analysis == an & group == g & outcome == o2], o1, o2)))
    dl <- D1[analysis == an]
    lines <- c(lines, unlist(lapply(unique(dl$contrast), function(cn) row2(cn, dl[contrast == cn & outcome == o1], dl[contrast == cn & outcome == o2], o1, o2))))
    nl <- c(sprintf("%-32s %11s %11s", "N", "", ""),
            unlist(lapply(unique(P1[analysis == an, group]), function(g) sprintf("%-32s %11s %11s", g,
              format(P1[analysis == an & group == g & outcome == o1, n], big.mark = ","), format(P1[analysis == an & group == g & outcome == o2, n], big.mark = ",")))))
    block(BASE[[b]], lines, nl)
  })
  c(out, unlist(blocks))
}
part2_section <- function(m, smp) {
  tab <- P2_EST[measure == m & sample == smp]; su <- P2_SUP[measure == m & sample == smp]
  mt <- if (m == "VA") "value-added" else "peer-achievement"
  both <- smp == "a positive chance at both types"
  hdr <- sprintf("2SLS of each outcome on attendance at a high-%s and at a low-%s over-demanded school, instrumented by an offer at a school of each type; the five controls and year effects; one fixed effect per pair of cells of the chances at the two types (the paper's hundredths cells; a cell of its own for no chance). The 2SLS rows: robust SEs without the N/(N-K) factor and normal p-values. The offer-effect rows, the first stage and its Wald F: OLS with robust SEs with the N/(N-K) factor (K counting the pair-cell fixed effects), t p-values for each offer and normal p-values for their difference, as the notebooks' OLS. Sample: %s children with no positive chance at an over-demanded school without the measure%s. Left out of the estimation sample of 185,970: %s (%s with a positive chance at a school without the measure%s). Offered a high-type school %s, a low-type school %s; attending a school without the measure (through a later stage) %s. Children per pair cell: %.1f (%.1f in the exam sample on time, the thinnest).",
                 mt, mt, format(su$children, big.mark = ","), if (both) " and with a positive chance at both types" else "",
                 format(su$left_out, big.mark = ","), format(su$left_out_no_measure, big.mark = ","),
                 if (both) sprintf("; %s with a chance at one type only", format(su$left_out_one_type_only, big.mark = ",")) else "",
                 format(su$offered_high, big.mark = ","), format(su$offered_low, big.mark = ","), format(su$attend_school_without_measure, big.mark = ","),
                 su$children / su$pair_cells, tab[outcome == "SCORE_LM_OT", n] / su$pair_cells)
  fs_lines <- c("```", "First stage (pp)                  offer high   offer low",
                sprintf("%-32s %11s %11s", "attend high type", fmt(100 * su$attend_high_on_offer_high, 2), fmt(100 * su$attend_high_on_offer_low, 2)),
                sprintf("%-32s %11s %11s", "", paste0("(", fmt(100 * su$attend_high_on_offer_high_se, 2), ")"), paste0("(", fmt(100 * su$attend_high_on_offer_low_se, 2), ")")),
                sprintf("%-32s %11s %11s", "attend low type", fmt(100 * su$attend_low_on_offer_high, 2), fmt(100 * su$attend_low_on_offer_low, 2)),
                sprintf("%-32s %11s %11s", "", paste0("(", fmt(100 * su$attend_low_on_offer_high_se, 2), ")"), paste0("(", fmt(100 * su$attend_low_on_offer_low_se, 2), ")")),
                sprintf("Joint Wald F of the two offers in each first-stage equation (a Sanderson-Windmeijer F is not computed): attend high %.0f, attend low %.0f; pair cells %d, varying in the high offer %d (%s children), in the low offer %d (%s children); a positive chance at both types %s",
                        su$wald_f_attend_high, su$wald_f_attend_low, su$pair_cells, su$pair_cells_vary_high, format(su$children_in_cells_vary_high, big.mark = ","),
                        su$pair_cells_vary_low, format(su$children_in_cells_vary_low, big.mark = ","), format(su$chance_both_positive, big.mark = ",")),
                "```", "")
  out <- c(paste0("## Part 2, ", mt, " types: ", if (both) "no chance at a school without the measure and a positive chance at both types" else smp), "",
           hdr, "", fs_lines,
           paste("Reading: with effects that differ across children, the two 2SLS coefficients are effects of attending each type only if each offer moves children only between its own type and no over-demanded school; the cross terms of the first stage show, approximately, how far offers move children between the two types.",
                 "The offer effects compare children within pair cells; with both offers in one regression, each coefficient of these regressions (first stages and offer effects), and so each 2SLS coefficient, can also carry part of the other offer's effect where that effect varies across cells (Goldsmith-Pinkham, Hull and Kolesar 2024)."), "")
  blocks <- lapply(names(BASE), function(b) {
    o1 <- paste0(b, "_OT"); o2 <- paste0(b, "_EVER")
    t1 <- tab[outcome == o1]; t2 <- tab[outcome == o2]
    lines <- c(row2("2SLS: attend high type", t1, t2, o1, o2, "est_high", "se_high", "p_high"),
               row2("2SLS: attend low type", t1, t2, o1, o2, "est_low", "se_low", "p_low"),
               row2("2SLS: difference", t1, t2, o1, o2, "est_diff", "se_diff", "p_diff"),
               row2("Offer effect: high type", t1, t2, o1, o2, "rf_high", "rf_se_high", "rf_p_high"),
               row2("Offer effect: low type", t1, t2, o1, o2, "rf_low", "rf_se_low", "rf_p_low"),
               row2("Offer effect: difference", t1, t2, o1, o2, "rf_diff", "rf_se_diff", "rf_p_diff"))
    block(BASE[[b]], lines, sprintf("%-32s %11s %11s", "N", format(t1$n, big.mark = ","), format(t2$n, big.mark = ",")))
  })
  c(out, unlist(blocks))
}
ld_va <- SCH[!is.na(VA), sum(abs(VA - median(VA)) <= VA_SE)]
REPORT <- c("# Issue 23: estimates", "",
            "Written by R/i2_estimates.R from the frame of R/i1_build.R; how to run and extend: README.md. Exploratory: nothing here is in the paper.", "",
            "Checks passed before any group was estimated:", "",
            paste("-", sub("^check \\d: ", "", LOG[grepl("^check", LOG)])), "",
            sprintf("School measures (fixed per school before SAE reached it): value added = Table I's estimate (classes of 2013 and 2015), %d of the 1,020 schools, %d of them within one SE (sigma_e / sqrt(graduates)) of the median; peer achievement = mean prior-year GPA (SD) of the school's ninth-grade entrants in the classes it selected before SAE (2012 to g-1), %d schools. A school is high type above the median over the schools with the measure, each school once. Correlation of the two measures: %.3f over schools, %.3f over children. A child's group is set by the highest-ranked over-demanded school among the rows she entered; %d children entered none (their only over-demanded row is the one SAE added for their current school) and form the group 'current only'.",
                    SCH[!is.na(VA), .N], ld_va, SCH[!is.na(PEER), .N], cor_schools, cor_children, ES[N_OWN == 0L, .N]), "",
            sprintf("Differences reported, each with its stars: %d (part 1: %d; part 2: %d 2SLS and %d offer-effect differences); %d of them carry a star. Each ever outcome includes its on-time outcome.",
                    nrow(D1) + 2L * nrow(P2_EST), nrow(D1), nrow(P2_EST), nrow(P2_EST),
                    sum(D1$p < 0.1) + sum(P2_EST$p_diff < 0.1) + sum(P2_EST$rf_p_diff < 0.1)), "",
            unlist(lapply(c("whole", "A", "B", "C", "D", "FC", "FC_A", "FC_B"), part1_section)),
            unlist(lapply(c("VA", "PEER"), function(m) unlist(lapply(c("no chance at a school without the measure", "a positive chance at both types"),
                                                                    function(s) part2_section(m, s))))))
writeLines(REPORT, file.path(OUT, "i2_report.md"))
LOG <- c(LOG, note("wrote output/i2_*.csv and output/i2_report.md in %.0f s", as.numeric(difftime(Sys.time(), t0, units = "secs"))))
writeLines(LOG, file.path(OUT, "i2_log.txt"))
