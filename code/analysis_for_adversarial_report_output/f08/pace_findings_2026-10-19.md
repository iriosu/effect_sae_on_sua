# PACE audit and new estimates — 2026-10-19

The approved short PACE paragraph and footnote are in `3_background.tex`.

**Subsequent Ranking reconstruction:** the author's proposed reconstruction from
national grade histories is implemented and validated in the central notebook's
`f08-ranking-*` chunks. See
[`ranking/ranking_reconstruction_report_2026-10-19.md`](ranking/ranking_reconstruction_report_2026-10-19.md).
That extension fills missing scores where the histories and reference contexts
support a proxy, preserves recorded scores, and documents remaining measurement
error. The academic diagnostics below predate this extension and have not been
substituted into manuscript tables.

## What was established

1. Official school lists exist. The new construction uses independent historical ministry rosters for 2019–2025, including the 2024 and 2025 amendments; it does not infer participation from applicants or override school status with a student's own PACE record.
2. The stored PACE label changes definition. Through 2022 it comes from P167 (registration-stage PACE status). In 2023–2025 the upstream script constructs it from a PACE program at the first preference. It cannot serve as a common eligibility or academic-qualification variable.
3. Recorded PACE selection is status 24 at any PACE preference. Its reconstruction matches `assigned_pace` exactly for all 1,789,837 registrant-process rows in 2020–2025. Every overlapping positive Ranking score also matches the separately compiled college-outcome file (1,481,303 matched rows overall).

## New estimates on the finalized Section 3 design

Common sample: 131,709 lottery applicants with all controls, SAE 2016–2020; on-time admission processes 2021–2025. Chance-group and application-year fixed effects, the Section 3 controls, and heteroskedasticity-robust SE. These are not the archived first-choice accounting estimates.

- Offer effect on recorded PACE selection: -0.62 pp (95% CI [-0.74, -0.51]; N=131,709).
- Attendance IV effect on recorded PACE selection: -1.01 pp (95% CI [-1.19, -0.82]; N=131,709).
- Offer effect on recorded attendance at PACE schools in both scheduled grades 11 and 12: -9.64 pp (95% CI [-10.17, -9.12]; N=131,709).
- Offer effect on observing a Ranking score for an on-time graduate: -1.77 pp (95% CI [-2.36, -1.17]; N=131,709).
- Among on-time graduates with observed Ranking scores, the offer comparison for the annual absolute threshold is -5.13 pp (95% CI [-5.74, -4.52]; N=91,136). This conditions on an outcome affected by the offer and is not an unconditional causal effect on academic qualification.
- The observed-score percentile OR absolute-score proxy gives -5.99 pp (95% CI [-6.63, -5.35]; N=89,996) among observed-score graduates with a classifiable proxy. It is a diagnostic proxy, not official eligibility.

## What remains unresolved

The annual academic thresholds are implemented separately: 15%/710, 15%/749, 20%/863, 20%/851, 25%/815, and 25%/830 for admission 2021–2026. The within-school percentile cannot be reconstructed exactly from observed registrants alone. The missing Ranking scores change the denominator and ordering. Conservative lower/upper classifications retain unknown cases; `academic_completion_ranges.csv` reports the range of fitted coefficients over their possible completions, not confidence intervals.
The school-history-restricted reference is reported separately. Operational confirmation of the reference roster, ties and rounding is still needed, as are official Ranking scores for unobserved graduates. Nonconsecutive school histories, adult-education graduation, and missing/ambiguous school records are not certified as eligible. Required exams are checked when observed; unused carryover cannot be inferred solely from current-year scores, and these new models deliberately focus on the on-time process rather than claim a complete ever-eligible reconstruction.
The MRUN-linked 2026 extract does not preserve the admission route. Do not code that year as zero PACE admissions. Extend the common sample only when its original route records are available.

The results establish lower recorded PACE selection and lower recorded PACE-school attendance. Academic scores provide evidence consistent with a second channel, but the current data do not identify a complete academic-eligibility effect or the share of the admission effect mediated by either channel. F08.3 stays open. The manuscript's existing empirical tables have not been replaced with provisional eligibility estimates.

## Sources and reproducibility

- Ministry PACE document registry: https://dfi.mineduc.cl/instrumentos-de-financiamiento/asignacion-directa/programa-pace/
- Annual school directories: https://datosabiertos.mineduc.cl/directorio-de-establecimientos-educacionales/
- Official annual guides/resolutions and source URLs: `sources/`, `pace_rules_2021_2026.csv`.
- School roster and correction log: `sources/schools/official_pace_schools_2019_2025.csv`, `sources/schools/ocr_corrections.csv`.
- Upstream source: `archive/1_data_processing_upstream.Rmd`, lines 294–342, 1102–1105, 1351–1353.
- Original P167 dictionary: `sources/dictionaries/20220420_Diccionario de variables Actualizado 2022.xlsx`, sheet 1 rows 363 and 369.
- All new statistical code: `analysis_for_adversarial_report.Rmd`, chunks `f08-*`. The Python helper performs only memory-bounded RDS projection.
- Aggregate estimates and coverage: `pace_new_estimates.csv`, `pace_panel_coverage.csv`, `graduate_score_coverage.csv`, `pace_school_score_coverage.csv`, `academic_classification_coverage.csv`, `pace_status_crosstabs.csv`.
