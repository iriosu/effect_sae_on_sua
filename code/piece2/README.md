# Piece 2 — Effect of Winning an SAE Lottery on College Outcomes

This folder is a self-contained, reproducible package for the second result of the
paper. At over-demanded schools, SAE fills contested seats by lottery: every applicant
in the same classroom draw with the same priority standing gets a random number, and
the seats go to the best numbers. Piece 2 compares the children who won a 9th-grade
seat this way to the nearest losers of the same draw, inside the same income tier. The
question of record: **does winning a contested seat reduce on-time entry into the
college system?** — finishing 12th grade on schedule, and appearing, being assigned a
seat, and enrolling in the college admission process in the cohort's own on-time year.
The on-time year is the one point every cohort reaches inside the data (the college
records end at process 2026, the youngest cohort's on-time year), so every stratum is
asked the identical question.

## The result

**Headline** (`tables/lottery_headline.tex`): four on-time outcomes. Grad. on time =
promoted out of 12th grade in the on-time year (application + 4, from the school
records); the three college outcomes are measured at application year + 5, when the
cohort reaches the college admission process; no record = 0 throughout.

```
                   Grad. on time    Applied         Assigned        Enrolled
Won the lottery      -0.0212***     -0.0109**       -0.0184***      -0.0152***
                     (0.0052)       (0.0047)        (0.0043)        (0.0040)
Loser-arm mean        0.8033         0.3703          0.2830          0.2409
Observations          45,123         45,123          45,123          45,123
Strata                 1,215          1,215           1,215           1,215
```

Standard errors are clustered school-by-year and reported for scale; significance
stars come from randomization inference — reshuffle who wins within each stratum
9,999 times, holding each stratum's winner count fixed.

**The draw was clean.** Losers with a better lottery number than the worst winner
(protocol violations) are 45 of 38,306 losers (0.12%) across the surviving strata,
and strata are screened at a 10% violation share. Winners and losers match on the
low-income flag (+0.0022, RI p 0.655), gender (+0.0040, p 0.377; within stratum
+0.0045, p 0.312), and 8th-grade GPA (+0.0040, p 0.651, measured for 98.8% of winners
and 98.9% of losers).

**The treatment happened.** In the entry year, 89.5% of winners are enrolled at the
lottery school against 18.8% of losers (+0.6979***, SE 0.0077), and both arms are
enrolled somewhere (98.9% of winners, 98.3% of losers, +0.0061***). The draw put
winners and losers in different schools; the outcome gap five years later traces to
that random assignment.

**Robustness** (`tables/lottery_robustness.tex`): five rows, one change each —
pooling the income tiers into raw lotteries, each tier alone, dropping strata with a
special-admission winner, dropping losers who ended up at the school anyway — across
all four headline outcomes. All twenty estimates are negative; nineteen carry stars
(grad on time is starred at 1% in every row), the no-priority tier's Applied column
(−0.0077, SE 0.0068) does not.

**The 7th-grade door** (`tables/lottery7_headline.tex`, `lottery7_robustness.tex`):
the identical design at the other SAE entry gate — grad on time at application + 6,
college outcomes at application year + 7, cohorts 2016–2019, predetermined GPA from
6th grade. The usable frame is 3,755 first-choice applications from 3,750 distinct
children in 89 strata (most 7th-grade lotteries hand out fewer than 5 seats; no 2016
stratum clears the five-winner screen, so the realized sample is 2017–2019).
Estimates: Grad on time −0.0153 (0.0139), Applied −0.0009 (0.0224), Assigned +0.0011
(0.0205), Enrolled −0.0044 (0.0184), no stars; the 95% intervals contain both zero
and the 9th-door estimates, and rule out effects beyond roughly ±4 percentage points
on the college outcomes. The lottery machinery checks out at this door too:
entry-year enrolment at the lottery school +0.8404*** (0.0189), balance flat,
violations 12 of 3,590 losers (0.33%).

## What's here

| File | Role |
|------|------|
| `00_build_lottery_panel.Rmd` | **Build, 9th door.** Packed SAE files + DEMRE/PAES records + canonical panels → `college_outcomes_2018_2026.rds` (the college outcome table, shared by both doors) and `lottery_panel.rds`. Documents every input, filter, and construction step; fails loud on any input mismatch. |
| `1_effect_lottery.Rmd` | **Analysis, 9th door.** Reads only the panel → headline table, treatment-happened lines, balance lines, robustness table. |
| `00b_build_lottery_panel_7th.Rmd` | **Build, 7th door.** Same construction, four parameter changes at the top (door 7, cohorts 2016–2019, horizon +7, 6th-grade GPA). Requires the college outcome table from `00` — run `00` first. |
| `1b_effect_lottery_7th.Rmd` | **Analysis, 7th door.** Same structure as `1`. |
| `lottery_panel.rds` | 9th-door panel of record: 395,950 rows, 3,987 lotteries. MD5 `acb5b2fff844f8692f234442273ab4c8`. |
| `lottery_panel_7th.rds` | 7th-door panel of record: 44,643 rows, 1,273 lotteries. MD5 `966e7ae8e033e95a13f8d19c85c447c4`. |
| `college_outcomes_2018_2026.rds` | One row per student per college admission process 2018–2026 with applied/assigned/enrolled flags. Built by `00`. MD5 `28dd1874092a0835bbcb11839ff2e57c`. |
| `run_log_2026-08-17.txt` | Console logs of the record runs, end to end: both panel builds, both full-population validations, both analysis documents. |
| `tables/` | Generated `.tex` tables and, for each exhibit, a values CSV with the unrounded numbers. |
| `checks/` | The two validation scripts (every panel column against its source file, full population). Run them from this folder. |
| `DATA_FILE_LIST.md` | What each build reads and which raw public releases stand behind each packed file. |
| `PIECE2_DESCRIPTION.md` | The plain-language description of the design and results (the text for the coauthor-facing issue). |

Both panels also sit in the shared data folder with the same MD5s, so the analysis
files run without rebuilding anything. Each panel was built twice from scratch with
byte-identical output, and every column was validated against its source file over the
full population (36 checks for the 9th door, 32 for the 7th, all zero). The validation
scripts ship in `checks/` (`86_panel_validation.R`, `87_panel7_validation.R`); run
them with this folder as the working directory — they find the panels here and the
raw inputs through the shared data folder.

## Data provenance

Everything the build reads lives in the shared data folder
(`~/Dropbox/Effect SAE on SUA/data`):

- `sae_admissions.rds` — packed SAE tables (built by Piece 1's `00a_pack_raw_data.R`
  from the public MINEDUC releases): applications (C1) and assignments (D1) for
  processes 2016–2025 with the lottery number, priority flags, and special-admission
  ordering columns, and the applicant register (B1) with the low-income and gender
  flags. Piece 2 reads C1/D1/B1.
- `paes_2026.rds` — packed PAES 2026 registration/score/application/assignment
  files (also from `00a_pack_raw_data.R`); extends the college outcome table to
  process 2026.
- `data_students_2004_2025.rds` — the DEMRE student file the coauthors hold;
  supplies college processes 2018–2025.
- `entrant_composition_panel.rds` — Piece 1's analysis panel. Piece 2 takes its
  school list from it (the always-over-demanded cells at each door), so both pieces
  use one over-demand definition.
- `panel_performance_2002_2023.rds` — the canonical graded panel; supplies the
  predetermined GPA (8th grade for the 9th door, 6th for the 7th; z-scored nationally
  within year) and the 12th-grade promotion records through 2023 for grad on time.
- `rendimiento_2024_2025.rds` — packed school records for academic years 2024–2025
  (from the two public releases, by Piece 1's `00a_pack_raw_data.R`); extend the
  12th-grade promotion records to the last cohorts' on-time years. The canonical
  graded panel is untouched.
- `matricula_2011_2023.rds` and `matricula_2024_2025.rds` — the packed annual
  enrolment census plus its 2024–2025 supplement; supply the entry-year and
  persistence enrolment flags.

The raw public releases behind the packed files are inventoried in Piece 1's
`DATA_FILE_LIST.md` and this folder's `DATA_FILE_LIST.md`.

## How to run

Requires **R 4.5.1** with `data.table`, `fixest`, and `knitr`. Every chunk that
estimates anything re-seeds `set.seed(20260919)` at its own top, so no exhibit's
random draws depend on which chunks ran before it (chunks share frame objects, so run
each document top to bottom), and the randomization stars are exact reproductions.
The closed-form estimate is asserted equal to the `feols(y ~ won | key)` coefficient
at every call, so a `fixest` version drift affecting the point estimate halts the run;
the parenthesized clustered SEs come from `fixest` unguarded and are printed for
scale — the stars never depend on them. Rendering the PDF documents additionally
needs `rmarkdown`, pandoc, and a LaTeX distribution; running the chunks
(`knitr::purl` + source, as the record runs did) needs only the packages listed
above.

The intended workflow: clone the repo (this folder lives under `code/`), have the
shared Dropbox data folder synced at `~/Dropbox/Effect SAE on SUA/data`, and run.
Do not commit data or generated outputs to git.

- **Reproduce the tables**: knit `1_effect_lottery.Rmd` and `1b_effect_lottery_7th.Rmd`.
  Each reads its panel from the folder if present, otherwise from the shared data
  folder.
- **Rebuild the panels**: knit `00_build_lottery_panel.Rmd`, then
  `00b_build_lottery_panel_7th.Rmd`. Rebuilt panels land next to the code and should
  match the MD5s above.
- **Repack from the original public releases**: Piece 1's `00a_pack_raw_data.R`.

## Design in one paragraph

Within one classroom draw of one application year, applicants in the same priority
standing are ordered by a random number. The frame keeps regular, contested
applications: children whose application was genuine (no continuity auto-add, no
sibling/staff/returning-student/special-education priority) and who ranked the
classroom at least as high as the placement they finally got. A stratum is one
classroom in one application year within one income tier (prioritario vs not) —
low-income children face their own quota's cutoff, so tiers are compared only within
themselves (the marginal-priority-group construction of Abdulkadiroğlu, Angrist,
Narita and Pathak 2017). The primary frame keeps first-choice applications in strata
with at least five winners, screens strata where more than 10% of losers hold a
number better than the worst winner, and keeps the nearest losers up to the winner
count. Winning is defined by the official assignment file. Outcomes are four on-time facts:
promoted out of 12th grade in the on-time year (application + 4 at the 9th door, + 6
at the 7th, from the school records), and appearing in the college admission process
(applied), receiving a program assignment (assigned), and enrolling (enrolled) at
application year + 5 (9th door) or + 7 (7th door); a child with no record counts 0
throughout. The estimate is the within-stratum winner–loser difference,
precision-weighted across strata; stars come from reshuffling winners within strata
9,999 times.

## Panel columns

`lottery_panel.rds` / `lottery_panel_7th.rds`: `proc, MRUN, key, RBD, won, PREF,
loteria, vintage, rbd_a, test_track, pie_track, tracked, applied, assigned, enrolled,
grad_ontime, sch_year, prioritario, female`, plus the predetermined GPA (`gpa8_z` at
the 9th door, `gpa_pre_z` at the 7th) and the enrolment-census flags (9th:
`at_y1..at_y4, yrs_at_school, at_assigned, in_any`; 7th: `at_y1, in_any`). The
analysis files build every frame — headline, balance, robustness — from these
columns alone.
