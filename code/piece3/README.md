# Piece 3 — Why Winning Hurts: the Room, the Transcript, and the Exam

This folder is a self-contained, reproducible package for the third result of the
paper. Piece 2 showed that winning a contested 9th-grade seat reduces on-time
entry into the college system. Piece 3 measures what moved underneath, on the
identical frame with the identical estimator and inference: winning puts the
child in a room with measurably stronger classmates; the child's own grades,
class position, four-year grade average, and standing against their school's own
history all fall, the last two being the records the admission formula scores as
NEM and rank. The national exam moves the other way: among children who sat it —
winners and losers indistinguishable on everything the records hold from before
the draw — winners score higher.

## The result

```
                        Peer 8th GPA   9th GPA   9th pctile   4-yr GPA   12th pctile   Rank vs hist.
Won the lottery           0.1335***  -0.1188***  -0.0542***  -0.0836***   -0.0278***     -0.1888***
                          (0.0084)    (0.0188)    (0.0043)    (0.0137)     (0.0038)       (0.0164)
Loser-arm mean             -0.0153     -0.0917      0.5194     -0.1569       0.5135         0.2194
Observations                44,055      43,610      43,610      35,461       35,650         35,172
Strata                       1,214       1,214       1,214       1,204        1,204          1,200

                        Exam score   Official NEM   Official rank
Won the lottery           0.0227**     -0.0941***      -0.1194***
                          (0.0099)       (0.0146)        (0.0147)
Loser-arm mean             -0.3080        -0.0547         -0.0386
Observations                26,757         30,806          30,806
Strata                       1,179          1,192           1,192
```

Frame asserted equal to Piece 2's certified headline frame (45,123 first-choice
applications, 1,215 classroom-by-year-by-tier strata, cohorts 2016–2021).
Transcript columns from ministry school records (no college participation
involved); score columns conditional on showing up to the college system, with
every denominator reported per arm. Among the children who sat the exam, winners
and losers are alike on the grades they carried in from 8th grade (+0.0090
(0.0110), not starred), so the exam column compares comparable children.
Standard errors clustered school-by-year for scale; stars from
randomization inference (9,999 within-stratum reshuffles, seed 20260919).

## What's here

| File | Role |
|------|------|
| `00a_pack_rendimiento_grades.R` | **Packer.** The two raw public Rendimiento releases (2024, 2025; resolved by content) → `rendimiento_grades_2024_2025.rds`: grades, school id, promotion status for the years the canonical graded panel does not reach. |
| `00_build_mech_panel.Rmd` | **Build.** Stamped Piece 2 panel (MD5-asserted, columns re-asserted byte-identical) + canonical graded panel + grades supplement + census + stamped college outcome table → `lottery_panel_mech.rds`. Documents every construction; asserts both stamped inputs by MD5, re-derives the certified 8th-grade GPA z and asserts it equals the stamped column, and halts on any construction mismatch. |
| `1_effect_mech.Rmd` | **Analysis.** Reads only the panel → the two tables, the coverage block, and the three registered exam checks (floor, tilt, crossing). |
| `lottery_panel_mech.rds` | Panel of record: 395,950 rows, 49 columns (27 stamped + 22 new). MD5 `6296a6de9feb98a18b5fc850e7b3a275`. |
| `rendimiento_grades_2024_2025.rds` | Grades supplement, 7,109,910 rows. MD5 `5f222bbc8ad544f9863aab63cf1c949f`. |
| `tables/` | Generated `.tex` tables and, for each exhibit, a values CSV with the unrounded numbers (transcript, scores, coverage, column coverage, floor, tilt, crossing, and the per-process scale translation the crossing point is expressed in). |
| `checks/88_mech_panel_validation.R` | Full-population validation: 44 checks, every new column re-derived through an independent code path, the supplement compared row-for-row against the raw csvs, input MD5 anchors, coverage floors, duplicate-conflict guards, two-direction schema guard. Run it from this folder. |
| `run_log_2026-08-18.txt` | Console transcripts of the record runs, end to end: the panel build, the full-population validation with its 44 check lines, and the analysis with every printed number. |
| `DATA_FILE_LIST.md` | What each document reads and which sources stand behind each file. |
| `PIECE3_DESCRIPTION.md` | The plain-language description of the design and results (the coauthor-facing text). |

## Data provenance

Every file the build reads lives in the shared data folder
(`~/Dropbox/Effect SAE on SUA/data`), verified present there on 2026-08-18; the
two this-piece files also ship in this folder. The raw csv releases behind the
supplement are not shipped and are needed only to repack it or to run the
validation (see below).

- `lottery_panel.rds` — Piece 2's stamped panel of record (MD5
  `acb5b2fff844f8692f234442273ab4c8`), never modified; its 27 columns are
  re-asserted byte-identical inside the build and the validation.
- `college_outcomes_2018_2026.rds` — Piece 2's stamped outcome table (MD5
  `28dd1874092a0835bbcb11839ff2e57c`): exam scores, official NEM/rank scores.
- `panel_performance_2002_2023.rds` — the canonical graded panel (grades,
  schools, promotion through 2023).
- `rendimiento_grades_2024_2025.rds` — this piece's supplement (built by
  `00a_pack_rendimiento_grades.R` from the public releases
  `20250212_Rendimiento_2024_20250131_WEB.csv` and
  `20260210_Rendimiento_2025_20260202_WEB.csv`); the certified Piece 2 packs and
  the canonical panel are untouched.
- `matricula_2011_2023.rds` — the packed enrolment census (Piece 1's pack).

## How to run

Requires **R 4.5.1** with `data.table`, `fixest`, and `knitr`. Every chunk that
estimates anything re-seeds `set.seed(20260919)` at its own top, so the
randomization stars are exact reproductions; the closed-form estimate is asserted
equal to the `feols(y ~ won | key)` coefficient at every call. Rendering the PDF
documents additionally needs `rmarkdown`, pandoc, and a LaTeX distribution;
running the chunks (`knitr::purl` + source, as the record runs did) needs only
the packages listed above.

- **Reproduce the tables**: run `1_effect_mech.Rmd` (reads the panel from this
  folder, else the shared data folder; the panel MD5 is pinned).
- **Rebuild the panel**: run `00_build_mech_panel.Rmd`; the rebuilt panel lands
  next to the code and must match the MD5 above (the record rebuild reproduced
  it byte-identically).
- **Validate**: `checks/88_mech_panel_validation.R` from this folder — 44 checks
  over the full population, all must PASS. Check V2 re-reads the two raw public
  Rendimiento releases and compares them to the supplement row for row, so the
  script needs those csvs: set `RAW_DIR` at the top of the script to the folder
  holding your copies (it stops with that instruction if they are missing).
- **Repack the supplement**: `00a_pack_rendimiento_grades.R` (repoint its
  `SRC_DIRS` to your copies of the two public releases; it writes the rds into
  the working directory, so run it from this folder).

## Design in one paragraph

Within one classroom draw of one application year, applicants of the same
priority standing are ordered by a random number, and a stratum is one classroom
in one year within one income tier. Piece 3 takes Piece 2's certified frame of
those strata unchanged — first-choice contested regular applications, at least
five winners, the 10% violation screen, nearest losers capped, cohorts
2016–2021, asserted equal to 45,123 applications in 1,215 strata at run time —
and changes only the outcomes. The estimate is the within-stratum winner–loser
difference, precision-weighted across strata, with the closed form asserted
equal to the stratum-fixed-effects regression at every call; stars come from
reshuffling winners within strata 9,999 times with winner counts fixed. The
transcript outcomes come from ministry school records covering every enrolled
child, so they condition on nothing the treatment moved; where a record does not
exist the row drops and the stratum drops if it is left single-armed, and the
non-NA share of every column is reported by arm. The exam and official-score
outcomes exist only for children who reach the college system, a margin winning
itself moves, so they sit in a separate table, and a registered check compares
the arms on their predetermined records inside that column: the winners and
losers who sat the exam are alike on the grades they carried in from 8th grade.
Two further registered checks bound how far the absent children could move the
exam column; their values ship in `tables/` and their runs are on the ledger.

## Panel columns

`lottery_panel_mech.rds` = the 27 stamped Piece 2 columns, unchanged, plus:
`gpa9, gpa9_z, pct9, has_g9` (own 9th-grade GPA, national z, school-cohort
percentile, coverage flag), `gpa4, gpa4_z, has_4yr` (on-time 4-year GPA, national
entry-cohort z, flag), `pct12` (12th-grade percentile, on-time year),
`rank_hist_z, hist_n` (rank vs the school's three prior promoted classes, pooled
history size), `in_room9, peer_n, peer_cov, peer_gpa8_z` (census 9th-grade room:
presence, size, peer-coverage share, leave-one-out peer mean), `exam_lm, exam_z,
exam_z_floor, has_exam` (exam score raw, taker z, floor-imputed z, flag),
`nem, ranking, nem_z, ranking_z` (official scores raw and z). The analysis
builds every exhibit from these columns alone.
