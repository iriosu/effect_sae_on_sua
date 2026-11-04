# composition.Rmd

**What it is.** The composition notebook of *Effect of Centralized School Choice on College Admissions
Outcomes* (Rios, Larroucau and Marar). It produces the paper's access section ("Centralized Assignment
and Access to Over-Demanded Schools"), on who enters the over-demanded schools before and after SAE's
staggered rollout, and that section's appendix: it writes the tables and figures of the access section
and its appendix, Appendix Table B.8 included, and three macro files (two of the numbers quoted in their
text, one of Appendix Table B.7's estimates, which the paper inputs without printing), under the names and
relative paths the paper uses. A school-grade is over-demanded when it
offered seats in at least one SAE process of 2016-2021 and, in each such process, its effective demand
exceeded its seats in every one of 2,000 recorded reruns of SAE's main stage (10,027 school-grades,
whose ninth grades are the 1,020 over-demanded schools of the lottery analysis). Each estimate is did's
group-time average effect (Callaway and Sant'Anna 2021) with not-yet-treated comparison cells, base
period g-1 and no anticipation; the one exception is the robustness row "Reference period g-2" of
Appendix Table B.3, whose base period is g-2. The standard errors come from did's multiplier bootstrap
clustered by region, and the stars from the studentized randomization test over the saved
reassignments of the rollout across the 16 regions. The notebook reads one data folder and the
manifest beside it, and nothing else.

## How to run it

1. R 4.5.1 with did 2.1.2 (`remotes::install_version("did", version = "2.1.2")`), fixest 0.14.2 or
   later, data.table, knitr and, for `rmarkdown::render`, rmarkdown (the versions these results were
   run under are listed below). The notebook stops when R is not 4.5.1 or did is not 2.1.2, and
   when fixest is older than 0.14.2 (a newer fixest is named in a message). It also checks did's
   bootstrap multipliers: in each draw of its multiplier bootstrap, did gives each of the 16 regions a
   multiplier of +1 or -1, drawn by the BMisc package, and multiplies the regions' influence functions
   by them. From Table II's seed (20260815), the notebook draws the multipliers of one full call,
   10,000 draws for the 16 regions (the call did makes first in Table II's prior-year GPA fit), and
   stops unless the MD5 of their 160,000 signs is that of these results' multipliers: another BMisc,
   RcppArmadillo or random-number generator that draws other multipliers would change every bootstrap
   standard error. The check covers the multipliers of that call; the influence functions come from
   did, which must be 2.1.2.
2. The data folder holds the 19 files that `data_manifest.csv` beside this notebook lists (below), and
   a copy of that manifest. Its default location is the shared data folder, `<home>/Dropbox/Effect SAE
   on SUA/data/finalized_design_v1/composition/` (`<home>` is `USERPROFILE` on Windows, the home folder
   elsewhere). Before it reads any file, the notebook checks that the data folder's manifest is the one
   beside the notebook and every file's bytes and MD5 against it, and stops when a manifest or a file
   is missing or differs.
3. With the data folder at its default location, from this folder:

       Rscript -e "knitr::knit('composition.Rmd')"

   With the data folder anywhere else (or another output folder), give its location:

       Rscript -e "params <- list(data_dir = '<data folder>', out_dir = '<output folder>'); knitr::knit('composition.Rmd')"

   If `Rscript` is not on the PATH, give its full path (on Windows, for example
   `"C:\Program Files\R\R-4.5.1\bin\Rscript.exe"`). On Windows, write the paths inside the quotes with
   forward slashes (`C:/Users/...`): inside an R string, a backslash starts an escape. A relative `data_dir` or `out_dir` is read from this notebook's
   folder, whatever folder the chunks run in (RStudio's Knit Directory setting, `rmarkdown::render`'s
   `knit_root_dir`).
4. `rmarkdown::render('composition.Rmd', params = list(data_dir = '<data folder>'))` and RStudio's Knit
   button read the same parameters. They need pandoc, which RStudio includes; from a plain R session on
   Windows, `Sys.setenv(RSTUDIO_PANDOC = "<RStudio's folder>/resources/app/bin/quarto/bin/tools")` first.
5. With `knitr::knit`, or when running the chunks one at a time, the notebook reads `params` from the R
   session when it is defined there, for example `params <- list(data_dir = "<data folder>", out_dir =
   "output", cores = 0)`, and takes each parameter's default otherwise. When the chunks are run one at a
   time, the working directory must be this notebook's folder. `cores` sets the number of processes (0,
   the default: every core).
6. The knit writes `composition.md` (code and printed results) and the output folder (default `output/`
   here): `tables/`, `figures/` and `numbers/`. During the knit, did's bootstrap draws are saved in a new
   folder of the R session's temporary directory, one for each knit, which R removes when the session
   ends; the notebook writes nothing else. A knit that stops in the setup checks or the data-folder
   check writes no output file (the setup may already have made the empty output folders). A knit that
   stops later leaves the files it wrote before the stop, beside any files of an earlier knit, so delete
   the output folder before knitting again. A stopped `knitr::knit` leaves its transcript of the knit so
   far in `composition.md`; a stopped `rmarkdown::render` leaves none.

## Inputs (`data_manifest.csv`; the same file is beside this README)

| File | Bytes | MD5 | What it is |
|---|---:|---|---|
| `composition_panel.rds` | 9,362,680 | `062eac71b982c860ea2281850e896c9d` | one row per entrant child-year in an over-demanded school-grade, 2012-2023: 1,707,775 rows, 10,027 school-grades |
| `composition_schools.rds` | 252,351 | `d536e8b1cdccae6a696e4ccd01acd9b2` | one row per school of the historical comparison: 2,533 schools, 1,020 over-demanded (Table I, Appendix Tables B.1 and B.2) |
| `composition_applicants.rds` | 4,022,529 | `fc4ae77760df7a8935f06b8adb2d202b` | one row per child of the lottery analysis: 316,538 children (Appendix Table B.6) |
| `draws/did/regional/headline.rds` | 61,253 | `8fba99598b055af2420780f23eb437a2` | 9,999 saved reassignments of the rollout (Table II) |
| `draws/did/regional/gpa_robustness_2.rds` to `_6.rds` | 19,257; 22,989; 22,989; 22,989; 22,986 | `c9787f96b13f289545dcbedd9e6d2063`, `cc1f2d7fc419f1d1ad20e7d7320d8755`, `464b1e06f3167adfed2c5c5940443535`, `14d412aca01afa701b4eca3a4cdbd443`, `296f79c9522d64bd65e8f2dbb99da97a` | 2,999 each (Appendix Table B.3, GPA column, rows 2-6) |
| `draws/did/regional/prioritario_robustness_2.rds` to `_6.rds` | 19,265; 22,998; 22,998; 22,998; 22,995 | `50178860510ed5712ebd54e8121a9357`, `d3df74661b4854f97bcd650b79352d82`, `e3fae3f52e7902f763a78b00266c91e2`, `ed74a2de4087a98d5605de3fb017fa3f`, `ac53f1767b77d993409e863d2f5c83d4` | 2,999 each (Appendix Table B.3, low-income column, rows 2-6) |
| `draws/did/regional/pretrends_gpa_z.rds`, `pretrends_sh_prio.rds` | 22,989; 23,045 | `d8458dada6abaff6d23c90ab3496e3ab`, `fcaf1037de00f4da8bd2c865ca765a9d` | 2,999 each (Figure 2's joint tests of the leads) |
| `draws/did/regional/intake_count.rds`, `intake_gpa_coverage.rds` | 22,985; 22,993 | `18d6e5bce437c6874ba43f408334c97d`, `c1582c9a654ba50abf95cf922cd06b51` | 2,999 each (Appendix Tables B.4 and B.7) |
| `draws/did/regional/prior_gpa.rds` | 61,078 | `9a6b78b0a82c594f1bdc07066cb8844b` | 9,999 (Appendix Table B.3's last row) |

The manifest's own MD5 is `48b42014bbba3dba09d543527f6a096b` (written on Windows, its lines end in
CRLF).

## Outputs

The paper's files (`output/tables/`, `output/figures/`), each table and macro file with the first line
`% Generated by composition.Rmd`. The MD5s below are those of the files as written on Windows, whose
lines end in CRLF; written on macOS or Linux, the lines end in LF and the MD5s differ, with the same
text. A PDF's MD5 also changes with its creation date.

| File | Exhibit in the paper | MD5 |
|---|---|---|
| `tables/lottery_od_historical_records.tex` | Table I: the historical academic records of the over-demanded schools and the other SAE schools | `d4ba30ce3a9e08718d47a8ad62437c75` |
| `tables/alloc_headline.tex` | Table II: SAE's effect on entering-class composition | `451d4938b73470bb02a1ca5a9cf33c32` |
| `figures/alloc_event_study.pdf` | Figure 2, prior-year GPA panel | `11ff9c1c5e78adb7beafa8fd3e240340` |
| `figures/alloc_event_study_prio.pdf` | Figure 2, low-income panel | `f88cc9b7d7a3ee3c88969aa82477f026` |
| `tables/lottery_od_historical_macros.tex` | the macros of the access section's text and Appendix Table B.1 (Table I's measures, school counts, the value-added sample) | `927b9ce8eeb702ecf58646e0f0e646bb` |
| `tables/entrant_count_macros.tex` | macros of Appendix Table B.7's estimates (the paper inputs the file; its text prints none of them) | `93271b6de4d7f39445082dbcab79009d` |
| `tables/composition_text_macros.tex` | the rows of `numbers/composition_text_numbers.csv` as macros (the Introduction prints two of them) | `50b75d42b2e20e18b1f6683b36870734` |
| `tables/lottery_od_historical_va_coverage.tex` | Appendix Table B.1: coverage of the historical school value-added estimates | `67034f4709e683bee08062d5aaaa9bcd` |
| `tables/lottery_od_historical_va_checks.tex` | Appendix Table B.2: school value added under alternative specifications | `01b7cc9f08e2ea17d6c45dbe04e41ef5` |
| `tables/appendix14_a1_allocation.tex` | Appendix Table B.3: checks on the change in entrant composition (seven rows) | `d40683da31d34875ff4016b56fda5742` |
| `tables/appendix14_a2_intake.tex` | Appendix Table B.4: the number of entrants and the availability of prior-year grades | `bf2569166812ad327bde159aba3b24fd` |
| `tables/appendix_ninth_grade_composition.tex` | Appendix Table B.5: entering-class composition at ninth-grade entry | `28f5015570a8cc0926e7b559c9626432` |
| `tables/appendix_ninth_grade_profiles.tex` | Appendix Table B.6: entrants and lottery compliers in the supported ninth-grade cohorts | `c5a76cdf744731af1a854d5ba8902b46` |
| `tables/appendix_entrant_counts.tex` | Appendix Table B.7: entrant counts and low-income composition | `2842af3c7149fd03bee534bc1b2ca6fc` |
| `tables/appendix_alloc_event_study.tex` | Appendix Table B.8: entering-class composition in the first two years of SAE (the whole table environment; see the notes) | `a2ee34d0a969be77cab97f35202db4d7` |

The notebook's csvs (`output/numbers/`), at full precision:

| File | What it holds |
|---|---|
| `composition_text_numbers.csv` | every number the access section and its appendix quote in words, one row per number, named as the text's macros (`AllocES...`: the first two SAE-assigned classes and the joint tests of the leads; `Access...`: the rest) |
| `text_claims.csv` | each statement the current text makes in words about these results, with whether each holds with these results |
| `headline.csv` | Table II: estimate, SE, randomization p, pre-adoption mean, cell-years |
| `gpa_robustness.csv`, `prio_robustness_values.csv`, `restricted_results.csv` | Appendix Table B.3: rows 1-6 of the GPA and low-income columns, and the table's last row |
| `observations_estimate_years.csv` | the Observations rows of Table II and Appendix Tables B.3 and B.4, with the counts over every year |
| `intake_checks.csv` | Appendix Table B.4 |
| `event_time_estimates.csv`, `gpa_leads_check.csv` | Figure 2 and Appendix Table B.8: every event-time estimate with its SE and 95% interval; the five GPA leads |
| `ninth_grade_composition.csv`, `ninth_grade_composition_support.csv`, `ninth_grade_gpa_conversion.csv` | Appendix Table B.5, the group-time effects behind it, and the GPA conversion of the lottery applicants by entry year |
| `ninth_grade_profiles.csv` | Appendix Table B.6 |
| `entrant_counts.csv` | Appendix Table B.7, Panels A and B, with each p-value's count and total |
| `historical_records.csv`, `historical_value_added_checks.csv` | Table I and Appendix Table B.2 |

## Run time and memory

3.7 minutes for a knit with `knitr::knit` in a fresh R session on Windows 11 with 20 logical cores (an
Intel Core Ultra 7 265) and 64 GB of memory, every core: one model process runs the 28 did fits and up
to 20 worker processes score the saved reassignments; the knit and its workers held at most 5.9 GB
together. On the same computer, `rmarkdown::render` with no parameters (RStudio's pandoc 3.8.3,
rmarkdown 2.32), from a copy of this folder reading the shared data folder, took 3.6 to 4 minutes and gave
the same table and macro files and the same figures apart from their creation dates.

## Versions (these results)

R 4.5.1; did 2.1.2; data.table 1.18.4; fixest 0.14.2; knitr 1.51; BMisc 1.4.10; DRDID 1.3.0; Matrix
1.7.3; Rcpp 1.1.2; RcppArmadillo 15.4.2.1. Collation `English_United States.utf8`. On a second computer
(Windows 11, 32 logical cores; knitr 1.50, BMisc 1.4.8, DRDID 1.2.2, Rcpp 1.1.0, RcppArmadillo
14.6.0.1), the notebook as it stood before its last changes (to its statements, its checks and its
comments) took 6.3 minutes and 7.3 GB, and gave the same table and macro files, the same figures apart
from their creation dates and the same bootstrap multipliers, which have the MD5 the notebook stores.
On a processor with performance and efficiency cores, such as the Intel Core Ultra 7 265, the standard
errors, interval bounds and group-time estimates in the full-precision csvs of `numbers/` can differ
from one knit to the next by relative amounts below 1e-12 (at most 7.8e-13 against the second
computer's knit); every table and macro file is the same.

## Notes

- Appendix Table B.3 has seven rows: the main estimate, five robustness specifications and the
  restricted sample. Its sixth row, "Reference period $g-2$", is a robustness row: it compares each
  SAE-assigned class with the class of g-2 (did's anticipation of one year) and covers the entering
  classes of 2017-2019.
- Appendix Table B.8 ("Entering-Class Composition in the First Two Years of SAE"):
  `tables/appendix_alloc_event_study.tex` holds the whole table (caption, label, column heads, rows and
  note), which the paper's appendix inputs, with these results: Figure 2's estimates for the first two
  SAE-assigned classes, prior-year GPA in SD with three decimals and the low-income share in percentage
  points with one, the numbers of `AllocESGPAFirstClassDrop`, `AllocESGPASecondClassDrop` (printed with
  a minus sign in the table), `AllocESLowIncomeFirstClassRise` and `AllocESLowIncomeSecondClassRise` in
  `composition_text_numbers.csv`.
- With these results, all 37 statements in `text_claims.csv` hold. When one does not, the knit writes
  this file, names the statement and stops, so that a change in the results shows which sentences move
  with it. By then it has written every table, figure, macro file and csv; its check of the outputs
  does not run.

The project keeps its records of how the data folder and these results were built and checked
separately.
