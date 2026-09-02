# Piece 1 - v2, exploratory: SAE and the college outcomes of entering classes

This folder holds the working scripts that produced the Version A board, sent as
they are for an adversarial review. It is not a finished package. There is no
single entry point, the scripts take command-line arguments, and they read and
write through the exploration folder layout described below.

Read `VERSION_A_RESULTS.md` first. It carries every Version A number, the design
in plain language, and the explanation of how significance is scored.

## Status, stated plainly

Nothing here has been through a code review, an adversarial review, or a
completed replication. That is the work this folder is being sent for.

Known open items, all of them found before sending:

1. **The 12th-grade promotion set leaves out one school stream.** Graduation is
   counted from school types 310, 410, 510, 610, 710 and 810. Piece 2's two
   builds, both of its validation scripts, and Piece 3's build use the same list
   plus 910, artistic secondary. The panel has been rebuilt with the stream
   added, so the size of the omission is measured rather than estimated:

   ```
   cell-years whose graduation rate changes     137 of 82,752 (0.166%)
     of those, in the public arm                125
   distinct cells affected                      121, across 98 schools
   entrant counts, applied, assigned, enrolled  no change at all
   mean graduated on time                       0.783149 -> 0.783326
   ```

   It affects the graduated-on-time column and nothing else: entrant prior GPA
   and share prioritario come from the entrant panel, and applied, assigned and
   enrolled come from the college admission files. The affected cells are small,
   one to a few entrants each, so one student moves such a cell's rate a long
   way, and that carries most weight in the unweighted column where every class
   counts equally. The fix is one entry in a vector followed by a panel rebuild
   and a rerun of the board. The numbers in this folder come from the panel
   before the fix, and the two agree with each other.
2. **The full replication has not been run.** Two of the Version A scripts were
   rerun and reproduced every column they completed digit for digit before the
   reruns were stopped. Those two logs are in `logs/` next to the originals, so
   the comparison can be checked. The remaining scripts have not been rerun.
3. **Two scripts were edited after producing some of the outputs recorded here.**
   The era standard-error script and the event-study script were changed to add
   and then remove an unweighted branch while the board was being computed. The
   arithmetic for the weighted arms was not touched, and the logs show the runs
   completing, so this is a provenance gap rather than a known error. A rerun
   closes it.
4. **The randomization test runs on a reimplementation of the estimator, gated
   against the package.** Before any permutation is scored, the reimplementation
   has to reproduce the package's own answer on the real data to machine
   precision, or the run halts. Running the package itself on every permutation
   costs about sixty hours per table. Whether the final numbers should carry that
   full certification is the open decision in
   `DECISION_FOR_TOMAS_inference_certification.md`.

## What is here

| Path | Role |
|------|------|
| `VERSION_A_RESULTS.md` | Every Version A number: headline, admission-test era split, joint pre-trend tests, six event studies, three weightings side by side. Written by `R/a22_version_A_results_md.R` from the output files. |
| `R/b2_build_private_cells.R` | Builds the private-school entering-class cells. Needed because the class-panel build reads them to keep those schools out of the public arm. |
| `R/b3_build_allgrades_panel.R` | Builds the class panel: entering classes at all grades of the always-over-demanded schools, on the college-process clock, with the four college outcomes. |
| `R/a20a_versionA_unweighted.R`, `R/a15_versionA_rule1.R`, `R/a13_versionA_locked.R` | Headline and era estimates for Version A under the three weightings: unweighted, own-year class size, fixed mean class size. |
| `R/a19u_es_stud_unweighted.R`, `R/a19_es_stud_full.R` | Event studies with per-cell scores and the joint pre-trend test. The first runs the unweighted arm, the second takes the weighting as an argument. |
| `R/a16_era_boot_se.R` | Region-clustered bootstrap standard errors for the era pools, built from the influence functions of the calendar-year cells, with two gates. |
| `R/a21_bands.R` | 95 percent simultaneous confidence bands for the event studies. |
| `R/a22_version_A_results_md.R` | Writes `VERSION_A_RESULTS.md` from the output files. Display only, no estimation. |
| `R/d3`, `R/d5`, `R/d6`, `R/d7` | The diagnostic scripts that identified the estimator's exact arithmetic and aggregation weights against the package. These are the evidence behind the machine-precision gates. |
| `logs/` | Console logs of every run behind the Version A numbers, plus the two partial reruns. |
| `DECISION_FOR_TOMAS_inference_certification.md` | The open decision on how far the randomization test should be certified. |

Version B, which adds private schools as never-treated controls, is computed by
the same scripts through their version argument. Its numbers are not in this
folder.

The repository excludes data files, so the `.csv` outputs the scripts write are
not here. Every Version A number they contain is reproduced in
`VERSION_A_RESULTS.md`.

## Data

Two panels are read by these scripts and are placed in the shared data folder
`~/Dropbox/Effect SAE on SUA/data`, next to the files the rest of the project
reads:

```
private_entrant_cells.rds            MD5 e43faa7be42d02cfe190fad6924ce6a2
class_college_allgrades_panel.rds    MD5 9b2a5f80a0dc3a1400cc12195665a382
```

Every analysis script asserts these fingerprints and halts on a mismatch, so the
numbers cannot silently drift from the data. The builds that produce them read
the packed Ministry of Education files already in that folder: the enrolment
census, the school performance panel, the 2024-2025 performance supplement, the
SEP records, the school directory, the SAE application file, the certified
entrant panel, and the college admission records for processes 2018 to 2026.

## Running them

Requires R 4.5.1 and the `did` package at 2.1.2. Every script checks both and
halts on anything else. Install the pinned estimator with
`remotes::install_version("did", "2.1.2")`.

The scripts resolve paths from the home directory and expect this layout:

```
~/Dropbox/Effect SAE on SUA/data/                                  the shared data folder
~/Dropbox/Effect of Centralization/explorations/2026-08-31_did_college_outcomes/R/       these scripts
~/Dropbox/Effect of Centralization/explorations/2026-08-31_did_college_outcomes/output/  where they write
```

Create that folder pair and put the `R/` scripts in it, or edit the two path
lines at the top of each script. Order and arguments:

```
Rscript R/b2_build_private_cells.R                  builds the private cells
Rscript R/b3_build_allgrades_panel.R                builds the class panel
Rscript R/a20a_versionA_unweighted.R                headline, unweighted
Rscript R/a15_versionA_rule1.R                      headline, own-year class size
Rscript R/a13_versionA_locked.R                     headline, fixed mean class size
Rscript R/a19u_es_stud_unweighted.R A 0 <cores>     event studies, unweighted
Rscript R/a19_es_stud_full.R        A 1 <cores>     event studies, own-year size
Rscript R/a19_es_stud_full.R        A 2 <cores>     event studies, fixed mean size
Rscript R/a16_era_boot_se.R         A 0|1|2         era standard errors
Rscript R/a21_bands.R               A 0|1|2         simultaneous bands
Rscript R/a22_version_A_results_md.R                writes the results page
```

The two builds take a few minutes each. Each headline script takes 30 to 60
minutes on 10 to 16 cores and each event-study stream 100 to 165 minutes; the
permutation scoring is what costs the time. The era and band scripts take under
a minute. The event-study scripts must run before the band script for the same
weighting, because the band script checks its estimates against them.

Results are independent of the number of workers. Every permutation is drawn in
the main process before any scoring is handed out.

## Where the numbers come from

The design, the estimator, the weighting, and the scoring rule are all described
in `VERSION_A_RESULTS.md`. In one paragraph: Callaway and Sant'Anna staggered
difference-in-differences on always-over-demanded public school-grade cells, with
not-yet-treated cells as controls and a universal base period, no covariates, and
standard errors from a region-clustered multiplier bootstrap. Composition
outcomes sit on the entry-year clock and college outcomes on the college-process
clock. Significance comes from randomization inference over which regions
received the reform in which year, with each permutation divided by its own
delete-one-region jackknife spread before ranking.
