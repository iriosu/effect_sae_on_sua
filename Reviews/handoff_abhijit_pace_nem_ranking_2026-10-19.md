# Handoff: adopted NEM/Ranking baseline, expanded 2SLS and PACE eligibility

## Latest update — F08.3 operational analysis completed with explicit uncertainty

The current [operational PACE report](../code/analysis_for_adversarial_report_output/f08/operational_eligibility_2026-10-19/operational_pace_report_2026-10-19.md) supersedes the earlier PACE status below. The adopted NEM/Ranking baseline and continuous-score estimates are unchanged.

- Actual school histories, enrollment checks, missing/ambiguous peer membership, percentile roster/tie/quota intervals, regular exams, carryover and prior use are implemented. Official restricted rosters are confirmed for 2022–2026; 2021 is bracketed. Carryover can combine required subjects across valid sittings, correcting five validation failures.
- The public 2026 files recover elective scores and the PACE selection route. The old exclusion of 2026 selection is superseded. The full on-time design is 175,869 students; academic uncertainty falls from 5,434 to 3,875 on the same horizon. Full eligibility has 2,595 unresolved cases.
- Eligibility IV coefficient range: **[-6.84,-2.68] pp**; conservative **95% confidence envelope [-7.49,-2.02] pp**. It remains negative with 0.1% additional adversarial label errors, but includes zero at 0.5%. Recorded PACE selection effect: -0.99 pp, conventional 95% CI [-1.16,-0.82]. These are separate outcome effects, not additive mediation shares.
- Independent administrative-status validation: 49 disagreements among 13,389 determinate explicit 2026 decisions (99.634% agreement); selected-applicant support only. Unresolved/out-of-frame cases are retained. Remaining discrepancies include correct observed scores and graduation-school identifiers, so exact Ranking matching cannot close them by itself.
- New manuscript Appendix Tables D.12–D.13 and Section VI/Appendix D.10 explain the estimates and limits. Old tables remain. Prior section files are backed up in `Others/*_before_pace_operational_2026-10-19.tex`.

Run `Rscript code/run_pace_operational_analysis.R --from-cache` to reproduce events, estimates, validation and tables using the shared private caches; omit the flag for a source rebuild. Use `--tables-only` for aggregate-only table regeneration. Set `SAE_PAPER_ROOT` to the manuscript's `Initial submission` folder to export. All statistical code is in the central notebook's `f08-operational-*` chunks. [Inference proof](../code/analysis_for_adversarial_report_output/f08/operational_eligibility_2026-10-19/inference_method.md) and numerical checks accompany the report.

Private records: `Dropbox/Effect SAE on SUA/data/finalized_design_v1/section3/pace_operational_eligibility_2026-10-19/`. All 13 delivered files have verified sizes and MD5s; see [reproduction instructions](../code/analysis_for_adversarial_report_output/f08/operational_eligibility_2026-10-19/reproduction.md). Git contains aggregate outputs, sources, code and manifests only. The earlier 5,938 unknown count referred to observed-graduation qualification, not the current on-time horizon; do not compare these counts directly.

**Remaining optional information:** official percentile tie/quota rules, the precise 2021 roster and reconciliation of residual administrative/history discrepancies. F08.3's empirical deliverables are complete under partial classification; exact administrative replication is not established. The previous execution history follows and does not create new gates for the adopted baseline.


Updated October 19, 2026, after executing the author-approved expanded-score analysis. **Attendance at a sought-after school, instrumented by its SAE lottery offer, reduces NEM by 0.1647 SD and Ranking by 0.2097 SD in the expanded available-score samples.** The baseline includes non-exam takers with reconstructible scores. Continuous-score estimates and PACE academic-classification diagnostics are complete; full official PACE eligibility remains unresolved. The reconstruction is an adopted research baseline, not a certified reproduction of official scores.

## Earlier expanded-score analysis — PACE details superseded above

Read the [expanded-score and PACE report](../code/analysis_for_adversarial_report_output/f30/expanded_scores_2026-10-19/expanded_scores_and_pace_report_2026-10-19.md). Run `Rscript code/run_adopted_score_analysis.R` from the repository root; it executes eight named chunks in the central Rmd without rerunning earlier reconstruction. Baseline v1 is unchanged. The main draft now uses the separately saved expanded table; its original recorded-score table is preserved.

| Outcome | Original Table 4 | New definition, common observed sample | Expanded sample | Expanded 95% CI | Expanded N |
|---|---:|---:|---:|---|---:|
| NEM (SD) | -0.1796 | -0.1764 | **-0.1647** | [-0.1808, -0.1487] | 154,620 |
| Ranking (SD) | -0.2268 | -0.2238 | **-0.2097** | [-0.2261, -0.1933] | 154,170 |

Original estimates reproduce numerically. RF/FS/IV use identical outcome-specific samples and the finalized controls/inference. Uniform reconstruction, graduation-cohort vintage, on-time scores and older-cohort checks retain negative estimates. On identical reconstructible graduation samples, switching from combined to independent scores changes coefficients by only +0.00035 SD (NEM) and +0.00056 SD (Ranking). All application cohorts have negative point estimates; 2016 is small and imprecise. Estimates, covariances, coverage and numerical checks are in the report directory.

**Selection remains relevant.** The offer lowers expanded NEM availability by 0.708 pp and Ranking availability by 0.666 pp in the fixed 175,869-student design population. There are still 21,249/21,699 missing scores. Restoring the 68/98 original-score raw-source gaps at any process-compatible score gives coefficient-completion ranges [-0.1697, -0.1599] and [-0.2158, -0.2034] SD; these are not confidence intervals and do not address all unresolved outcomes. No original raw values were invented or old/new SD units mixed.

**PACE validation:** absolute-threshold agreement is 99.8805% among 1,033,587 comparisons and 97.2702% among 7,876 PACE-school students within ten points. For the percentile-OR diagnostic, replace only each student's own score while holding the full augmented peer roster fixed and removing their original score from peer counts. Among 196,833 comparable PACE-history graduates, 185,068 have determinate classifications under both versions: 99.9411% agreement, 26 false positives and 83 false negatives. The remaining 11,765 are not counted as matches. At the percentile boundary, 29,026/40,767 comparisons are determinate, with 99.7967% agreement. This validates own-score stability conditional on peer scores, not an official full-roster truth.

The [PACE output folder](../code/analysis_for_adversarial_report_output/f08/eligibility_baseline_v1_2026-10-19/) contains annual/offer checks, error sensitivity, sources and uncertainty decomposition. Resolutions verify the school-history-restricted percentile roster for admissions 2024-2026; extending it to 2021-2023 remains an assumption. School history uses consecutive grade-11/12 records. Among all design students, 5,938 joint graduation/school-history/academic events remain unresolved. The fitted IV coefficient-completion range is [-10.283, -0.291] pp, widening to [-10.405, -0.176] pp under a ten-point allowance for reconstructed-score errors. These ranges omit sampling uncertainty and are not confidence intervals or evidence of statistical significance. Exams, carryover/use and actual selection remain separate.

**Shared private delivery:** `Dropbox/Effect SAE on SUA/data/finalized_design_v1/section3/expanded_score_analysis_2026-10-19/` contains the graduate audit input, compact model summaries and new classification records, with hashes in the report directory. Baseline files remain in the separate `score_baseline_v1_2026-10-19/` folder. No student-level records enter Git.

**Remaining broader work:** address outcome selection and mediation questions. The operational PACE analysis and manuscript exhibits are completed in the extension above. Perfect one-point matching is not a gate. F30.9 and the source-gap/availability audit in F30.10 are complete; F08.3 is now addressed by the operational extension above; broader selection/mediation questions remain open. The execution contract below is preserved for reproduction, rather than a list of unrun analyses.

### Manuscript table integration

The draft now inputs `tables/results/lottery_scores_expanded_2026-10-19.tex` from Section VI, retaining the original `lottery_scores.tex` unchanged. The new file preserves the table label and column layout, updates coefficients/SE/means/N and explains reconstruction and normalization. Nearby text uses 0.165/0.210 SD and updated availability effects. The appendix's original trimming/balance checks are explicitly labeled as pre-reconstruction comparisons. Regenerate only the table with `Rscript code/run_adopted_score_analysis.R --table-only`; set `SAE_PAPER_ROOT` to `Initial submission` for manuscript export. F30.11 records completion, and F30.12 retains the expanded-sample diagnostic follow-up.

## Adopted decision — start here

Use **baseline v1, October 19**. NEM retains the established independent grade/GPA calculation. Ranking adopts `first_pass_reference_only`: narrow same-school HC–HC–TP–TP contexts, reconciled historical GPAs, rounded cohort/context arithmetic and first-passed records for historical peers. Preserve positive recorded scores and use reconstruction when those are unavailable. Exclude peer-based Ranking calibration from the main baseline; retain it only as a separately labeled sensitivity.

**Perfect score replication is no longer a prerequisite for the analysis.** Expanded NEM/Ranking 2SLS, outcome-availability checks and classification accuracy near PACE cutoffs are now completed as reported above. The historical-mean/precision investigation below is optional refinement unless a substantive result is sensitive to it. This decision supersedes earlier instructions to keep the first-pass candidate separate or prioritize further one-point matching.

The [baseline package and manifest](../code/analysis_for_adversarial_report_output/f08/ranking/baseline_v1_2026-10-19/baseline_readme.md) is the authoritative current export. All statistical construction remains in `code/analysis_for_adversarial_report.Rmd`. Private RDS files are in the ignored `code/analysis_for_adversarial_report_output/input/f08/` directory; code, aggregate checks and manifests are committed. Coauthors need the existing private Dropbox inputs/outputs or must regenerate them; a Git clone alone does not contain individual records.

| Private file | Role |
|---|---|
| `score_analysis_baseline_v1_2026-10-19.rds` | 1,286,127 regular-youth graduation records, 2020–2025; key `(MRUN, grad_year)`; observed, reconstructed and combined scores with provenance |
| `section3_score_baseline_v1_2026-10-19.rds` | **Start the new 2SLS here.** All 304,547 original Section 3 panel rows/columns, expanded score outcomes and explicit availability/source flags |
| `missing_scores_baseline_v1_2026-10-19.rds` | All originally missing NEM or Ranking cases, including unresolved records |

The original combined score file and the finalized Section 3 panel are preserved. They are historical comparisons, not the newly adopted score export.

**Shared private delivery:** the same three RDS files are also copied to the coauthors' existing data workspace, `Dropbox/Effect SAE on SUA/data/finalized_design_v1/section3/score_baseline_v1_2026-10-19/`. Use that directory after pulling the code. `shared_private_delivery.csv` verifies byte counts and MD5s against the local exports. `SAE_SCORE_BASELINE_EXPORT_DIR` can override the copy destination; a differing existing version is not overwritten. No individual records are committed to Git.

National validation of the independent calculation remains **98.9797% exact NEM** (1,052,561 observed-score comparisons) and **90.7134% exact Ranking / 96.0694% within one point / 98.1098% within five** (1,033,587 comparisons). Among 209,749 originally missing scores, the cohort baseline supplies 185,216 NEM and 178,638 Ranking values; 24,533 and 31,111 remain unresolved. This validation concerns observed-score students and does not directly establish accuracy among nonregistrants.

### Outcomes and sample contract

- Start from `score_analysis_design_sample == TRUE`: **175,869** members of the finalized lottery sample with its original five controls. Do not restrict on exam participation, college application, original score availability, realized destination-school PACE status or graduation. Keep all these rows for availability and denominator checks.
- Main continuous outcomes are **`NEM_ANALYSIS_Z` and `RANKING_ANALYSIS_Z`**, with `*_ANALYSIS_RAW`, `*_ANALYSIS_YEAR`, `*_ANALYSIS_SOURCE`, `*_ANALYSIS_RECONSTRUCTED` and `HAS_*_ANALYSIS` fields. Each uses the latest positive official score available through admission 2026; when none is available, it uses the linked graduation-cohort baseline. The current outcome extract has priority over the cached registration projection for positive same-process conflicts. Score years/scales travel with the values.
- Graduation-cohort alternatives are `NEM_BASELINE_Z_BY2025`, `RANKING_BASELINE_Z_BY2025` and the corresponding raw fields. These use a unique 2020–2025 regular-secondary graduation and its next-admission-year scale. Their `_OT` versions additionally require graduation by `YEAR + 4`. The `_RECONSTRUCTED_*` versions apply the independent calculation to observed-score students too. These measure a different score vintage from the latest-registration main outcomes; label comparisons accordingly.
- SD units for admissions 2021–2026 use **fixed national graduation-cohort moments**, computed from available observed-plus-reconstructed scores, including nonregistrants. Do not restandardize by offer/attendance or only in the outcome estimation sample. `analysis_standardization.csv` gives all moments and reference counts. Earlier official-score processes, if used, have explicitly labeled observed-score reference moments because those graduating cohorts have not been reconstructed. Raw scores must be compared within compatible process scales.
- Keep unknown scores as `NA`, not zero. A retained panel row need not have a computable score, especially without a supported graduation/history. Report the outcome-specific estimation count and availability effects; an available-score 2SLS is not automatically an unconditional effect for every lottery applicant.

### Verified expanded coverage

In the fixed 175,869-student design population:

| Outcome | Original Table 4 availability | Expanded baseline availability | Newly available students | Still unresolved |
|---|---:|---:|---:|---:|
| NEM | 137,480 | **154,620** | 17,208 | 21,249 |
| Ranking | 137,480 | **154,170** | 16,788 | 21,699 |

The gross newly available count differs from the net increase because **68 NEM and 98 Ranking cases** have an original standardized score but no positive raw value in either available source and no usable reconstruction. Their original standardized columns remain untouched, and `NEM_RAW_SOURCE_UNRESOLVED` / `RANKING_RAW_SOURCE_UNRESOLVED` flag them. Resolve their original source or report the exclusion/sensitivity; do not mix old and new standardized units to fill them. The raw-source audit does not establish that their original score was wrong.

An initial graduation-only merge would also have excluded thousands of already-scored students without a target regular-secondary graduation. The expanded main fields recover their available official values and avoid that graduation restriction. `section3_expanded_coverage.csv` is the main coverage table; `section3_coverage.csv` describes only the narrower graduation-cohort alternatives. Every original panel column is preserved and every row remains present.

### 2SLS specification and required comparisons

Keep the finalized Section 3 design: instrument **`D_OD` with `OFFER`**, with `CHANCE_GROUP` fixed effects, application-year indicators, and `GPA8_Z`, `ES_MUJER`, `PRIORITARIO`, `ALTO`, `ORIGIN_OD`. Use the established heteroskedasticity-robust inference, no clustering in the baseline, `fixef.rm = 'none'`, `ssc(K.adj = FALSE)` for IV, and normal-reference IV p-values. The outcome equation is `Y ~ controls + i(YEAR, ref = 2016) | CHANCE_GROUP | D_OD ~ OFFER`. Reestimate the reduced form and first stage on each outcome's exact estimation sample; do not reuse a first stage from a different sample.

These tasks have now been implemented in `f30-expanded-*`; the results and remaining limits are summarized above:

1. Reproduce the original Table 4 results using the untouched `NEM_Z_LATEST` and `RANK_Z_LATEST` fields. Estimate the new score definition on the common observed sample, then on the expanded sample, so measurement/standardization changes are separated from adding students.
2. Estimate NEM and Ranking RF/FS/2SLS with `NEM_ANALYSIS_Z` and `RANKING_ANALYSIS_Z`; report raw-score checks by compatible admission process, sample counts by application cohort and offer, non-offered means, SEs, confidence intervals and first stages. Keep the national admission-test outcome unchanged; its missing values are not reconstructed here.
3. Estimate offer effects on `HAS_NEM_ANALYSIS` and `HAS_RANKING_ANALYSIS` in the **entire fixed design population**, alongside the original availability indicators. Report new/old-only/unresolved cases by offer and cohort, and examine remaining selection rather than treating score missingness as random.
4. Compare the combined baseline with uniform independent reconstruction where available, the graduation-cohort vintage, and fixed follow-up cohorts. Keep peer-based calibration and cutoff perturbations as sensitivities. Do not condition the main effect on post-offer PACE eligibility or graduating from a particular school.
5. The continuous-score estimates have now been run and checked. The main admission-score exhibit and its accompanying paragraph/availability note now use the expanded estimates; original table files are preserved. Other mechanism exhibits have not been replaced.

Baseline checks completed: all **84 R chunks parse**; the four adoption/export chunks run; saved files preserve original panel columns/row counts and recorded positive scores; national and design-sample coverage counts reproduce; all expanded raw outcomes respect their process-specific scales; standardized/raw availability agrees; and private student-level files remain Git-ignored. `artifact_manifest.csv` records input and output fingerprints.

### PACE eligibility work after adoption

Use the year-specific **percentile OR absolute-threshold** academic rule from `f08/pace_rules_2021_2026.csv`, the appropriate full school reference population, and explicit tie/quota/missing-peer handling. Do not rank only exam takers or only lottery applicants. Preserve graduation-cohort score versions for the academic rule/carryover; the main latest-registration score outcome is not automatically the right eligibility vintage.

Validate false positives/negatives and near-cutoff disagreement by cohort and offer; assess sensitivity to plausible score errors and uncertain peer ranks, and whether estimated eligibility effects materially change. School participation/history, required exams and carryover/use conditions remain separate requirements. PACE application, selection and enrollment are not eligibility. The existing 97.27% agreement near the absolute cutoff is encouraging but does not validate the full OR rule. F08.3 stays open for this work; exact-score improvements are not a blocking gate.

## Earlier diagnostic record — preserved for provenance

The following reports describe earlier stages. Where an older section calls a method a separate candidate or names the morning delivery, the adoption instructions above control.

## Latest test: one-point errors and the shared historical mean

The [one-point report](../code/analysis_for_adversarial_report_output/f08/ranking/one_point_2026-10-19/one_point_report_2026-10-19.md) narrows the next investigation to the historical **mean** and its operational reference records. In the exact-NEM, complete-history, one-context sample, the baseline has 42,007 one-point errors among 842,942 students. Changing only the historical mean by at most 0.02 GPA points can reconcile every interior score in 3,300/3,394 mixed contexts whose errors are all one point (97.23%). A maximum-only change of at most 0.01 works in just 24. Only 404/40,106 interior one-point errors lie at a final half-point rounding threshold. These are feasibility diagnostics, not recovered official benchmarks.

**Retain the independent reconstruction.** None of 34 new arithmetic, interpolation or scale variants improves development-school agreement. The published NEM-cell audit also finds no supported systematic table replacement in admissions 2021, 2022 or 2026. Do not add one point uniformly or choose a formula separately for each student's observed error.

A separate **peer-based calibration diagnostic** is promising: split students within each strict context by MRUN parity, infer an anchor interval from the other half, and change a held-out score only when every feasible anchor implies the same integer. This resolves **24,316/42,007 one-point errors (57.89%)**, resolves 27,473 mismatches overall, introduces **zero new mismatches**, and worsens no existing errors in this evaluation. Clean-sample exact agreement rises from **92.5532% to 95.8124%**, with improvements in every admission year. Of 632,385 uniquely implied predictions, **99.8901%** match. The less conservative midpoint variant resolves more errors but introduces 814, so keep both clearly labeled as diagnostics.

This calibration uses **other students' recorded Ranking**, rather than grades and official rules alone. No held-out student's Ranking enters its prediction, but the clean evaluation requires exact observed NEM and does not establish performance among nonregistrants or complex histories. No delivered score file or eligibility estimate has been replaced. Private `ranking_one_point_peer_diagnostic_2026-10-19.rds` contains the two separate exploratory predictions and training intervals; aggregate outputs, input hashes and the reproduction instructions are shared. Run the `f08-one-point-*` chunks after `f08-score-reconstruction-functions`.

Next: obtain or independently reconstruct the operational historical means; audit reference-roster completeness, historical GPA provenance and grade revisions near mean-rounding boundaries. If pursuing peer calibration as an imputation sensitivity, validate additional fixed folds and applicability beyond this clean sample before using it for PACE mechanism estimates. F08.3 stays open.

## Earlier test: national performance panel and full histories

The author's suggested source was checked against the [MINEDUC collection](https://datosabiertos.mineduc.cl/rendimiento-por-estudiante-2/) and a newly downloaded `/Grade Inflation/Data/Master/panel_performance_2002_2025.rds`. The existing calculation already uses the 2002–2023 panel plus 2024–2025 grades. The [performance-panel report](../code/analysis_for_adversarial_report_output/f08/ranking/performance_panel_2026-10-19/performance_panel_report_2026-10-19.md) records source provenance, comparison checks, NEM tests and nine Ranking candidates.

**Retain the existing reconstruction.** On the common 2010–2025 high-school domain, all grades and passed-grade classifications agree; 1,365 literal record differences concern blank/missing final-status labels only. Source refresh leaves NEM at 98.9797% exact on 1,052,561 existing cases and Ranking at 90.7134% on 1,033,587 cases. Extending historical records back to 2002 fixes 22 Ranking errors but introduces 115. Performance-only historical references fall to 87.9177% exact versus 90.7258% for the baseline on their common 1,033,029 cases, and lose 558 previously calculable observed scores. In the exact-NEM/full-history clean subset, they fall to 89.1542% versus 92.5633% on 842,521 cases. Reversing the historical GPA-source priority on a preserved roster, separately changing the mean or maximum, and using unrounded performance GPAs also worsen matching.

Own-history recovery still validates poorly: the 92 newly reconstructible observed NEM cases match only 56.52%. Extending own histories to 2002 resolves 14 NEM mismatches, introduces 46 and loses four previously calculable observed cases. None of these new candidates replaces existing deliveries. Prioritize the shared score curve and operational reference/arithmetic definitions; adding this panel or pre-2010 records does not solve the residual gap. F08.3 remains open.

Run `f08-score-reconstruction-functions`, followed by `f08-performance-source-audit`, `f08-performance-reference-candidates`, `f08-performance-validation`, `f08-performance-nem-audit`, `f08-performance-record-differences` and `f08-performance-panel-report`. The new master, projected grades, histories, source-difference records and candidate scores remain private under ignored `input/f08/`; the report, aggregate tables and source/hash manifests are shared. The source-difference cache must be invalidated if replacing its input files.

## Earlier diagnostic: same context and actual classroom

The [within-context report](../code/analysis_for_adversarial_report_output/f08/ranking/within_context_2026-10-19/within_context_report_2026-10-19.md) restricts to 842,942 graduates with exact independently reconstructed NEM, complete four-grade histories, one accepted context, three reference cohorts and adequate school/modality counts. Exact contexts hold all four school IDs, attendance years and teaching codes fixed. Raw 2023 grades recover actual classroom letter/session for all 148,084 clean-sample graduates that year; earlier classroom identifiers are not used.

- Mixed matches are common: 6,765 exact-context groups across all six admission years; 2,188 of 7,973 actual 2023 classroom-context groups with at least two students. Removing floors and caps still leaves 1,516 mixed classroom groups.
- Identical inputs behave consistently: among 21,236 same-class/context/GPA groups (46,479 students), none has differing recorded Ranking. Among all six cohorts' 176,079 same-context/GPA groups, only one three-student group differs (admission 2021, 14 points). None of 9,108 exact-context groups with identical four annual grades differs in recorded Ranking.
- Common benchmark errors can produce different integer errors at different own GPAs. Correct NEM does not validate historical means or maxima. Allowing a shared continuous maximum while holding the mean/formula fixed can reconcile only 18.34% of mixed classroom groups (13.37% across all exact contexts). Prioritize historical-mean construction and arithmetic jointly with the maximum; inspect the lone equal-GPA anomaly separately. These are diagnostics, not certified causes or outcome-calibrated imputations.

Run `f08-score-reconstruction-functions`, `f08-ranking-remaining-patterns`, `f08-ranking-classroom-map`, `f08-ranking-within-context`, then `f08-ranking-within-context-report` from `code/`. Raw classroom data, the class map and the diagnostic records remain private under ignored `input/f08/`; source metadata, aggregate results and an anonymous classroom score example are shared. All 66 R chunks parse; the new chunks and substantive assertions pass. Existing scores and manuscript estimates are unchanged; F08.3 remains open.

## Earlier diagnosis: what still drives mismatches

[Remaining-discrepancy patterns](../code/analysis_for_adversarial_report_output/f08/ranking/remaining_patterns_2026-10-19/remaining_discrepancy_patterns_2026-10-19.md) uses the first-pass historical-reference candidate on the same 1,033,587 validated students (95,985 mismatches). Small-school pooling is not the main observed-error pattern: 99.41% of mismatches have school-wide historical graduation counts >=30 in every context; 93.45% still do when counts are split by HC/TP modality. This conclusion concerns reconstructible scores; small references excluded from scoring remain a coverage problem.

Most mismatches are small (57.67% exactly one point; 79.65% at most five). The clean group with exact NEM, one accepted context, three observed cohorts and adequate school/modality counts accounts for 65.40% of mismatches. By contrast, NEM-mismatched students are only 1.02% of the validated sample but account for 31.92% of total absolute Ranking error and 47.06% of errors over five points. Technical graduates and school/modality changers have higher error rates, but most mismatch counts still occur in larger, simpler-history groups.

Prioritize academic-record reconciliation for large errors and historical benchmark/precision checks in the exact-NEM clean group for the bulk of small differences. These are diagnostic hypotheses, not identified causes. The two `f08-ranking-remaining-patterns*` chunks generate aggregate shares, joint strata, coverage and an explicitly ordered non-overlapping decomposition. Candidate scores and manuscript estimates are unchanged.

## Latest follow-up: short historical records and first-passed grades

See [the short-history report](../code/analysis_for_adversarial_report_output/f08/ranking/short_history_2026-10-19/short_history_report_2026-10-19.md) and its linked official-source review. DEMRE and MINEDUC agree on pooling schools below 30 graduates and permitting one/two available cohorts above 30. Our code already permits incomplete cohort counts. The more detailed 93-student/commune–province–region procedure in the 2025 committee annex begins in admission 2028 and must not be applied to this sample.

- Among 15,330 validated graduates with one/two usable context cohorts and more than 30 records, 80.82% match; they account for 3.06% of remaining mismatches and 13.32% of absolute error. Most remaining mismatches have three usable cohorts.
- Six diagnostics varied the count unit (school or school-modality graduates) and pooling (none, small peers, all comparable peers). All pooling approximations introduce more mismatches than they resolve. None is adopted. Exact operational pool memberships remain unavailable in the reviewed public sources.
- MINEDUC's current rules and 2018 manual specify the first passed instance when a grade is approved in different years. The separate historical-peer correction improves exact Ranking agreement from **90.7017% to 90.7134%** on the same 1,033,587 observed-score students: 173 resolved, 52 introduced, net 121. Agreement improves in every admission year. This is a **small promising candidate**, not a replacement for the preserved accepted delivery or certified official reconstruction.
- Recovering the students' own histories is unreliable: new NEM matches only 56.52% of 92 observed cases, and new Ranking 48.24% of 85. Do not blindly fill those cases. Same-year conflicts remain unresolved; chronological order is not guessed.

Code chunks: `f08-ranking-short-history-setup`, `f08-ranking-short-history-candidates`, `f08-ranking-first-pass-history`, `f08-ranking-first-pass-validation`, `f08-ranking-short-history-report`, preceded by the shared scoring-functions chunk. Private `input/f08/ranking_first_pass_candidates_2026-10-19.rds` stores all three first-pass variants; use `first_pass_reference_only` for the promising historical-peer sensitivity. The original narrow HHTT candidate is preserved. Reports, source notes, aggregate results and input hashes are shared; F08.3 stays open and manuscript estimates are unchanged.

## Latest requested test: four annual scores, October 19

The [annual-score test](../code/analysis_for_adversarial_report_output/f08/ranking/annual_test_2026-10-19/annual_ranking_test_2026-10-19.md) implements the author's suggested four annual Ranking calculations followed by averaging. **It does not improve replication.** For the same 21,139 TP-to-HC switchers, the latest context candidate matches 88.45% exactly (MAE 0.502); annual averaging with otherwise unchanged benchmark/formula conventions matches 28.38% (MAE 3.833). It worsens every admission year, 2021–2026. Additional pooled-reference/formula variants also worsen replication. The annual-only code exactly reproduces the context implementation for all 2,988 available histories with four one-year contexts.

The linked current DEMRE webpage describes annual averaging; dated guides describe context averaging. Its embedded interior equation could not be visually retrieved, so the two converted-score equations tested are explicitly sensitivities, not a verified transcription. Resolve this source/operational discrepancy before calling any reconstruction official. Retain the previous narrow HHTT candidate provisionally. All annual diagnostics are separate; existing score deliveries, NEM calculation and manuscript estimates are unchanged.

New notebook chunks: `f08-ranking-annual-setup`, `f08-ranking-annual-candidates`, `f08-ranking-annual-report`, preceded by `f08-score-reconstruction-functions`. Aggregate tables/report are in `f08/ranking/annual_test_2026-10-19/`; private candidates are in `input/f08/ranking_annual_candidates_2026-10-19.rds`. The report supplies definitions, limitations, checks and reproduction instructions. F08.3 remains open.

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

For current work, start with the adopted-baseline instructions above and the [baseline package](../code/analysis_for_adversarial_report_output/f08/ranking/baseline_v1_2026-10-19/baseline_readme.md). The [iterative score report](../code/analysis_for_adversarial_report_output/f08/ranking/ranking_iterative_report_2026-10-19.md) describes the preserved morning delivery; the [broader PACE findings](../code/analysis_for_adversarial_report_output/f08/pace_findings_2026-10-19.md) describe institutional and route-data checks. The [review checklist](adversarial_report_action_checklist_2026-10-17.md) records author decisions and leaves F08.3/F30 open for eligibility and expanded-score estimates.

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

## 4. Archived morning outputs for missing NEM and Ranking

**Historical snapshot only:** `input/f08/score_reconstruction_records.rds` is the preserved morning delivery. Use `score_analysis_baseline_v1_2026-10-19.rds` and the linked Section 3 panel above for new analyses. The national files have one row per `MRUN, grad_year`; `admission_year = grad_year + 1`. Do not merge stacked cohorts/processes on MRUN alone without a documented unique-student/horizon rule.

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

### Other earlier files that should not be mistaken for the adopted baseline

- `ranking_augmented_graduates.rds`: **original** Ranking reconstruction and provisional percentile bounds; not the latest candidate.
- `ranking_refined_validation_records.rds`: intermediate historical-GPA/broad-modality candidate, before the final cohort-mean/context-rounding changes.
- `ranking_context_score_rounding_candidates.rds`: contains several final-stage variants; the selected one is `variant == "context_round"`.
- `ranking_reconstruction_report_2026-10-19.md`, `ranking_validation.html`, `ranking_iterative_report_2026-10-19.md`, and the main generated HTML/Markdown notebook are earlier snapshots. The authoritative adopted export is now **`ranking/baseline_v1_2026-10-19/`**. The full notebook has not been reknit after the final iterations; the new chunks were executed directly.

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
| `f08-adopted-score-baseline`, `f08-adopted-score-panel`, `f08-adopted-score-expanded-panel`, `f08-adopted-score-manifest` | Adopted national baseline, full Section 3 linkage, retention of available official scores, coverage/normalization/source audits and manifests |

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
  "input/f08/score_analysis_baseline_v1_2026-10-19.rds")))
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

1. **Reproduce the completed analysis when inputs change.** Run `Rscript code/run_adopted_score_analysis.R`; baseline hashes must match. Original Table 4 reproduction and the source-gap completion check are built in. Do not rerun expensive reconstruction merely to reproduce estimates.
2. **Address remaining outcome selection.** Expanded estimates and availability effects are complete, but 21,249/21,699 scores remain unavailable. Any always-observed or unconditional interpretation needs additional assumptions and a justified selection sensitivity. Source gaps alone cannot explain the negative estimates.
3. **Resolve PACE operational classification.** Own-score threshold/OR validation, by-year/offer checks and +/-1/5/10-point sensitivity are complete. Recover operational school-history/percentile rosters and tie/quota rules, especially nonconsecutive histories and admissions 2021-2023. Keep uncertain events explicit; the report decomposes their causes.
4. **Complete habilitation and selection channels where data permit.** Joint school/academic event completion ranges use the full design population. They are not full eligibility or inference intervals. Add exam sitting, carryover/prior use and sampling uncertainty separately; do not condition causal mechanism claims on realized PACE destination or graduation. Keep 2026 route outcomes unavailable until recovered.
5. **Complete remaining manuscript diagnostics.** The expanded admission-score table and accompanying text are integrated (F30.11), and the original table is preserved. Reestimate expanded-sample balance/probability-group exclusions (F30.12); old appendix checks are now labeled as original-sample comparisons. No imputed PACE-eligibility exhibit has been inserted. F08.3 and broader mechanism/selection tasks remain open.
6. **Optional further score refinement.** Investigate historical means/rosters, grade versions, remaining NEM discrepancies and the operational arithmetic conflict if classification or effect estimates are sensitive. Keep improvements independently validated and versioned; do not tune rules using individual observed Ranking or desired treatment estimates. These unresolved exact-score issues no longer block proceeding with the author-approved baseline.

## 7. Draft status and author decisions to preserve

F08.1, F08.2 and F08.4 are marked revised. Background, mechanism text, appendix rules and table notes were updated to distinguish recorded selection from eligibility and describe the limits of the old accounting. Ignacio approved the short PACE paragraph in `sections/3_background.tex`, with a footnote saying the qualifying percentage ranged from 15% to 25% and referring to the appendix table. Keep that concise wording; the detailed annual rules belong in the appendix. The earlier manuscript update was compiled and visually checked; the subsequent iterative score audit did not change manuscript estimates.

Related earlier work is recorded in the checklist: F03.3 and F03.4 were reviewed and postponed as noncritical; Ignacio explicitly retained his political discussion. F04.4 entrant-count work is complete in `f04_entrant_counts.R` and `output/f04/`. Its unbalanced-panel count intervals include zero for both income groups, while the low-income share rises. This supports a composition result more clearly than an increase in low-income entrant numbers; it does not prove counts are unchanged. The income-count paragraph in `4_access.tex` is currently commented out and should remain so unless Ignacio requests otherwise.
