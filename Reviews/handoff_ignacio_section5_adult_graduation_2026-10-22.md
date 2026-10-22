# Handoff for Ignacio: Section V counts adult-education graduates (2026-10-22)

From Abhijit. Written for you and your agent. It covers what changed in the paper and the data, and the changes your notebook needs.

## 1. The decision

A student who completes the last level of adult secondary education now counts as a high-school graduate. That route grants the same secondary-school diploma (the Licencia de Educación Media, Decreto Exento 2169 de 2007, art. 10). This answers items F25.2 and F25.4 of your adversarial-report checklist and the completion part of F25.3 (taking part in adult education belongs to Section VI). F25.1 in the checklist describes graduation as regular twelfth-grade promotion; graduation now includes the adult route.

Table IV and the two appendix tables keep one graduation row for either route, with two indented rows under it that split it by route:

- **Graduated from high school:** promoted from twelfth grade in regular secondary education, or from the last level of adult secondary education.
- **Through regular secondary education:** the previous graduation outcome.
- **Through adult secondary education:** graduated only through adult secondary education. A student with both records counts in the regular row (among Table IV's 175,869 students: 1 on time, 3 ever).

Adult completion is read from the Ministry's public year-end files (rendimiento), 2017 to 2025. It counts promotion (final status P) from the last adult level after the application year: code 363 grade 3, or codes 463, 563, 663, 763 and 863 grade 4. On time means by the application year plus 4; ever means through the 2025 school year.

## 2. What changed in the paper (already in `Initial submission/`; new text in `\marar{}`)

| File | Change |
|---|---|
| `tables/results/lottery_college.tex` | Table IV: the three graduation rows; the note's sentence on adult education, and a sentence on the 345 students who completed school through validation exams or recognition of studies abroad (outside the year-end files; they count as not graduated) |
| `tables/results/lottery_college_offer.tex` | The offer table: the three graduation rows; the note's graduation sentence |
| `tables/results/lottery_college_first_choice.tex` | The first-choice table: the three graduation rows; the note's sentence on adult education |
| `sections/5_outcomes.tex` | The outcome footnote (graduation by either route); the reduced-form footnote (1.70); the results paragraph (2.72, 3.2%, and one sentence on the two routes); the horizon paragraph (2.72 to 0.86, 0.9%) and its footnote on the first-choice table |
| `sections/0_front.tex` | 3.12 becomes 2.72 |
| `sections/1_introduction.tex` | "on-time graduation from regular secondary education by 3.12" becomes "on-time high school graduation by 2.72" |
| `sections/9_appendix_outcomes.tex` | One sentence on the first-choice table's adult row |

The numbers (heteroskedasticity-robust standard errors; stars at 10, 5 and 1%):

```
Table IV (2SLS, attending)        On time                Ever
                                Mean   Effect          Mean   Effect
Graduated from high school     85.67  -2.72*** (0.34)  91.84  -0.86*** (0.26)
  Through regular secondary    81.08  -3.12*** (0.37)  85.53  -1.39*** (0.33)
  Through adult secondary       4.59   0.40**  (0.20)   6.31   0.53**  (0.24)

Offer table (OLS, receiving an offer)
Graduated from high school     85.67  -1.70*** (0.21)  91.84  -0.54*** (0.17)
  Through regular secondary    81.08  -1.95*** (0.23)  85.53  -0.87*** (0.21)
  Through adult secondary       4.59   0.25**  (0.13)   6.31   0.33**  (0.15)

First-choice table (2SLS, first-choice offer as the instrument)
Graduated from high school     85.59  -3.75*** (0.49)  92.07  -1.20*** (0.38)
  Through regular secondary    81.24  -4.00*** (0.53)  85.99  -1.67*** (0.48)
  Through adult secondary       4.35   0.25    (0.29)   6.08   0.48    (0.34)
```

Every other row of the three tables is unchanged. The means are among the students without an offer (in the first-choice table, without a first-choice offer), in %.

## 3. What changed in the data

`section3_panel.rds` in `<home>/Dropbox/Effect SAE on SUA/data/finalized_design_v1/section3/` is replaced: 304,547 rows, 34 columns, 7,015,832 bytes, MD5 `878a9a8a9459d972dc6dd732d6278ae4` (it was `3390a0487374564a5350a98be299f1a2`, 30 columns). `code/finalized_design_v1/data_manifest.csv` on the `finalized-design-v1` branch carries the new size and MD5.

- `GRAD_OT` and `GRAD_EVER` now count either route.
- New: `GRAD_REGULAR_OT`, `GRAD_REGULAR_EVER` (the previous `GRAD_OT` and `GRAD_EVER`, value for value) and `GRAD_ADULT_OT`, `GRAD_ADULT_EVER`. The two routes add up to `GRAD` on every row.
- Missing values follow `GRAD`: the on-time columns are missing outside the lottery sample; the ever columns have a value on every row.
- Every other column is unchanged.

Our Section V notebook (`code/finalized_design_v1/section3/Section3_IV.Rmd` and its README) reads the new panel and writes the three-row Table IV.

## 4. What your agent needs to do in `code/analysis_for_adversarial_report.Rmd`

Your notebook writes the offer table (`lottery_college_offer.tex`). Line numbers below refer to your version on the branch (commit d3714e8).

1. **Pull the branch** (`finalized-design-v1`) so that `data_manifest.csv` carries the new panel's size and MD5; the notebook reads the shared panel and checks both against the manifest (lines 76-90). A copy of the old panel in `analysis_for_adversarial_report_output/input/` fails that check; replace it with the shared file.
2. **`college_labels`** (line 123): add the two routes right after `GRAD`, and relabel `GRAD`:
   ```r
   college_labels <- c(
     GRAD = "High-school graduation (regular or adult secondary)",
     GRAD_REGULAR = "Through regular secondary education",
     GRAD_ADULT = "Through adult secondary education",
     APPLIED = "Applied through SUA",
     ASSIGNED = "Assigned a seat through SUA",
     INSUA = "First enrollment through SUA",
     OUTSIDE = "First enrollment outside SUA"
   )
   ```
   `binary_vars` and the estimation loop then pick up the four new outcome columns.
3. **The `reference-check` chunk** (lines 304-366) compares your estimates with the paper's Table IV, pairing the paper's rows with `names(college_labels)[k]` by position (line 333). With the two routes in `college_labels`, pair by name: next to `ref_labels`, add
   ```r
   ref_vars <- c("GRAD", "APPLIED", "ASSIGNED", "INSUA", "OUTSIDE")
   ```
   and use `ref_vars[k]` in place of `names(college_labels)[k]` at line 333. The paper's Table IV (the three-row file now in `Initial submission/tables/results/`) keeps its "Graduated from high school" row with the either-route numbers, which the new `GRAD` reproduces. Leave the two route rows out of this check while their labels in the paper's file are wrapped in `\marar{}`: the label match at line 328 would find no row and stop.
4. **`table_labels`** in the `offer-table-tex` chunk (line 770), in the same order as `college_labels`:
   ```r
   table_labels <- c("Graduated from high school", "\\quad Through regular secondary education",
                     "\\quad Through adult secondary education", "Applied to a college program",
                     "Assigned a college seat", "Enrolled (In SUA)", "Enrolled (Outside SUA)")
   ```
5. **The table note** (line 795): replace
   `"Graduation records completion of regular secondary education and excludes adult education. "`
   with
   `"Graduation records completion of regular or adult secondary education; the two indented rows divide it by route, and a student who completes both counts in the regular row. "`
6. **The text after the sample chunk** (lines 155-156): "Graduation excludes adult-education completion." becomes "Graduation counts completion of regular or adult secondary education."
7. **Check** that the regenerated `lottery_college_offer.tex` has the offer-table numbers in section 2 above. It will match the paper's file except that our `\marar{}` markup is gone, which accepts the change.
8. **Other uses of `GRAD_OT` and `GRAD_EVER`.** Line 712 (the diagnostics) reads the new panel, where they now count adult completion: keep `GRAD` if a graduate by either route is meant, or switch to `GRAD_REGULAR` if regular-secondary graduation is meant. Lines 5837-5881 (the score linkage) sit inside the chunks of section 5 below. Lines 6190, 6385 and 6915 read the v1 score baseline, built from the old panel: with v1 kept, they keep its regular-only graduation and need no change; with a v2 baseline, the same choice applies to them.

## 5. Before a full render: the frozen score baseline

The `f08-adopted-score-panel` chunk (line 5801) reads the same manifest-checked panel and saves `input/f08/section3_score_baseline_v1_2026-10-19.rds` from it (line 5857). With the new panel that file changes: the render stops at "Shared baseline differs" (lines 6016-6017), and the later chunks and `run_adopted_score_analysis.R` pin the v1 file's MD5 `07a43656157ca8d3a9d5b14669f9a963` (lines 6072-6073 and 7073-7074). Before a full render, your agent chooses one of two:

- keep the v1 baseline as it is, by not running the `f08-adopted-score-baseline`, `f08-adopted-score-panel`, `f08-adopted-score-expanded-panel` and `f08-adopted-score-manifest` chunks (lines 5715-6041); the `f30-expanded` chunks (lines 6052-6225) and the chunks after them still run, reading the v1 files already saved; or
- build a v2 baseline from the new panel under new file names, and point the later chunks and their MD5 checks at it.

## 6. Next

Section VI (Table V and the admission scores) moves to the same definition next, in a separate session; until then its Table V note still says that adult-education finishers count as not graduated.
