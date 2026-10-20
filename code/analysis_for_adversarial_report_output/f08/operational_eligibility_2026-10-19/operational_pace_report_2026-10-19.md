# F08.3 operational PACE analysis — October 19, 2026

**Status:** the reproducible analysis and manuscript exhibits are complete using explicitly partial eligibility classifications. This does not certify every administrative eligibility label. Historical ambiguity and input discrepancies are retained as uncertainty/sensitivity, not filled to match administrative outcomes. The adopted NEM/Ranking score files are unchanged.

## Main results

| Outcome | Nonoffer mean (%) | IV range (pp) | 95% envelope (pp) | Uncertain |
|---|---:|---:|---:|---:|
| PACE school history | [25.12, 26.08] | [-16.09, -13.23] | [-16.95, -12.38] | 1593 |
| School and academic qualification | [6.10, 8.73] | [-8.55, -2.06] | [-9.42, -1.19] | 3875 |
| PACE eligibility | [5.49, 7.30] | [-6.84, -2.68] | [-7.49, -2.02] | 2595 |
| PACE application record | 10.11 | -5.92 | [-6.41, -5.43] | 0 |
| Recorded PACE selection | 1.22 | -0.99 | [-1.16, -0.82] | 0 |

The exact adopted-v1 academic proxy has 5434 uncertain on-time outcomes; the revised construction has 3875 on the identical 175,869-student population. The earlier 5,938 figure concerned qualification at observed graduation, a different horizon, and should not be compared directly with the on-time count.

The expanded score results and their existing manuscript table remain unchanged. These eligibility effects do not separate the academic channel from school participation and do not identify a causal mediation share. School exposure, joint qualification, eligibility, application appearance and selection are distinct outcomes, not an accounting decomposition.

## Construction and substantive changes

- Actual school histories replace the preceding-year shortcut. All observed grade-11 histories before graduation and graduation-year grade-12 records are linked to independent annual school lists. Consistent participation across multiple schools can be classified; conflicting participation, pre-2019 roster gaps, absent records and conflicting graduation years remain unknown. School enrollment records supplement and audit performance records. No application-based school override is used.
- Full national graduating cohorts supply the percentile references. Ambiguous graduation schools contribute possible peers to each observed candidate school; no such graduate lacks a candidate school in these inputs. This prevents omission of ambiguous peers from silently narrowing intervals. Missing scores span the process-specific score scale.
- MINEDUC resolutions confirm the school-history-restricted reference for admissions 2022–2026. The 2021 resolution/annual guide do not establish the later restriction, so the main interval spans both full-roster and restricted-roster interpretations. Lower/upper ranks and floor/ceiling quotas cover unresolved percentile tie/quota conventions. Program-selection PPP tie-breaking is not substituted for percentile tie-breaking.
- Exam completion uses current regular subject scores for new graduates. Carryover allows subjects to be completed across the originating regular sitting and the next process's winter/regular sittings by the results date. The previous complete-set-within-year requirement incorrectly rejected five administratively eligible 2026 carryover applicants; combining valid subject sittings resolves that diagnostic.
- Carryover retains the originating cohort's academic rule and expiration date. It is not recalculated against the next graduating class. SIES enrollment at any of the 29 PACE universities removes already-used eligibility, regardless of admission route, conditional on first-process habilitation. Guaranteed/possible prior use are reported separately. No 2027 outcome is asserted.
- The complete 2022 registrant file recovers 192 records omitted from the harmonized extract. New public 2026 registrant and application files recover elective scores and TIPO_PREF, making 2026 PACE selection observable. The 2026 selection count is 2,730 nationally. The former route-coverage restriction is superseded.

## Validation and uncertainty

Among 2026 applicants with an explicit administrative eligibility decision and a determinate constructed label, 49 of 13389 disagree (agreement 99.634%). This is selected-applicant validation, not population accuracy. All unresolved and out-of-frame comparisons remain in administrative_status_2026_validation.csv.
The remaining academic disagreements use observed Ranking scores. For the current graduating cohort, all 43 initial academic contradictions also match the new DEMRE score and graduation-school field: 34 official-positive cases lie below our possible percentile boundary, and nine official prehabilitation denials exceed the absolute threshold under our school-history measure. Thus score reconstruction alone cannot resolve these cases. They implicate reference-population, history, administrative-vintage or implementation differences; the cause is not proven. No official status is used to recalibrate scores or overwrite a school history.

Score-error variants allow independently reconstructed scores to differ by 1, 5 or 10 points, propagating changes through peer ranks. Separate full-roster and min/max-tie quota variants are retained. Additional_misclassification_stress.csv allows 0.1%, 0.5% or 1% of the entire design population to have erroneous determinate labels, allocated adversarially. These are assumed budgets, not transported validation error rates.

## Inference

The design, controls, chance-group effects, application-year effects and outcome-independent population follow the finalized Section 3 specification. RF uses HC1/t; IV uses HC0/normal, with a reestimated identical-sample first stage. All ordinary identities and independent robust-SE checks pass. No outcome-conditioned sample is used.
For each interval outcome, the coefficient is linear in individual outcomes after residualizing the offer. Its minimum and maximum therefore allocate unresolved labels by the sign of the residualized-instrument weight. The confidence envelope adds a conservative upper bound on the robust SE across every completion. This differs from regressing the lower and upper outcomes and calling those effects bounds. The method contains the usual Wald interval for any admissible actual completion under the maintained IV and sampling assumptions. It is an outer confidence envelope, not a sharp identified set or a finite-sample guarantee. See inference_method.md for the derivation and the additional-error extension.
Validation includes exact FWL/Wald coefficients and HC0 SE against fixest for midpoint and extremal completions, exhaustive enumeration of 64 completions in a small design, percentile boundary tests, monotonic score-error intervals, full denominators, and unchanged baseline hashes.

## Remaining external information, not silently assumed

Official percentile tie/quota implementation, the 2021 operational roster, complete early/conflicting school records, and reconciliation of the residual administrative contradictions would tighten or validate classifications. They are not required to run the reported partial-classification analysis, but prevent claiming exact administrative replication. The additional-error table states the practical limits of the inference.

## Reproduction

`Rscript code/run_pace_operational_analysis.R --from-cache` reruns events, estimates, validation and tables from the shared private classification and sitting caches. Without that flag it rebuilds histories, exams and classification from the listed source inputs. `--tables-only` regenerates TeX and this report from aggregate CSVs. Set `SAE_PAPER_ROOT` to the manuscript's `Initial submission` directory to export the two dated TeX files. Statistical code is entirely in the central Rmd's `f08-operational-*` chunks.
Private files are delivered to `Dropbox/Effect SAE on SUA/data/finalized_design_v1/section3/pace_operational_eligibility_2026-10-19/`; a Git clone alone does not contain individual records. The full rebuild additionally needs the previous performance/score inputs and public admissions archives (see fetch_pace_operational_sources.py). Building enrollment projections from the original 1 GB SIES file can use approximately 15 GB of memory; cached analysis uses substantially less.

## Official sources

- [Admission 2021 original resolution](https://www.diariooficial.interior.gob.cl/publicaciones/2020/07/22/42711/01/1787650.pdf).
- [Admission 2022 resolution 3395](https://acceso.mineduc.cl/wp-content/uploads/2022/01/REX-3395-de-2021-SUBESUP.pdf), article 1 and footnote 1.
- [Admission 2023 resolution 2625](https://www.bcn.cl/leychile/navegar?idNorma=1177426), article 1 and footnote 1.
- [Admission 2024 resolution 3625](https://www.bcn.cl/leychile/navegar?i=1193966), articles 1–2.
- [Admission 2025 resolution 5543](https://acceso.mineduc.cl/wp-content/uploads/2024/07/REX-5543-APRUEBA-CRITERIOS-PACE.pdf).
- [Admission 2026 resolution 7447](https://acceso.mineduc.cl/wp-content/uploads/2025/06/REX-N%C2%B0-7447-PACE.pdf).
- [MINEDUC public admissions files and data dictionaries](https://datosabiertos.mineduc.cl/pruebas-de-admision-a-la-educacion-superior/). Public 2026 files were posted in July 2026; dictionaries distinguish PACE status 51 (prehabilitation denial), 52 (habilitation denial), and 24/25 (selected/waitlisted). Other status codes are not treated as eligibility ground truth.
