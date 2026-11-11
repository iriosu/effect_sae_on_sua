# mechanisms.Rmd

The mechanisms notebook of *Sought-After Schools and College Access: Evidence from Chile* (Marar, Rios and
Larroucau). It writes the tables of the mechanisms section (Section VI, "Mechanisms") and of its appendix
(Appendix D), and the two macro files with the numbers their text quotes.

## What it writes

Fourteen files in the output folder (default: `output/` in the folder the notebook is knit in, which is the
notebook's folder for the commands below), under the names the paper inputs:

| File | Exhibit |
|---|---|
| `tables/lottery_graduation_part1.tex` | Table V: high school graduation and grade failure |
| `tables/lottery_graduation_part2.tex` | Table VI: school environment and performance in ninth grade |
| `tables/results/lottery_admission_tracks.tex` and its body `tables/lottery_admission_tracks.tex` | Table VII: college assignment by admission track |
| `tables/results/lottery_application_choices.tex` and its body `tables/lottery_application_choices.tex` | Table VIII: college application choices |
| `tables/results/lottery_admission_scores.tex` and its body `tables/lottery_admission_scores.tex` | Table IX: college admission scores |
| `tables/pace_bea_access.tex` | Table X: PACE and BEA eligibility conditions |
| `tables/appendix_promotion_rules.tex` | Appendix Table D.1: promotion rules in secondary education, school years 2017-2025 |
| `tables/appendix_failing_by_year.tex` | Appendix Table D.2: failing a year in the first four school years |
| `tables/appendix_pace_rules.tex` | Appendix Table D.3: PACE academic requirements by admission process (the whole table, with caption and note) |
| `tables/grade_stringency_facts.tex` | macros: the grade-stringency numbers the mechanisms section and Appendix D quote |
| `tables/mechanisms_text_macros.tex` | macros: the other numbers the mechanisms section and Appendix D quote |

`knitr::knit` also writes `mechanisms.md`, with the code and the printed results; `rmarkdown::render` writes
`mechanisms.html`.

## Inputs

The data folder holds three data files and a copy of `data_manifest.csv`, which lists each data file with its
bytes and MD5 (the same manifest is beside the notebook).

- `mechanisms_panel.rds`: one row per child of the lottery sample of the 2016-2021 processes (186,440 children, 83
  columns; 185,970 have every characteristic): the chance group, the offer, attendance, the five characteristics,
  the entry school, and the outcomes of the tables, on time and ever.
- `mechanisms_schools.rds`: one row per publicly funded school with a 12th grade and school year, 2019-2025 (22,451
  rows): whether the school is one of the over-demanded schools and whether it is on the Ministry's PACE list that
  year.
- `mechanisms_calibration.rds`: one row per tenth grader of 2014-2016 (511,276 rows, 13 columns), with her GPA, her
  SIMCE scores and her school, for the grade-stringency index.

The default data folder is `<home>/Dropbox/Effect SAE on SUA/data/finalized_design_v1/mechanisms`, where `<home>`
is the `USERPROFILE` folder on Windows and `~` elsewhere. On recent macOS, Dropbox often sits in
`~/Library/CloudStorage/Dropbox`; give the data folder there as `data_dir`.

## How to run it

R with fixest, data.table, dplyr, tidyr, purrr and knitr. fixest 0.14.2, the version of the paper's numbers;
versions before 0.13.0 add a factor n/(n-1) to robust standard errors.

From the notebook's folder:

    Rscript -e "knitr::knit('mechanisms.Rmd')"

With another data folder or output folder:

    Rscript -e "params <- list(data_dir = '<data folder>', out_dir = '<output folder>'); knitr::knit('mechanisms.Rmd')"

`rmarkdown::render('mechanisms.Rmd', params = list(data_dir = '<data folder>', out_dir = '<output folder>'))`
works too, in a fresh R session; it needs pandoc. On Windows, write the paths inside the quotes with forward
slashes. There is no random element, so there is no seed.

## Versions and run time

On 2026-11-11 this notebook wrote the fourteen files equal, byte for byte apart from line endings, to the paper's,
under R 4.5.1 with fixest 0.14.2, data.table 1.18.4, dplyr 1.2.1, tidyr 1.3.2, purrr 1.2.2 and knitr 1.51
(rmarkdown 2.32 and RStudio's pandoc 3.10 for `rmarkdown::render`), on Windows 11.

A knit with `knitr::knit` takes about 17 seconds (15.7 to 17.9 seconds in four runs) on an Intel Core Ultra 7 265
with 64 GB of memory; about half of it is the five fits of the grade-stringency index.
