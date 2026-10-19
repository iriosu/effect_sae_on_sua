# Reconstruction and validation of Ranking scores

This report documents the original reconstruction. See `ranking_iterative_report_2026-10-19.md` for the subsequent arithmetic/reference audit, refined provisional proxy, and missing-NEM outputs.

For admission processes 2021–2025, 99.22% of missing Ranking scores belong to graduates with no linked admission record or no positive observed current exam score. Absence from the files does not prove nonparticipation. A small group took exams and still lacks Ranking. The 2026 extract observes mandatory exams only.

A rules-based proxy was constructed for 182,295 graduates whose Ranking was missing, across admission 2021–2026. Remaining missing cases are retained as unknown.

## Construction

All construction and validation is in `analysis_for_adversarial_report.Rmd`, chunks `f08-ranking-*`. The national grade records cover 2010–2025. The target population is regular youth-secondary graduates in 2020–2025. Adult education, foreign grades, free examinations, and ambiguous histories are outside this reconstruction.

Passed grades in years 1–4 are linked by MRUN. Failed attempts are excluded; nonconsecutive passed years are permitted when the order is clear. Identical duplicate records collapse; conflicting/multiple passed records remain unresolved. Consecutive grades in the same school define one context. Transfers generate additional contexts. For each interval, the reference population comprises earlier students ending that interval in that school, using their cumulative grades over the same interval. The reference population includes students who never registered for an admission examination.

For each context, let g be the student average, h the historical mean, M the mean of three annual maxima, T the relevant NEM conversion, and U the scale maximum. The proxy is T(g) below h; T(h)+(U−T(h))(g−h)/(M−h) between h and M; and U above M. Context scores are weighted by their grade counts, rounded to an integer, and floored at the reconstructed NEM. Ranking averages and historical summaries use two-decimal truncation; the NEM average uses conventional two-decimal rounding. Published 2022 and 2023 worked examples reproduce scores 713 and 824.

The scale maximum is 850 for admissions 2021–2022 and 1,000 from 2023. The old NEM tables differ between 2021 and 2022. The 2023–2026 guides retain the context formula; the new 2028 reform is not applied. Older delayed applicants can carry a frozen Ranking and need separate treatment. The present validation concerns each graduation cohort’s next admission process.

The complete historical Group A table is an archived print of DEMRE’s page. Group C comes from a school-hosted reproduction of the historical table; all 31 one-decimal anchors match MINEDUC’s own table, and all modal observed GPA/NEM cells match for both older admission processes. Current tables are downloaded directly from DEMRE and checked separately by cohort. The harmonized average-grade field in admissions 2023–2025 has only integer precision; its exact point of precision loss has not been located. Validation for those years uses the independently reconstructed four-grade GPA, not that rounded field. Neither observed Ranking nor observed NEM is used to fit the proxy.

Official rules require pooling schools with fewer than 30 reference students using region, teaching modality, and administrative dependence. The exact official pooling assignments are unavailable, so those contexts remain missing. A school with one or two populated reference years and at least 30 observed reference students is retained, as permitted by the guides. Missing grade histories can also alter historical reference summaries.

## Validation

| Admission | Validation N | Mean absolute error | Within 5 points | Absolute PACE cutoff agreement | Ranking coverage before | Recorded or proxy coverage |
|---|---:|---:|---:|---:|---:|---:|
| 2021 | 151,663 | 2.84 | 91.4% | 99.00% | 76.0% | 97.9% |
| 2022 | 152,642 | 2.95 | 91.0% | 98.89% | 75.2% | 97.8% |
| 2023 | 176,740 | 3.61 | 90.0% | 98.97% | 85.6% | 98.3% |
| 2024 | 181,784 | 3.17 | 90.7% | 99.09% | 87.3% | 97.9% |
| 2025 | 186,123 | 2.57 | 91.7% | 99.17% | 88.6% | 97.7% |
| 2026 | 193,286 | 2.35 | 92.1% | 99.22% | 88.7% | 97.6% |

Errors are in the score scale applicable to that admission process. These validation comparisons use graduates with both recorded and reconstructed scores. They cannot establish the same accuracy among nonregistrants. Exact matches, RMSE, error tails, PACE-school status, transfers, and offer-status comparisons are in the accompanying CSV files.

Within ten points of the annual absolute cutoff, agreement ranges from 87.5% to 89.1% across cohorts. Boundary classifications therefore warrant sensitivity checks even though overall agreement is high.

In the observed-score lottery subsample, the offer coefficient on reconstructed-minus-recorded absolute-threshold classification is 0.151 percentage points (95% CI [-0.010, 0.312]; N=89,755). This is a differential-measurement-error diagnostic on a selected subsample, not proof of nondifferential error among missing-score students.

The same-school-only historical reference, rounded student averages, equal weighting of historical cohort means, and context-specific conversion modalities are reported as sensitivities. The baseline remains the pooled-reference, truncated-average implementation. No variant is selected by optimizing the treatment effect.

## Implications for PACE

The augmented score keeps all recorded Ranking scores and fills only missing ones. Separate flags identify recorded, reconstructed, and unresolved scores. Absolute-threshold and percentile-OR diagnostics are supplied. The latter validation uses the same observed-score population for both measures, so its agreement rate does not validate the full official percentile population.

Full graduating-cohort academic classifications retain uncertainty from missing scores and tied cutoff positions. Their lower/upper indicators condition on proxy accuracy; they are not measurement-error-robust bounds. The official PACE reference roster, tie/quota conventions, full school/exam requirements, and carryover still require separate validation. The manuscript’s empirical tables have not been replaced by these diagnostics.

## Files

- `ranking_validation_summary.csv`: cohort-level accuracy and coverage.
- `ranking_validation.png`: binned observed and reconstructed scores.
- `ranking_rules_2021_2026.csv` and `ranking_source_manifest.csv`: rules and source provenance.
- `lottery_differential_reconstruction_error.csv`: offer-related validation errors.
- `academic_proxy_partial_coverage.csv`: unresolved academic classification after augmentation.
- Private student-level caches are under the ignored input directory, not in report exports.
