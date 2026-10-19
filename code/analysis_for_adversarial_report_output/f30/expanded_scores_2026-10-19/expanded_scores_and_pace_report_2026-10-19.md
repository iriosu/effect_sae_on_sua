# Expanded NEM/Ranking effects and PACE academic classification

October 19, 2026. Baseline v1 is unchanged. These results use the adopted expanded outcomes and the finalized Section 3 lottery design. A separately named expanded table is exported for the manuscript; the original recorded-score table is retained for comparison.

## Continuous score results

Including students without originally observed admission scores modestly reduces the magnitude of both negative estimates. The original Table 4 estimates reproduce to numerical precision. Score units and score vintage also change; the common-sample comparison separates those changes from adding students. Differences between reported coefficients are descriptive, not formal difference tests.

| Outcome | Definition/sample | N | 2SLS (SD) | Robust SE | 95% CI |
|---|---|---:|---:|---:|---|
| NEM | Original Table 4 | 137,480 | -0.1796 | 0.0088 | [-0.1969, -0.1624] |
| NEM | New definition, common observed sample | 137,412 | -0.1764 | 0.0086 | [-0.1933, -0.1595] |
| NEM | New definition, expanded sample | 154,620 | -0.1647 | 0.0082 | [-0.1808, -0.1487] |
| RANKING | Original Table 4 | 137,480 | -0.2268 | 0.0089 | [-0.2443, -0.2092] |
| RANKING | New definition, common observed sample | 137,382 | -0.2238 | 0.0088 | [-0.2411, -0.2065] |
| RANKING | New definition, expanded sample | 154,170 | -0.2097 | 0.0084 | [-0.2261, -0.1933] |

The common observed samples contain 137,412 NEM and 137,382 Ranking observations. In the original units on these same samples, the coefficients are -0.1801 and -0.2273. Thus only a small portion of the original-to-expanded change comes from units/vintage or the raw-source exclusions; most comes from adding students. The new-sample first stages are 0.62757 (NEM) and 0.62777 (Ranking). Reduced forms are -0.10339 and -0.13163 SD. The unchanged reading-mathematics estimate is in `score_effects.csv`.

The 175,869-student design population is fixed before observing outcomes. Available outcomes rise from 137,480 each to 154,620 NEM and 154,170 Ranking, leaving 21,249 and 21,699 unresolved. We include non-exam takers whenever a score can be reconstructed; this is not an unconditional score effect for all applicants. Scores can remain unavailable or undefined without supported graduation histories.

## Availability and sensitivity

| Availability | N | Offer effect (pp) | 95% CI (pp) |
|---|---:|---:|---|
| HAD_NEM_ORIGINAL | 175,869 | -0.549 | [-1.024, -0.075] |
| HAS_NEM_ANALYSIS | 175,869 | -0.708 | [-1.088, -0.327] |
| HAD_RANKING_ORIGINAL | 175,869 | -0.549 | [-1.024, -0.075] |
| HAS_RANKING_ANALYSIS | 175,869 | -0.666 | [-1.050, -0.282] |

Offer-induced differences in availability remain. Do not interpret the observed-score 2SLS as identifying the effect for all applicants or an always-observed population without additional assumptions.

Graduation-cohort combined outcomes give -0.1654 SD NEM and -0.2111 SD Ranking. Uniform independent reconstruction gives -0.1661 and -0.2064 SD. On the identical reconstructible graduation sample, switching from combined to independent calculation changes NEM by only +0.00035 SD and Ranking by +0.00056 SD. On-time-graduation score sensitivities and applications 2016-2019 give similar negative results. Every application cohort has a negative point estimate; the 2016 cohort is small and imprecise. These are available-outcome comparisons, and graduation vintage/horizon restrictions change their estimands.

Restoring the 68 NEM and 98 Ranking raw-source gaps at any score within the pooled process-compatible support gives fitted 2SLS coefficient ranges [-0.1697, -0.1599] and [-0.2158, -0.2034] SD, respectively. These are completion ranges, not confidence intervals, and concern only original-score source gaps. They do not address all remaining missing outcomes.

Raw-score regressions are supplied separately for compatible admission processes. Conditioning on the score process is a descriptive scale/vintage check. The seven students scored in admission 2020 do not support the fixed-effect specification, so those two raw-process regressions are explicitly not estimated.

## PACE academic classification

The annual percentile OR absolute rule is applied to the national graduation cohorts, never just exam takers or lottery applicants. Academic classification uses the graduation-cohort Ranking vintage, not the latest-registration main score outcome. Official resolutions confirm that the percentile reference is restricted to graduates meeting the school-history requirement in admissions 2024-2026. Applying that reference to 2021-2023 remains a historical-rule assumption; the full-graduating-cohort diagnostic is retained. See the [2024 resolution](https://dfi.mineduc.cl/wp-content/uploads/sites/114/2023/06/Rex3625-2023_aprueba-criterios-prehab-y-habilitacio%CC%81n-PACE2024.pdf), [2025 resolution](https://acceso.mineduc.cl/wp-content/uploads/2024/07/REX-5543-APRUEBA-CRITERIOS-PACE.pdf), and [2026 resolution](https://acceso.mineduc.cl/wp-content/uploads/2025/06/REX-N%C2%B0-7447-PACE.pdf).

School history retains the earlier audit measure: a participating graduation school and participating grade-11 school in the preceding year. Missing, conflicting and nonconsecutive histories are not certified. Official operational rosters and tie/quota rules remain unavailable. We use worst tied rank/floor quota for a guaranteed pass and best tied rank/ceiling quota for a possible pass, allowing unresolved peers and unknown school histories to affect the ordering. These intervals condition on the chosen roster/history assumptions; they are not certified official eligibility.

The independent Ranking calculation agrees with the recorded-score absolute-threshold indicator for 99.881% of 1,033,587 comparisons. Among PACE-school graduates within ten points of the threshold, agreement is 97.270% (N=7,876; 76 false positives and 139 false negatives).

For the full OR diagnostic below, each validated student's own recorded Ranking is replaced by their independently reconstructed Ranking while every other peer's combined baseline score is held fixed. The student's original score is removed from their peer count. The denominator includes all qualifying peers and unresolved members. This tests individual classification stability; it does not establish an official full-roster ground truth or validate simultaneous errors in all missing peers.

| Validation subset | Comparable | Determinate for both | Agreement | False positive / negative |
|---|---:|---:|---:|---|
| All comparable | 196,833 | 185,068 | 99.941% | 26 / 83 |
| Within 10 of absolute threshold | 7,483 | 6,081 | 98.948% | 13 / 51 |
| Within 2 rank positions of quota | 40,767 | 29,026 | 99.797% | 11 / 48 |

Agreement is reported only when both classifications are determinate. The 11,765 unresolved comparisons in the overall PACE-history row are retained and reported, not treated as matches. Annual determinate agreement is 99.876%-99.984%. Conditional measurement-error regressions show no statistically detectable offer difference: in the PACE-history lottery subsample the OR-error offer effect is +0.034 pp (95% CI -0.060 to +0.128 pp); this does not prove measurement error is absent or ignorable for nonregistrants.

## Joint school/academic event and unresolved scope

Across all 175,869 lottery design students, 5,938 have an unresolved joint graduation/school-history/academic classification at the baseline. They comprise:

- Unresolved PACE school history: 2,993 students.
- Peer ranks, ties, quota or score-error sensitivity: 2,621 students.
- Unresolved own Ranking:   324 students.

The fitted joint-event IV coefficient ranges from -10.28 to -0.29 percentage points over all individual completions of those interval outcomes. Allowing every reconstructed score to differ by up to ten points changes this to [-10.40, -0.18] pp. These are conservative coefficient ranges without sampling uncertainty, not confidence intervals or proof of a statistically negative effect. Regressions of the lower/upper event indicators are also exported but must not be mistaken for effect bounds: residualized-instrument weights have both signs.

This joint event is a prehabilitation diagnostic. Regular exam sitting, full habilitation, carryover, prior use, application, selection and enrollment are separate. No full eligibility indicator, causal mediation share or 2026 PACE selection route is asserted. The score reconstruction is adequate to proceed with continuous-score analysis and classification sensitivity; the next PACE gains come chiefly from resolving histories and the operational roster/tie rule, rather than chasing exact one-point matches.

## Reproduction and deliverables

Run `Rscript code/run_adopted_score_analysis.R` from the repository root. It executes only the eight named analysis/report/table chunks in the central Rmd (no full reconstruction or earlier notebook sections). Dependencies are data.table, fixest >= 0.13.0 and knitr for the wider notebook; ggplot2 is optional for the comparison figure. The baseline inputs are fingerprinted and unchanged. Coauthors need the private baseline folder and `graduates_pace_audit.rds`, delivered in the adjacent shared analysis folder.

The specification instruments D_OD with OFFER, holds CHANCE_GROUP fixed effects, application-year indicators and the five original controls fixed, and reestimates RF and first stage on each outcome-specific sample. OLS uses HC1/t inference; IV uses HC0/normal inference. No clusters or outcome-specific restandardizations are introduced. The small process-specific cohort checks change the year reference as needed without changing the span of controls.

Main estimates, all coefficient covariance matrices, estimator identities, coverage by year/offer, source-gap ranges and the comparison figure are in this directory. PACE validation, by-year/offer diagnostics, roster sources, uncertainty decomposition and coefficient completion ranges are under `../../f08/eligibility_baseline_v1_2026-10-19/`. Student-level records remain Git-ignored and in the shared private data workspace. The existing full HTML/Markdown notebook is an earlier snapshot; this report and the new CSVs are the current results.

Checks: exact original-score reproduction; identical RF/FS/IV samples; Wald and FWL coefficient identities; independently calculated OLS HC1 SEs; original input hashes; percentile tie/missing-peer/own-score replacement boundary tests; monotonic widening of classification intervals with larger error bands; complete 175,869-student event/availability denominators; and no individual records in public output.
