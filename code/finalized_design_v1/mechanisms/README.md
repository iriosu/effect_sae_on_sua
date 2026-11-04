# mechanisms.Rmd

The notebook of the paper's mechanisms section and its appendix: the records that explain why attending an over-demanded school lowers
graduation and college assignment (failing a year, the school a student attends, ninth-grade performance, the grading of her school, the
college seat by admission track, the first application list, the admission scores, PACE and BEA). It compares children with the same
chance of an offer at one of the paper's 1,020 over-demanded schools (in each SAE process of 2016-2021 in which a school offered
ninth-grade seats, its effective demand exceeded them in every one of 2,000 reruns of SAE's main stage; the paper's rules on schools that
switch funding status and on entrants apply), with the 2SLS of the paper's Table IV: attendance at an over-demanded school instrumented
by the offer, chance-group and application-year fixed effects, the five characteristics as controls, heteroskedasticity-robust standard
errors, stars at 10, 5 and 1%. Run, it writes every table file of the section and its appendix exactly as the paper inputs them, and the
estimates behind them, with the other numbers the text quotes (apart from the appendix's three counts of 2025 graduates, whose source the
section on outputs gives), at full precision. It also writes the macro file of the numbers the section's text and its appendix's text print
(the text's Table IV numbers are the outcomes notebook's macros, and its grade-stringency numbers come from `grade_stringency_facts.tex`,
which this notebook also writes), and checks each statement the paper's text makes about these results. It reads its data folder and the `data_manifest.csv` beside
it, and has no random step.

## How to run it

From this folder (or with the notebook's full path in place of `"mechanisms.Rmd"`), in R 4.5.1 with the packages below (fixest 0.14.2 or
later: earlier versions compute a different robust standard error, and the notebook stops on them; a later version gets a message):

```r
rmarkdown::render("mechanisms.Rmd", params = list(data_dir = "<the mechanisms data folder>"))
```

* `data_dir` is the folder holding the three data files. Its default is the shared data folder,
  `<home>/Dropbox/Effect SAE on SUA/data/finalized_design_v1/mechanisms`, where `<home>` is `USERPROFILE` on Windows and `~` elsewhere.
  When Dropbox sits elsewhere (on recent macOS, `~/Library/CloudStorage/Dropbox`), give the folder's full path as `data_dir`; on
  Windows, a `~` typed in `data_dir` stands for R's home folder (usually Documents), so give the full path there too.
* `out_dir` is where the tables go; its default is `output` beside the notebook.
* A relative `data_dir` or `out_dir`, and `data_manifest.csv`, are taken from the notebook's own folder, whatever folder the chunks run in:
  RStudio's Knit Directory setting (rmarkdown::render's `knit_root_dir`) changes neither what the notebook reads nor where it writes.
  When the chunks are run one by one outside a knit, the working directory must be the notebook's folder.
* When running the chunks by hand or with `knitr::knit()`, first define `params` in the R session, for example
  `params <- list(data_dir = "<the mechanisms data folder>", out_dir = "output")`.
* `rmarkdown::render()` needs pandoc. RStudio includes it (the Knit button uses it); from a plain R session, point rmarkdown to it with
  `Sys.setenv(RSTUDIO_PANDOC = "<RStudio's folder>/resources/app/bin/quarto/bin/tools")` on Windows. Without pandoc, knit with knitr and
  the two parameters in a list:

  ```r
  params <- list(data_dir = "<the mechanisms data folder>", out_dir = "output")
  knitr::knit("mechanisms.Rmd", output = "mechanisms.md")
  ```

At the start the notebook stops with a plain message when `params` is not defined, when the notebook's folder cannot be found (chunks run
by hand outside it), when fixest is older than 0.14.2, when `data_manifest.csv` is missing beside the notebook or does not list the three
data files once each, when the data folder or any of its files is missing, when `data_manifest.csv` beside the notebook and the data folder's
own `data_manifest.csv` differ, or when any input's bytes or MD5 differ from the manifest. Later it stops when a regression drops a
regressor or its outcome is not the row's, when the panel does not hold one row
per child with its design's columns complete (the offer and attendance 0/1, each chance group a whole number from 0 to 100, the
application years 2016-2021), when a 0/1 flag is not complete or does not take both values, when a row of Table V's Panels A or B is not 0
for a student who graduated within the horizon, when a row of Table IX is not 0 for a student who did not, when a table's panel has more than one N or a row does not use every student
who has it, when the four admission tracks do not add up to the college seat, when a gender-quota first assignment comes before the 2024
admission process, when the application score's three parts do not add up to it or the exams part to its three scores, when a
school index joined to the children differs from its lookup, when the schools file's two flags (over-demanded, on the PACE list) are not
logical, when a grade-stringency calibration student is in the lottery sample, when, on
the data of record, Table V's graduation row or Table VI's total differs, on time or ever, from Table IV's estimate and robust standard error
of record (the outcomes notebook's), when a table or macro file would print a missing or infinite number, when a statement of the text does
not hold, or when this knit did not write one of its outputs. It also stops on its other checks of the data, each with a message; on the
data of record none of them fires. `rmarkdown::render()` itself stops when `params` already exists in the session (after a `knitr::knit()`
run, for example), so render in a fresh session.

The four estimates and robust standard errors that Table V's graduation row and Table VI's total share with Table IV, on time and ever,
are typed into the chunk `admission-tracks` from the outcomes notebook's `numbers/outcomes_estimates.csv` (table IV, rows GRAD_OT,
GRAD_EVER, ASSIGNED_OT and ASSIGNED_EVER). The check runs only on the panel of record (the MD5 the manifest lists) and stops the knit when
a value differs by more than 1e-12, as a later fixest that moved these standard errors would; on another panel it prints a message and goes
on. When Table IV is estimated again on new data, these values change together with this data folder.

`numbers/mechanisms_text_claims.csv` lists each statement the paper's text makes about these results (a sign, a significance call, a
comparison), with whether it holds. When one does not, the knit writes this file, names the statement and stops, so that a change in the
results shows which sentences move with it. By then it has written the tables, `numbers/mechanisms_estimates.csv`, the macro file and
`numbers/mechanisms_text_numbers.csv`; its check of the outputs does not run. Copy files into the paper only from a knit that ran to its
end: such a knit ends with the table of the files it wrote and their MD5s.

## Inputs

The data folder holds three files and its own copy of `data_manifest.csv` (the one beside this README, MD5
af429a5e6be4b8171faed5281028bfcc). MRUN is the student ID.

| File | MD5 | Bytes | One row per | Rows x columns |
|---|---|---|---|---|
| mechanisms_panel.rds | 8d1b6996f18f2d678b543c4428567709 | 21,527,646 | child of the lottery sample, in MRUN order | 186,440 x 83 |
| mechanisms_schools.rds | 3b0f495bbd8ca638a777586d07fa8454 | 20,166 | publicly funded school with a 12th grade and school year, 2019-2025 | 22,451 x 4 |
| mechanisms_calibration.rds | 8549681a09e30636dcdd7cc1cc5b332c | 5,392,130 | grade-stringency calibration candidate: a tenth grader of 2014-2016 with a GPA and both SIMCE scores | 511,276 x 13 |

`mechanisms_panel.rds`, by group of columns (on time and ever are `_OT` and `_EVER`):

* the design: MRUN, YEAR (application year), CHANCE_GROUP, OFFER, D_OD (attendance at an over-demanded school), ENTRY_RBD (the school
  attended in April of the entry year), and the controls GPA8_Z, ES_MUJER, PRIORITARIO, ALTO, ORIGIN_OD; 185,970 children have every control;
* Table V and Table D.2: GRAD (graduation), FAILNG, WDNG, OTHNG (the reasons for not graduating), PB_G, PB_A, PB_U (what the failed
  years show), CLASS_SIZE, STUDENT_TEACHER, DIST_HOME_KM, FAILED_9, RANK9, START_RANK, FAIL_YEAR_1 to FAIL_YEAR_4 and FAIL_YEAR_ANY;
* Table VIII's admission scores: SCORE_LM, SCORE_NEM, SCORE_RANKING, on time and ever, each among the children who have it, and
  SCORE_NEM_RANKING_EVER_OFFICIAL (1 when both NEM and Ranking ever are DEMRE's official scores, 0 when computed from school records,
  missing without both);
* the first regular application list (Tables VII and VIII): LIST_PROGRAMS, LIST_MEAN_CUTOFF, LIST_MAX_CUTOFF, LIST_WEIGHT_NEM_RANKING,
  LIST_SCORE and its parts (LIST_SCORE_NEM, LIST_SCORE_RANKING, LIST_SCORE_EXAMS, LIST_SCORE_READING, LIST_SCORE_MATH,
  LIST_SCORE_HIST_SCIENCE), LIST_MISSED, LIST_REACHED, on time and ever, missing without a list;
* Table IX: PACE_SCHOOL, PACE_GRADE, PACE_BOTH, BEA_GRADE, on time and ever;
* Table VI: ASSIGNED (Table IV's college seat), on time and ever, and each child's first recorded college assignment in the admission
  processes 2018-2026, FIRST_ASSIGNED_PROCESS and FIRST_ASSIGNED_TRACK (REG, BEA, PACE or GENERO; missing without one);
* the appendix's check of Table IX's rows: PACE_SEAT_EVER (a PACE seat in DEMRE's selections in any admission process after the year of
  the graduation record her row reads) and BEA_SEAT_EVER (a BEA seat in the process right after that year); the record is her regular
  graduation record, or her adult-education record on the adult route; 0 without one.

The scores, list, PACE-BEA, first-assignment and seat columns are missing for the 470 children without every control.

`mechanisms_schools.rds`: YEAR, RBD, OVER_DEMANDED (one of the paper's over-demanded schools), ON_PACE_LIST (on the Ministry's list of
PACE schools that year). 1,019 of the 1,020 over-demanded schools appear in the file; the records give the other (RBD 12735) no
enrollment and no funding status in 2019-2025.

`mechanisms_calibration.rds`: MRUN, AGNO, RBD, math and reading (SIMCE, tenth grade), female, COD_ENSE, COD_GRADO, COD_DEPE, PROM_GRAL
(the year's GPA), SIT_FIN_R (P promoted, R failed), and two school columns: EVER_PRIVATE (the school appears as fee-paying private,
COD_DEPE 4, in some year 2012-2025 of the year-end records or the school directory) and OVER_DEMANDED.

The project keeps its records of how the data folder and these results were built and checked separately.

## Outputs and the paper's exhibits

Under `out_dir`, in the layout of the paper's `tables/` folder. Each table file starts with the line `% Generated by mechanisms.Rmd`.
The MD5s below are those of the files as written on Windows, whose lines end in CRLF; written on macOS or Linux, the lines end in LF and
the MD5s differ: compare the table and macro files and the two text csvs there with their line endings normalized.
`numbers/mechanisms_estimates.csv` holds every number at 17 significant digits, whose last digits can differ under another processor,
compiler or linear-algebra library, so compare it number by number (relative differences below about 1e-10).

| Exhibit | File | MD5 of the run of record |
|---|---|---|
| Table V, graduation, Panels A and B | tables/lottery_graduation_part1.tex | d65a65e2af1895fa82303d7e1d9e8f6f |
| Table V (continued), Panels C (with the grade-stringency row) and D | tables/lottery_graduation_part2.tex | 6c4a4efd6b8509f75d8dc53d90efd223 |
| The text's grade-stringency numbers (`\GSEffect` and the other macros) | tables/grade_stringency_facts.tex | e0ae776810d2eae15277c2d313508f3f |
| Table VI, the college seat by admission track | tables/results/lottery_admission_tracks.tex (body tables/lottery_admission_tracks.tex) | 84c9d6526217d760f7fff72d8c61bf4b (body 5689f7180127e7b5ce76230d81eba465) |
| Table VII, the application choices | tables/results/lottery_application_choices.tex (body tables/lottery_application_choices.tex) | 0ed6868707231d791e897dbd10400f33 (body d451392a034e386c5661e57cf0b8f6ac) |
| Table VIII, the admission scores | tables/results/lottery_admission_scores.tex (body tables/lottery_admission_scores.tex) | 65130733bcd32f2f446bc310f41fef8b (body dcf2a6e413b4197ccb7f920824881ad8) |
| Table IX, PACE and BEA | tables/pace_bea_access.tex | 209b5aa31ff79ead54a2352dfe39285b |
| Table D.1, the promotion rules | tables/appendix_promotion_rules.tex | 7e8fb5de6fd1431d1c551521fe796acf |
| Table D.2, failing a year in each of the first four school years | tables/appendix_failing_by_year.tex | 2ed9b84eaaae1088d05ee1f01ec04bed |
| Table D.3, PACE's academic rules (the whole table environment) | tables/appendix_pace_rules.tex | 8600d2e39e70e47555ee0d4c0685bc9b |
| Every estimate at full precision, and the numbers of the text | numbers/mechanisms_estimates.csv | 37c37c9939963be77dbb3799db8645dd |
| The numbers of numbers/mechanisms_text_numbers.csv as the LaTeX macros the paper's text prints (effects in absolute value where the text gives the direction in words, the withdrawal estimate, quoted with no direction, with its sign; shares as plain numbers, the text adds the percent sign) | tables/mechanisms_text_macros.tex | 68d0823f96070688df1ebe69e31bc45e |
| Each number the mechanisms section (sections/6_mechanisms.tex) and its appendix (sections/9_appendix_mechanisms.tex) quote, other than the text's Table IV numbers (the outcomes notebook's macros), the grade-stringency numbers (`grade_stringency_facts.tex`) and the appendix's three counts of 2025 graduates; one row per number: its macro, its value and what it is | numbers/mechanisms_text_numbers.csv | c9665fa3ef319868bdd7e70745443ab5 |
| Each statement the abstract, the Introduction, the mechanisms section, its appendix and the conclusion make about these results, with whether it holds | numbers/mechanisms_text_claims.csv | 740f91b6de2f377b38b8437c53fce831 |

The csv (120 rows) has one row per outcome of a table (`table` is the file the row is printed in, `column` its panel): the estimate, its
SE, p-value and N, the students without an offer among them (n0) and their mean. Its rows under `table = text` are the numbers the text
and notes quote:

* each year's share of schools on the PACE list (over-demanded and other schools);
* the shares of Table IV's children with an exam score and with grade-based scores on time;
* the count of students whose NEM and Ranking ever are official;
* the share (%) of the students of Table V's Panel D who fail ninth grade that end it in the bottom fifth of their class (`est`), over
  those who fail (`n`);
* for the appendix's check of Table IX, the students holding a PACE seat ever (PACE_SEAT_EVER) and those of them meeting both PACE
  conditions (PACE_SEAT_EVER_MEETING_BOTH), and the students holding a BEA seat ever (BEA_SEAT_EVER) and those of them meeting BEA's grade
  rule (BEA_SEAT_EVER_MEETING_GRADE) (`est`, each over the group it is counted in, `n`);
* the eight numbers the text works out from two estimates of the tables (`est` alone): the effects on class size and on students per
  teacher over their means without an offer, in % (CLASS_SIZE_EFFECT_OVER_MEAN, STUDENT_TEACHER_EFFECT_OVER_MEAN); how much lower the
  percentile at the start of ninth grade is, the change's effect less the end-of-year effect, in percentile points
  (START_PERCENTILE_LOWER); the declines on time in meeting PACE's grade rule, BEA's grade rule and both PACE conditions over their means
  without an offer, in % (PACE_GRADE_OT_DECLINE, BEA_GRADE_OT_DECLINE, PACE_BOTH_OT_DECLINE), BEA's also as a fraction
  (BEA_GRADE_OT_DECLINE_FRACTION); and that fraction times the BEA assignment rate on time without an offer (Table VI's BEA row), in
  percentage points (BEA_ASSIGNED_OT_IMPLIED_DECLINE). They are computed from the estimates at full precision; the same arithmetic on
  the tables' rounded cells can differ from them in the last digit.

The rows under `grade_stringency_facts` hold the robustness estimates, the effect of the offer on whether the index is observed, and the
calibration counts.

The same appendix sentence also counts the 2025 graduates of every school with a decision of the Ministry (MINEDUC) on PACE's two
conditions for the 2026 admission process: 14,018 with a decision, 13,728 whose conditions the records settle, 13,642 agreeing with the
decision. Those counts cover every school's graduates, so they do not depend on the lottery sample or on the over-demanded schools, and
they need every school's decisions, which this data folder does not carry. They are counted outside this package, from the national
graduates, the Ministry's 2026 decisions and each graduate's PACE conditions.

How the constructions are made:

* Table VI counts each assigned student once, under the track of her first recorded assignment within the horizon (regular, BEA, PACE
  or the gender quota), so the four tracks add up to Table IV's college seat.
* The grade-stringency row gives each child the historical grading index of the school she attends: the school fixed effects of a
  regression of tenth-grade GPA in 2014-2016 on sex, cohort and splines of the SIMCE scores, centered, with the sign reversed and shrunk
  by an empirical Bayes weight, on publicly funded schools never fee-paying in 2012-2025. The notebook's grade-stringency section gives
  the details and the robustness numbers.
* Tables VII and VIII are assembled from two sets of estimates, the admission scores and the first regular application list. Table VII
  takes the list's Panel A; Table VIII takes the scores and the application score with its parts, each with its N, and keeps the listed
  cutoffs as comment lines.

## Runtime, R and packages

20 to 30 seconds rendered by `rmarkdown::render()` with pandoc in a fresh R session on an Intel Core Ultra 7 265 (64 GB of memory,
Windows 11).

R 4.5.1; fixest 0.14.2 (the notebook requires 0.14.2 or later); data.table 1.18.4; dplyr 1.2.1; tidyr 1.3.2; purrr 1.2.2; tibble 3.3.1;
knitr 1.51; rmarkdown 2.32; pandoc 3.8.3 (RStudio's). The notebook as it stood on 2026-11-01 gave the same files on this computer as on an
AMD Ryzen 9 5950X with dplyr 1.1.4, tidyr 1.3.1, purrr 1.0.4, tibble 3.3.0, knitr 1.50, rmarkdown 2.29 and pandoc 3.6.3, byte for byte.
The notebook stops on a fixest older than 0.14.2, which computes a different robust standard error, and prints a message naming a later
one; it prints a message when R is not 4.5.1. The notebook also calls the splines, stats, tools and utils packages that come with R.
