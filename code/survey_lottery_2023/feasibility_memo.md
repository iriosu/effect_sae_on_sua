# Feasibility memo and first results: Mistakes surveys and the school-lottery sample

11 November 2026. Sections 7 and 8 were added the same day, after the first results. Issue: https://github.com/iriosu/effect_sae_on_sua/issues/22.
Branch `survey-lottery-2023`, created from `finalized-design-v1` at commit `251e9ef20ebdd1836737df8651100d1730b2aba3`. The analysis is kept on this branch and is not merged. The authors decided on 11 November 2026 not to add it to the paper now.

Numbers marked "actual" come from the scripts of this folder, run on 11 November 2026.
Numbers marked "projected" were computed earlier from committed October aggregates and are kept only for comparison.
The analysis is exploratory. Specifications were written in `specification_log.md` before the estimates.

## 1. Summary

- The link works. Every one of the 39,051 students of the 2023 baseline survey is found in the public registration file of the 2023 process, and 4,091 are in the lottery sample (actual).
- The cohort scheduled for the 2023 process is application year 2018: 34,052 lottery children with every control. Of them, 23,283 registered for the 2023 tests, 3,680 started the baseline, and 1,342 completed it (actual).
- The offer lowers the chance of being observed. In the 2018 cohort it lowers registration by 2.7 pp (SE 0.6) and starting the survey by 0.95 pp (SE 0.42), from 11.2 percent without offer (actual).
- No main outcome shows an offer effect. The six point estimates are below 0.05 SD in absolute value, and every Holm-adjusted p-value is 1.00 (actual).
- The three smallest unadjusted p-values are in admission and cutoff beliefs (0.016 to 0.028). None survives the adjustment within the family (q = 0.17). Every interval for the trimming bounds includes zero.
- No attendance effect (IV) is reported for a baseline outcome of step 3. No outcome there meets the conditions of the specification log.
- Family D is complete (Section 7). The public files of applications of the 2023 process are in `~/Dropbox/Mistakes Structural/Data/2023/input/`. Among survey-linked children, no offer effect is detected on listing the top true program, on inadmissible applications, or on the risk of no assignment (q of 0.80 or more).
- In the whole cohort, the offer lowers the probability of admission of the final list by 2.0 pp (SE 0.6), counting a child without an application as zero. It does not change inadmissible applications (Section 7).
- The offer raises expected minus realized Ranking by 18.2 points (SE 8.3) among children who answered. Realized Ranking falls by about 21 points in the whole cohort, and no change in expected Ranking is detected (-2.4, SE 8.9). The row stays inconclusive (Section 8).
- The design detects offer effects of about 0.13 to 0.16 SD for items asked of every respondent, 0.22 to 0.30 SD for items in two or more random groups of questions, and 0.50 SD for the annual payment, asked in one group (actual standard errors).

## 2. Sources

| Source | Path | Version |
|---|---|---|
| Lottery sample | `~/Dropbox/Effect SAE on SUA/data/finalized_design_v1/mechanisms/mechanisms_panel.rds` | MD5 `8d1b6996f18f2d678b543c4428567709` (matches the manifest); 186,440 children, 185,970 with every control |
| Mistakes replication package | `~/Dropbox/mistakes_replication/replication_package` | git `master` at `11ec15fbe445b56f5544e1e9b5d9a0b1e48d6825`; `Data/` is not tracked |
| 2023 baseline export | `Data/qualtrics_exports/Baseline survey mistakes 2023_January 3, 2023_09.csv` | SHA-256 `594ef6c268a43bdcad359c02b4d3fd1db78a831493ab8179166ac53cbce8cd44` |
| 2023 endline exports | `Data/qualtrics_exports/Endline survey mistakes 2023_January 17, 2023_17.05.csv` and `... - Fixings_January 17, 2023_17.10.csv` | MD5 in `logs/04_endline_overlap.txt` |
| Public registration file of the 2023 process | `Data/survey_2023/A_INSCRITOS_PUNTAJES_PAES_2023_PUB_MRUN.csv` | SHA-256 `64adf9a1bd76624253b8939578e0764ac34eb8a69fe99500e69d3edef5161d8d`; 296,812 rows |
| Program files | `Data/survey_2023/cutoffs_and_extras_official_2023.csv`, `names_codes.csv`, `carreras.csv` | MD5 in `logs/03_baseline_offer_effects.txt` |
| Public files of applications of the 2023 process (regular, BEA, PACE seats) | `~/Dropbox/Mistakes Structural/Data/2023/input/ABCD/C_POSTULANTES_SELECCION_PAES*_2023_PUB_MRUN.csv`, with the layout documents `ER_Alumnos_PAES_2023_MRUN_(C_*).docx` | SHA-256 in `logs/05_application_outcomes.txt`; 187,225 applicants. Copies of the same size are in `~/Dropbox/mistakes replication nacho scaleup/Data/raw/2023/` |
| Admission probabilities of the Mistakes project | Same folder: `applications_and_probs_final.csv` (final lists, 182,104 students) and `applications_and_probs_20230104_1800.csv` (lists on file on 4 Jan 18:00, 132,975 students) | SHA-256 in `logs/05_application_outcomes.txt` |
| Questionnaires in English | `IRB/Baseline_survey_mistakes_2023_english.pdf`, `IRB/Endline_survey_mistakes_2023_english.pdf`, `IRB/2022-mistakes-survey_english.pdf` | SHA-256 `20558b23…`, `58aee5d0…`, `3f66f347…` |
| Dictionaries, codebook, cleaning code | `docs/survey_dictionaries/`, `docs/CODEBOOK.md`, `R/survey_2023/` | At the commit above |

The repository's `documents/draft/` is the July draft and was not used.
Data stay where they are. Outputs are aggregates, and no count below 11 children is printed.
The sample sizes of some nested rows differ by fewer than 11 children (for example, children who named a program and children whose program matches a program code). No table reports a count below 11 or a statistic for a group of fewer than 11 children.

## 3. Timing

- The baseline ran from 27 Dec 2022 to 2 Jan 2023, after the tests and before results (3 Jan) and applications (3 to 6 Jan).
- Table C.6 of the paper schedules application year 2018 for the 2023 process. By the rollout calendar, the Metropolitan Region enters SAE in application year 2019 and is absent.
- Every survey answer is an outcome of the lottery. None enters a regression as a control.
- The endline (13 to 16 Jan 2023) follows the personalized websites of 5 Jan. The 2022 survey (18 to 22 Jan 2022) corresponds to application year 2017.

## 4. Linkage and overlap (actual)

Source: `output/survey_link_aggregates.md`, `output/endline_overlap.md`.

| Quantity | Number |
|---|---|
| Students with a baseline response | 39,051 |
| Of them, found in the registration file | 39,051 |
| Of them, found in the lottery sample (all application years) | 4,091 |
| Lottery children found in the registration file | 26,523 |
| Students with an endline response | 19,147 |
| Of them, found in the lottery sample | 1,803 |

Application year 2018 (34,052 children, 13,828 with offer and 20,224 without):

| Stage | With offer | Without offer | Offer effect | SE |
|---|---|---|---|---|
| Graduated on time | 11,323 | 17,162 | -0.0301 | 0.0048 |
| Has a test score on time | | | -0.0153 | 0.0061 |
| Applied on time | 5,281 | 8,275 | -0.0140 | 0.0061 |
| Registered for the 2023 tests | 9,191 | 14,092 | -0.0268 | 0.0058 |
| Started the baseline | 1,420 | 2,260 | -0.0095 | 0.0042 |
| Answered the expected Mathematics score | 1,212 | 1,918 | -0.0071 | 0.0039 |
| Answered the probability of admission (`Q61`) | 937 | 1,523 | -0.0064 | 0.0035 |
| Named a top true program (`Q8`) | 868 | 1,411 | -0.0061 | 0.0033 |
| Completed the baseline | 513 | 829 | -0.0034 | 0.0026 |
| Regular module | 955 | 1,284 | 0.0069 | 0.0034 |
| BEA module | 136 | 240 | -0.0029 | 0.0014 |
| PACE module | 329 | 736 | -0.0135 | 0.0022 |
| Started the endline | 652 | 981 | -0.0025 | 0.0028 |
| Completed the endline | 269 | 347 | 0.0033 | 0.0018 |
| Answered both surveys | 319 | 456 | -0.0004 | 0.0020 |

Offer effects are from the equation of the specification log (paper's controls and chance-group effects).
Among the 2018 children who started the baseline, the first stage is 0.570 (SE 0.017), against 0.566 (SE 0.006) in the whole cohort.
Balance among them: the offer coefficient on the female indicator is -0.041 (SE 0.020). The offer coefficients on the other four controls are at most 1.1 standard errors from zero.

Other application years in the 2023 process. Application year 2017 has 355 children who started the baseline, and the offer raises their registration for the 2023 tests by 2.7 pp (SE 1.0). Application year 2019 has 44 children who started.

## 5. Power: actual against projected

| Quantity | Projected | Actual |
|---|---|---|
| Lottery children, application year 2018 | 31,535 (October vintage) | 34,052 |
| Share registered for the 2023 tests | 0.55 to 0.70 (assumed) | 0.684 |
| Started the baseline | 2,282 to 2,904 | 3,680 |
| Completed the baseline | 919 to 1,170 | 1,342 |
| Started the endline | at most 1,802 | 1,633 |
| Minimum detectable offer effect, items asked of everyone | 0.105 to 0.146 SD | 0.13 SD (expected Mathematics score), 0.15 SD (`Q61`) |
| Same, program named by the respondent | | 0.16 SD (cutoff percentile of the top true program) |
| Same, item in two or more random groups of questions | 0.233 to 0.325 SD | 0.22 to 0.30 SD |
| Same, annual payment (one random group, 235 children) | | 0.50 SD |

Actual minimum detectable effects are 2.80 times the standard error of the offer effect, divided by the standard deviation of the outcome among children without offer.
Lottery children respond more than the average invited student: 15.8 percent of the registered children of the cohort started the baseline, against 13.2 percent of all registered students.

## 6. Offer effects on baseline outcomes (actual)

Source: `output/baseline_offer_effects.md`. Application year 2018. Each estimate compares offered and non-offered children who answered the item.

Main outcome of each family:

| Family | Main outcome | Children | Mean without offer | Offer effect | SE | Effect in SD | p | Holm p |
|---|---|---|---|---|---|---|---|---|
| A. Earnings and progression | Expected monthly income, planned first preference (pesos) | 814 | 1,224,206 | 24,414 | 84,689 | 0.031 | 0.773 | 1.000 |
| B. College attainment | `Q61`, probability of admission to any program | 2,460 | 69.8 | -0.75 | 1.41 | -0.029 | 0.596 | 1.000 |
| C. Selectivity of the top true program | Cutoff percentile of the program named in `Q8` | 2,164 | 69.5 | 1.20 | 1.49 | 0.045 | 0.423 | 1.000 |
| D. Strategic reports | Planned first preference differs from the top true program | 2,149 | 0.236 | 0.003 | 0.024 | 0.008 | 0.886 | 1.000 |
| E. Admission and cutoff beliefs | Expected minus realized Mathematics M1 score | 3,123 | -22.9 | -0.6 | 6.6 | -0.004 | 0.931 | 1.000 |
| F. Application choices | Highest cutoff percentile of the submitted list, children who started | 2,717 | 88.0 | 0.34 | 0.75 | 0.022 | 0.650 | 1.000 |

Other outcomes with unadjusted p below 0.05 (all in family E, 18 adjusted outcomes):

| Outcome | Children | Mean without offer | Offer effect | SE | p | q within family | Trimming bounds | 95% interval for the bounds |
|---|---|---|---|---|---|---|---|---|
| Absolute difference between expected and realized Ranking score | 3,074 | 161.6 | -16.9 | 7.0 | 0.016 | 0.167 | -31.3 to 18.6 | -47.2 to 43.5 |
| `Q65`, probability own score above the cutoff, planned first preference | 1,812 | 60.6 | -3.4 | 1.5 | 0.026 | 0.167 | -9.7 to 3.0 | -13.9 to 7.5 |
| Expected minus realized Ranking score | 3,074 | -131.8 | 18.2 | 8.3 | 0.028 | 0.167 | -18.8 to 45.3 | -45.6 to 65.3 |

Companion rows for the same children, outside the adjusted set:

| Outcome | Offer effect | SE |
|---|---|---|
| Realized NEM score | -12.7 | 5.0 |
| Realized Ranking score | -20.6 | 5.7 |
| Expected NEM score | -7.0 | 7.6 |
| Expected Ranking score | -2.7 | 8.9 |
| Realized Mathematics M1 score | 3.0 | 4.1 |
| Realized Reading score | 6.2 | 4.8 |

What the estimates support:

- No detected offer effect on any main outcome. The 95 percent confidence intervals exclude offer effects beyond about 0.16 SD in absolute value for families B to F, and beyond about 0.25 SD for family A. This holds among children who answered, and is subject to the selection of Section 4.
- Among respondents, the offer lowers realized NEM and Ranking scores, as in the paper. The point estimates for expected NEM and Ranking are smaller and not distinguishable from zero. For NEM, the expected and realized effects are not distinguishable from each other. For Ranking, their difference is the row "expected minus realized" above (p = 0.028 unadjusted, q = 0.17).
- The Ranking rows and `Q65` are inconclusive. They do not survive the adjustment within the family, and their bounds include zero.
- Beliefs about earnings and progression are imprecise. The largest estimates are the probabilities of graduating and of staying for the planned first preference (0.18 and 0.14 SD, p = 0.07, q = 0.39).

Selection and bounds:

- The offer lowers answering for every item except the annual payment, by 0.2 to 0.8 pp. The trimming shares are 0.06 to 0.22.
- Every 95 percent interval for the trimming bounds includes zero.
- Worst-case bounds for the main outcomes of families B, C, and D span almost the whole range of the outcome. Fewer than one child in ten answers.
- Reweighting respondents to the registered children of the cohort gives estimates within two standard errors of the unweighted ones. The Ranking rows are larger in absolute value after reweighting (35.6, SE 10.9, for expected minus realized; -27.4, SE 9.2, for the absolute difference).

Attendance effects (IV): none is reported. For every outcome, the interval of the stage effect excludes zero or the trimming bounds have opposite signs.

Application year 2017 in the 2023 process (267 to 283 answering children for the early items): reported in Section 4 of the output. These children are a year behind schedule, and the offer changes who among them registers. Several unadjusted estimates are large (for example expected Reading score, 74.5 points, SE 29.8). I do not interpret them.

Whole 2018 cohort, application choices on time (13,556 applicants): the offer raises listed cutoffs missed by 2.5 pp (SE 0.7) and lowers reaching a listed cutoff by 1.8 pp (SE 0.9). The same outcomes among children who started the survey are 0.4 (SE 1.7) and 0.0 (SE 2.2).

## 7. Applications of the 2023 process: family D (actual)

Source: `output/application_outcomes.md`. Definitions were written in the specification log (entry of 21:23 UTC) before the estimates.

- An inadmissible application is a listed preference with a status other than 24, 25 or 26 in the public file.
- The probability of admission is `overall` of the Mistakes project, for the final list. The risk of no assignment is one minus that probability.
- 13,526 children of the cohort are in the public file. The paper's panel has 13,556 applicants on time.
- Of the 3,680 children who started the baseline, 2,717 applied. Of the 2,278 who named a top true program that matches a program code, 1,811 applied.
- The offer effect on applying is -1.4 pp (SE 0.6) in the whole cohort and -0.3 pp (SE 1.8) among children who started the baseline.

Survey-linked rows (q-values adjust over the 16 survey-linked rows of family D):

| Outcome | Children | Mean without offer | Offer effect | SE | p | q | Minimum detectable effect |
|---|---|---|---|---|---|---|---|
| Top true program in the final list (0 without an application) | 2,278 | 0.703 | -0.023 | 0.024 | 0.340 | 0.802 | 0.068 |
| Top true program listed first (0 without an application) | 2,278 | 0.490 | 0.001 | 0.027 | 0.964 | 0.992 | 0.076 |
| Top true program in the final list, applicants | 1,811 | 0.872 | -0.002 | 0.019 | 0.936 | 0.992 | 0.054 |
| Top true program listed first, applicants | 1,811 | 0.607 | 0.022 | 0.030 | 0.458 | 0.802 | 0.083 |
| At least one inadmissible application, applicants | 2,717 | 0.179 | -0.009 | 0.017 | 0.593 | 0.802 | 0.049 |
| Every listed preference inadmissible, applicants | 2,717 | 0.067 | -0.017 | 0.012 | 0.152 | 0.802 | 0.032 |
| Risk of no assignment, applicants | 2,672 | 0.264 | 0.024 | 0.021 | 0.253 | 0.802 | 0.058 |
| Probability of admission below 0.01, final list, applicants | 2,672 | 0.216 | 0.023 | 0.020 | 0.248 | 0.802 | 0.056 |
| Not selected in any preference, applicants | 2,717 | 0.284 | 0.011 | 0.022 | 0.601 | 0.802 | 0.060 |
| `Q61` minus 100 times the probability of admission | 1,852 | -4.4 | -0.03 | 2.84 | 0.992 | 0.992 | 7.9 |
| Absolute value of that difference | 1,852 | 36.0 | 1.30 | 1.77 | 0.462 | 0.802 | 5.0 |

Whole cohort, no survey (outside the adjusted set):

| Outcome | Children | Mean without offer | Offer effect | SE | p | 95% interval for the trimming bounds |
|---|---|---|---|---|---|---|
| Applied with at least one inadmissible application (0 without an application) | 34,052 | 0.068 | -0.005 | 0.003 | 0.154 | no selection stage |
| At least one inadmissible application, applicants | 13,526 | 0.167 | -0.007 | 0.008 | 0.358 | -0.026 to 0.055 |
| Every listed preference inadmissible, applicants | 13,526 | 0.060 | -0.008 | 0.005 | 0.110 | -0.018 to 0.058 |
| Probability of admission of the final list (0 without an application) | 33,755 | 0.294 | -0.020 | 0.006 | below 0.001 | -0.035 to -0.009 |
| Risk of no assignment, applicants | 13,229 | 0.271 | 0.025 | 0.009 | 0.006 | -0.002 to 0.084 |
| Probability of admission below 0.01, final list, applicants | 13,229 | 0.223 | 0.021 | 0.009 | 0.018 | -0.004 to 0.082 |
| Probability of admission below 0.01, list on file on 4 Jan 18:00 | 10,370 | 0.263 | 0.033 | 0.011 | 0.002 | 0.000 to 0.102 |
| Not selected in any preference, applicants | 13,526 | 0.286 | 0.023 | 0.009 | 0.015 | -0.006 to 0.082 |

What the estimates support:

- Top true program. No offer effect is detected. The design detects effects of 5 to 8 pp.
- Inadmissible applications. No offer effect is detected in either sample. Among applicants of the whole cohort, the 95 percent confidence interval is -2.2 to 0.8 pp.
- Risk of no assignment, survey-linked children. No offer effect is detected. The point estimate (2.4 pp, SE 2.1) is close to that of the whole cohort.
- Risk of no assignment, whole cohort. The offer lowers the probability of admission of the final list by 2.0 pp (SE 0.6), counting a child without an application as zero. Among applicants, the risk of no assignment is 2.5 pp higher with offer (SE 0.9). The rows among applicants compare children who applied, and the offer lowers applying. Their intervals for the trimming bounds include zero or touch it.
- Stated against computed probability of admission. No offer effect is detected.
- Attendance effects. Two rows are defined for every child of the cohort and have no selection stage. Attendance lowers the probability of admission of the final list by 3.6 pp (SE 1.0) and applying with an inadmissible application by 0.8 pp (SE 0.6). Both rest on the paper's exclusion restriction for college outcomes. No survey-linked row meets the conditions.

## 8. Expected against realized Ranking (actual)

Source: `output/ranking_belief_gap.md`. This examination was added after the first results. Its rows were fixed in the specification log before running, are descriptive, and enter no adjusted set.

Children who answered `Q41` and have a realized score (3,074):

| Outcome | Mean without offer | Offer effect | SE | 95% confidence interval | Minimum detectable effect | p |
|---|---|---|---|---|---|---|
| Expected minus realized Ranking | -131.8 | 18.2 | 8.3 | 2.0 to 34.4 | 23.2 | 0.028 |
| Absolute difference, Ranking | 161.6 | -16.9 | 7.0 | -30.7 to -3.2 | 19.7 | 0.016 |
| Expected Ranking | 624.7 | -2.4 | 8.9 | -19.7 to 15.0 | 24.8 | 0.788 |
| Realized Ranking | 756.4 | -20.6 | 5.7 | -31.7 to -9.4 | 15.9 | below 0.001 |
| Expected minus realized NEM | -78.0 | 6.2 | 6.4 | -6.4 to 18.7 | 18.0 | 0.336 |
| Expected NEM | 648.4 | -6.6 | 7.5 | -21.3 to 8.2 | 21.1 | 0.386 |
| Realized NEM | 726.5 | -12.7 | 5.0 | -22.5 to -3.0 | 13.9 | 0.011 |
| Realized Ranking minus realized NEM | 30.0 | -7.9 | 1.3 | -10.4 to -5.3 | 3.6 | below 0.001 |
| Expected Ranking minus expected NEM | -23.8 | 4.2 | 5.5 | -6.7 to 15.0 | 15.5 | 0.452 |
| Expected Ranking more than 100 points below realized | 0.477 | -0.045 | 0.023 | -0.090 to 0.000 | 0.064 | 0.052 |
| Expected Ranking above realized | 0.202 | 0.022 | 0.019 | -0.015 to 0.058 | 0.053 | 0.252 |

Realized Ranking without the survey:

| Sample | Children | Offer effect | SE |
|---|---|---|---|
| Children of the cohort with a score in the registration file | 23,153 | -21.1 | 2.0 |
| Of them, started the baseline | 3,679 | -24.4 | 5.3 |
| Of them, did not start the baseline | 19,474 | -20.1 | 2.2 |
| Difference between the last two (interaction) | 23,153 | 2.4 | 4.6 |
| `SCORE_RANKING_OT` of the paper's panel (SD units) | 28,426 | -0.113 | 0.011 |

Quantiles of expected minus realized Ranking (difference between offer groups, bootstrap SE): 46.0 (19.9) at quantile 10, 22.0 (12.5) at 25, 17.0 (9.6) at the median, 1.0 (1.7) at 75, and 9.0 (15.6) at 90.

What the estimates support:

- The change in the difference comes from the realized score. Realized Ranking falls by about 21 points with offer, among respondents and in the whole cohort. Expected Ranking does not change detectably.
- The confidence interval of expected Ranking (-19.7 to 15.0) includes zero, the case of expectations that do not move. It ends just above -20.6, the case of expectations that follow the realized score. The test of that second case is the row "expected minus realized" (p = 0.028 unadjusted, q = 0.167).
- Children without offer expect a Ranking 131.8 points below the realized one on average, and 47.7 percent expect more than 100 points below. A lower realized Ranking therefore brings the difference closer to zero. This explains the fall of the absolute difference (-16.9, SE 7.0).
- The change is concentrated in the lower half of the distribution of the difference.
- NEM shows a smaller estimate of the same sign (6.2, SE 6.4). Ranking minus NEM falls by 7.9 points (SE 1.3) in realized scores and shows no detected change in expected scores (4.2, SE 5.5).
- Precision. The design detects a change of 23 points with 80 percent power. A change equal to the whole fall of realized Ranking (21 points) is below that.
- Robustness. The estimate is 19.7 (SE 8.3) without controls and 17.9 (SE 8.1) winsorized at percentiles 1 and 99. Reweighted to registered children it is 35.6 (SE 10.9).
- Selection. The offer lowers answering by 0.74 pp (SE 0.38). The trimming bounds are -18.8 to 45.3, and their 95 percent interval is -45.6 to 65.3.
- Multiple testing. The q-value in family E is 0.167. The row was examined because it had one of the smallest p-values.
- Application year 2017 has 283 answering children and a different pattern (expected Ranking 79.2 points higher with offer, SE 35.1). It is not a replication.
- Three added rows meet the written conditions for an attendance effect: expected Ranking above realized, absolute difference of 50 points or less, and realized Ranking minus realized NEM. The stage interval includes zero by a narrow margin (-0.0074, SE 0.0038), and the intervals for their bounds include zero. I do not treat them as findings.

## 9. Not done

| Item | Reason |
|---|---|
| Top true program in the list on file on 4 January 18:00 | Only the final list is used. The file of 4 January holds the program codes of the earlier list |
| Selectivity with 2022 cutoffs | Not computed. Candidate inputs, located by name and not opened: `~/Dropbox/Mistakes Structural/Data/2022/outputs/cutoffs_and_extras_unica_student_finales.csv` and the public application files of the 2022 process in `Data/2022/ABCD/` |
| Effects on endline outcomes | Overlap is computed (1,633 children started, 616 completed). The endline follows the personalized websites, and program lists depend on baseline progress. Outcomes are not built yet |
| 2022 survey | Not linked. Projected overlap is 833 children who started (application year 2017) |
| WhatsApp reminder of 31 Dec | Not used. Candidate inputs, located by name and not opened: `~/Dropbox/Mistakes Structural/Data/2023/survey_baseline_2022_2023/code/create_sets_reminder_2.R` and `outputs/reminders/second/recordatorios_joined.csv` |
| Check of the cutoff percentile against the paper's formula | The paper's construction code is upstream of the three notebooks |

## 10. Assumptions not tested

- Exclusion of the offer for belief outcomes. It matters only for attendance effects, and none is reported for a belief.
- That the admission probabilities of the Mistakes project (`overall`) measure the risk of no assignment. They are taken as given. Applicants without a row in the final file (297 of 13,526 in the cohort) are left out.
- That registered students were all invited. No invitation list is on file.
- That answering is as good as random given the controls and on-time outcomes (reweighted estimates only).
- Monotonicity of answering in the offer (trimming bounds).

## 11. Open choices for the author

1. The item that stands for own probability of college attainment. `Q61` is used. No survey asks an unconditional probability of obtaining a college degree.
2. Whether to build the endline outcomes and link the 2022 survey, given their expected precision (minimum detectable effects above 0.2 SD).
3. Whether the stated against computed probability of admission belongs in family D (as estimated) or in family E (as the inventory lists it).
