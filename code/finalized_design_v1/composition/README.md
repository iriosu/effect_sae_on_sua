# composition.Rmd

The composition notebook of *Sought-After Schools and College Access: Evidence from Chile* (Marar, Rios and
Larroucau). It writes the tables and figures of the access section ("Centralized Assignment and
Access to Over-Demanded Schools") and of its appendix, and the macro files with the numbers their text quotes.

## What it writes

Fourteen files in the output folder (default: `output/` beside the notebook), under the names the paper inputs:

| File | Exhibit |
|---|---|
| `tables/lottery_od_historical_records.tex` | Table I: the over-demanded schools and the other SAE schools before SAE |
| `tables/alloc_headline.tex` | Table II: SAE's effect on entrants' prior-year GPA and on the low-income share |
| `figures/alloc_event_study.pdf`, `figures/alloc_event_study_prio.pdf` | Figure 2: the event studies of the two outcomes |
| `tables/lottery_od_historical_va_coverage.tex` | Appendix Table B.1: coverage of the value-added estimates |
| `tables/lottery_od_historical_va_checks.tex` | Appendix Table B.2: school value added under other specifications |
| `tables/appendix14_a1_allocation.tex` | Appendix Table B.3: checks on the change in entrant composition |
| `tables/appendix14_a2_intake.tex` | Appendix Table B.4: the number of entrants and the share with prior-year grades |
| `tables/appendix_ninth_grade_composition.tex` | Appendix Table B.5: entering-class composition at ninth-grade entry |
| `tables/appendix_entrant_counts.tex` | Appendix Table B.6: entrant counts by low-income status |
| `tables/appendix_alloc_event_study.tex` | Appendix Table B.7: the estimates of Figure 2 with their SE |
| `tables/lottery_od_historical_macros.tex` | macros: Table I's measures, the school counts and the value-added sample (Appendix Table B.1 prints six of them) |
| `tables/entrant_count_macros.tex` | macros: Appendix Table B.6's nine count estimates, and the low-income effect as a percentage of its pre-adoption mean in the entry grades and in ninth grade |
| `tables/composition_text_macros.tex` | macros: the numbers the access section and its appendix quote in words |

`knitr::knit` also writes `composition.md`, with the code and the printed results; `rmarkdown::render` writes
`composition.html`.

## Inputs

The notebook reads 18 data files from the data folder; `data_manifest.csv`, beside the notebook, lists each with
its bytes and MD5.

- `composition_panel.rds`: one row per entrant child-year in an over-demanded school-grade, academic years
  2012-2023 (1,707,775 rows; 10,027 school-grades).
- `composition_schools.rds`: one row per school of Table I's comparison (2,533 schools; 1,020 of them
  over-demanded).
- `draws/did/regional/`: 16 files of saved reassignments of SAE's rollout across the 16 regions, 9,999 or 2,999
  each. The randomization tests behind the stars score them.

The default data folder is `<home>/Dropbox/Effect SAE on SUA/data/finalized_design_v1/composition`, where
`<home>` is `USERPROFILE` on Windows and the home folder elsewhere.

## How to run it

R 4.5.1 with did 2.1.2, data.table and knitr. did must be 2.1.2 exactly, since its bootstrap standard errors
depend on the version: `remotes::install_version("did", version = "2.1.2")`.

From the notebook's folder:

    Rscript -e "knitr::knit('composition.Rmd')"

With another data folder or output folder:

    Rscript -e "params <- list(data_dir = '<data folder>', out_dir = '<output folder>'); knitr::knit('composition.Rmd')"

`rmarkdown::render('composition.Rmd', params = list(data_dir = '<data folder>'))` works too; it needs pandoc.
On Windows, write the paths inside the quotes with forward slashes. `cores` sets the number of worker
processes that score the saved reassignments (0, the default: every core).

## Versions and run time

The paper's files were written under R 4.5.1 with did 2.1.2, data.table 1.18.4, knitr 1.51, BMisc 1.4.10, DRDID
1.3.0, Matrix 1.7.3, Rcpp 1.1.2 and RcppArmadillo 15.4.2.1 (rmarkdown 2.32 for `rmarkdown::render`), on
Windows 11.

A knit with `knitr::knit` took 3.1 minutes on a computer with 20 logical cores (an Intel Core Ultra 7 265) and
64 GB of memory, using every core. The R process and its 20 workers held about 5.6 GB together at the measured peak,
about 0.27 GB for each worker; on a computer with less memory, a smaller `cores` lowers it.
