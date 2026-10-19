# Follow-up: NEM and Ranking mismatches by year

Prepared October 19, 2026. All new statistical work is in `code/analysis_for_adversarial_report.Rmd`, chunks `f08-score-followup-patterns`, `f08-score-followup-context-hypothesis`, `f08-score-followup-validation`, and `f08-score-followup-report`. Aggregate outputs are alongside this report. Individual records remain in the ignored `input/f08/` directory.

## Main result

The errors are not concentrated in one year. A specific context-definition hypothesis improves exact Ranking agreement from 84.56% to 90.71% on the same 1,033,342 observed-score graduates. Mean absolute error falls from 1.458 to 0.420 points. At PACE schools, agreement rises from 73.34% to 85.82% and MAE falls from 3.028 to 0.608. This is a new provisional candidate, not a verified official rule or a completed reconstruction of PACE eligibility.

PACE is not itself a score. The earlier audit reproduced recorded PACE selection exactly from selection-status records; full academic eligibility, including the percentile alternative, remains unresolved. The score results here concern NEM and Ranking.

## Year-by-year accuracy

Years below are **college admission processes**: graduates from 2020 enter the 2021 row. NEM is independently reconstructed from four annual grades. Each Ranking before/after pair uses identical observed-score students with both candidates available; NEM has its own valid-history sample.

| Admission | NEM validation N | NEM exact | Ranking comparison N | Ranking before | Ranking candidate | MAE before → candidate |
|---|---:|---:|---:|---:|---:|---:|
| 2021 | 154,027 | 98.90% | 150,023 | 87.88% | 93.42% | 1.135 → 0.276 |
| 2022 | 154,371 | 98.70% | 150,339 | 86.22% | 92.13% | 1.372 → 0.367 |
| 2023 | 178,457 | 99.26% | 174,997 | 84.19% | 90.98% | 1.939 → 0.531 |
| 2024 | 183,366 | 98.89% | 180,181 | 83.30% | 89.72% | 1.777 → 0.540 |
| 2025 | 187,826 | 99.18% | 184,956 | 84.00% | 90.20% | 1.311 → 0.385 |
| 2026 | 194,514 | 98.90% | 192,846 | 82.73% | 88.65% | 1.185 → 0.392 |

NEM has 10,739 mismatches spread across all six years. On the full baseline Ranking validation sample, each year accounts for 11.4%–20.9% of mismatches. The latest cohort contributes the most mismatches, while 2023 has the largest baseline average absolute error. Raw score points use an 850 maximum in 2021–2022 and a 1,000 maximum thereafter, so cross-period MAEs are not on an identical scale.

These comparison counts differ slightly from the morning report’s 1,032,921 common original/refined observations. The new comparison requires the delivered refined score and the new candidate, rather than the original pre-refinement score. All differences within the table are computed on the same students; `year_common_sample_accuracy.csv` reproduces the morning baseline separately.

### Ranking at PACE schools

| Admission | Same-sample N | Before | Candidate | MAE before → candidate |
|---|---:|---:|---:|---:|
| 2021 | 25,982 | 78.90% | 90.32% | 2.571 → 0.402 |
| 2022 | 25,677 | 75.40% | 87.92% | 3.089 → 0.547 |
| 2023 | 34,719 | 73.58% | 87.95% | 3.785 → 0.629 |
| 2024 | 39,420 | 71.64% | 84.45% | 3.620 → 0.782 |
| 2025 | 40,824 | 72.44% | 84.24% | 2.725 → 0.627 |
| 2026 | 44,510 | 71.05% | 83.00% | 2.424 → 0.573 |

## Main pattern: an internal HC-to-TP transition

The strongest mismatch concentration is among students staying at one RBD for all four grades, with HC code 310 in grades 1–2 and a TP code in grades 3–4 (HHTT). In the full baseline validation, their exact agreement is 34.19%, versus 83.63% for HHTT students who change schools. The poor same-school fit appears in every admission year.

The targeted hypothesis treats the four years in this particular same-school HHTT sequence as one context, using the exit TP modality for the historical peers and conversion table. It retains the existing context definition for every other history. The history-based rule is uniform across years and PACE/offer groups; it never selects a score using that student’s observed Ranking.

Among 123,433 affected students with both scores available, the change resolves 64,347 former mismatches but introduces 801 new mismatches; net improvement is 63,546 matches. It is not a universal fix. A broader rule collapsing every within-school modality change performs worse (89.00% exact overall) and harms other histories, so that broad rule is not retained.

Interpretation: the empirical pattern is consistent with an administrative HC/TP code transition being mistaken for a genuine change of educational context. It does **not** establish that explanation conclusively. [MINEDUC describes context using school and teaching type](https://ayudamineduc.cl/ficha/puntaje-ranking), while the dated annual guides describe accumulated grades in consecutive institutional contexts. The mapping between the raw codes and DEMRE’s operational contexts needs confirmation. The prior rounding-versus-truncation documentation conflict also remains. This candidate was discovered and evaluated on the available data; year/subgroup checks are not a prospectively held-out validation.

## NEM: evidence against a final-rounding explanation

Independent NEM remains 98.98% exact over 1,052,561 complete observed-score histories. Of 10,739 mismatches, 70.30% imply a GPA discrepancy of ±0.02 or ±0.03, and 85.99% imply ±0.02, ±0.03, or ±0.05. These increments are consistent with differences in the underlying annual grades (a 0.1 difference in one annual grade changes a four-year mean by 0.025), but do not identify which record is correct.

Truncating rather than rounding the four-year GPA repairs 0 mismatches and introduces 520,162 new ones. Exact agreement falls to roughly 49.5%. A blanket truncation change is rejected.

Among 2,351 mismatched graduates with a later registration and invertible NEM, only 15 later agree with the grade-history calculation; 2,333 keep the original score-implied GPA in all available later records. The longitudinal comparison converts each process’s NEM back to GPA to avoid confusing the 2023 scale change with revisions. Later records end in 2025, so this does not test subsequent revisions for the last two admission cohorts.

The evidence points toward persistent differences between grade-history extracts and admissions academic records, rather than a universal final-rounding error. No observed NEM is used to choose a replacement prediction for that same student. The score-inverted GPAs here are diagnostic outcomes only.

## Implications for PACE qualification

For observed-score graduates at PACE schools within 10 points of the annual absolute threshold (N=7,871), threshold-side agreement improves from 89.82% to 97.27%. False positives fall from 107 to 76; false negatives from 694 to 139. These are checks of the **absolute-score alternative**, not the full percentile-OR-absolute PACE rule, school/exam conditions, or carryover.

On the same 88,554 lottery-sample graduates with both reconstructions observed, the conditional OFFER coefficient on mismatch probability changes from -7.74 pp to -4.61 pp; the coefficient on signed Ranking error changes from 0.492 to 0.085 points. The diagnostic conditions on hundredth propensity-group and application-year effects and uses heteroskedasticity-robust uncertainty. Differential measurement error remains. These selected-sample diagnostics do not identify a causal effect among always-observed students.

After the context change, cases whose independent NEM does not match account for 31.7% of remaining absolute Ranking error, although they are only 1.0% of the validation sample. GPA input reconciliation is therefore a useful next step for both scores.

## Files, checks, and next steps

- The morning delivery `input/f08/score_reconstruction_records.rds` is preserved. The new candidate is in ignored `input/f08/ranking_context_hypothesis_2026-10-19.rds`, keyed by `MRUN, grad_year`; `targeted_candidate` is the narrow hypothesis and `school_context_candidate` is the rejected broad sensitivity. Recorded scores are not overwritten. Unknown scores remain unknown.
- `context_hypothesis_coverage.csv` reports changes in reconstructibility, so matched-score gains are not confused with gaining/losing validation cases. `targeted_candidate_changes.csv` reports both resolved and introduced errors.
- Confirm the operational treatment of the same-school HHTT sequence with DEMRE’s context/benchmark data or codebook; examine whether mixed HC/TP schools differ from schools offering only TP in upper grades.
- Reconcile annual grades against authoritative academic certificates or revised grade files for the remaining NEM discrepancies. Later registration records generally preserve the initial GPA, so simply choosing a later NEM does not solve them.
- Investigate remaining Ranking errors conditional on exact NEM and correct context, including historical cohort rosters, maxima, small-school pooling and reference precision. Do not infer benchmarks from current Ranking and then report in-sample agreement as independent validation.
- Keep the official PACE percentile population, ties/quota rounding, school history, exams, and carryover as separate unresolved eligibility tasks. Do not insert imputed eligibility mechanism estimates into the manuscript yet.

### Reproduce from the code directory

```r
lines <- readLines("analysis_for_adversarial_report.Rmd")
run_chunk <- function(name) {
  start <- which(lines == paste0("```{r ", name, "}"))
  stopifnot(length(start) == 1L)
  end <- start + which(lines[(start + 1L):length(lines)] == "```")[1L]
  eval(parse(text = lines[(start + 1L):(end - 1L)]), envir = .GlobalEnv)
}
for (name in c("f08-score-reconstruction-functions",
               "f08-score-followup-patterns",
               "f08-score-followup-context-hypothesis",
               "f08-score-followup-validation",
               "f08-score-followup-report")) run_chunk(name)
```

The required private caches are listed in the handoff and the code; they are not delivered by Git. The full notebook need not be reknit to reproduce this follow-up. Package versions and input hashes are saved alongside the report.
