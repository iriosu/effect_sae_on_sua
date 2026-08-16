## Piece 1: SAE changed who gets into over-demanded schools

**The claim.** When a school came under SAE and lost the ability to choose among its
applicants, the students entering it changed. Entering classes became academically
weaker: their average prior-year GPA fell by about 0.15 national standard deviations,
significant at 1% under randomization inference, and the drop appears in the data at
each region's own adoption year. The share of low-income students in the entering class
rose by about 3.5 percentage points; this moves in the same direction in every
specification and is not significant on its own.

**Why this is the first piece.** Pieces 2 and 3 ask what happens to students' college
outcomes when SAE reallocates them. Piece 1 establishes that SAE actually reallocated
them, at the schools where selection used to operate.

### Definitions

**A cell.** One school crossed with one grade level, followed over the years. Example:
9th grade at Liceo San Martín. The panel follows 8,958 cells over 2012 to 2023.

**Over-demanded.** A cell is over-demanded in a year when the children who genuinely
applied to it and ranked it at least as high as their final placement outnumber the
seats offered. A cell is in our sample when it is over-demanded in **every** year we
observe it. Demand is computed from the official SAE application, offer and assignment
files, and the computation is done by two independent methods that are required to agree
cell by cell.

**One caveat on that definition, and its check.** Application data only exist in SAE
years, so "always over-demanded" is measured after the reform and extrapolated
backward: we assume these same schools were also turning children away before SAE. The
code checks this school by school: it compares each cell's enrollment in the four years
before its region joined SAE with the three years after, netting out growth of the
school as a whole. A cell that looks like it had empty seats before SAE (a school with
empty seats takes everyone and had no selection to lose) is flagged, and one robustness
column drops every flagged cell. The estimate barely moves.

**Entrant.** A student enrolled in a cell in year t who was not enrolled at that school
in the April enrollment census of year t−1. The census is the official register of every
enrolled student, so a continuing student is recognized whether or not they have grades
on file.

**The outcomes.** For each cell and year, take its entrants. Outcome one: their average
GPA from the year before entry, earned at whatever school they came from, converted to a
z-score against every graded student in Chile that year. This is the academic record the
class carried in, before the school could influence it. Outcome two: the share of
entrants holding prioritario status, the government's official low-income designation.

**Treated and control.** A cell is treated from its first SAE-admitted entering class
onward (its region's SAE start year for that grade, plus one). The control cells are
over-demanded cells of the same kind in regions whose SAE start had not yet arrived,
still admitting under school-controlled selection.

**Inference.** Chile has 16 regions, so conventional clustered standard errors cannot
be trusted. Significance comes from randomization inference: reshuffle which regions got
which rollout wave 9,999 times, recompute the estimate each time, and ask how extreme
the real rollout is in that distribution. The clustered bootstrap SE is reported in
parentheses for scale only.

### Results

```
Headline (all grades, 76,702 cell-years):
  Entrant prior-GPA (z)    -0.150*** (0.031)    RI p < 0.001
  Share prioritario        +0.035    (0.009)    n.s. under RI

Robustness (entrant GPA), one change at a time:
  Drop Santiago entirely       -0.087***
  >= 5 graded entrants/cell    -0.180***
  Drop flagged pre-SAE slack   -0.151***
  Weight by entrant count      -0.173***
  Base year moved 1 earlier    -0.146**

Parallel trends: every pre-adoption lead under 0.03 SD, CIs straddling zero;
exact randomization joint test of the leads p = 0.81.
```

**Interpretation guards** (`tables/alloc_guards.tex`). Two checks that the headline is
a change in who is admitted, with everything else standing still. The entrant count
should not move, because seats are set by the school and were full before and after
SAE. The share of entrants with a prior-year GPA should not move either: only students
graded in Chile the year before have one, so if the 2017-2019 migration wave tracked
the rollout, the headline could reflect who is measurable instead of who is admitted.
Both come back flat:

```
                        Entrants per cell    Share with prior GPA
Treated                     -0.200                 -0.009
                            (0.394)                (0.010)
RI two-sided p               0.83                   0.16
Mean (pre-treatment)        13.9                   0.949
Observations                97,381                 77,160
```

### The package

`Updated Paper Spine/Piece 1/` is self-contained: three packed data files in `data/`
(SAE admissions, enrollment census, prioritario rosters; ~0.4 GB, packed from the
public MINEDUC releases by `00a_pack_raw_data.R`), the code that constructs the panel
(`00_build_entrant_panel.Rmd`, the packed files + the shared canonical panels →
`entrant_composition_panel.rds`), the analysis (`1_effect_sae_alloc.Rmd`, reads only
that panel), the generated tables and figure, a README, and a run log with every
printed number. Requires R 4.5.1 with `did` 2.1.2 (the analysis halts on any other
version).
