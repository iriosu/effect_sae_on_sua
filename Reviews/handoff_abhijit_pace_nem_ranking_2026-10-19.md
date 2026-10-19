# Handoff to Abhijit: PACE audit and NEM/Ranking reconstruction

Prepared October 19, 2026, for continuing the F08 work with Ignacio. The main unresolved task is to establish whether SAE reduced PACE admission through lower attendance at participating schools, lower academic qualification, or both. We now have official school rosters, an audit of the recorded PACE variables, and reconstructed scores for many graduates without recorded NEM/Ranking. **The Ranking reconstruction remains provisional; full academic eligibility and the corresponding mechanism estimates are not finished.**

## Follow-up later on October 19: year patterns and a better context candidate

Read the [score-mismatch follow-up](../code/analysis_for_adversarial_report_output/f08/ranking/followup_2026-10-19/score_mismatch_followup_2026-10-19.md) for the newest diagnostic results. The tables below describing 84.57% Ranking accuracy refer to the **morning delivery**, which is preserved.

- Mismatches occur in every admission year, 2021–2026. Independent NEM matches 98.70%–99.26% by year, 98.98% overall.
- The main new pattern is students staying at one school with HC codes in the first two grades and TP codes in the last two. Treating that particular same-school HHTT sequence as one context improves Ranking accuracy from **84.56% to 90.71%** on the same 1,033,342 observed-score graduates; MAE falls from **1.458 to 0.420**. At PACE schools, exact agreement improves from **73.34% to 85.82%**. The improvement appears in every year. A broader rule collapsing all within-school modality changes performs worse.
- This is a **tested provisional candidate**, not a confirmed official context rule. The narrow change resolves 64,347 mismatches but introduces 801. Confirm whether the raw HC/TP code transition represents a genuine DEMRE context change. The earlier arithmetic/documentation conflict remains.
- Near the PACE absolute threshold (within 10 points), agreement improves from 89.82% to 97.27% among 7,871 observed-score PACE-school graduates. This does not establish full eligibility. Differential error by lottery offer remains, even on a common validation sample.
- NEM mismatches primarily imply GPA differences of 0.02–0.03. Truncation repairs none and introduces 520,162 errors; later registration vintages agree with our grade histories for only 15 of 2,351 initially mismatched graduates with usable later records. The priority is reconciling underlying academic records, not switching final rounding.

New code: the four `f08-score-followup-*` chunks in the central notebook. New private candidate: `input/f08/ranking_context_hypothesis_2026-10-19.rds`, keyed by `MRUN, grad_year`; use `targeted_candidate` for the narrow hypothesis. `school_context_candidate` is the broader sensitivity, **not** the preferred candidate. No morning score-delivery file or manuscript estimate was overwritten. The follow-up report includes an executable chunk runner, aggregate comparisons, coverage, and limitations. F08.3 remains open.

## 1. Start here

All statistical work is in [`code/analysis_for_adversarial_report.Rmd`](../code/analysis_for_adversarial_report.Rmd). The exception is the F04 entrant-count implementation, which that notebook calls from `code/f04_entrant_counts.R`. The F08 Python helper only projects columns from a large RDS file; it does not estimate models.

Three directories matter:

| Directory | Contents |
|---|---|
| `code/analysis_for_adversarial_report_output/f08/` | Aggregate PACE results, rule matrix, archived code and public sources |
| `code/analysis_for_adversarial_report_output/f08/ranking/` | Score-validation reports, aggregate diagnostics, NEM tables and reusable functions |
| `code/analysis_for_adversarial_report_output/input/f08/` | **Private student-level records and intermediate caches; excluded from Git** |

For the morning baseline, read the [iterative score report](../code/analysis_for_adversarial_report_output/f08/ranking/ranking_iterative_report_2026-10-19.md) first, then the [broader PACE findings](../code/analysis_for_adversarial_report_output/f08/pace_findings_2026-10-19.md). The [review checklist](adversarial_report_action_checklist_2026-10-17.md) records author decisions and leaves F08.3 open.

Local locations on Ignacio's machine:

- Code/reviews: `/Users/iriosu/Dropbox/Effect SAE on SUA - repo` (branch `finalized-design-v1`).
- Raw/shared data: `/Users/iriosu/Dropbox/Effect SAE on SUA`.
- Manuscript: `/Users/iriosu/Projects/Effect of Centralized School Choice on College Admissions Outcomes/Initial submission` (separate Overleaf repository).

Pulling Git provides code, documentation and aggregate outputs. It does **not** deliver the private score files. Obtain these through the existing shared Dropbox workspace/access, retaining the relative `input/f08/` layout, or regenerate them from the underlying data. No student-level observations should be added to Git.

## 2. PACE measurement: what we established

**Official school lists exist.** We recovered ministry rosters for school years 2019–2025, including amendments, and linked schools by RBD and year. The derived roster is `f08/sources/schools/official_pace_schools_2019_2025.csv`; source documents, extraction code and OCR corrections are in the same directory. The new measures use these independent lists, without overriding school participation using an individual student's PACE record. See the [ministry PACE document registry](https://dfi.mineduc.cl/instrumentos-de-financiamiento/asignacion-directa/programa-pace/).

**The harmonized `pace`/`is_pace` field is not a consistent full-eligibility indicator.** The recovered upstream script uses registration-stage P167 through 2022. For 2023–2025 it replaces `pace` with the presence of a PACE program in the first preference and then constructs `is_pace`. Relevant evidence:

- `f08/archive/1_data_processing_upstream.Rmd`, especially lines 294–342, 1102–1105 and 1351–1353.
- `f08/sources/dictionaries/20220420_Diccionario de variables Actualizado 2022.xlsx`, sheet 1, rows 363 and 369.
- `f08/pace_flag_definition_audit.csv`, `pace_status_crosstabs.csv` and `code_provenance.csv`.

**Recorded PACE selection is recoverable.** A PACE preference with status 24, at any preference position, exactly reproduces `assigned_pace` across all 1,789,837 registrant-process rows checked for 2020–2025. Positive Ranking overlaps also agree with the independently compiled college-outcome file (1,481,303 overlapping rows). Selection, application, eligibility and enrollment must remain separate concepts.

**The old accounting tables do not decompose full academic eligibility.** Archived `piece4` code is preserved under `f08/archive/`, with original commit and hashes in `code_provenance.csv`. `L_PACE` denotes record appearance; `S_PACE` denotes selected-preference status. The old school proxy was inferred from applicants and forced to one when the student's own PACE record was present, including in the partial official-list variant. Its second accounting component is not an academic-qualification indicator. First-choice and selection restrictions also change denominators. The exact updated old horizon exporter was not recovered; the new estimates use the finalized Section 3 design and do not claim to reproduce that exporter.

### Annual academic alternatives

The percentile criterion and absolute Ranking threshold are joined by **OR**. Participating-school history, graduation, required examinations and any carryover conditions are additional requirements.

| Admission process | Top share | Absolute Ranking threshold | Score maximum |
|---|---:|---:|---:|
| 2021 | 15% | 710 | 850 |
| 2022 | 15% | 749 | 850 |
| 2023 | 20% | 863 | 1,000 |
| 2024 | 20% | 851 | 1,000 |
| 2025 | 25% | 815 | 1,000 |
| 2026 | 25% | 830 | 1,000 |

The complete source-backed matrix is `f08/pace_rules_2021_2026.csv`, generated by `f08-rules`, and exported to Appendix Table D.11 (`tab: pace annual rules`). It also records exams, school history, graduation cohorts, duration/carryover, selection rules and sources. Carryover must preserve the qualifying cohort's rule; do not automatically apply a later graduating cohort's threshold.

The operational percentile reference population, ties and quota rounding still need confirmation. The 2024 rule explicitly refers to graduates satisfying both years of PACE-school attendance. Ranking the entire graduating class is therefore not automatically the correct official PACE reference. A reconstructed score alone does not certify eligibility.

### New estimates already produced

`f08/pace_new_estimates.csv` uses the finalized Section 3 lottery design: 131,709 applicants, SAE application years 2016–2020, scheduled college admission 2021–2025; chance-group and application-year fixed effects, Section 3 controls, heteroskedasticity-robust standard errors.

| Outcome/estimand | Estimate, percentage points | 95% CI |
|---|---:|---:|
| Offer effect on recorded PACE selection | −0.62 | [−0.74, −0.51] |
| Attendance IV effect on recorded PACE selection | −1.01 | [−1.19, −0.82] |
| Offer effect on PACE-school attendance in both scheduled grades 11 and 12 | −9.64 | [−10.17, −9.12] |
| Offer effect on observing Ranking for an on-time graduate | −1.77 | [−2.36, −1.17] |

The observed-score academic diagnostics condition on outcomes affected by the offer. They are not unconditional causal effects on qualification or causal mediation estimates. They also predate the latest score reconstruction. The MRUN-linked 2026 extract lacks the selection route: that year is excluded from the common selection analysis, not coded as zero PACE selection.

## 3. NEM and Ranking reconstruction

### Population and inputs

The target contains **1,286,127 regular youth-education graduates in 2020–2025**, corresponding to on-time admission 2021–2026. We use national grade records from 2010–2025, including nonregistrants. The implementation selects passed annual grades, flags missing/ambiguous/unordered histories and follows school/modality contexts. Adult education, foreign/free-exam cases and other unsupported modalities are not silently assigned regular-school scores.

The principal cached inputs are:

- `ranking_targets.rds`: target graduates, recorded scores/GPA, four annual grades, school/teaching-code histories, completeness flags and PACE rules.
- `ranking_passed_histories.rds`: wide passed-grade histories used for historical references.
- `ranking_grade_records_2010_2023.rds` and `rendimiento_grades_2024_2025.rds`: projected grade records.
- `student_columns/`: memory-bounded projections of `data_students_2004_2025.rds`; metadata and projection manifests describe the columns. Avoid loading the full 775-column source unnecessarily.
- `pace_finalized_panel.rds`: finalized lottery analysis frame for the mechanism regressions.

All these files are under `input/f08/`. `code/f08_extract_rds_columns.py` performs the projection; it requires NumPy. Existing projections can be reused.

### Rules and source checks

NEM uses the four passed annual GPAs, averaging and rounding to two decimals before applying the appropriate year/modality conversion table. `ranking/nem_tables_used.csv` contains the tables used. HC is group A and regular TP is group C; unsupported groups remain unknown.

The dated 2021–2026 Ranking guides describe a context-based rule. For student context GPA `g`, historical mean `h`, mean of the preceding three cohorts' maxima `M`, NEM conversion `T`, and score maximum `U`:

```text
g <= h:       T(g)
h < g < M:    T(h) + (U - T(h)) * (g - h) / (M - h)
g >= M:       U
```

Context contributions are weighted by their number of high-school grades out of four; the final score is floored at NEM. Historical cohorts are aligned with the context's exit grade/year. We do not invent official pooling assignments for contexts with fewer than 30 historical students or assign scores to degenerate benchmarks.

Annual guides, conversion sources and manifests are archived under `f08/sources/ranking/` and `ranking/ranking_source_manifest.csv`. See the [2021 guide](https://acceso.mineduc.cl/wp-content/uploads/2020/08/DOCUMENTO-OFICIAL-N%C2%BA1-17-agosto.pdf), [2022 guide](https://acceso.mineduc.cl/wp-content/uploads/2021/06/5-INSTRUMENTOS-DE-ACCESO-ESPECIFICACIONES-Y-PROCEDIMIENTOS.pdf), [2023 guide](https://acceso.mineduc.cl/wp-content/uploads/2022/06/2.-INSTRUMENTOS-ACCESO-ADM-2023.pdf), [2024 guide](https://acceso.mineduc.cl/wp-content/uploads/2023/06/DOC.-Instrumentos-Acceso-Admision-2024.pdf), [2025 guide](https://acceso.mineduc.cl/wp-content/uploads/2024/04/INSTRUMENTOS-DE-ACCESO-ESPECIFICACIONES-Y-PROCEDIMIENTOS-ADM-2025.pdf), and [2026 guide](https://acceso.mineduc.cl/wp-content/uploads/2025/09/V2-INSTRUMENTOS-ACCESO-ADM-SEPTIEMBRE-2026.pdf).

The scale changes from 850 to 1,000 in admission 2023. Earlier NEM tables are year-specific. The new Ranking formula scheduled for 2028 is outside this sample. The current DEMRE website describes a per-grade procedure that differs from the dated guides; we did not silently substitute it for historical rules.

**Important unresolved discrepancy:** the dated guides explicitly describe truncation at some arithmetic stages, but rounding replicates the data much better. The final candidate is an empirical improvement, not a certified correction to the official rule.

### What the small-difference audit showed

The initial proxy had 430,989 observations with nonzero absolute errors below five points (1–4, excluding exactly five). They were not generally in smaller schools: median graduating-cohort size 94 versus 90 for exact matches; 17.08% versus 18.50% were in cohorts below 50 students.

Independent NEM reconstruction was exact for **430,587/430,989 (99.9067%)** of these cases. This strongly supports the underlying rounded four-year GPA and directs attention to historical benchmarks and Ranking-specific arithmetic. It does not by itself validate context averages or their truncation.

Required calendar-year files were available. All three reference cohorts had usable students for 99.133% of these cases, but only 15.387% retained every observed raw reference student in every context; mean pooled retention was 98.129%. Even full retention is relative to our extract, not DEMRE's final reference roster or corrected grades. These results are in `ranking/small_difference_audit_2026-10-19.md` and `small_difference_*.csv`.

### Iterations completed and current accuracy

We removed a blanket 2013 reference cutoff; compared school-only, exact teaching-code and broad HC/TP contexts; tested 162 arithmetic combinations; reconciled historical full-course GPAs; compared pooled-student and equally weighted annual means; and tested rounding each context score before weighting.

The retained uniform candidate uses broad HC/TP contexts, rounded GPAs/benchmarks, equal weighting of rounded annual cohort means, and rounded context scores. Historical GPA reconciliation uses precise recorded GPAs where available and NEM-inverted GPAs where the 2023–2025 GPA extract has lost decimals. Nonregistrants remain in historical references through their grade histories. **Neither current nor historical Ranking is an input to benchmark construction.** An unrounded old-to-new scale conversion was tested and rejected because it worsened replication.

| Validation measure | Original | Refined provisional candidate |
|---|---:|---:|
| Same common sample | 1,032,921 | 1,032,921 |
| Exact Ranking agreement | 48.83% | 84.57% |
| Mean absolute error | 2.783 | 1.458 |
| Within one point | 65.78% | 89.75% |
| Within five points | 91.56% | 93.70% |

In the strict original small-difference subset (exact NEM, one school, complete observed references, no own-GPA rounding ambiguity), 26,433 of 26,469 remain reconstructible under the modality-specific requirement. **95.26% now match exactly**; the other 36 remain unknown.

PACE-school performance is materially worse: **73.34% exact, MAE 3.028**, versus **87.46% exact, MAE 1.055** outside PACE schools. This is a priority before relying on reconstructed PACE academic eligibility. Annual exact agreement ranges from 82.7% to 87.9%. The candidate was selected using validation comparisons across the available data; even/odd-RBD tables are subgroup checks, not a prospectively held-out validation exercise.

Independent four-grade NEM reconstruction matches **98.98% of 1,052,561** observed-score complete histories. For admission 2023–2025, the harmonized `promedio_notas` field has only integer precision, so direct table conversion from that field is not a valid check. The upstream cause of that precision loss has not been established.

## 4. Exact outputs for missing NEM and Ranking

**Use `input/f08/score_reconstruction_records.rds` as the latest combined delivery.** It has one row per `MRUN, grad_year`; `admission_year = grad_year + 1`. Do not merge stacked cohorts/processes on MRUN alone.

| Private file under `input/f08/` | Purpose |
|---|---|
| `score_reconstruction_records.rds` | All 1,286,127 target graduates, original/refined scores, provenance and missingness |
| `missing_score_records.rds` and `.csv.gz` | Originally missing NEM **or** Ranking; includes both successfully filled and still unresolved cases |
| `nem_augmented_graduates.rds` | NEM-specific output for all target graduates |
| `nem_missing_score_records.rds` and `.csv.gz` | Originally missing NEM, including unresolved observations |

The combined file includes:

- Keys/context: `MRUN`, `grad_year`, `RBD`, `pace12`, `nem_group`, `complete_history`, `n_contexts`, `gpa_from_history`.
- NEM: `nem_recorded`, `nem_history_proxy`, `nem_reported_gpa_proxy`, `nem_proxy`, `nem_augmented`, `nem_source`, `nem_is_imputed`, `nem_unresolved_reason`.
- Ranking: `ranking_recorded`, `old_proxy`, `ranking_proxy_refined`, `ranking_augmented_refined`, `ranking_source`, `ranking_is_imputed`, `ranking_unresolved_reason`.
- Version: `reconstruction_version`, currently `2026-10-19 iterative rounded-cohort candidate; precision rule unresolved`.

Recorded scores are preserved. For missing NEM, precise recorded GPA conversion takes priority where usable; otherwise the four-grade reconstruction is used. For missing Ranking, the refined candidate is used only when available. Unknowns remain `NA`, not zero or ineligible. Source labels distinguish recorded, reconstructed, converted-GPA and unresolved cases.

**Validate `nem_history_proxy` against `nem_recorded`, and `ranking_proxy_refined` against `ranking_recorded`.** Comparing augmented fields with observed values would create mechanical agreement because observed scores are retained.

| Admission | Graduates | NEM filled | NEM unresolved | Ranking filled | Ranking unresolved |
|---|---:|---:|---:|---:|---:|
| 2021 | 206,728 | 46,266 | 3,442 | 44,473 | 5,235 |
| 2022 | 208,879 | 47,957 | 3,809 | 45,702 | 6,064 |
| 2023 | 212,167 | 27,409 | 3,235 | 26,282 | 4,362 |
| 2024 | 214,248 | 23,031 | 4,196 | 22,358 | 4,869 |
| 2025 | 217,564 | 20,069 | 4,720 | 19,594 | 5,195 |
| 2026 | 226,541 | 20,484 | 5,131 | 20,119 | 5,496 |
| **Total** | **1,286,127** | **185,216** | **24,533** | **178,528** | **31,221** |

There were 209,749 originally missing observations for each score. Counts come from `ranking/score_augmentation_coverage.csv`. Filling a missing score is not evidence that it equals the unavailable official score; validation is among observed-score students and may not transport perfectly to nonregistrants.

### Earlier files that should not be mistaken for the final delivery

- `ranking_augmented_graduates.rds`: **original** Ranking reconstruction and provisional percentile bounds; not the latest candidate.
- `ranking_refined_validation_records.rds`: intermediate historical-GPA/broad-modality candidate, before the final cohort-mean/context-rounding changes.
- `ranking_context_score_rounding_candidates.rds`: contains several final-stage variants; the selected one is `variant == "context_round"`.
- `ranking_reconstruction_report_2026-10-19.md`, `ranking_validation.html`, and the main generated HTML/Markdown notebook are earlier snapshots. The authoritative latest numerical summary is **`ranking_iterative_report_2026-10-19.md`**. The full notebook has not been reknit after the final iterations; the new chunks were executed directly.

Other useful final aggregates are `ranking_iterative_summary.csv`, `ranking_iterative_pace_validation.csv`, `ranking_iterative_clean_validation.csv`, `ranking_iterative_absolute_cutoff_validation.csv`, `ranking_iterative_error_distribution.csv`, `nem_augmentation_validation.csv` and `score_reconstruction_rules_2021_2026.csv`.

## 5. Code map and how to resume

Run R from the repository's **`code/` directory**. Named chunks are more stable references than line numbers:

| Chunks | Work |
|---|---|
| `f08-rules` through `f08-review-report` | Rule matrix, official-school linkage, PACE-variable audit, finalized-design estimates and initial eligibility diagnostics |
| `f08-ranking-histories`, `f08-ranking-contexts`, `f08-ranking-nem-tables` | Initial grade histories, historical contexts and conversion tables |
| `f08-ranking-score-validation` through `f08-ranking-report` | Initial reconstruction, discrepancy/size/NEM audit and provisional eligibility validation |
| `f08-score-reconstruction-functions` | Reusable scoring/reference functions |
| `f08-score-iterative-validation`, `f08-score-precision-audit` | Context variants and arithmetic grid |
| `f08-nem-reconstructed-records` | Missing-NEM records and validation |
| `f08-ranking-refined-candidates`, `f08-ranking-historical-gpa-reconciliation` | Broad-modality contexts and historical GPA reconciliation |
| `f08-ranking-scale-transformation-audit`, `f08-ranking-remaining-discrepancies` | Scale-anchor checks and remaining-error diagnostics |
| `f08-ranking-cohort-averaging-audit`, `f08-ranking-context-rounding-audit` | Final cohort averaging and context-score variants |
| `f08-score-final-records-and-report` | Combined delivery, latest aggregate results/report, exported functions and assertions |

`ranking/score_reconstruction_functions.R` is a generated, sourceable export. **Edit the Rmd function chunk, not the export.** Important functions: `nem_from_gpa()`, `nem_from_history()`, `ranking_reference_by_context()`, `ranking_student_contexts()`, `ranking_context_benchmarks()` and `ranking_from_contexts()`.

Minimal reuse without rerunning the full notebook:

```r
# Working directory: repository/code
library(data.table)
out <- "analysis_for_adversarial_report_output"
source(file.path(out, "f08/ranking/score_reconstruction_functions.R"))
tables <- fread(file.path(out, "f08/ranking/nem_tables_used.csv"))
targets <- readRDS(file.path(out, "input/f08/ranking_targets.rds"))
nem <- nem_from_history(targets, tables)
scores <- as.data.table(readRDS(file.path(out,
  "input/f08/score_reconstruction_records.rds")))
stopifnot(!anyDuplicated(scores, by = c("MRUN", "grad_year")))
scores[, .(graduates = .N, nem_filled = sum(nem_is_imputed),
           ranking_filled = sum(ranking_is_imputed)), by = grad_year]
```

**Do not call the default `ranking_from_contexts()` and assume it produces the final candidate.** Its defaults are guide-like diagnostic settings. The final chunks use broad modality, reconciled histories, replace `h_round_raw` with `h_equal_rounded_cohort_raw`, and specify rounded own/historical/benchmark/context/final arithmetic before flooring at the independent NEM proxy. Follow those chunks or use the final saved records.

Dependencies include `data.table`, `jsonlite`, `xml2`, `fixest`, `knitr` and `rmarkdown`. Full-notebook F02 work additionally requires `did` 2.1.2 and the finalized panels; see the notebook setup and repository `HANDOFF.md`. The temporary library and runners under `/private/tmp/` are not portable dependencies.

Several expensive derived caches are created only if absent. When changing a construction rule, version or invalidate the affected **derived** cache and rerun its downstream chunks; otherwise an old file may silently survive. Preserve raw source caches.

A specific cache caveat: the code now excludes low-precision pre-2016 recorded GPAs from historical reconciliation, but the existing `ranking_reference_historical_gpa_v5.rds` predates that exclusion. This does not affect the current full-course target references (2017 onward); rebuild reconciliation before extending to earlier cohorts. Useful later caches include `historical_official_gpa.rds`, `ranking_contexts_historical_gpa_broad_modality.rds`, and `ranking_contexts_cohort_averaging.rds`.

Checks already run include parsing all 49 R chunks, published 2022/2023 worked examples, unsupported years, missing histories, small references, unique graduate keys, score bounds and preservation of recorded scores. Passing these checks does not resolve empirical disagreement with official Ranking.

## 6. Remaining work, in priority order

1. **Reproduce the delivered counts and validation summary.** Confirm the refined combined file and reconstruction version are being used. Keep the original proxy as a sensitivity comparison.
2. **Resolve remaining Ranking differences, especially in PACE schools.** Start with one-context students with exact NEM and complete observed historical references. Examine year, modality, transfers and distance to PACE thresholds. Seek official school/context historical means, maxima and small-school pooling assignments; a public bulk benchmark file was not located. Data completeness alone does not establish equality to DEMRE's reference roster or grade versions.
3. **Resolve the documentation/arithmetic conflict.** Confirm truncation versus rounding, annual-cohort weighting and context-score rounding for each admission year. Do not choose rules separately by student or to produce a desired treatment estimate. A potential extension not yet implemented is using later registration records to recover historical GPAs for students absent from the on-time registration file, with careful provenance and grade-version checks.
4. **Investigate unresolved NEM cases.** Missing, ambiguous or unsupported histories account for remaining gaps; do not fill them indiscriminately. Clarify the 2023–2025 loss of decimals in the harmonized GPA field.
5. **Construct complete academic qualification.** Use year-specific percentile OR absolute Ranking thresholds, the correct official reference population and tie/quota rules, while keeping school participation, exams and carryover separate. Preserve unknowns and report sensitivity near cutoffs. The refined proxy's differential error by lottery offer still needs to be checked; earlier offer-group diagnostics used the original proxy.
6. **Reestimate the mechanisms on the finalized lottery sample.** Compare old/new classifications by cohort, offer and school; show coverage and disagreement reasons. Avoid conditioning the main causal mechanism claim on observed scores or post-offer graduation. Keep 2026 route outcomes unavailable until recovered.
7. **Update affected manuscript tables and interpretation together after validation.** No estimates based on the final imputed academic-eligibility variable have been inserted into the manuscript. F08.3 remains open.

## 7. Draft status and author decisions to preserve

F08.1, F08.2 and F08.4 are marked revised. Background, mechanism text, appendix rules and table notes were updated to distinguish recorded selection from eligibility and describe the limits of the old accounting. Ignacio approved the short PACE paragraph in `sections/3_background.tex`, with a footnote saying the qualifying percentage ranged from 15% to 25% and referring to the appendix table. Keep that concise wording; the detailed annual rules belong in the appendix. The earlier manuscript update was compiled and visually checked; the subsequent iterative score audit did not change manuscript estimates.

Related earlier work is recorded in the checklist: F03.3 and F03.4 were reviewed and postponed as noncritical; Ignacio explicitly retained his political discussion. F04.4 entrant-count work is complete in `f04_entrant_counts.R` and `output/f04/`. Its unbalanced-panel count intervals include zero for both income groups, while the low-income share rises. This supports a composition result more clearly than an increase in low-income entrant numbers; it does not prove counts are unchanged. The income-count paragraph in `4_access.tex` is currently commented out and should remain so unless Ignacio requests otherwise.
