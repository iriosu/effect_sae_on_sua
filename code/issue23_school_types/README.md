# Issue 23: lottery effects by the type of over-demanded school

Exploratory analysis for issue 23 ("School characteristics and heterogeneous lottery effects"). Nothing here is in the
paper. It runs the paper's lottery comparison (the mechanisms notebook's `tsls()`, code/finalized_design_v1/mechanisms/)
inside groups of children defined by the value added and the peer achievement of over-demanded schools, and compares
offers at different types of schools for children with the same chances.

## Files

| File | What it is |
|---|---|
| `R/i1_build.R` | Builds the child frame `output/i1_frame.rds` (one row per lottery child: 186,440 rows, 55 columns) and `output/i1_schools.csv` (the 1,020 over-demanded schools with their two measures and types). About 20 s. |
| `R/i2_estimates.R` | Reads the frame and writes every estimate: `output/i2_report.md` and the CSVs below. About 20 s. |
| `output/i2_report.md` | All results: one block per outcome, on time and ever, with SEs, stars, Ns, first stages and where the offers land. Start here. |
| `output/i2_part1_estimates.csv` | Part 1 at full precision: one row per analysis, group and outcome (2SLS estimate, SE, p, N, children without an offer, their mean, the first stage). |
| `output/i2_part1_differences.csv` | Part 1 differences between groups (for example "high minus low"), with SE and p. |
| `output/i2_part1_where_offers_land.csv` | For each part-1 group: the shares of offers at high, low and no-measure schools and at the highest-ranked school; attendance by type for offered and non-offered children. |
| `output/i2_part2_estimates.csv` | Part 2: the 2SLS effects of attending each type, the offer effects at each type and their differences. |
| `output/i2_part2_support_first_stage.csv` | Part 2: sample, support (pair cells and the children in them), the 2x2 first stage and each first stage's Wald F. |
| `output/i2_types_schools.csv`, `output/i2_types_children.csv` | Schools and children by value-added type x peer type. |
| `output/i1_build_log.txt`, `output/i2_log.txt` | What each script checked and counted. |

`output/i1_frame.rds` (child level) and `output/i1_schools.csv` (value added by school ID) stay out of the repository;
`R/i1_build.R` writes them. The repository's `.gitignore` covers `.rds` and `.csv`; anything saved in another format
(for example a `.txt` or `.parquet` with child rows) has to be kept out by hand.

## How to run

R 4.5.1 with data.table 1.18.4 and fixest 0.14.2 (`R/i2_estimates.R` stops with fixest below 0.13.0, whose robust SEs carry
an extra n/(n-1)). From this folder (each script stops if run from elsewhere):

    Rscript R/i1_build.R
    Rscript R/i2_estimates.R

Both scripts read the shared Dropbox folder *Effect SAE on SUA*: by default `<home>/Dropbox/Effect SAE on SUA/data`, with
`<home>` the USERPROFILE on Windows and `~` elsewhere. When Dropbox sits elsewhere (on recent macOS,
`~/Library/CloudStorage/Dropbox`), set the environment variable `EFFECT_SAE_DATA` to the data folder's full path, for example
`EFFECT_SAE_DATA="$HOME/Library/CloudStorage/Dropbox/Effect SAE on SUA/data" Rscript R/i1_build.R` (and the same for
`R/i2_estimates.R`); in PowerShell, `$env:EFFECT_SAE_DATA = "<full path>"` first. `R/i1_build.R` stops and names any input it cannot find. The scripts write only into `output/`.
The inputs total about 220 MB (sizes below); Dropbox files kept online-only download on first read. Peak memory was not
measured; the largest input is `sae_admissions.rds`.

To check a run: `R/i2_estimates.R` stops unless it reproduces the paper (below). To compare with the committed results,
copy `output/` to `output_record/` before rerunning, then compare each CSV with
`all.equal(fread("output/<file>"), fread("output_record/<file>"))` (the file bytes depend on the operating system's
line endings).

## Data

From the shared data folder; `R/i1_build.R` checks each file against its MD5 (lines 34-54):

| File | MB | What the scripts use |
|---|---|---|
| `finalized_design_v1/mechanisms/mechanisms_panel.rds` | 20.5 | The paper's lottery sample (186,440 ninth-grade applicants of 2016-2021): the ten outcomes, the five controls, the chance group, the offer, attendance (D_OD) and the entry school. |
| `finalized_design_v1/outcomes/outcomes_panel.rds` | 5.7 | N_OD, FC_OD, the first-choice columns and the thousandths chance group. The chance group, offer and attendance are checked against the mechanisms panel child by child; N_OD and FC_OD against SAE's application rows; the thousandths group against the chance recomputed from the reruns. |
| `finalized_design_v1/outcomes/outcomes_group.rds` | 0.0 | The 1,020 over-demanded schools (RBD). |
| `finalized_design_v1/composition/composition_schools.rds` | 0.2 | Value added: VA_HEAD, VA_N_HEAD, SIGMA_E_M_HEAD (Table I's "School Value Add (SD)"). |
| `finalized_design_v1/composition/composition_panel.rds` | 8.9 | The ninth-grade entrants' prior-year GPA (PRIOR_GPA_Z) by school and year, and each school's DOOR. |
| `sae_admissions.rds` | 111.2 | Element `c1`: the SAE application rows (the ranked lists). |
| `issue23_school_types/m15_ninth_grade_chance.rds` | 3.7 | One row per ninth-grade applicant of 2016-2021 in the reruns (443,270): STUDENT_ID (the reruns' id), MRUN, TYPE_ID (the applicant type: the list in order with every input the assignment reads, and in 2017-2021 the low-income status), LINKED (a family link: the child keeps her own share of the reruns; otherwise her chance is her type's mean, as in the paper). |
| `issue23_school_types/m14_rerun_rows.rds` | 25.6 | One row per applicant and listed classroom in the one million reruns of SAE's main stage, 2016-2021 (1,809,445; 2016 all grades, 2017-2021 grades 9-12): YEAR, STUDENT_ID, MRUN, NIVEL, RBD, PREFERENCE_INITIAL, DRAWS_PLACED (of DRAWS = 1,000,000, the reruns that place the child there). |
| `issue23_school_types/m08_sae_placements.rds` | 44.5 | SAE's placements, all grades, processes 2016-2025 (3,798,604 rows): RBD_MAIN_STAGE is the school of the main-stage placement, the paper's offer. |

The three files in `issue23_school_types/` are the reruns and placements behind the paper's chance and offer; nothing
else in the shared folder carries the chance at each school.

## What the scripts check (each stops the run)

`R/i1_build.R`: every input exists and matches its MD5; the mechanisms and outcomes panels agree child by child on the
chance group, the offer and attendance; the chance recomputed from the reruns gives the paper's chance group (hundredths
and thousandths) for all 186,440 children; the chances by school type add up to the chance to within 1e-12 (largest gap
in the run of record 2.2e-16); the main-stage school reproduces the paper's offer for every child (73,446 offers); the
over-demanded schools a child entered are the panel's N_OD; her highest-ranked one is her first choice exactly when
FC_OD is 1.

`R/i2_estimates.R`, before any group is estimated: (1) the whole sample reproduces the paper's Table IX Panel A and
Table X's two grade-rule rows (estimates, SEs, Ns), the 112,679 children without an offer and the first stage (61.04 pp);
(2) one group's 2SLS SE equals the HC0 sandwich computed by hand; (3) the first-choice estimator reproduces Appendix
Table C.4 on its own sample (N 114,550; 73,314 without an offer; first stage 50.42 (0.27)). Then every split adds up to
its pool, outcome by outcome.

## The design

Estimator, as the paper: 2SLS of each outcome on attendance at an over-demanded school (April of the entry year, any of
the 1,020), instrumented by an offer (SAE's main-stage placement at one of them); controls GPA8_Z, ES_MUJER, PRIORITARIO,
ALTO, ORIGIN_OD; application-year and chance-group fixed effects; robust SEs without the N/(N-K) factor; normal
p-values; stars at 10, 5 and 1%. Outcomes: the exam (math-verbal), NEM and Ranking scores (SD, among the children who
have each) and meeting PACE's and BEA's grade rules (pp), each on time and ever.

School measures, fixed per school before SAE reached it:
- Value added: VA_HEAD (graduating classes of 2013 and 2015); 929 of the 1,020 schools; 173 of them lie within one SE
  (sigma_e / sqrt(graduates)) of the median.
- Peer achievement: the mean prior-year GPA (SD) of the school's ninth-grade entrants in the classes it selected before
  SAE (academic years 2012 to g-1, g = DOOR + 1); 1,001 schools.
- Type: "high" above the median over the schools with the measure (each school once), "low" otherwise, "none" without
  the measure. The two measures correlate 0.536 over schools and 0.542 over children.

Part 1 (issue item 1): the paper's 2SLS inside groups fixed before the lottery, by the type of the highest-ranked
over-demanded school among the rows the child entered herself (SAE also adds a row for the school she attends; 821
children with every control entered none and form the group "current only"). Split A: value-added type; B: peer type;
C: peer type x the child's own 8th-grade GPA (above or at-or-below its median); D: value-added type x peer type; and the
first-choice 2SLS (instrument FIRST_CHOICE_OFFER, FIRST_CHOICE_LOTTERY fixed effects) split by A and B, on the 107,184
first-choice children inside the lottery sample (the shared panels hold the score outcomes for them only; the 7,366
outside it each have a chance of exactly 1). Part 1 reports the effect of attending (2SLS) and each group's first stage;
part 2 reports offer effects. An offer can land at another over-demanded school than the highest-ranked one (29,411 of
the 73,446 offers are at another school, the offers to "current only" children among them; 44,035 at the highest-ranked
one); `i2_part1_where_offers_land.csv` gives
where, group by group.

Part 2 (issue item 2): each child's chance at each over-demanded school, from the reruns and computed as the paper's
chance, summed by school type. Two attendance variables (a high-type school, a low-type school), each instrumented by an
offer at that type, with one fixed effect per pair of chance cells at the two types: the child's chance at high-type
schools and her chance at low-type schools, each rounded to the paper's hundredths cells, with a cell of its own for no
chance. Two samples: children with no positive chance at a school without the measure; and of those, the children with
a positive chance at both types. Reported: the 2SLS effects and offer effects at each type and their difference, the 2x2
first stage, each first stage's Wald F (a Sanderson-Windmeijer F is not computed).

Reading the results:
- The two measures go together across schools, so a split shows where an effect is larger; it cannot separate value
  added from peer achievement.
- In part 2, each coefficient can also carry part of the other offer's effect where that effect varies across pair cells
  (Goldsmith-Pinkham, Hull and Kolesár 2024); the two 2SLS coefficients are effects of attending each type only if each
  offer moves children only between its own type and no over-demanded school (Kirkeboen, Leuven and Mogstad 2016). The
  cross terms of the first stage show how far offers move children between the two types.
- The report carries 190 differences, 156 of them starred; no adjustment for the number of tests.

## How to extend

Another school characteristic X (a column for each of the 1,020 schools). The scripts name the two measures "VA" and
"PEER" in several places; each needs X too, or X's groups print wrong without stopping:
- `R/i1_build.R`: add X to `SCH` (line 86) and `X_TYPE` with `type_of()` next to `VA_TYPE` (line 90); add `"X_TYPE"` to `school_type()`'s
  allowed list (line 99); add `TOP_X_TYPE` next to `TOP_VA_TYPE` (line 125); add `X_TYPE` to `CS9` (line 174); run the
  loop of `chance_by_type()` over X too (line 195); add `OFFER_X_TYPE` and `ENTRY_X_TYPE` next to `OFFER_VA_TYPE` and
  `ENTRY_VA_TYPE` (line 218).
- `R/i2_estimates.R`: add X's groups to `GR` (line 186) and its high-minus-low rows to `D1` (line 267); add X to
  `landing()`'s column check (line 235) and its measure list (line 239); add X to the part-2 calls (line 343); add X's
  titles to `TITLES` (line 374); pick X's landing table in `part1_section()` (line 388, which picks "PEER" for splits B,
  C and FC_B and "VA" for the rest) and its label (line 397); its label in `part2_section()` (line 423); and add X's
  sections to the report (lines 467-468).
- A first-choice split of X (like FC_A and FC_B): also add its name to the lists on lines 389 (the report header) and 394
  (the landing text) of `R/i2_estimates.R`, and to the add-up check on line 225.

Each child's chance at each over-demanded school: `CS9` in `R/i1_build.R` (one row per child and school with a positive
chance; `num` is the draws behind the chance, so the chance is `num / DRAWS` for a linked child and
`num / type_n / DRAWS` otherwise). Save it to work at the school level; it carries MRUN, so it is child-level data and
stays out of the repository like `i1_frame.rds`.

Another outcome from the mechanisms panel: it must exist as a pair `<stem>_OT` and `<stem>_EVER`. Add the stem to `OUTC`
in `R/i1_build.R` (line 61) and to `BASE` in `R/i2_estimates.R` (line 46), with its scale in `SCALE` (line 49: 100 for a
0/1 outcome reported in pp). The build stops (line 66) if the outcomes panel also has a column of that name, a guard
against two versions of one outcome; the merge takes only the outcomes panel's columns listed on lines 67-68, so once the
two panels are seen to define the outcome the same way, that stop can be narrowed to those columns. Check 1 compares the
paper's ten outcomes by name, so it keeps passing.

A change to the sample, the controls, the fixed effects or the estimator moves the whole-sample estimates and stops
check 1; that check is the guarantee that a run still uses the paper's design.

## What the results show

Every part-1 group of more than 1,000 children has all eight grade-based estimates (NEM, Ranking, PACE's and BEA's grade
rules, on time and ever) negative, each with p < 0.10. The grade-based losses are larger at high-value-added and at
high-peer schools (in splits A and B every high-minus-low difference of a grade-based outcome has p < 0.01). The exam
gain goes the other way across the two measures: in split A it is at high-value-added schools (0.043*** on time against
0.003; difference 0.040** on time, 0.024 ever); in split B it is at low-peer schools (0.041** against 0.014; difference
-0.026 (0.020)). Part 2, by the school of the actual offer, shows the same pattern. Numbers: `output/i2_report.md`.
