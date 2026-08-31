# Piece 1, Updated: Entrant Composition at Over-Demanded Schools

## What the piece shows

When SAE removed schools' power to pick their students, the entering classes of
chronically over-demanded schools shifted toward children with weaker prior
academic records and toward low-income children, both at the 1% level, in the year
the door opened and never before it.

## Data and design

One row per always-over-demanded school-grade cell per year, 2012 through 2023:
8,958 cells, the Piece 1 panel of record (MD5-pinned in the analysis file, built
and documented in the Piece 1 package). A cell is always over-demanded when, in
every year observed, genuine applicants ranking it at least as high as their final
placement outnumber its seats. Treatment is the year the region's grade level
entered SAE; the estimator is Callaway and Sant'Anna difference-in-differences
with not-yet-treated controls and a universal base period. Two outcomes: the
entering class's mean prior-year GPA, standardized nationally within year, and
share prioritario, the share of the entering class carrying the government's
low-income designation, each entrant tagged by their year's published rule.

## How significance is scored, explained simply

Stars come from randomization inference over the rollout, and the idea can be told
as a make-believe game. The reform arrived region by region: one region in 2016,
four in 2017, ten in 2018, Santiago last. We invent 9,999 fake versions of
history, each shuffling which regions got which years, and recompute the effect in
every fake history. A result earns stars when almost no fake history produces a
number as big as the real one.

One feature of the setting shapes the scoring. Santiago holds about a third of
these schools, so a fake history that hands Santiago the reform early makes the
whole computation ride on one region's year-to-year luck, and one region's luck
produces big numbers easily. The scoring therefore makes every history, real and
fake alike, vouch for its own steadiness: delete one region at a time, recompute,
and measure how much the number moves across the sixteen deletions; the score is
the number divided by its own wobble. A fake history that leans on one region
collapses under this rule, because deleting that region guts its number.

The real share-prioritario effect barely notices the deletions: removing any
region, Santiago included, moves it only between +0.032 and +0.037. Steady
number, tiny wobble, high score. Three of 9,999 fake histories outscore it:
p = 0.0004 under the plus-one counting rule, and the conclusion does not depend
on which 9,999 fakes are drawn; an independent redraw gives p = 0.0002. The GPA
headline scores p = 0.0007 the same way. The two interpretation guards, outcomes
that are supposed to show nothing, stay far from stars (p 0.87 and 0.56): the
scoring separates steady results from shaky ones in both directions.

## Why this is the standard method

Two references carry the weight. Young (2019, *Quarterly Journal of Economics*,
"Channeling Fisher") re-examines a large body of experimental work using
randomization inference and adopts the studentized statistic, the number divided
by its own uncertainty, as the default test statistic throughout. MacKinnon and
Webb (2020, *Journal of Econometrics*, "Randomization inference for
difference-in-differences with few treated clusters") study randomization
inference for difference-in-differences when the reshuffled clusters differ
greatly in size, and show the raw-coefficient test misbehaves there while the
studentized test holds its size in their designs. The joint pre-trend test in the
analysis file applies the same principle, scaling each lead by its permutation
spread.

## Event studies

Dynamic ATT by event time, the headline configuration: each row compares treated
cells with not-yet-treated cells at that event time, against the reference period
(event time -1, zero by construction). **Bold entries are estimates whose 95%
confidence interval excludes zero.**

| years from door | entrant GPA (z) | (SE) | share prioritario | (SE) |
|---|---|---|---|---|
| -8 | +0.0166 | (0.0374) | -0.0347 | (0.0193) |
| -7 | +0.0072 | (0.0288) | -0.0224 | (0.0119) |
| -6 | +0.0241 | (0.0227) | **-0.0165** | **(0.0081)** |
| -5 | +0.0123 | (0.0236) | -0.0174 | (0.0090) |
| -4 | +0.0263 | (0.0241) | -0.0133 | (0.0114) |
| -3 | +0.0169 | (0.0267) | +0.0001 | (0.0062) |
| -2 | +0.0280 | (0.0308) | -0.0049 | (0.0084) |
| -1 | 0 (reference) | --- | 0 (reference) | --- |
| 0 | **-0.1311** | **(0.0366)** | **+0.0330** | **(0.0097)** |
| +1 | **-0.1924** | **(0.0416)** | **+0.0385** | **(0.0140)** |
| +2 | -0.1759 | (0.1490) | +0.0310 | (0.0300) |

Both outcomes move at event times 0 and +1, in opposite directions: weaker prior
records in, more low-income children in. In the pre-period one entry is bold, the
share prioritario lead at -6, whose pointwise interval excludes zero narrowly
(upper bound -0.001); the exact randomization joint test of the leads is the
inference of record and does not reject for either outcome (GPA p 0.81, share
prioritario p 0.86). The deeper leads (-8, -7) are identified by the latest
adopters and lean negative; they are printed with the path. Beyond +1
identification thins as the rollout completes: the +2 estimate is identified by
the earliest adopters against the final wave, hence its wide interval, and at +3
no not-yet-treated control remains, so no standard error is identified and that
point is reported only in the analysis document. The figures end at +1 for the
same reason.

## The results in one place

```
Headline (all grades, 2012-2023):
  Entrant prior-GPA (z)    -0.150*** (0.031)    76,702 cell-years
  Share prioritario        +0.035*** (0.009)    97,381 cell-years

Robustness (entrant GPA), one change at a time:
  Drop Santiago entirely       -0.087***
  >= 5 graded entrants/cell    -0.180***
  Drop flagged pre-SAE slack   -0.151***
  Weight by entrant count      -0.173***
  Base year moved 1 earlier    -0.146***

Event studies: see the table above; the exact joint lead tests
  do not reject (GPA p 0.81, share prioritario p 0.86). The
  estimator's own Wald pre-test rejects for both outcomes (GPA
  W 41.6, share W 59.6); for GPA the single-region channel behind
  it is documented in the Piece 1 package README, and the exact
  joint lead tests are the inference of record. Both statistics
  print in the run log.
Guards:
                       Entrants per cell    Share with prior GPA
  Treated                     -0.200                -0.009
                              (0.394)               (0.010)
  RI two-sided p               0.87                  0.56
  Mean (pre-treatment)        13.9                   0.949
  Observations                97,381                77,160
```

## References

Young, A. (2019). Channeling Fisher: Randomization tests and the statistical
insignificance of seemingly significant experimental results. *Quarterly Journal
of Economics*, 134(2), 557-598.

MacKinnon, J. G., and Webb, M. D. (2020). Randomization inference for
difference-in-differences with few treated clusters. *Journal of Econometrics*,
218(2), 435-450.
