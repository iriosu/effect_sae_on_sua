## Piece 3: why winning hurts — the room, the transcript, and the exam

**The claim.** Chile's college admission score has three parts: the national exam,
the student's grade average (NEM), and the student's rank, which compares their
grades to what their own school's last three graduating classes did. Programmes set
their own weights, and all three parts count. Winning a contested 9th-grade seat
puts a child in a room where the classmates carried in stronger records — 0.13
national standard deviations stronger. The child's own transcript then falls:
first-year grades, class position, the four-year grade average (the record the
NEM component scores), and standing against the school's own history (the record
the rank component scores). The national exam moves the other way: among the
children who sat it — winners and losers alike on the grades they carried in
from 8th grade — winners score 0.023 national standard deviations higher. Both
the grade average and the rank enter every programme's admission score alongside
the exam, so the measures that fell are measures the system reads.

**Why this piece.** Piece 1 shows SAE changed who enters over-demanded schools.
Piece 2 shows winning a contested seat reduces on-time entry into the college
system. Piece 3 shows what moved underneath: the room the child enters is
measurably stronger, every transcript record the admission formula scores falls,
and measured exam performance rises among children the records cannot tell apart
before the draw.

### Definitions

**The frame.** Identical to Piece 2's certified headline frame, asserted at run
time: first-choice contested regular applications, strata (classroom by year by
income tier) with at least five winners, the 10% violation screen, nearest losers
capped at the winner count — 45,123 applications in 1,215 strata, cohorts
2016–2021. Estimator and inference are Piece 2's, code copied verbatim:
within-stratum winner–loser difference, precision-weighted; school-by-year
clustered standard errors for scale; stars from randomization inference (9,999
within-stratum reshuffles, winner counts fixed, seed 20260919).

**The transcript columns** come from the education ministry's school records,
which cover every enrolled child in Chile, so no college participation is
involved. Peer 8th GPA: the mean 8th-grade GPA (national z, application year) of
the 9th graders at the school the child actually attends in the entry year,
excluding the child. 9th GPA and 4-yr GPA: the child's own grade average in the
entry year and across the four on-time high-school years (all four required),
each as a national z. Percentiles: the child's position among the graded students
of their school-grade cohort, 0 to 1. Rank vs. history: the child's four-year
average measured against the pooled averages of the three classes promoted from
the child's 12th-grade school just before their own — the bar the admission
formula's rank component prices; a student counts as promoted if any record of
that student-year-school says so, decided before deduplication, so file order can
never decide membership.

**The score columns** come from the college admission records and exist only for
children who show up to that system: the exam score for children who sat an exam,
DEMRE's official NEM and rank scores for score-carrying registrants, each as a
national within-process z. Winning moves who shows up, so these columns sit in
their own table, every denominator is reported per arm, and a registered check
compares the arms on the records they carried in from before the draw inside
those columns. An absent child is never scored 0.

### Results

```
The room and the transcript (per-column non-NA of the frame):
  Peer 8th GPA (z)         +0.1335*** (0.0084)   n 44,055   loser mean -0.0153
  9th GPA (z)              -0.1188*** (0.0188)   n 43,610   loser mean -0.0917
  9th percentile (0-1)     -0.0542*** (0.0043)   n 43,610   loser mean  0.5194
  4-yr GPA (z)             -0.0836*** (0.0137)   n 35,461   loser mean -0.1569
  12th percentile (0-1)    -0.0278*** (0.0038)   n 35,650   loser mean  0.5135
  Rank vs. history (z)     -0.1888*** (0.0164)   n 35,172   loser mean  0.2194

The exam and the official scores (conditional columns):
  Exam score (z)           +0.0227**  (0.0099)   n 26,757   loser mean -0.3080
  Official NEM (z)         -0.0941*** (0.0146)   n 30,806   loser mean -0.0547
  Official rank (z)        -0.1194*** (0.0147)   n 30,806   loser mean -0.0386

Who each column can see (winners | losers):
  a 9th-grade record            .9684 | .9658
  all four on-time years        .7818 | .8051
  sat the exam                  .5910 | .6087
  an official NEM score         .6787 | .7005
```

The transcript columns see nearly every child in both arms. The exam and the
official scores see only the children who reach the college system, and winning
moves that: 1.3 fewer winners in a hundred sit the exam, and 2.1 fewer hold an
official score. Full per-arm coverage for every column is in
`tables/mech_column_coverage_values.csv`.

**The exam result.** Within a draw the applicants are alike, and the random
number decides which of them get seats. Among the ones who sat the exam, winners
and losers are still alike on the grades they carried in from 8th grade, and
those winners score higher on the exam than those losers.

```
8th-grade GPA (z), winners minus losers within strata, among exam sitters:
  +0.0090 (0.0110)   not starred   n 26,597
Exam score (z), same children:
  +0.0227**  (0.0099)              n 26,757
```

**Why the rank falls further than the grades.** Rank measures the child against
the classes their own school graduated before them. A stronger room raises that
bar whatever the child does, so part of the rank and percentile fall is built
into the measure the moment the room strengthens. How much of the fall comes
from the higher bar and how much from the child's own lower grades is a separate
future registration, not run here.

### The package

`Updated Paper Spine/Piece 3/` is self-contained: the grades-supplement packer
(`00a_pack_rendimiento_grades.R`, the two raw public Rendimiento releases →
`rendimiento_grades_2024_2025.rds`), the panel build (`00_build_mech_panel.Rmd`,
the stamped Piece 2 panel + canonical graded panel + supplement + census + the
stamped college outcome table → `lottery_panel_mech.rds`, the stamped columns
re-asserted byte-identical), the analysis (`1_effect_mech.Rmd`, reads only the
panel), the generated tables with unrounded values CSVs, the full-population
validation (`checks/88_mech_panel_validation.R`: 44 checks, every new column
re-derived through an independent code path, the supplement compared row-for-row
against the raw csvs, input anchors, coverage floors, conflict guards, schema
guard), a README with the MD5s, and a run log with every printed number. Requires
R 4.5.1 with `data.table` and `fixest`; every estimating chunk re-seeds, so all
numbers including the randomization stars reproduce exactly.

Four registered specs stand behind the piece: LOTTERY-MECH-2026-08-17 (the nine
outcome columns and the coverage margins) and LOTTERY-MECH-FLOOR / -TILT /
-CROSSING-2026-08-18 (the checks on the exam column). The tilt check is the one
reported above. The floor and crossing checks bound how far the absent children
could move the exam column; both were run, neither produces a fall, and their
numbers ship in `tables/mech_exam_floor_values.csv`, `mech_crossing_values.csv`,
and `mech_scale_translation_values.csv` with the runs on the ledger. Ledger
RUN-302..318.
