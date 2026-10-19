# Iterative Ranking and NEM reconstruction audit

Status: substantial improvement, not exact replication. The rounded-cohort Ranking implementation is provisional because its empirical fit conflicts with the truncation wording in the official dated guides. No manuscript estimates or original eligibility classifications were replaced.

## Ranking accuracy on the same validation sample

On 1,032,921 students observed under both implementations, exact agreement increases from 48.83% to 84.57%; mean absolute error falls from 2.783 to 1.458 points. Within-one-point agreement is 89.75% and within-five-point agreement is 93.70% under the refined proxy.

| Admission | Common validation N | Exact | Mean absolute error | Within 5 |
|---|---:|---:|---:|---:|
| 2021 | 149,897 | 87.9% | 1.14 | 94.9% |
| 2022 | 150,286 | 86.2% | 1.37 | 94.1% |
| 2023 | 174,938 | 84.2% | 1.93 | 92.5% |
| 2024 | 180,153 | 83.3% | 1.78 | 92.7% |
| 2025 | 184,845 | 84.0% | 1.31 | 94.0% |
| 2026 | 192,802 | 82.7% | 1.18 | 94.2% |

Of the originally isolated 26,469 small-difference records with exact NEM, one school, no own-GPA rounding ambiguity, and complete observed references, 26,433 remain reconstructible after applying the modality definition. Among these, 95.26% now match exactly and 96.83% are within one point. Unavailable cases are retained as unknown, not counted as successful matches.

PACE-school validation remains weaker: exact agreement is 73.34% and mean absolute error is 3.028 points, compared with 87.46% and 1.055 points in non-PACE schools on the same common sample. This matters for the planned PACE mechanism analysis and remains unresolved.

## What was changed and tested

- Removed the blanket 2013 lower bound from historical references; use every available valid passed-grade history.
- Compared school-only, exact teaching-code, and broad HC/TP contexts. Broad modality is materially better than treating all TP branches as different contexts.
- Tested 162 combinations of student-average, historical-student-average, benchmark, and final-score precision on the clean one-school sample. Consistent rounding is substantially closer than the guide-based truncation implementation.
- Reconciled historical full-course GPAs with recorded graduation GPAs where precise, and with GPAs identified by the official NEM tables for the 2023–2025 integer-GPA extracts. Nonregistrants remain in the reference through their grade histories. Historical Ranking scores are never inputs.
- Compared pooling students with equal weighting of annual cohort means, including rounding annual means before averaging. Equal weighting of rounded annual means gives the best uniform replication among these specifications.
- Compared unrounded, rounded, and truncated context scores before combining contexts. Rounded context scores give the best uniform replication.
- Tested unrounded conversion of the old NEM anchor onto the PAES scale. Although the public NEM tables reproduce exactly after the scale conversion and rounding, using an unrounded anchor worsens Ranking replication and is not adopted.

The candidate is uniform across students and cohorts, with year-specific conversion tables and scale. There is no per-student rule choice, fitting of historical benchmarks to current Ranking scores, or selection based on lottery effects. Even/odd-RBD results are subgroup checks, not a prospectively held-out validation set.

## Rules by year and unresolved source conflict

The dated 2021–2026 guides retain the context-based linear formula. The score maximum changes from 850 in admissions 2021–2022 to 1,000 from 2023; NEM conversion tables are year-specific before that change. The new percentile-based Ranking scheduled for 2028 is outside this sample. The current DEMRE webpage describes a per-grade procedure that differs from the dated guides; it is not silently substituted for those historical rules.

The 2021–2026 guides explicitly truncate the student context average and historical maximum. The better-fitting rounded implementation is therefore evidence of an unresolved implementation/documentation mismatch, not proof that the official rules formally changed to rounding. Likewise, complete retention of the observed grade extract does not certify that it equals DEMRE’s final historical population or grade versions. A public bulk file of official school-context historical means/maxima was not located in this search.

Relevant sources: [2021 guide](https://acceso.mineduc.cl/wp-content/uploads/2020/08/DOCUMENTO-OFICIAL-N%C2%BA1-17-agosto.pdf), [2022 guide](https://acceso.mineduc.cl/wp-content/uploads/2021/06/5-INSTRUMENTOS-DE-ACCESO-ESPECIFICACIONES-Y-PROCEDIMIENTOS.pdf), [2023 guide](https://acceso.mineduc.cl/wp-content/uploads/2022/06/2.-INSTRUMENTOS-ACCESO-ADM-2023.pdf), [2024 guide](https://acceso.mineduc.cl/wp-content/uploads/2023/06/DOC.-Instrumentos-Acceso-Admision-2024.pdf), [2025 guide](https://acceso.mineduc.cl/wp-content/uploads/2024/04/INSTRUMENTOS-DE-ACCESO-ESPECIFICACIONES-Y-PROCEDIMIENTOS-ADM-2025.pdf), [2026 guide](https://acceso.mineduc.cl/wp-content/uploads/2025/09/V2-INSTRUMENTOS-ACCESO-ADM-SEPTIEMBRE-2026.pdf), [MINEDUC context definition](https://ayudamineduc.cl/ficha/puntaje-ranking), and [current DEMRE description](https://demre.cl/paes/factores-seleccion/puntaje-ranking). The source manifest and year-rule matrix record the archived material.

## Missing NEM and Ranking records

Independent reconstruction from the four annual grades matches NEM exactly for 98.98% of 1,052,561 validated complete histories. It does not use observed NEM to fit a GPA. When a precise recorded graduation GPA is available, the NEM augmentation uses its published conversion in preference to the grade-history proxy.

Across 1,286,127 graduates, 185,216 previously missing NEM scores are filled and 24,533 remain unresolved. The refined Ranking candidate fills 178,528 missing scores, leaving 31,221 unresolved. Recorded scores are never overwritten.

Student-level outputs are in the ignored `analysis_for_adversarial_report_output/input/f08/` directory: `nem_augmented_graduates.rds`, `nem_missing_score_records.rds` and `.csv.gz`, `score_reconstruction_records.rds`, and `missing_score_records.rds` and `.csv.gz`. They include identifiers for linking, observed/proxy/augmented scores, source labels, and unresolved reasons. Aggregate report files contain no identifiers.

## Functions and verification

The source is `analysis_for_adversarial_report.Rmd`, chunks `f08-score-*`, `f08-nem-reconstructed-records`, and subsequent Ranking audit chunks. `score_reconstruction_functions.R` is a sourceable export generated from the function chunk. `nem_from_gpa()` converts by admission year and modality; `nem_from_history()` produces observed/proxy/augmented NEM records; the Ranking functions build contexts, references, and scores with explicit arithmetic options.

Verification includes the published 2022/2023 examples, unsupported-year handling, small-reference handling, missing-history handling, one record per graduate/cohort, score bounds, and preservation of all recorded scores. Missing-data and small-school pooling cases remain unresolved rather than being assigned a fabricated official score.
