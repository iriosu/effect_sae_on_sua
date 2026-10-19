# Same-context and classroom diagnostic — October 19, 2026

**Answer:** yes, students with exact reconstructed NEM and complete observed histories can share a classroom/context while some Ranking scores match and others do not. However, virtually all students with the same GPA within an identical context have the same recorded Ranking. This is consistent with a shared reference or formula discrepancy whose score effect varies with GPA; it does not identify the precise cause.

## Sample and definitions

The sample has 842,942 graduates with exact independently reconstructed NEM, all four passed-grade records, one accepted context, three usable historical cohorts, and at least 30 observed prior graduates both school-wide and within modality. There are 62,772 remaining Ranking mismatches. The latest provisional `first_pass_reference_only` candidate is used; earlier score deliveries are preserved.

- An exact context fixes graduation year, all four school IDs, actual attendance years and exact teaching codes. It is stricter than grouping by final school/cohort or broad HC/TP modality. The accepted narrow same-school HHTT mapping is retained.
- Actual classroom groups additionally fix the fourth-grade classroom letter (`LET_CUR`) and session (`COD_JOR`). These identifiers were recovered from the raw 2023 grade file because the harmonized extracts omit them. Classroom identity in earlier grades is not observed here.
- All 148,084 clean-sample graduates from 2023 link to an unambiguous raw classroom record using person, year, school, teaching code and annual GPA. Actual-classroom conclusions cover graduation 2023/admission 2024; the exact-history comparison covers admission 2021–2026.
- A usable three-cohort reference means three cohorts appear in our extract, not that DEMRE used precisely the same students or grade versions. Exact NEM establishes agreement on this student's rounded GPA conversion; it does not validate historical means or maxima.

## Mixed matches within groups

Across six cohorts, 6,765 exact-context groups contain both matches and mismatches. They contain 61,762 mismatches, 98.39% of all 62,772 clean-sample errors. The groups below require at least two eligible students; singletons are reported separately in the CSVs.

| Admission year | Context groups with 2+ students | Mixed groups | Mismatches in mixed groups |
|---|---:|---:|---:|
| 2021 | 4,381 | 656 | 5,643 |
| 2022 | 4,293 | 855 | 7,422 |
| 2023 | 4,498 | 1,079 | 10,855 |
| 2024 | 4,534 | 1,306 | 12,273 |
| 2025 | 4,607 | 1,276 | 11,533 |
| 2026 | 4,445 | 1,593 | 14,036 |

For actual 2023 classrooms, 2,188 of 7,973 classroom-context groups with at least two eligible students are mixed (27.44%). They contain 21,750 matching and 12,178 nonmatching students. Restricting both recorded and predicted scores to a positive bonus strictly below the ceiling still leaves 1,516 mixed groups, with 7,739 matches and 7,810 mismatches. Thus floors and caps explain some apparent coexistence but do not eliminate it.

## Stronger test: identical GPA and annual grades

Among 176,079 exact-context/rounded-GPA groups with two or more students (466,303 students), only 1 group has different recorded Rankings: three students in admission 2021, with a 14-point range. The same exception survives holding the unrounded mean fixed. It should be checked as a record/context anomaly, but is not a widespread pattern.

Within actual classrooms, **none of the 21,236 same-GPA groups (46,479 students) has differing recorded Ranking scores**. Requiring all four annual grades to coincide gives 817 groups and 1,711 students, again with no disagreement. Across all six cohorts, none of the 9,108 exact-context/four-annual-grade groups (19,604 students) differs in recorded Ranking. These are groups of at least two observed students, not pair counts; the nested definitions must not be added together.

## Why a common benchmark can produce mixed exact matches

Inside the bonus region, the current formula is `T(h) + [C - T(h)] * (g - h)/(M - h)`, rounded to an integer: `g` is own GPA, `h` the historical mean, `M` the historical maximum benchmark, `T` the NEM conversion and `C` the score ceiling. A common error in `h` or `M` changes scores differently at different GPAs. Integer rounding can hide the discrepancy for some students while revealing it for others. Therefore common context and correct NEM do not imply that everyone must either match or mismatch.

An anonymized actual classroom example uses the same estimated historical mean 6.30 and maximum 6.95 for both rows. Both students' NEM conversions match; their own GPAs differ. The full frequency table is `anonymous_classroom_example.csv`.

| Own GPA | Recorded Ranking | Calculated Ranking | Calculation − recorded |
|---|---:|---:|---:|
| 6.70 | 923 | 923 | +0 |
| 6.45 | 846 | 845 | -1 |

## Can the maximum alone fix these groups?

For each student strictly inside both score curves, invert the observed integer score's half-open rounding interval into an admissible interval for the common maximum, holding the current historical mean and formula fixed. Intersect the intervals within each group, requiring at least two students and two distinct GPAs. Allow any continuous maximum up to 7, a more permissive test than restricting it to hundredths. The implementation includes the scoring helper's numerical rounding offset and independently reproduces the current score for every clean-sample student.

Only 658 of 4,923 mixed exact-context groups (13.37%), and 278 of 1,516 mixed classroom-context groups (18.34%), admit such a common maximum. Hence a maximum-only adjustment is insufficient for most mixed groups under the current historical mean/formula. This does not rule out jointly correcting the mean and maximum, a common arithmetic convention, or an incomplete context definition. The outcome-implied intervals are a diagnostic, not an independently validated reconstruction or imputation rule.

**Next analysis:** inspect the shared GPA-to-Ranking curve in these groups, varying historical-mean construction and arithmetic jointly with the maximum. Validate any proposed rule using independently constructed references and held-out cohorts/schools. Separately trace the lone identical-GPA discrepancy to its source records. There is little evidence here for pervasive person-specific Ranking discrepancies after holding GPA and context fixed.

## Reproduction and source provenance

From `code/`, execute `f08-score-reconstruction-functions`, `f08-ranking-remaining-patterns`, `f08-ranking-classroom-map`, `f08-ranking-within-context`, then `f08-ranking-within-context-report`. All statistical logic is in the central Rmd; the full notebook need not be knitted for this diagnostic.

Private raw source: shared Dropbox `/SAE - Datos/Rendimiento/Rendimiento-2023/Rendimiento por estudiante 2023.csv`; `class_source_manifest.csv` records its file ID, revision, exact byte count and MD5. The 2019–2023 grade-file dictionary identifies `LET_CUR` as classroom letter and `COD_JOR` as school session. The raw file contains 214,248 unique regular fourth-grade passed records with unambiguous class/session; `class_source_coverage.csv` records the screening counts. The byte count is checked before parsing, including handling the header BOM and decimal commas.

The raw file, person/class map and within-context records remain in ignored `input/f08/`. Only aggregate tables and the anonymized score example are shared. Assertions check unique graduate keys, identical references within strict contexts, exact formula reproduction, one prediction per identical GPA/context group, clean-sample totals, complete 2023 classroom linkage and infeasibility of the current maximum in mixed groups. No NEM/Ranking deliveries, eligibility measures or manuscript estimates are changed. F08.3 remains open.
