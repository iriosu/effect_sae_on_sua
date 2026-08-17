## Piece 2: winning an SAE lottery reduces on-time entry into the college system

**The claim.** When more children want a classroom than it has seats, SAE breaks the
tie with a random number. Children who won a contested 9th-grade seat this way fell
behind the children who lost the same draw by the narrowest margin, on their cohort's
own schedule: they were 2.1 percentage points less likely to be promoted out of 12th
grade on time (against a loser rate of 80.3%), and in the on-time college admission
process 1.1 points less likely to appear, 1.8 points less likely to be assigned a
program, and 1.5 points less likely to enrol (loser rates 37.0%, 28.3%, 24.1%).
Whether the children who missed the on-time year catch up later is a question the
records, which end at process 2026, can only partially reach; this piece asks the
question every cohort can answer in full.

**Why this piece.** Piece 1 shows SAE changed who enters over-demanded schools, using
the region-by-region rollout. Piece 2 asks the follow-on question — what happened to
the children the lottery let in — with the cleanest variation the system produces: a
coin flip between observably identical applicants to the same classroom.

### Definitions

**A lottery.** One classroom draw at one school in one application year. Example: the
2018 draw for a 9th-grade classroom at Liceo San Martín. Every applicant gets a random
number; among applicants with the same priority standing, seats go to the best numbers.

**The comparison.** Take María, a low-income applicant to that classroom whose number
cleared the cutoff, and the low-income applicants to the same classroom whose numbers
just missed it. María is a winner; they are her nearest losers. The estimate compares
their college outcomes, averaged over every such stratum. Low-income (prioritario)
children face their own quota's cutoff, so María is never compared to a
non-low-income loser: each stratum is one classroom, one year, one income tier —
the marginal-priority-group construction of Abdulkadiroğlu, Angrist, Narita and
Pathak (2017).

**Who is in the frame.** Regular, contested, first-choice applications: no continuity
auto-adds, no sibling/staff/returning-student/special-education priority, ranked at
least as high as the child's final placement, and the classroom was the child's first
choice. Strata need at least five winners, pass a screen on protocol violations (at
most 10% of losers holding a number better than the worst winner), and keep the
nearest losers up to the winner count. Application cohorts 2016–2021.

**The outcomes.** Four yes/no facts, all on the cohort's own schedule. Was the child
promoted out of 12th grade in the on-time year (application + 4, from the school
records)? And at application year + 5 — when an on-time 9th grader faces the college
process — did she appear in the centralized college admission system (applied),
receive a program assignment (assigned), enrol in a program (enrolled)? A child with
no record counts 0 throughout.

**Inference.** Stars come from randomization inference: reshuffle who wins within
each stratum 9,999 times (winner counts fixed), recompute, and ask how extreme the
real draw is. School-by-year clustered standard errors are shown for scale.

### Results

```
Headline (45,123 first-choice applications from 45,073 distinct children, 1,215 strata):
  Grad on time  -0.0212***  (0.0052)    loser-arm mean .8033
  Applied       -0.0109**   (0.0047)    loser-arm mean .3703
  Assigned      -0.0184***  (0.0043)    loser-arm mean .2830
  Enrolled      -0.0152***  (0.0040)    loser-arm mean .2409

The draw was clean:
  protocol violations 45 of 38,306 losers (0.12%)
  balance: prioritario +0.0022 (p .655), female +0.0040 (p .377),
           female within stratum +0.0045 (p .312),
           8th-grade GPA within stratum +0.0040 (p .651)

The treatment happened (entry year):
  at the lottery school   winners .8948  losers .1879   +0.6979*** (0.0077)
  enrolled at any school  winners .9894  losers .9830   +0.0061*** (0.0012)

Robustness, one change per row (Grad on time / Applied / Assigned / Enrolled):
  Pooled (tiers mixed)           -0.0224*** / -0.0103**  / -0.0169*** / -0.0150***
  No-priority tier only          -0.0178*** / -0.0077    / -0.0155**  / -0.0124*
  Low-income tier only           -0.0238*** / -0.0132**  / -0.0205*** / -0.0174***
  Drop special-admission strata  -0.0207*** / -0.0124*** / -0.0185*** / -0.0159***
  Drop same-school losers        -0.0209*** / -0.0105**  / -0.0181*** / -0.0150***
```

### The robustness checks, one by one

Each row rebuilds the headline comparison with exactly one rule changed, and asks
whether the same four differences come out.

**Pooled (tiers mixed).** The headline splits every classroom draw in two, because
the 15% low-income quota gives low-income children their own cutoff. This row undoes
the split: María (low-income) and Tomás (not low-income) applied to the same
classroom, and now all the classroom's winners are compared to all its nearest
losers, tiers mixed. If the tier-splitting machinery itself were producing the
headline, this simpler version would say something different. (43,405 applications
in 793 lotteries.)

**No-priority tier only.** Keep only Tomás's world: children without the low-income
flag, compared to losers without the flag. Does the result exist among the
non-low-income children standing alone? (19,039 applications, 601 strata.)

**Low-income tier only.** The mirror image, only María's world: low-income winners
against low-income losers. The headline combines these two tiers; showing them apart
proves neither group's answer is hiding inside the other's. (26,084 applications,
614 strata.)

**Drop special-admission strata.** Some schools fill part of the class through a
separate special-education admission channel with its own ordering. A child admitted
through that channel who also happened to draw a lottery number would appear in our
winner column without having won a coin flip — his seat was never up for the draw.
There are 94 such winners, sitting in 60 strata; this row deletes those 60 strata
entirely, so every remaining winner won by the number and nothing else. (42,321
applications, 1,155 strata.)

**Drop same-school losers.** Carla lost the draw for classroom A but the system
placed her in classroom B of the same school. She is coded a loser, yet losing did
not send her to a different school — and the design rests on winners and losers
ending up at different schools. There are 90 children like Carla; this row drops
them, so every remaining loser truly ended up elsewhere. (45,026 applications,
1,214 strata.)

Reading across the table: all twenty differences are negative; Grad on time carries
three stars in every row; the single cell without a star is Applied in the
no-priority tier (−0.0077, SE 0.0068). The 7th-door robustness table below runs the
same five checks.

**The 7th-grade door.** The identical design at SAE's other entry gate (grad on time
at application + 6, college outcomes at application year + 7, cohorts 2016–2019,
6th-grade GPA as the predetermined record). The usable frame is 3,755 first-choice
applications from 3,750 distinct children in 89 strata; most 7th-grade lotteries hand
out fewer than five seats, and no 2016 stratum clears the five-winner screen. The
headline intervals contain both zero and the 9th-door estimates and rule out effects
beyond roughly ±4 percentage points on the college outcomes.

```
Headline (3,755 first-choice applications from 3,750 distinct children, 89 strata):
  Grad on time  -0.0153     (0.0139)    loser-arm mean .8716
  Applied       -0.0009     (0.0224)    loser-arm mean .5237
  Assigned      +0.0011     (0.0205)    loser-arm mean .4439
  Enrolled      -0.0044     (0.0184)    loser-arm mean .3827

The draw was clean:
  protocol violations 12 of 3,590 losers (0.33%)
  balance: prioritario -0.0140 (p .411), female +0.0159 (p .344),
           female within stratum +0.0160 (p .302),
           6th-grade GPA within stratum +0.0161 (p .558)

The treatment happened (entry year):
  at the lottery school   winners .9344  losers .0936   +0.8404*** (0.0189)
  enrolled at any school  winners .9947  losers .9922   +0.0034    (0.0026)

Robustness, one change per row (Grad on time / Applied / Assigned / Enrolled):
  Pooled (tiers mixed)           -0.0395*** / +0.0001    / -0.0024    / -0.0035
  No-priority tier only          -0.0117    / +0.0024    / +0.0123    / +0.0080
  Low-income tier only           -0.0194    / -0.0047    / -0.0118    / -0.0187
  Drop special-admission strata  -0.0248**  / -0.0041    / -0.0028    / -0.0090
  Drop same-school losers        -0.0153    / -0.0009    / +0.0011    / -0.0044
```

### The package

`Updated Paper Spine/Piece 2/` is self-contained: the build documents
(`00_build_lottery_panel.Rmd`, `00b_..._7th.Rmd` — packed SAE/PAES files + DEMRE
records + canonical panels + the packed 2024–2025 school records → the two lottery
panels), the analysis documents
(`1_effect_lottery.Rmd`, `1b_..._7th.Rmd` — read only the panels), the panels of
record with MD5s in the README, the generated tables with unrounded values CSVs, a
README, and a run log with every printed number. Both panels rebuilt byte-identically
from scratch and every column validated against its source over the full population.
Requires R 4.5.1 with `data.table` and `fixest`; every estimating chunk re-seeds, so
all numbers including the randomization stars reproduce exactly.
