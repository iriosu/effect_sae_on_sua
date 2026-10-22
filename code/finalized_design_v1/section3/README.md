# Section 3: the reviewers' notebook

`Section3_IV.Rmd` reads the two panels in the shared data folder (see Panels below) and writes to `output/` the six table files the paper inputs: Tables 2, 3
and 4 of Section 3 (`lottery_balance.tex`, `lottery_college.tex`, `lottery_scores.tex`) and Appendix Table A3, cited in the
Introduction (`lottery_od_historical_records.tex`, `lottery_od_historical_va_checks.tex`, and `lottery_od_historical_macros.tex`,
the macros through which the abstract, the Introduction and the appendix quote Table A3's numbers). It also writes
`output/Section3_IV.md`, the code with its printed results.

## Numbers in Section 3's text

The notebook prints these numbers of the text:

| Subsection | Numbers |
|---|---|
| 3.3 | 1,045 over-demanded schools; 304,547 children; 176,321 in the lottery sample and 175,869 of them with every characteristic; 128,226 with a chance of 0 or 1 |
| 3.6 | 63,211 children with an offer and 113,110 without; 1.2% with no enrollment record in the entry year |
| 3.7 | the on-time effects as shares of the non-offered means: 3.2%, 3.5%, 7.4% and 9.1% |
| 3.7, the footnote to Table 4 | -0.16 and -0.55 pp; the two joint tests; the one statistically significant difference of the sixteen, 0.011 SD; the trim of about 5% of the sample and its effects of 0.032, -0.181 and -0.228 SD |

The other results the text quotes (3.4's 101 chance groups; 3.6's 0.380, 19.36, 62.56, 62.57 and 14.39; the effects in 3.7)
are cells and notes of Tables 2, 3 and 4.

Not reproduced yet; each needs data outside the two panels:

| Subsection | Numbers | Data needed |
|---|---|---|
| 3.1 | 37% | Section 2's school-grades by region (Section 2's notebook prints it) |
| 3.3 | 321,463 and 315,946 | the 9th-grade applications of the 2016-2021 processes before the sample steps |
| 3.3 | 72.1% and 891 | every main-stage 9th-grade placement at the 1,045 schools in those processes, with the placed child's priority group and the seats it filled (the school's general seats, or its special-education or academic-track ordering) |
| 3.6 | 96.8% and 2.0% | the funding status (publicly funded or fee-paying private) of each child's school in the entry year |

## Command

From this folder:

    Rscript -e "knitr::knit('Section3_IV.Rmd', 'output/Section3_IV.md')"

Table 3 (`lottery_college.tex`) carries the three graduation rows of Table IV in the submission draft
(`Initial submission/tables/results/lottery_college.tex`), in this notebook's format. On Windows R writes the table files with
CRLF line endings, on macOS and Linux with LF; compare files with `identical(readLines(a), readLines(b))`, which reads either
line ending.

## Setup

R 4.5.1 with fixest 0.14.2, dplyr 1.2.1, tidyr 1.3.2, purrr 1.2.2, tibble 3.3.1 and knitr 1.51. The notebook's
`ssc(K.adj = FALSE)` needs fixest 0.13.0 or later; the paper's tables were run with 0.14.2:

    install.packages(c("remotes", "dplyr", "tidyr", "purrr", "knitr"))
    remotes::install_version("fixest", "0.14.2")

## Run time

19 seconds for the command above on Windows 11 (Intel Core Ultra 7 265, 20 logical processors, 64 GB), measured while another
R job was running on the same machine.

## Standard errors

Heteroskedasticity-robust, as in Abdulkadiroglu, Angrist, Narita and Pathak (2017, "Research Design Meets Market Design").
OLS (Table 2, Table 3's first stage, and the footnote's effects of the offer on having each score and its balance rows):
fixest's N/(N-K) factor and p-values from t(N-K), as Stata's `robust`. 2SLS (Tables 3 and 4, the 1.2% in 3.6, and the
trimmed effects): no factor and p-values from the normal distribution, as ivreg2's `robust`. Joint tests: F(8, N-K) from the
eight regressions together, as Stata's `mvreg` followed by `test`.

## Panels

Both files are in the coauthors' shared Dropbox folder `<home>/Dropbox/Effect SAE on SUA/data/finalized_design_v1/section3/`,
where `<home>` is `USERPROFILE` on Windows and `~` on macOS and Linux; the notebook reads them from there.

| File | Rows | Columns | MD5 |
|---|---|---|---|
| `section3_panel.rds` | 304,547 | 34 | `878a9a8a9459d972dc6dd732d6278ae4` |
| `table_a3_panel.rds` | 2,545 | 40 | `572f4faba00263d249abc267b41146e2` |

`section3_panel.rds` has one row per applicant to 9th grade in SAE's 2016-2021 processes.

| Column | Meaning |
|---|---|
| `MRUN` | student ID |
| `YEAR` | application year |
| `CHANCE_GROUP` | the chance of an offer at an over-demanded school, from one million reruns of SAE's main stage, rounded to the nearest hundredth and written in hundredths (0 to 100) |
| `CHANCE_GROUP_THOUSANDTHS` | the same chance in thousandths (0 to 1,000) |
| `LOTTERY_SAMPLE` | a chance strictly between 0 and 1, in a hundredths group that holds a child with an offer and a child without one |
| `LOTTERY_SAMPLE_THOUSANDTHS` | the same with the thousandths groups (Table 2, column 4) |
| `OFFER` | 1 if SAE's main stage placed the child at an over-demanded school |
| `D_OD` | 1 if the enrollment census of the entry year shows the child at an over-demanded school |
| `ENTRY_RBD` | the child's school in the enrollment census of the entry year; missing with no enrollment record |
| `N_CLASS`, `N_OD`, `FC_OD` | choices ranked; over-demanded schools ranked; 1 if an over-demanded school is ranked first (Table 2, Panel A) |
| `GPA8_Z`, `ES_MUJER`, `PRIORITARIO`, `ALTO`, `ORIGIN_OD` | the characteristics of 3.3: 8th-grade average (SD); female; low income; top 20% of the school's grade ranking; enrolled at an over-demanded school in 8th grade |
| `GRAD`, `APPLIED`, `ASSIGNED`, `INSUA`, `OUTSIDE`, each with `_OT` (on time) and `_EVER` | graduated from high school (promoted from twelfth grade in regular secondary education or from the last level of adult secondary education); applied to a college program; assigned a college seat; enrolled through SUA; enrolled outside SUA (3.3) |
| `GRAD_REGULAR_OT`, `GRAD_REGULAR_EVER`, `GRAD_ADULT_OT`, `GRAD_ADULT_EVER` | `GRAD` by route: graduated through regular secondary education; graduated only through adult secondary education (a child with both records counts in the regular columns); the two add up to `GRAD` |
| `LM_Z_MAX`, `NEM_Z_LATEST`, `RANK_Z_LATEST` | Table 4's scores in SD: the highest reading-mathematics mean, the latest NEM and ranking scores |

Outside the lottery sample, `N_CLASS`, `N_OD`, `FC_OD` and the outcome columns other than `GRAD_EVER`, `GRAD_REGULAR_EVER`,
`GRAD_ADULT_EVER` and `ASSIGNED_EVER` are missing.

`table_a3_panel.rds` has one row per school: the 1,045 over-demanded schools, 1,033 of them in Table A3's comparison, and the
comparison's 1,500 other SAE schools.

| Column | Meaning |
|---|---|
| `RBD` | school ID, kept as `MRUN` is kept in `section3_panel.rds`; the notebook reads neither |
| `IS_OD` | one of the 1,045 over-demanded schools |
| `IN_CATALOGUE` | in Table A3's comparison (the rule is in the table's note) |
| `GROUP` | `od` or `other_sae` for the schools in the comparison |
| `IS_HISTORICAL` | has graduates of the 2012-2015 classes in the school profiles |
| `IS_COMMON` | has every measure of Panel A |
| `NEM_PERCENTILE_MEAN`, `LM_PERCENTILE_MEAN`, `ASSIGNED_ANY_MEAN`, `ASSIGNED_TOP10_MEAN`, `ASSIGNED_TOP25_MEAN`, `ASSIGNED_TOP50_MEAN` | Panel A's measures, school means over the school's graduates (the table's note gives each) |
| `VA_<fit>`, `VA_N_<fit>`, `SIGMA_E_M_<fit>` | value added (SD), the school's students in the fit, and the fit's residual SD, for the main fit (`HEAD`) and Panel B's (`REG`, `NOGPA`, `NOPAR`, `SPL`, `C13`, `C15`) |
| `COMPLETIONS_<class>`, `TAKERS_<class>`, `LINKED_<class>`, `STAYERS` | graduates of the 2013 and 2015 classes; those with valid admission-test scores in the next process; those in the value-added sample; the sample students tested in 8th grade at the same school |
