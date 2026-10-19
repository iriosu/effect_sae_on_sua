# Annual Ranking calculation test — October 19, 2026

**Conclusion:** the existing code scores consecutive school/modality contexts and weights by their lengths; it does not compute four annual scores. Implementing annual scores does not reduce observed discrepancies. Among the same 21,139 technical-to-scientific (TP-to-HC) switchers, exact agreement falls from 88.45% to 28.38% and mean absolute error rises from 0.502 to 3.833 points when only the annual aggregation procedure changes.

## Source and scope

[DEMRE’s linked page](https://demre.cl/paes/factores-seleccion/puntaje-ranking), checked October 19, describes four grade-specific rankings and their average, using the same grade and school in the three preceding calendar years. Its text specifies a pooled historical mean and pooled maximum, converted to the NEM scale. The displayed example refers to 2026 attendance, and the site navigation to admission 2027. The equation between the boundary cases is embedded in an image that could not be retrieved for inspection. The converted-score equations below are therefore alternative implementations, not a certified transcription of that image.

The dated admission-2021–2026 guides already archived in `f08/sources/ranking/instruments_YYYY.txt` describe consecutive educational contexts and averages of historical cohort maxima. This conflict remains unresolved. Do not infer from this test that DEMRE’s current description is wrong, that the webpage reflects a newly introduced rule, or that our better-fitting context implementation is definitively official.

## Implementation

- Score each of the four passed grades separately against the preceding three years at the same school, grade and broad modality (HC/TP); average exactly four scores with equal weights. No reference year is contemporaneous or future.
- Use admission-year NEM tables and caps: 850 in admission 2021–2022 and 1,000 in 2023–2026. Use the annual context’s conversion type. School-only reference pooling is a separately reported sensitivity.
- The main isolation test keeps the previous mean-of-cohort-means, mean-of-cohort-maxima, grade-linear formula and rounding conventions. It changes the temporal aggregation unit. This is different from simply splitting an existing multi-year context score into repeated annual copies.
- Preserve the independently reconstructed overall NEM floor in the main comparison; also save the literal annual average without that floor. Neither uses recorded Ranking to construct predictions.
- All before/after comparisons use the identical observed-score students for that candidate. The main TP-to-HC category has at least one TP-to-HC transition and no HC-to-TP transition; histories with both directions have a separate category. These are raw-code transitions and may include administrative recoding.
- Missing annual inputs or fewer than 30 historical records leave the score unknown. Official small-school pooling, foreign-school and free-exam substitutions remain unimplemented. Coverage differences are reported separately; the test does not extrapolate accuracy to students without observed scores.

## Admission-year results: isolate annual averaging

| Admission year | Same students | Context exact | Annual exact | Context MAE | Annual MAE |
|---|---:|---:|---:|---:|---:|
| 2021 | 3,038 | 88.08% | 22.32% | 0.406 | 4.853 |
| 2022 | 2,690 | 88.62% | 23.53% | 0.466 | 4.469 |
| 2023 | 3,206 | 89.77% | 25.67% | 0.530 | 4.945 |
| 2024 | 3,848 | 89.42% | 26.33% | 0.487 | 4.072 |
| 2025 | 4,201 | 89.53% | 32.99% | 0.423 | 2.715 |
| 2026 | 4,156 | 85.61% | 35.27% | 0.666 | 2.729 |

Exact agreement deteriorates and absolute error increases in every admission year. Point errors are in each year’s native scale; the within-year results avoid conflating the scale change with performance.

## Additional specifications: TP-to-HC

| Annual candidate (with NEM floor) | Same-sample N | Exact | MAE |
|---|---:|---:|---:|
| `annual_only_old_benchmarks` | 21,139 | 28.38% | 3.833 |
| `annual_pooled_modality_linear` | 21,139 | 21.04% | 10.638 |
| `annual_pooled_school_linear` | 21,358 | 20.67% | 11.976 |
| `annual_pooled_modality_bonus` | 21,139 | 11.89% | 21.678 |
| `annual_pooled_school_bonus` | 21,358 | 11.40% | 23.769 |
| `annual_meanmax_modality_linear` | 21,139 | 27.59% | 3.879 |
| `annual_pooled_modality_linear_round_each` | 21,139 | 21.00% | 10.580 |

Candidate definitions are in `candidate_specifications.csv`. `linear_score` interpolates from converted historical mean h to the cap c: h+(c-h)(g-h)/(m-h); `bonus_score` uses g+(c-g)(g-h)/(m-h). Both have the same lower/upper boundary rules. Neither is represented as the verified image formula. All seven candidates worsen replication for TP-to-HC students. Removing the overall NEM floor also worsens replication; the isolated annual variant then matches only 17.34%, with MAE 4.168.

## Verification, outputs and decision

- A direct equivalence test passes for all 2,988 available graduates with four one-year contexts: the annual-only implementation exactly reproduces the previous context calculation, maximum difference zero. This checks the temporal aggregation implementation independently of recorded scores.
- Assertions cover formula boundaries, nondegenerate benchmarks, four annual contributions, unique student/year/variant keys, score caps, reference timing and preservation of the earlier delivered input hashes. The named chunks were executed successfully; the full notebook was not reknit.
- `annual_same_sample_validation.csv` contains year, transition direction, PACE-school and same-school strata for all seven variants, with/without the floor. `annual_transition_summary.csv` aggregates those strata; `annual_coverage.csv` distinguishes changes in reconstructibility. Other outputs record input hashes, specifications, cohort sizes and the equivalence check.
- Private `input/f08/ranking_annual_candidates_2026-10-19.rds` saves the diagnostic annual candidates. Existing score deliveries and the prior narrow HHTT candidate remain unchanged. This test concerns Ranking, not a revision of NEM or a completed reconstruction of PACE qualification.
- **Decision:** retain annual scoring as a rejected empirical refinement for these extracts. Keep official context/reference reconciliation open. Before adopting a different rule, obtain the operational benchmarks/rosters and resolve the dated-guide versus current-page discrepancy. F08.3 remains open; no manuscript estimates change.

## Reproduce

Run from `repository/code`, with the existing private caches named in the setup chunk. Read `analysis_for_adversarial_report.Rmd` and execute these named chunks in order:

1. `f08-score-reconstruction-functions`
2. `f08-ranking-annual-setup`
3. `f08-ranking-annual-candidates`
4. `f08-ranking-annual-report`

The report chunk can also run alone against saved candidate outputs. The preceding follow-up report contains a minimal named-chunk runner. Student-level caches are intentionally excluded from Git.
