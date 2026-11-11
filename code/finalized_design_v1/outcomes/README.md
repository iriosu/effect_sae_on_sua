# outcomes.Rmd

The outcomes notebook of *Sought-After Schools and College Access: Evidence from Chile* (Marar, Rios and
Larroucau). It writes the tables of the outcomes section ("Effects of Attending Over-Demanded Schools") and of
its appendix, and the macro file with the numbers their text quotes.

## What it writes

Eight files in the output folder (default: `output/` beside the notebook; in RStudio, the Knit Directory setting
moves it to the project directory or the current working directory when set to one of them), under the names the
paper inputs:

| File | Exhibit |
|---|---|
| `tables/results/lottery_balance.tex` | Table III: lottery balance and enrollment |
| `tables/results/lottery_college.tex` | Table IV: graduation and college outcomes, 2SLS |
| `tables/lottery_sample_construction.tex` | Appendix Table C.1: construction of the ninth-grade lottery sample |
| `tables/results/lottery_characteristics.tex` | Appendix Table C.2: characteristics of lottery compliers |
| `tables/results/lottery_college_offer.tex` | Appendix Table C.3: offer effects on graduation and college outcomes |
| `tables/results/lottery_college_first_choice.tex` | Appendix Table C.4: the outcomes of Table IV using first-choice admission lotteries |
| `tables/lottery_followup.tex` | Appendix Table C.5: scheduled outcomes and additional follow-up by application year |
| `tables/outcomes_text_macros.tex` | macros: the numbers the outcomes section and its appendix quote (the abstract, the Introduction and the mechanisms section print some of them too) |

`knitr::knit` also writes `outcomes.md`, with the code and the printed results; `rmarkdown::render` writes
`outcomes.html`.

## Inputs

The data folder holds five data files and a copy of `data_manifest.csv`, which lists each data file with its
bytes and MD5 (the same manifest is beside the notebook).

- `outcomes_panel.rds`: one row per ninth-grade applicant child of the 2016-2021 processes (316,538 children, 35
  columns): the chance group, the offer, attendance, the five characteristics, the ranked list, the entry school,
  the first-choice design's columns, and the outcomes on time and ever.
- `outcomes_applications.rds`: one row per ninth-grade application involving an over-demanded school (333,791):
  the sample steps of Appendix Table C.1 and each main-stage placement at an over-demanded school with its priority
  category and seat type.
- `outcomes_entrants.rds`: one row per ninth-grade entry at the over-demanded schools under SAE (122,830), for
  column (3) of Appendix Table C.2.
- `outcomes_group.rds`: the 1,020 over-demanded schools.
- `outcomes_note_counts.rds`: the count in Table IV's note, the 356 students DEMRE's registration records list as
  completing secondary school through validation exams or studies recognized abroad.

The default data folder is `<home>/Dropbox/Effect SAE on SUA/data/finalized_design_v1/outcomes`, where `<home>` is
the `USERPROFILE` folder on Windows and `~` elsewhere.

## How to run it

R with fixest, dplyr, tidyr, purrr and knitr. fixest 0.14.2, the version of the paper's numbers; versions before
0.13.0 add a factor n/(n-1) to robust standard errors.

From the notebook's folder:

    Rscript -e "knitr::knit('outcomes.Rmd')"

With another data folder or output folder:

    Rscript -e "params <- list(data_dir = '<data folder>', out_dir = '<output folder>'); knitr::knit('outcomes.Rmd')"

`rmarkdown::render('outcomes.Rmd', params = list(data_dir = '<data folder>', out_dir = '<output folder>'))` works
too; it needs pandoc. On Windows, write the paths inside the quotes with forward slashes. There is no random
element, so there is no seed.

## Versions and run time

On 2026-11-11 this notebook wrote the eight files equal, byte for byte apart from line endings, to the paper's,
under R 4.5.1 with fixest 0.14.2, dplyr 1.2.1, tidyr 1.3.2, purrr 1.2.2 and knitr 1.51 (rmarkdown 2.32 and
RStudio's pandoc 3.10 for `rmarkdown::render`), on Windows 11.

A knit with `knitr::knit` takes about 7 seconds (6.8 to 7.1 seconds in seven runs) on an Intel Core Ultra 7 265
with 64 GB of memory; `rmarkdown::render`, which also writes the HTML, about a second more.
