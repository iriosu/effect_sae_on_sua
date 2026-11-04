# outcomes.Rmd

`outcomes.Rmd` writes every table of the paper's outcomes section and of its appendix: the effect of attending an over-demanded
school on high-school graduation and college outcomes, from SAE's ninth-grade lotteries 2016-2021 (the paper's 1,020 over-demanded
schools). It compares children with the same chance of an offer at an over-demanded school, some offered and some not
(each child's chance comes from one million reruns of SAE's main stage), and estimates by 2SLS with the offer as the instrument for
attendance, chance-group and application-year fixed effects, heteroskedasticity-robust standard errors and stars at 10, 5 and 1%. It
reads only the five files of its data folder and the two copies of `data_manifest.csv`, and writes the table files at the paths the paper
inputs, the macro file of the numbers the text quotes, and three csv files of numbers. There is no random element, so there is no seed.

## How to run it

From this folder (or with the notebook's full path in place of `"outcomes.Rmd"`), in R 4.5.1 with the packages below (fixest 0.14.2 or
later: earlier versions compute a different robust standard error, and the notebook stops on them; a later version gets a message):

```r
rmarkdown::render("outcomes.Rmd")
```

The defaults read the data folder `<home>/Dropbox/Effect SAE on SUA/data/finalized_design_v1/outcomes`, where `<home>` is
`USERPROFILE` on Windows and `~` elsewhere, and write the outputs into `output/` next to the notebook. When Dropbox sits elsewhere (on
recent macOS, `~/Library/CloudStorage/Dropbox`), give the data folder's full path as `data_dir`; on Windows, a `~` typed in
`data_dir` stands for R's home folder (usually Documents), so give the full path there too. Both are parameters:

```r
rmarkdown::render("outcomes.Rmd", params = list(data_dir = "<the data folder>", out_dir = "<the output folder>"))
```

A relative `data_dir` or `out_dir`, and `data_manifest.csv`, are taken from the notebook's own folder, whatever folder the chunks run in:
RStudio's Knit Directory setting (rmarkdown::render's `knit_root_dir`) changes neither what the notebook reads nor where it writes.
When the chunks are run one by one outside a knit, the working directory must be the notebook's folder.

Both commands need pandoc, which RStudio supplies. With pandoc, `rmarkdown::render()` also writes the knitted document, `outcomes.html`,
beside the notebook, as RStudio's Knit button (or Knit with Parameters) does. Without pandoc, add `run_pandoc = FALSE`: the knit writes
every output file and leaves the knitted markdown `outcomes.knit.md` beside the notebook.

When running the chunks by hand or with `knitr::knit()`, first define `params` in the R session, for example
`params <- list(data_dir = "<the data folder>", out_dir = "output")`. `rmarkdown::render()` stops when `params` already exists in the session,
so run it in a fresh session.

At the start the notebook stops with a plain message when `params` is not defined, when the notebook's folder cannot be found (chunks run
by hand outside it), when fixest is older than 0.14.2, when `data_manifest.csv` is missing beside the notebook, when the data folder or any
of its files is missing, when `data_manifest.csv` beside the notebook and the data folder's own `data_manifest.csv` differ, or when any
input's bytes or MD5 differ from the manifest. Later it stops when the panel does not hold one row per child with its design's columns
complete, when the offer or attendance is not what the text defines (a main-stage placement at, and entry-year enrollment at, one of the
over-demanded schools), when a chance group of Table III or of Table IV's sample does not hold a child with an offer and one without, when
a child outside the lottery sample is in a chance group other than 0 or 100, when the completers of Table IV's note do not all count as not
graduated, when a row of Tables III, IV, C.3, C.4 or C.5 does not cover the children of its N row or a row of Table C.2 what its note says
it covers, when an outcome on an estimation sample is not a complete 0/1 flag or the two rows under graduation do not divide it, when a
Table IV estimate is not its offer effect divided by the first stage, when, on the data of record, Table IV's and Table C.4's first robust
standard errors, Table III's three joint F statistics or Table C.2's first standard error differ from the values of record (a later fixest
with other defaults would move them), when a table or macro file would print a missing or infinite number, when a statement of the text
does not hold, or when this knit did not write one of its outputs. It also stops on its other checks of the data, each with a message; on
the data of record none of them fires.

`numbers/outcomes_text_claims.csv` lists each statement the abstract, the Introduction, the outcomes section, its appendix, the mechanisms
section's opening and the conclusion make about these results (a sign, a significance call, a comparison, a count) with whether it holds. When one does not, the knit writes this file, names the statement and stops, so that a change in the results shows which
sentences move with it. By then it has written the tables, the macro file and `numbers/outcomes_text_numbers.csv`; it has not written
`numbers/outcomes_estimates.csv`, and in an output folder used before, the earlier knit's copy of that file stays.

## Inputs

The data folder holds these five files and `data_manifest.csv` (MD5 3224c6d62de615f30587218337440ea5, the file as written on Windows,
whose lines end in CRLF), which lists them; the same file sits beside the notebook, and the notebook compares the two by their contents.

| File | Bytes | MD5 | What it holds |
|---|---|---|---|
| outcomes_panel.rds | 5,956,209 | 2402d24e51204816f0346855a616a38e | one row per ninth-grade applicant child, 316,538 children, 35 columns: the chance group, the offer, attendance, the five characteristics, the ranked list, the entry school, the first-choice design's columns and the outcomes on time and ever |
| outcomes_applications.rds | 1,573,816 | f753f40c44ff91c3946f217ba5f400fb | one row per application of the population, 333,791: the sample steps and each main-stage placement at an over-demanded school with its priority category and seat type |
| outcomes_entrants.rds | 697,117 | 71a0d79af5587d499488927698da9692 | one row per ninth-grade entry at the over-demanded schools under SAE, 122,830 |
| outcomes_group.rds | 2,570 | 16e3f75879c90385ffa47e7a7644039b | the paper's 1,020 over-demanded schools |
| outcomes_note_counts.rds | 191 | cead7b5f05c62ac4c708eb981d03f47d | Table IV's note: the students DEMRE's registration records list as completing secondary school through validation exams or studies recognized from abroad (356) |

The panel carries only the columns the notebook reads.

The two enrollment rows classify each child by her first higher-education record after the application year: an enrollment in
DEMRE's file D puts her in SUA; any higher-education registry row without a matching DEMRE enrollment, coded or uncoded, puts her
outside SUA; the earlier record decides, and a same-year pair counts in SUA. The notebook adds "Enrolled anywhere", being in either
row, and checks that each child is in at most one.

## Outputs

Under `out_dir`, in the paper's folder layout. Each table file begins with the line `% Generated by outcomes.Rmd`. The MD5s are
those of the run of record, of the files as written on Windows, whose lines end in CRLF. Written on macOS or Linux, the lines end in LF and
the MD5s differ: compare the table and macro files and the two text csvs there with their line endings normalized. The runs on record are
on Windows; `numbers/outcomes_estimates.csv` holds every number at 17 significant digits, whose last digits can differ under another
processor, compiler or linear-algebra library, so compare it number by number (relative differences below about 1e-10).

| File | Exhibit | MD5 |
|---|---|---|
| tables/results/lottery_balance.tex | Table III, lottery balance and enrollment | ece83c43a1216c9c55e77853d9127420 |
| tables/results/lottery_college.tex | Table IV, graduation and college outcomes (2SLS) | 825afc1ac2ad7383f422ae68a7c52811 |
| tables/lottery_sample_construction.tex | Table C.1, the lottery sample's construction | 21cd8bf17d801690cdc6c6b8bfe23f80 |
| tables/results/lottery_characteristics.tex | Table C.2, the characteristics of the students whose attendance depends on the offer | fe83342631ce9c8880200e97a2622c59 |
| tables/complier_alternatives.tex | Table C.3, their entry-year destinations without an offer | f4ad8660a6d1c0972b0dd62bb38f43af |
| tables/results/lottery_college_offer.tex | Table C.4, the offer's effect (reduced form) | de9a2e2bde4c89d887b538b3f3e1ac8c |
| tables/results/lottery_college_first_choice.tex | Table C.5, first-choice admission lotteries (2SLS) | 0940ed4c8857f6c2c32644a65f0f28d7 |
| tables/lottery_followup.tex | Table C.6, the outcome horizons by application year | 953645e7f7f039093ee2af65e1714f62 |
| tables/outcomes_text_macros.tex | the numbers of numbers/outcomes_text_numbers.csv as the LaTeX macros the paper's text prints; shares are plain numbers, the text adds the percent sign; the years stay typed | eaa703b0ab677ab421a4f3b699fd51ca |
| numbers/outcomes_estimates.csv | every estimate of the tables at 17 significant digits, and the counts of the notes and the text | a4568c40a19769850f90dc12b80e7116 |
| numbers/outcomes_text_numbers.csv | each number the outcomes section (sections/5_outcomes.tex) and its appendix (sections/9_appendix_outcomes.tex) quote, one row per number: its macro, its value and what it is (the abstract, the Introduction and the mechanisms section print some of them too) | 73bee48a65580d88eed83eba3b8f53e6 |
| numbers/outcomes_text_claims.csv | each statement the abstract, the Introduction, the outcomes section, its appendix, the mechanisms section's opening and the conclusion make about these results, with whether it holds | b0add8a25cd66defe271522dabe5b9ff |

The notebook writes nothing else; with pandoc, `rmarkdown::render()` adds the knitted document `outcomes.html` beside the notebook. To
put a run in the paper, copy the files under `tables/` into the paper's `tables/` folder at the same relative paths; the paper's text prints
the macros and inputs the table files, so its numbers follow. Copy only from a knit that ran to its end: such a knit ends with the table of
the 12 files it wrote.

## Runtime

8.4 seconds for the whole knit in a fresh R session (`rmarkdown::render()` with `run_pandoc = FALSE`) on an Intel Core Ultra 7 265 (64 GB
of memory, Windows 11; 2026-11-02).

## R and packages

R 4.5.1; fixest 0.14.2, dplyr 1.2.1, tidyr 1.3.2, purrr 1.2.2 (attached); knitr 1.51, rmarkdown 2.32 (loaded); pandoc 3.8.3 (RStudio's) for
`outcomes.html`. The notebook as it stood on 2026-11-01 gave the same files on the Intel Core Ultra 7 265 as on an AMD Ryzen 9 5950X with dplyr
1.1.4, tidyr 1.3.1, purrr 1.0.4, knitr 1.50, rmarkdown 2.29 and pandoc 3.6.3, byte for byte. The notebook requires fixest 0.14.2 or later: it
stops on an earlier version, which computes a different robust standard error, and prints a message naming a later one; on the data of record
it stops if Table IV's and Table C.4's first robust standard errors, Table III's three joint F statistics or Table C.2's first standard error
differ from the values of record (a later fixest with other defaults would move them). It prints a message when R is not 4.5.1.
