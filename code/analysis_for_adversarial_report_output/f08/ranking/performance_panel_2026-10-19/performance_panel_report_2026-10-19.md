# Performance-panel audit and benchmark tests — October 19, 2026

**Decision: retain the existing reconstruction.** The national performance data already feed the NEM/Ranking calculations. Refreshing the source with the newer full panel makes no difference to validated scores. Extending grade histories to 2002 and giving performance-derived historical GPAs priority over historical admissions GPAs both worsen replication. Every candidate is saved separately; no production score delivery or manuscript estimate is overwritten.

## What was checked

- The author's [MINEDUC collection](https://datosabiertos.mineduc.cl/rendimiento-por-estudiante-2/) currently lists annual performance downloads for 2002–2025. The code already reads `panel_performance_2002_2023.rds` plus `rendimiento_grades_2024_2025.rds`, including students without college-admission records. The earlier panel is assembled from the shared `/SAE - Datos/Rendimiento` files; `1a_data_processing_primary_secondary.Rmd` documents that source.
- A newer shared Dropbox file, `/Grade Inflation/Data/Master/panel_performance_2002_2025.rds`, was independently downloaded and verified against Dropbox's byte count and content hash. It has 80,778,642 rows covering 2002–2025, with annual GPA, grade, teaching code, school and final status. Its complete schema and coverage by year/teaching code/grade are archived. These are annual grade averages across school levels, not subject-level transcripts.
- On the common 2010–2025 regular-high-school domain, 15,971,156 records match literally on all seven scoring fields. The remaining 1,365 paired records have **identical grades and passed-grade status**; the only changes are blank/whitespace versus missing final-status labels. They supply no additional passed-grade information. `source_difference_types.csv` and `source_status_changes.csv` document this by year.
- An additional direct check against the raw 2023 CSV finds 1,043,276 literally identical high-school records and 47 unmatched records on each side. Raw source metadata and file hashes are retained. The broader master comparison separately establishes that all observed master/current-input differences are non-passing blank-status representations.

## NEM results

Rebuilding first-passed histories from the newer master, using the existing 2010 start, preserves NEM agreement at **98.9797%** on the same **1,052,561** previously reconstructible observed-score students. It resolves no existing mismatches and introduces none. There are 92 newly reconstructible observed-score cases under first-passed recovery, but only 56.52% match. This repeats the earlier poor validation of own-history recovery; they are not added to the accepted delivery.

Allowing own histories to start in 2002 gives 98.9768% exact NEM versus 98.9798% for the baseline on the same 1,052,557 cases: 14 mismatches resolved and 46 introduced. It also loses 4 previously calculable observed-score cases. Older repeated passed records can change the selected first completion or create chronology conflicts; additional old records therefore do not automatically improve a student's usable history.

## Ranking: isolate the historical mean and maximum

The target students' own accepted histories, NEM calculation, narrow HHTT context rule, score formula and rounding remain fixed. The tests change only the historical full-course references. Partial-context references retain their previous definition. This directly addresses the exact-NEM, one-context diagnostic; it is not a new annual-score procedure.

- **Source refresh:** reconstruct the current historical benchmark from the newer master, retaining historical admissions GPA first and performance GPA as fallback.
- **2002 extension:** use all available earlier high-school records when selecting historical peers' first passed grades, retaining the current GPA-source priority.
- **Performance only:** use the rounded average of all four performance grades, excluding historical peers whose usable GPA can only be recovered from admissions records. This can reduce reference coverage.
- **Performance preferred:** reverse GPA-source priority, using historical admissions GPA only when performance GPA is unavailable. The usable historical roster is preserved relative to the source-refresh rule. Separately replace the mean, maximum, or both.
- **Full precision:** use the unrounded four-grade performance average before constructing the historical benchmark, with the same admissions fallback. Final benchmark and score rounding remain unchanged. This is a precision sensitivity, not evidence that the official process uses unrounded averages.

| Candidate | Common validation N | Ranking exact | Exact-NEM/full-history subset exact | Errors resolved | Errors introduced |
|---|---:|---:|---:|---:|---:|
| Refresh from newer master; current rule | 1,033,587 | 90.7134% | 92.5532% | 0 | 0 |
| Extend historical records back to 2002 | 1,033,587 | 90.7044% | 92.5422% | 22 | 115 |
| Performance grades only | 1,033,029 | 87.9177% | 89.1542% | 18,947 | 47,956 |
| Prefer performance grades for mean only | 1,033,587 | 90.5121% | 92.3094% | 1,257 | 3,338 |
| Prefer performance grades for maximum only | 1,033,587 | 90.1046% | 91.8099% | 269 | 6,562 |
| Prefer performance grades for both | 1,033,587 | 89.9238% | 91.5914% | 1,258 | 9,419 |
| Unrounded performance GPA for mean only | 1,033,587 | 88.7204% | 90.1481% | 14,517 | 35,116 |
| Unrounded performance GPA for maximum only | 1,033,587 | 84.8736% | 85.4645% | 2,305 | 62,665 |
| Unrounded performance GPA for both | 1,033,587 | 83.0786% | 83.2940% | 14,019 | 92,931 |

The current benchmark matches **90.7134%** of 1,033,587 observed Ranking scores; in the exact-NEM/one-context/three-cohort/adequate-count subset it matches **92.5532%** of 842,942. The newer master reproduces these results unchanged.

**Common-sample caveat:** performance-only references match 87.9177% versus 90.7258% for the baseline on the same 1,033,029 students, and lose 558 previously calculable observed scores. In the clean subset the corresponding comparison is 89.1542% versus 92.5633% on 842,521 students. All other rows retain the full common validation sample. Coverage tables distinguish common, lost, newly available and unavailable cases; lower coverage must not be mistaken for better accuracy.

The 2002 extension resolves 22 Ranking errors and introduces 115, a net increase of 93. Among the relevant 2017–2024 historical graduation cohorts, it recovers only 7 complete performance histories, loses 15 and changes 75 previously complete GPAs. It substantially fills earlier cohorts, but those earlier graduates generally do not enter the full-course three-cohort references for admission 2021–2026.

Performance-only references worsen exact matching in 6 of the six admission years. Detailed year comparisons, error sizes, PACE-school strata, modality and the clean-subset breakdown are saved in `validation_by_year.csv`, `selected_year_comparison.csv` and `validation_strata.csv`. These are exploratory validation comparisons, not held-out evidence for a newly selected rule.

## Interpretation and next step

The residual gap is not reduced by obtaining this more recent master, adding pre-2010 records, or substituting performance-derived GPA for historical admissions GPA. These tests support retaining the existing GPA reconciliation and show that lacking the national performance panel was not the obstacle. They do not establish which DEMRE reference roster, grade version or arithmetic convention explains the remaining within-context curve discrepancies.

The next useful task is to compare the shared GPA-to-Ranking curve with independently constructed historical means/maxima and exact operational reference definitions, particularly in the exact-NEM clean sample. Do not select a GPA source separately for each student or school based on whether it matches observed Ranking. Keep the observed scores and previous proxy deliveries intact.

## Reproduce and resume

All statistical logic is in `code/analysis_for_adversarial_report.Rmd`. From `code/`, run `f08-score-reconstruction-functions`, `f08-performance-source-audit`, `f08-performance-reference-candidates`, `f08-performance-validation`, `f08-performance-nem-audit`, `f08-performance-record-differences`, then `f08-performance-panel-report`. The full manuscript notebook need not be knitted. The source-difference cache is tied to the input manifest; invalidate it if replacing any source file.

New private inputs include the downloaded master, projected high-school records, histories starting in 2010 and 2002, full-course reference candidates, student-level candidate scores and source-difference rows. They remain in ignored `input/f08/`. Only aggregate outputs, source metadata and this report are shared. `source_provenance.json` records the Dropbox revision/content hash; `input_manifest.csv` records local byte counts and MD5s. No temporary download URL is retained in shared artifacts.

Checks cover source schema and size/hash, unique score keys, expected validation counts, historical-roster equality for preferred-source variants, non-overlapping coverage categories, exact-NEM clean-sample size, mismatch accounting and blank-status versus grade differences. Existing NEM/Ranking deliveries, eligibility measures and manuscript estimates are unchanged. F08.3 remains open.
