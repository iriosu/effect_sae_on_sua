# One-point Ranking errors: historical-mean and peer-curve diagnostics

October 19, 2026. F08.3 remains open. Existing score deliveries and manuscript estimates are preserved.

## Result and scope

The clean sample contains 842,942 students with exact independently reconstructed NEM, complete grade histories, one accepted context, three historical cohorts and adequate school/modality counts. The baseline matches 780,170/842,942 (92.5532%), with 62,772 mismatches, including 42,007 one-point discrepancies.

**No new independent arithmetic rule improves matching.** The 34 alternatives cover interpolating historical NEM anchors; averaging cohort NEM anchors; changing historical precision; grade-space versus NEM-space formulas; uniform anchor shifts; final rounding; coefficient rounding; the legacy score transformation; and binary/half-to-even cohort rounding. Every alternative introduces more exact-match losses than it resolves on development schools. The frozen input-only selection is the existing baseline.

Development schools have RBD modulo 5 different from zero; all cohorts of a school stay together. Reserved schools have RBD modulo 5 equal to zero. Prior investigations have already examined these schools, so this is a reserved comparison for new arithmetic rules, not an untouched research holdout. No new arithmetic rule passed development, so none was promoted for reserved-school validation. The peer experiment below has a separate student-level split.

## What the common score curves reveal

Among 3,394 strict contexts with both matches and discrepancies, and only one-point errors among interior students, all 3,394 admit a common straight line. Holding the existing mean and maximum fixed, a shared adjustment to the historical NEM anchor fits every interior score in 3,390 (99.88%). A uniform additive shift to all students is feasible in only 41.63%.

Changing only the historical mean by -0.02, -0.01, 0, +0.01 or +0.02 GPA points, with its corresponding published NEM-table anchor and the maximum unchanged, reconciles every interior score in 3,300/3,394 contexts (97.23%). A maximum-only shift of at most 0.01 works in 24 contexts. Among the better-supported contexts (at least 10 interior students and five distinct GPAs), the mean-only grid fits 2,055/2,118. These are outcome-based feasibility calculations, not recovered official benchmarks or admissible per-context tuning rules.

Only 404/40,106 interior one-point discrepancies (1.01%) sit within 0.000001 of a final half-point boundary. This and the failed rounding candidates argue against final tie-breaking as the main explanation.

The recorded-GPA/official-NEM cell audit covers 515,057 students in admissions 2021, 2022 and 2026, when two-decimal GPA is usable. No cell with at least 20 observations has a different modal NEM supported by at least 90% of its observations. This does not cover sparse cells or the years whose recorded GPA loses decimals, but gives no basis to replace the published conversion table.

**Interpretation:** small errors in the shared historical mean, its reference roster, or the operational grade version are a stronger lead than the maximum or final integer rounding for this subset. A changed anchor can also compensate for other formula/reference differences, so these diagnostics do not identify a unique administrative cause. The tested full-precision/cohort-mean arithmetic alternatives do not explain which contexts need an adjustment.

## Separate held-out peer experiment

Within each strict context, students are split by MRUN modulo 2. Each half is predicted using only the other half's recorded Ranking. The training half must contain at least five interior students and three distinct GPAs. Their observed integer scores bound a single common anchor adjustment. The held-out student's Ranking never enters its prediction; neither variant selects targets by whether their current prediction is wrong.

Two exploratory variants are retained. The midpoint variant keeps the original anchor whenever feasible and otherwise uses the midpoint of the training interval. The conservative variant changes a score only if every anchor in that interval implies the same held-out integer score. Intervals account for the existing decimal half-up epsilon and are expanded slightly for the conservative endpoint check, preventing borderline half-points from being treated as uniquely determined.

| Peer diagnostic, all 842,942 clean students | Exact agreement | All mismatches resolved | New mismatches | One-point errors resolved |
|---|---:|---:|---:|---:|
| Baseline | 92.5532% | — | — | — |
| Anchor interval midpoint | 96.6670% | 35,491 | 814 | 30,741 |
| Change only uniquely implied scores | 95.8124% | 27,473 | 0 | 24,316 |

The conservative diagnostic resolves 57.89% of the original one-point discrepancies, introduces no new mismatches, and worsens no existing errors in this evaluation. It has 632,385 uniquely implied predictions (75.02% of the clean sample), of which 99.8901% match. There remain 17,691 original one-point cases unresolved and 35,299 total mismatches across the clean sample. Full agreement has not been obtained.

| Admission year | Clean students | Baseline exact | Conservative diagnostic exact | One-point cases resolved | New mismatches |
|---|---:|---:|---:|---:|---:|
| 2021 | 123,537 | 95.33% | 97.42% | 2,377 | 0 |
| 2022 | 124,885 | 93.92% | 96.28% | 2,735 | 0 |
| 2023 | 146,563 | 92.47% | 95.47% | 3,696 | 0 |
| 2024 | 148,084 | 91.58% | 95.10% | 4,708 | 0 |
| 2025 | 147,461 | 92.02% | 95.60% | 4,554 | 0 |
| 2026 | 152,412 | 90.72% | 95.35% | 6,246 | 0 |

**This is empirical calibration using peers' recorded Ranking, not independent reconstruction from grades and published rules.** The clean evaluation sample also requires exact observed NEM. The results do not establish performance among nonregistrants, NEM-mismatched students, multiple-context histories or contexts with few observed scores. The zero newly introduced errors is a sample result, not a guarantee. These are exploratory diagnostics, and the existing independently reconstructed scores remain the main comparison.

## Next tasks

- Prioritize the historical **mean** and its roster/grade version. For contexts with narrow feasible intervals, compare the independently constructed cohort means with the implied interval; seek official school-context means or archived operational reference records. Do not substitute outcome-fitted means in the main reconstruction.
- Audit historical-peer inclusion and GPA provenance near the rounding boundary: missing cumulative GPAs, late registrations, revised grade records and reported-GPA versus NEM-implied GPA. The national performance refresh and simple alternative rounding rules have already been tested and rejected.
- If peer calibration is pursued as an imputation sensitivity, keep it labeled separately. Validate across fixed additional folds and school/cohort groups; characterize coverage and remaining errors before testing NEM mismatches, multiple contexts or missing-score students. Examine dependence on offer status and observed-score availability before using it in PACE mechanism estimates.
- Preserve unknown eligibility cases and existing score files. F08.3 and the complete academic-eligibility reconstruction remain open.

## Reproduce and inspect

All statistical logic is in `code/analysis_for_adversarial_report.Rmd`. From `code/`, run `f08-score-reconstruction-functions`, followed by `f08-one-point-setup`, `f08-one-point-development`, `f08-one-point-curve-diagnostic`, `f08-one-point-arithmetic-development`, `f08-one-point-benchmark-diagnostic`, `f08-one-point-peer-diagnostic`, `f08-one-point-nem-table-diagnostic`, and `f08-one-point-report`. The full notebook need not be knitted.

Aggregate CSVs in this folder contain development comparisons, the frozen baseline selection, rounding frequencies, curve/benchmark feasibility, NEM-table-cell checks and held-out peer results. Private clean inputs, feasible intervals and peer predictions are versioned `ranking_one_point_*_2026-10-19.rds` under ignored `input/f08/`. None replaces a delivered score file. Input fingerprints are in `input_manifest.csv`.

Checks assert the baseline sample and one-point counts, unique student/cohort keys, prediction bounds, honest held-out-fold assignment, interval/midpoint consistency, unchanged fallback predictions, all-year improvement for the conservative diagnostic, zero introduced/worsened errors, and resolved-minus-introduced accounting. All R chunks are parsed after the edit.

The [2023 MINEDUC guide](https://acceso.mineduc.cl/wp-content/uploads/2022/06/2.-INSTRUMENTOS-ACCESO-ADM-2023.pdf), pp. 8–9, gives the shared straight-line formula and says coefficient calculations use full precision; pp. 13–14 discuss the legacy scale transformation. Current annual-score descriptions should not silently replace the dated context rules for this sample.
