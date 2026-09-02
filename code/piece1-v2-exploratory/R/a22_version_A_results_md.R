# a22: display only (no inference). Writes the Version A results, three
# weightings side by side, as a markdown file for the coauthors, reading every
# number from the frozen stage-1 record (output/_stage1_record/). Nothing is
# typed by hand. Halts if the era estimates in the bootstrap-SE files differ
# from the era estimates in the randomization-scored files.
suppressMessages(library(data.table))
stopifnot(identical(paste(R.version$major, R.version$minor, sep = "."), "4.5.1"))
home <- Sys.getenv("USERPROFILE")
proj <- file.path(home, "Dropbox", "Effect of Centralization")
rec  <- file.path(proj, "explorations", "2026-08-31_did_college_outcomes", "output", "_stage1_record")
dp   <- file.path(home, "Dropbox", "Effect SAE on SUA", "data")
outd <- file.path(proj, "Updated Paper Spine", "Piece 1 - v2")
dir.create(outd, showWarnings = FALSE, recursive = TRUE)
outf <- file.path(outd, "VERSION_A_RESULTS.md")

W <- data.table(rule = c("0", "1", "2"),
                file = c("versionA_unweighted_results.csv", "versionA_rule1_results.csv",
                         "versionA_locked_results.csv"),
                label = c("Unweighted", "Own-year class size", "Fixed mean class size"))
OUT <- data.table(outcome = c("gpa_z", "sh_prio", "grad_ontime", "applied", "assigned", "enrolled"),
                  label = c("Entrant prior GPA (z-score)", "Share prioritario", "Graduated on time",
                            "Applied", "Assigned a seat", "Enrolled"),
                  part = c("comp", "comp", "col", "col", "col", "col"))
star <- function(p) ifelse(is.na(p), "", ifelse(p < .01, "***", ifelse(p < .05, "**", ifelse(p < .1, "*", ""))))
f4   <- function(x) ifelse(is.na(x), "", sprintf("%+.4f", x))
fse  <- function(x) ifelse(is.na(x), "", sprintf("(%.4f)", x))
fp   <- function(x) ifelse(is.na(x), "", sprintf("%.4f", x))
fn   <- function(x) format(x, big.mark = ",")

# some record files already carry an integer 'rule' column; replace it with the
# character key used throughout this script
rd <- function(f, r) { d <- fread(f); if ("rule" %in% names(d)) d[, rule := NULL]; d[, rule := r]; d }
H  <- rbindlist(lapply(seq_len(nrow(W)), function(i) rd(file.path(rec, W$file[i]), W$rule[i])))
E  <- rbindlist(lapply(W$rule, function(r) rd(file.path(rec, sprintf("era_boot_se_A_rule%s.csv", r)), r)))
J  <- rbindlist(lapply(W$rule, function(r) rd(file.path(rec, sprintf("es_stud_joint_A_rule%s.csv", r)), r)))
Bd <- rbindlist(lapply(W$rule, function(r) rd(file.path(rec, sprintf("es_bands_A_rule%s.csv", r)), r)))
stopifnot(all(H$version == "A"), all(E$version == "A"), all(J$version == "A"), all(Bd$version == "A"))

# era estimates must agree between the two files (same fits, same weights)
chk <- merge(H[cell %in% c("era_old", "era_new"), .(rule, outcome, cell, att_ri = att)],
             E[, .(rule, outcome, cell, att_boot = att)], by = c("rule", "outcome", "cell"))
stopifnot("era estimates identical across the two record files" =
            nrow(chk) == 24L && chk[, max(abs(att_ri - att_boot))] < 1e-8)

# sample sizes from the panels of record
epf <- file.path(dp, "entrant_composition_panel.rds")
stopifnot(identical(unname(tools::md5sum(epf)), "8ccec73b5955b723485195d5085b669d"))
EP <- setDT(readRDS(epf))
clf <- file.path(rec, "class_college_allgrades_panel.rds")
stopifnot(identical(unname(tools::md5sum(clf)), "9b2a5f80a0dc3a1400cc12195665a382"))
CL <- setDT(readRDS(clf))[arm == "pub"]
N <- data.table(outcome = OUT$outcome,
                n_obs = c(EP[!is.na(gpa_z), .N], EP[!is.na(sh_prio), .N], rep(nrow(CL), 4)),
                n_cells = c(EP[!is.na(gpa_z), uniqueN(paste(rbd, cod_nivel))],
                            EP[!is.na(sh_prio), uniqueN(paste(rbd, cod_nivel))],
                            rep(CL[, uniqueN(paste(rbd, cod_nivel))], 4)),
                n_schools = c(EP[!is.na(gpa_z), uniqueN(rbd)], EP[!is.na(sh_prio), uniqueN(rbd)],
                              rep(CL[, uniqueN(rbd)], 4)))

L <- character(0)
add <- function(fmt, ...) L <<- c(L, if (...length() == 0L) fmt else sprintf(fmt, ...))  # plain lines may contain '%'
add("# Piece 1 - v2, Version A: three weightings side by side")
add("")
add("## What Version A estimates")
add("")
add("Chile's centralized school admission system (SAE, Sistema de Admision Escolar) reached the regions in waves: one region in 2016, four in 2017, ten in 2018, and the Metropolitan Region in 2019. Version A compares the entering classes of always-over-demanded public schools in regions already under SAE with the entering classes of always-over-demanded public schools in regions not yet under SAE, year by year. A school-grade cell is always over-demanded when, in every year observed, genuine applicants ranking it at least as high as their final placement outnumber its seats (the Piece 1 definition). Private schools are not in Version A.")
add("")
add("The unit is the entering class of a school-grade cell in a year: the students enrolled at that school-grade who were not at that school the year before. The causal statement is about the class the lottery formed versus the class the school would have formed itself.")
add("")
add("Two clocks. The composition outcomes (entrant prior GPA, share prioritario) sit on the entry-year clock, 2012 to 2023. The college outcomes sit on the college-process clock: an entering class at grade g in year t is followed to its on-time college admission process, t + 13 - g, so every comparison within a process year shares one admission-test regime; processes 2018 to 2026. Graduated on time means promoted out of 12th grade in the year before that process. Applied, assigned a seat, and enrolled are read from the centralized college admission records of that process; a student with no record counts as zero. Dropping out, never registering, and never applying all count as zeros: the denominator is the entering class.")
add("")
add("Estimator: Callaway and Sant'Anna (2021) staggered difference-in-differences, not-yet-treated controls, universal base period, no covariates, standard errors from a region-clustered multiplier bootstrap (16 regions, 10,000 draws). The headline is the simple average of the group-time effects over post-treatment cells.")
add("")
add("## The three weightings")
add("")
add("- **Unweighted.** Every class counts equally. The estimate answers for the average class.")
add("- **Own-year class size.** Each class-year is weighted by its number of entrants in that year. The estimate answers for the average entering student; the weights move with the class size from year to year.")
add("- **Fixed mean class size.** Each cell is weighted by its average number of entrants over the window, the same weight in every year. The estimate answers for the average entering student with weights that do not move when class sizes change.")
add("")
add("All three are shown because they answer different questions. When an effect varies across schools, a weighted and an unweighted estimator recover different averages of it, so the choice of weight is a choice of which population the number describes, and a gap between the columns is itself information about how the effect varies with class size (Solon, Haider and Wooldridge 2015). The column shown is never chosen by where its stars land.")
add("")
add("## How to read the tables")
add("")
add("**Where the stars come from.** Significance on this page comes from randomization inference, and the idea is easiest to see as a game of alternative histories.")
add("")
add("SAE arrived region by region on a published schedule: Magallanes in 2016, four regions in 2017, ten regions in 2018, and the Metropolitan Region in 2019. That schedule is the only thing separating a treated class from a control class in this design. So the test asks a direct question: if the reform had reached the regions in a different order, how large a number would this comparison have produced?")
add("")
add("To answer it we invent 9,999 alternative schedules. Each one reshuffles which of the sixteen regions received the reform in which year, holding the group sizes at one, four, ten and one, so every invented schedule is a schedule the country could plausibly have followed. There are 240,240 of them in total and we draw 9,999. The whole estimate is recomputed from scratch under each one. A result earns stars when almost none of the invented schedules produces a number as large as the real one.")
add("")
add("**Why each schedule is divided by its own steadiness.** One feature of the country shapes the scoring. The Metropolitan Region holds 37 of every 100 school-grade cells in this sample, and the next largest region holds 12. An invented schedule that hands the Metropolitan Region an early year makes the whole computation rest on that one region’s year-to-year luck, and one region’s luck produces large numbers easily. Those schedules would fill the comparison with large numbers and bury a real effect.")
add("")
add("Every schedule therefore has to vouch for its own steadiness, the real one included. Drop one region from the data, recompute the estimate, put the region back, and repeat for all sixteen. The spread across those sixteen answers measures how much the estimate leans on any single region. Each schedule’s number is divided by its own spread before any comparison is made. A schedule resting on one region collapses under this rule, because deleting that region guts its number. This is the studentized randomization statistic used throughout Young (2019) and recommended by MacKinnon and Webb (2020) for this exact situation, where the units being reshuffled differ greatly in size.")
add("")
add("**Reading the p-value.** The p-value is the share of invented schedules whose number, measured this way, is at least as large as the real one. Size is compared in absolute value, so an effect in either direction counts. The real schedule is counted alongside the invented ones, which is the plus one in (1 + matches) divided by (1 + 9,999). Stars: three for p below 0.01, two for p below 0.05, one for p below 0.10.")
add("")
add("**How the test is computed.** Each of the 9,999 schedules needs seventeen recomputations, the full estimate plus the sixteen region deletions. Running the estimation package itself that many times costs about sixty hours per table. The test uses a reimplementation of the same arithmetic instead, which runs in minutes. Before any invented schedule is scored, that reimplementation has to reproduce the package’s own answer on the real data to machine precision, or the run halts. Every column on this page passed that check.")
add("")
add("**The standard errors in parentheses.** These come from a separate calculation, a bootstrap that resamples the sixteen regions ten thousand times. They describe how precisely the estimate is measured. They play no part in the stars. Clustering is at the region because that is the level at which the reform was assigned (Abadie, Athey, Imbens and Wooldridge 2023).")
add("")
add("**Bold in the event-study tables.** A confidence interval is normally built for one row at a time. Reading a column of a dozen rows, one or two will fall outside their own interval through chance alone. The bands used here are widened so that the entire path stays inside them 95 percent of the time. Bold marks an estimate lying outside that widened band.")
add("")
add("**The joint pre-trend test.** The rows above the reference row cover the years before the reform reached the region, where a design that works shows nothing. Judging those rows one at a time runs into the problem just described: check seven rows and one will look unusual by chance. The joint test takes the single largest pre-reform row, measured in the studentized way described above, and asks how often an invented schedule produces a largest pre-reform row that big. One number then covers the whole pre-period. A small p-value says the pre-reform years do not look flat. Taking the largest member of a family this way is the maximum-statistic construction of Romano and Wolf (2005).")
add("")

# ---- Table 1: headline ----
add("## Table 1. Headline effects")
add("")
add("| Outcome | %s | %s | %s | Cell-years | Cells | Schools |", W$label[1], W$label[2], W$label[3])
add("|---|---|---|---|---|---|---|")
for (i in seq_len(nrow(OUT))) {
  o <- OUT$outcome[i]
  est <- sapply(W$rule, function(r) { h <- H[rule == r & outcome == o & cell == "simple"]; stopifnot(nrow(h) == 1L)
    paste0(f4(h$att), star(h$p_ri)) })
  se  <- sapply(W$rule, function(r) fse(H[rule == r & outcome == o & cell == "simple", se]))
  nn <- N[outcome == o]
  add("| %s | %s | %s | %s | %s | %s | %s |", OUT$label[i], est[1], est[2], est[3], fn(nn$n_obs), fn(nn$n_cells), fn(nn$n_schools))
  add("| | %s | %s | %s | | | |", se[1], se[2], se[3])
}
add("")
add("Composition outcomes: entry years 2012 to 2023. College outcomes: processes 2018 to 2026. Cell-years, cells, and schools are the same across the three weightings.")
add("")

# ---- Table 2: era split ----
add("## Table 2. College outcomes by admission-test era")
add("")
add("Each era cell is the fixed-weight average of the calendar-year effects in that era, with the weights the estimator itself puts on those years. Old exam: processes 2020 to 2022. PAES (Prueba de Acceso a la Educacion Superior): processes 2023 to 2026. Standard errors from the region-clustered multiplier bootstrap of the combined influence function; stars from the randomization test on the era average.")
add("")
add("| Era | Outcome | %s | %s | %s |", W$label[1], W$label[2], W$label[3])
add("|---|---|---|---|---|")
for (era in c("era_old", "era_new")) {
  elab <- if (era == "era_old") "Old exam, 2020-2022" else "PAES, 2023-2026"
  for (i in 3:6) {
    o <- OUT$outcome[i]
    est <- sapply(W$rule, function(r) { h <- H[rule == r & outcome == o & cell == era]; stopifnot(nrow(h) == 1L)
      paste0(f4(h$att), star(h$p_ri)) })
    se <- sapply(W$rule, function(r) { e <- E[rule == r & outcome == o & cell == era]; stopifnot(nrow(e) == 1L); fse(e$se_boot) })
    add("| %s | %s | %s | %s | %s |", elab, OUT$label[i], est[1], est[2], est[3])
    add("| | | %s | %s | %s |", se[1], se[2], se[3])
  }
}
add("")

# ---- Table 3: joint pre-trend tests ----
add("## Table 3. Joint pre-trend tests")
add("")
add("Exact randomization p of the largest studentized lead across all identified pre-treatment event times (the reference period, event time -1, excluded). Number of leads tested in brackets.")
add("")
add("| Outcome | %s | %s | %s |", W$label[1], W$label[2], W$label[3])
add("|---|---|---|---|")
for (i in seq_len(nrow(OUT))) {
  o <- OUT$outcome[i]
  v <- sapply(W$rule, function(r) { j <- J[rule == r & outcome == o]; stopifnot(nrow(j) == 1L)
    sprintf("%s [%d]", fp(j$p_joint_maxT), j$n_leads) })
  add("| %s | %s | %s | %s |", OUT$label[i], v[1], v[2], v[3])
}
add("")

# ---- Event studies ----
add("## Event studies")
add("")
add("Dynamic effects by event time, each row comparing treated cells with not-yet-treated cells at that event time against the reference period (event time -1, zero by construction). For the composition outcomes, event time counts years from the year the region's grade entered SAE. For the college outcomes, event time counts college processes from the first process in which the cell's entering class was SAE-assigned. **Bold**: outside the 95% simultaneous band.")
add("")
for (i in seq_len(nrow(OUT))) {
  o <- OUT$outcome[i]
  add("### %s", OUT$label[i])
  add("")
  add("| Event time | %s | %s | %s |", W$label[1], W$label[2], W$label[3])
  add("|---|---|---|---|")
  es <- sort(unique(Bd[outcome == o, e]))
  # an event time with no standard error in any weighting also has no
  # randomization score (every permutation draw non-finite); it is not an
  # estimate on the same footing as the rest and is not displayed
  drop_e <- vapply(es, function(ee) all(is.na(Bd[outcome == o & e == ee, se])), logical(1))
  es <- es[!drop_e | es == -1L]   # the reference row always stays
  for (ee in es) {
    if (ee == -1L) { add("| -1 | 0 (reference) | 0 (reference) | 0 (reference) |"); next }
    cellv <- sapply(W$rule, function(r) {
      b <- Bd[rule == r & outcome == o & e == ee]; if (nrow(b) == 0L) return("")
      stopifnot(nrow(b) == 1L)
      est <- f4(b$att)
      if (isTRUE(b$outside)) est <- paste0("**", est, "**")
      if (is.na(b$se)) est else paste(est, fse(b$se))
    })
    add("| %+d | %s | %s | %s |", ee, cellv[1], cellv[2], cellv[3])
  }
  jp <- sapply(W$rule, function(r) fp(J[rule == r & outcome == o, p_joint_maxT]))
  add("| Joint pre-trend p | %s | %s | %s |", jp[1], jp[2], jp[3])
  add("")
}

add("## Data")
add("")
add("Always-over-demanded cells and entrants: the Piece 1 entrant panel (Ministry of Education enrollment census, performance records, and the SAE application files). College outcomes: the centralized college admission records for processes 2018 to 2026 (application, assignment, enrollment) and the school performance records through 2025 for on-time graduation. Sixteen regions form the clusters for the bootstrap and the randomization test.")
add("")
add("## References")
add("")
add("Abadie, A., Athey, S., Imbens, G. W., and Wooldridge, J. M. (2023). When should you adjust standard errors for clustering? *Quarterly Journal of Economics*, 138(1), 1-35.")
add("")
add("Callaway, B., and Sant'Anna, P. H. C. (2021). Difference-in-differences with multiple time periods. *Journal of Econometrics*, 225(2), 200-230.")
add("")
add("MacKinnon, J. G., and Webb, M. D. (2020). Randomization inference for difference-in-differences with few treated clusters. *Journal of Econometrics*, 218(2), 435-450.")
add("")
add("Romano, J. P., and Wolf, M. (2005). Stepwise multiple testing as formalized data snooping. *Econometrica*, 73(4), 1237-1282.")
add("")
add("Solon, G., Haider, S. J., and Wooldridge, J. M. (2015). What are we weighting for? *Journal of Human Resources*, 50(2), 301-316.")
add("")
add("Young, A. (2019). Channeling Fisher: Randomization tests and the statistical insignificance of seemingly significant experimental results. *Quarterly Journal of Economics*, 134(2), 557-598.")
add("")
writeLines(L, outf, useBytes = TRUE)
cat(sprintf("wrote %s (%d lines)\n", outf, length(L)))
print(N)
