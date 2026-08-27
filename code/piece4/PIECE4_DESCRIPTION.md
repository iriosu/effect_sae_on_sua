# Piece 4: where the seats are lost

**The setting, in three sentences.** Chile assigns seats at publicly funded
schools through one centralized system (SAE), which breaks ties at over-demanded
schools with a lottery, and assigns university places through another (run by
DEMRE, the agency behind the national admission process). This package is the
fourth piece of a series built on those lotteries. Piece 2 established the
headline fact, locked by the project's verification runs: winning a contested
9th-grade seat lowers a child's chance of an on-time university seat by 1.84 per
100 children (three stars).

**What this piece adds.** It takes that fall apart. It finds where along the
road each seat is lost, and for the two big losses it shows the mechanism with
direct counts: the winner's GPA and class rank, repriced by her stronger
classroom, cost her more seats than she loses in total at the score contest; and
her lost PACE route is entirely about which school she stands in, with her
standing inside the school contributing close to nothing.

## The road to a seat has four steps

Take María, who won a contested 9th-grade seat, and Luisa, who lost the same
draw by the narrowest margin. To hold a university seat five years later, each
girl must, in order: finish 12th grade on time; hold a usable exam score, which
means BOTH compulsory tests (a girl with one test cannot be scored by any
program, so one test counts the same as none); submit an application; and be
selected at a program she listed. Her chance of a seat is the product of the
four pass rates.

```
Of 100 children who reach each step:           María (won)   Luisa (lost)
  finishes 12th grade on time                     78.17         80.29
  holds both compulsory test scores               73.18         73.01
  submits an application                          61.71         62.00
  is selected where she listed                    73.72         76.63
  gets a seat (all four)                          26.03         27.85

Children passing each step (counts):           María (won)   Luisa (lost)
  in the study                                    26,397        18,726
  finishes 12th grade on time                     20,571        15,043
  holds both compulsory test scores               14,975        10,997
  submits an application                           9,045         6,861
  gets a seat                                      6,661         5,264
```

The rates are computed from these counts with one refinement: each rate
compares winners only with the losers of their own draw and then averages
across the 1,215 draws with the estimator's weights, which is what keeps the
two columns comparable and makes the four pieces below add exactly to the
estimated total.

The winner-loser gap in the product splits into one piece per step, and here is
the entire computation. Multiply Luisa's four rates: her chance of a seat.
Multiply María's four: hers. Then walk from Luisa's product to María's by
swapping in María's rates one step at a time, in the order the steps happen in
life; each swap changes the product by some amount, and that amount is that
step's piece:

```
  all four rates Luisa's       .8029 x .7301 x .6200 x .7663 = 27.85 per 100
  swap in María's step 1       .7817 x .7301 x .6200 x .7663 = 27.12   change -0.73
  swap in her step 2 as well   .7817 x .7318 x .6200 x .7663 = 27.18   change +0.06
  swap in her step 3 as well   .7817 x .7318 x .6171 x .7663 = 27.05   change -0.13
  swap in her step 4 as well   .7817 x .7318 x .6171 x .7372 = 26.03   change -1.02
                                                        the changes add to -1.82
```

The walk starts at Luisa's 27.85 and ends at María's 26.03 whatever happens in
between, so the four changes must add up to the whole gap. Run with full digits
instead of the rounded rates shown, the changes are exactly the pieces below.
In seats per 100 children:

```
  finishes school late            -0.7361 ***
  no usable exam score            +0.0644
  never applies                   -0.1249
  not selected once she applies   -1.0249 ***
  total                           -1.8215 ***   (clustered SE 0.4278)
```

Two steps carry everything: finishing school late, and losing at selection. The
two middle steps hold close to nothing. (Counted strictly step by step, 11,925
of the certified panel's 12,006 seat-holders clear all four; the other 81 are
recorded with a seat despite failing a step on paper, and those 81 are the whole
gap between this total and the certified -1.8356 seats per 100.)

## The selection step, split into its two doors

Among the 15,392 applicants whose draws still contain at least one winner and at
least one loser, a seat comes through one of two doors: her weighted score beats
a program's cutoff, or a special route seats her. The special routes are PACE (a
program that enrolls disadvantaged schools and gives their top graduates a
university path), BEA (a route reserved for holders of the academic excellence
scholarship, earned near the top of one's class), and a gender quota some
programs run. Before 2024 DEMRE published the special-route selections in
separate files; folding those files in gives every year its route labels and
makes the published statuses agree with the assignment file for every single
child, with nobody dropped.

```
Per 100 applicants:                        winners vs losers      loser rate
  got a seat                               -2.9295 *** (0.7842)     76.77
    her score beat a program cutoff        -1.2982 *   (0.8315)     72.08
    selected through a special route       -1.6312 *** (0.3195)      4.69
       through PACE                        -1.3483 *** (0.2522)      2.84
       through BEA                         -0.3656 **  (0.1765)      1.28
       through the gender quota            +0.0826     (0.1249)      0.57

  listed or held the PACE route            -8.9680 *** (1.0289)     21.56
  listed or held the BEA route             -4.0972 *** (0.5774)     14.51
  listed a gender-quota preference         +0.4010     (0.4605)      8.53
```

Every sub-line is an exact piece of the line above it: the two doors add to the
total, and the three routes add to the special-route door, to machine precision.
The one route that ignores the classroom, the gender quota, does not move; the
two routes earned by standing near the top of your own school both fall.

## Why the score door closes: her repriced GPA and rank

The admission score mixes two kinds of inputs. The exam is scored on one
national scale for everyone. The GPA points (the score the system calls NEM)
and the class-rank points are earned against a child's own classmates. Winning
moved María into a stronger classroom, so her school-record inputs are measured
against stronger children.

**Fact one, certified in Piece 3.** Winning lowers exactly those inputs. In
standard-deviation units, María relative to Luisa:

```
  official GPA score (NEM)                    -0.0941 *** (0.0146)
  official class-rank score                   -0.1194 *** (0.0147)
  exam score, among children who sat          +0.0227 **  (0.0099)
```

Her record got worse only where the record is relative; the one nationally
scaled input moved up.

**Fact two, new in this piece: those lost points cost seats.** We show it by
rebuilding admission scores by hand. A winner enters this test if three things
are on file: her official GPA and rank points; at least one listed program
whose score and cutoff we can rebuild; and at least one loser in her own draw
who also has GPA and rank points on file. 8,356 winners qualify; call them the
counted winners. The test has three moves:

1. Compute her admission score at every program she listed, with the real
   program weights and the real cutoffs. With her own record, 77.48 of 100
   counted winners clear the cutoff at some program on their list.
2. Erase her GPA and rank points and write in those of a loser from her own
   draw. Keep her own exam scores and her own program list. Recompute. Now
   79.56 of 100 clear somewhere.
3. The difference is the answer: 2.09 seats per 100 counted winners, moved by
   the GPA and rank points alone.

Two checks that the machine does nothing on its own. Give her another WINNER's
GPA and rank instead of a loser's: the change is 0.19 per 100, close to
nothing — the test's noise floor, eleven times smaller than the answer. Run
the test in reverse, handing losers the winners' points: they lose 2.62 per
100 counted losers, the mirror image. A stricter version, matching each winner
to the single loser closest to her in 8th-grade GPA, gives 2.15 per 100
matched winners, the same answer.

```
Seats per 100 counted winners:
  clears a listed cutoff, her own record                77.48
  same girl, a draw-loser's GPA and rank points         79.56
  moved by the GPA and rank points alone                 2.09 ***   RI p .0001
  noise floor (another winner's points instead)          0.19
  matched to her closest loser by 8th-grade GPA          2.15  (per 100 matched)
Seats per 100 counted losers:
  the reverse test (losers given winners' points)        2.62 ***   RI p .0001
```

**The stars of this test.** The two net rows carry permutation p-values from a
registered addendum test: reshuffle who wins within each draw, exactly as the
lottery did, rebuild the entire count, and repeat 9,999 times. The observed
nets are larger than in every one of the 9,999 reshuffled lotteries, p = .0001
each; so is the estimator-weighted net (-2.34, p = .0001). The placebo sits
inside the reshuffled distribution, where it should. This channel therefore
carries stars at all three of its links: the falling inputs above (-0.0941***
and -0.1194***), the swap itself (-2.09***, p .0001), and the seat line in the
selection table, "her score beat a program cutoff", -1.2982* (0.8315), RI p
.088, per 100 applicants. The selection step as a whole, both doors together,
is -1.0249*** per 100 children. Clearing a cutoff is a common outcome, 72 of
100 losing applicants do it, so comparisons on it are noisy; the route lines
sit on rare outcomes with small standard errors.

The construction has direct precedent in top journals. Recomputing a real,
deterministic admission rule under counterfactual inputs and counting who
changes status is the practice of Ellison and Pathak (2021), Dur, Kominers,
Pathak and Sönmez (2018), and, outside admissions, Currie and Gruber (1996);
those papers report such counts descriptively. The permutation p-value added
here follows the within-lottery re-randomization test of Cullen, Jacob and
Levitt (2006).

The table note fixes the remaining details. The cutoffs are the real ones, held
fixed. The exam and the program list stay her own, so the count isolates the
GPA and rank points.

## Why the PACE route closes: the school

What the route is, from the ministry's resolution (REX 7.447/2025, consolidated
by REX 4042/2026): PACE reserves guaranteed university seats for students of
disadvantaged schools. A guaranteed seat requires two things of María: she
attended a PACE school in 11th and 12th grade, and she stands in the top 25% of
her school's ranking score (or holds 830 ranking points nationally). Applying
through the route requires no rank standard: any PACE-school student who sat
the compulsory tests can list PACE programs. The guaranteed seats are then
assigned by PACE's own score, 80% ranking points and 20% GPA points plus
bonuses, on its own scale.

So the road from school to PACE seat has three links, and our data measure each:

```
Of 100 applicants, her 12th-grade school is in PACE:    13.60 (won)   23.38 (lost)
Of 100 at a PACE school, she lists the route:           91.78         91.73
Of 100 route-listers, she ends with a PACE seat:        11.56         13.01
```

The first link carries everything. The over-demanded schools that children
fight to enter are rarely in the program, so winning moves María out of PACE
territory: her school is in the program 13.60 times in 100 against Luisa's
23.38. Once at a PACE school, the two girls list the route equally, which is
exactly what the resolution predicts, because listing has no rank gate. The
split of the route loss says the same thing with stars:

```
The route loss of -8.97 per 100 applicants splits into:
  her school is not in the PACE program          -8.9751 ***
  her standing inside a PACE school              +0.0071
```

Substituting the ministry's published school lists for the years they exist
gives the same picture (-8.89 school, -0.08 standing), and so does locating
children graded at two schools by either school. (A school counts as
PACE-enrolled in a year when any of its previous-year 12th-graders appears in
that year's PACE application file; these files cover every year of the study.)

The third link is where a repriced class rank could bite a winner a second
time — the top-25% standard and PACE's own 80%-ranking score both operate
there — and it does not, measurably. Splitting the seat loss of -1.3483*** per
100 applicants across the three links with the same machinery:

```
  her school is not in the PACE program            -1.1678 ***   RI p .0001
  she does not list the route, at a PACE school    +0.0009       RI p .97
  she lists and is not seated (conversion)         -0.1814       RI p .42
```

Of 100 route-listers, 11.56 winners and 13.01 losers end seated; that gap's
piece carries no star. The PACE loss is school geography at every link.

The 12th-grade school is itself part of what the draw changed, so this split
sorts children by an outcome of the draw; it is an accounting of the route
loss. Reading either piece as its own separate causal effect would require more
than this table claims.

## Method, in one paragraph

The chance of a seat is a product of pass rates at ordered steps (Mare 1980),
each later rate measured only among children who cleared the earlier steps.
Every rate compares winners with the losers of their own draw and averages the
draws with weights equal to draw size times the variance of winning in the draw
-- definitionally the same estimate as a regression of the outcome on the win
indicator with draw fixed effects (the equality is asserted at every run), which
is the standard estimator of lottery-based school-choice studies (Deming,
Hastings, Kane and Staiger 2014, whose equation (1) is this regression and who
state its weights; the weighting algebra is Angrist 1998). A
difference of two products splits additively by substituting one factor at a
time (Kitagawa 1955; Das Gupta 1993), in the factors' time order (Kim and
Strobino 1984). The same construction, applied to a college-entry funnel, is
Chetty, Deming and Friedman (2026). Stars come from randomization inference:
reshuffle who wins within each draw 9,999 times, recompute the entire
decomposition each time, and read the p-value off the permutation distribution
(Young 2019). Because each later rate is measured among earlier-step survivors,
the pieces are an accounting of the clean total; they are never claimed as
separate per-step causal effects (Rosenbaum 1984; Frangakis and Rubin 2002).

## The package

`Updated Paper Spine/Piece 4/` holds the analysis document
(`1_decompose_assignment.Rmd`), two companion programs (the permutation test
behind the transcript-swap stars, and the three-link PACE seat chain), the
launcher (`checks/90_run_package_analysis.R` — it extracts the document's code
and runs it top to bottom, the same pattern the earlier pieces used), the six
DEMRE special-route files and the extracted official PACE school lists
(`data/`), the four tables with unrounded values CSVs for every displayed
number (`tables/`), and the run logs with every printed number and every input
MD5. The package is complete given the Piece 2 and Piece 3 packages, the
mechanism exploration record, and the shared data folder; `DATA_FILE_LIST.md`
names every input, where it lives, and its fingerprint. Each of the six
analyses in this piece was registered in the project's plan registry before it
ran; every run is recorded in the project's append-only run ledger; and every
number reproduced byte-identically across repeated runs. The row-level audit
trail is in the README. Requires R 4.5.1 with
`data.table`, `fixest`, and `knitr`; every results chunk re-seeds, so all
numbers including the randomization stars reproduce exactly.

## References

Angrist, Joshua D. 1998. "Estimating the Labor Market Impact of Voluntary
Military Service Using Social Security Data on Military Applicants."
*Econometrica* 66(2): 249-288.

Chetty, Raj, David J. Deming, and John N. Friedman. 2026. "Diversifying
Society's Leaders? The Determinants and Causal Effects of Admission to Highly
Selective Private Colleges." *Quarterly Journal of Economics* 141(1): 51-145.

Cullen, Julie Berry, Brian A. Jacob, and Steven Levitt. 2006. "The Effect of
School Choice on Participants: Evidence from Randomized Lotteries."
*Econometrica* 74(5): 1191-1230.

Currie, Janet, and Jonathan Gruber. 1996. "Health Insurance Eligibility,
Utilization of Medical Care, and Child Health." *Quarterly Journal of
Economics* 111(2): 431-466.

Das Gupta, Prithwis. 1993. *Standardization and Decomposition of Rates: A
User's Manual.* Current Population Reports, Series P23-186. Washington, DC:
U.S. Bureau of the Census.

Deming, David J., Justine S. Hastings, Thomas J. Kane, and Douglas O. Staiger.
2014. "School Choice, School Quality, and Postsecondary Attainment." *American
Economic Review* 104(3): 991-1013.

Dur, Umut, Scott Duke Kominers, Parag A. Pathak, and Tayfun Sönmez. 2018.
"Reserve Design: Unintended Consequences and the Demise of Boston's Walk
Zones." *Journal of Political Economy* 126(6): 2457-2479.

Ellison, Glenn, and Parag A. Pathak. 2021. "The Efficiency of Race-Neutral
Alternatives to Race-Based Affirmative Action: Evidence from Chicago's Exam
Schools." *American Economic Review* 111(3): 943-975.

Frangakis, Constantine E., and Donald B. Rubin. 2002. "Principal
Stratification in Causal Inference." *Biometrics* 58(1): 21-29.

Kim, Young J., and Donna M. Strobino. 1984. "Decomposition of the Difference
Between Two Rates with Hierarchical Factors." *Demography* 21(3): 361-372.

Kitagawa, Evelyn M. 1955. "Components of a Difference Between Two Rates."
*Journal of the American Statistical Association* 50(272): 1168-1194.

Mare, Robert D. 1980. "Social Background and School Continuation Decisions."
*Journal of the American Statistical Association* 75(370): 295-305.

Rosenbaum, Paul R. 1984. "The Consequences of Adjustment for a Concomitant
Variable That Has Been Affected by the Treatment." *Journal of the Royal
Statistical Society, Series A* 147(5): 656-666.

Young, Alwyn. 2019. "Channeling Fisher: Randomization Tests and the
Statistical Insignificance of Seemingly Significant Experimental Results."
*Quarterly Journal of Economics* 134(2): 557-598.
