# Specification log: lottery effects on survey outcomes

Written 11 November 2026 (18:55 UTC), before any estimate of this project was computed and before any survey row was opened.
Later changes are appended at the end with a date and a reason.
The outcome definitions are in `outcome_inventory.md`.
The project is exploratory.
No sign, mechanism, or result is assumed.

## 1. Samples

- Lottery sample: the paper's lottery sample (`mechanisms_panel.rds`, one row per child), restricted to children with every control, as in the paper.
- Main cohort for the 2023 surveys: application year 2018. Table C.6 of the paper schedules this cohort for the 2023 admission process.
- Application years 2016 and 2017 in the 2023 process: reported separately. They are not pooled with the main cohort. Their presence in the 2023 process requires delay or a repeated application, and the paper studies both as outcomes of the lottery.
- 2022 survey: application year 2017, reported separately from the 2023 surveys.
- Survey samples: consenting responses kept by the cleaning code of the Mistakes package (`Q17 == "Acepto"`, started after 27 Dec 2022 10:00). A student with several baseline responses keeps the response with the highest `Progress`, and the earliest of these when tied.

## 2. Stages of observation

Each stage is an indicator defined for every child of the lottery cohort.
The offer effect on each indicator is estimated with the equation of Section 3, on the full cohort.

1. Graduated on time (`GRAD_OT`).
2. Has a test score on time (`SCORE_LM_OT` observed). After linkage: registered for the tests of the 2023 process (public registration file).
3. Applied on time (`LIST_PROGRAMS_OT` observed).
4. Started the baseline with consent.
5. Reached the questions on programs (answered `Q60 > 0` and named a program in `Q8`).
6. Entered the regular module (embedded field `regular`), the BEA module, or the PACE module.
7. Answered each item of `outcome_inventory.md`.
8. Completed the survey (`Finished`).

Stages 1 to 3 use the paper's data only.
Stages 4 to 8 need the survey.
The documentation states that every registered student was invited.
No invitation list is on file, so invitation cannot be told apart from registration.

## 3. Estimating equations

Offer effect (ITT), for outcome or stage indicator y:

    y_i = b * OFFER_i + X_i'g + chance-group effects + application-year effects + e_i

- `OFFER`, `CHANCE_GROUP`, and `YEAR` are the paper's variables. A single application year has no year effects.
- X holds the paper's controls: `GPA8_Z`, `ES_MUJER`, `PRIORITARIO`, `ALTO`, `ORIGIN_OD`. All are measured before the lottery.
- Estimation follows the paper's notebooks: `fixest::feols`, heteroskedasticity-robust standard errors, `fixef.rm = "none"`.
- Each estimate is reported with and without X.
- For items in a randomized group of questions, the equation adds fixed effects for the group (`block`) and uses only the groups that hold the item.
- No survey answer enters X.

First stage: the same equation with `D_OD` (attendance at an over-demanded school) as outcome, estimated in every analysis sample.

Balance among respondents: the paper's balance equation (`OFFER` with chance-group and year effects, no controls) for each pre-lottery characteristic, in each survey sample.

## 4. Order of reporting

1. Stage effects (Section 2), with denominators at each stage.
2. Offer effects on survey outcomes among students observed at the relevant stage.
3. Bounds for the effects of step 2 (Section 5).
4. Attendance effects (Section 6), only where its conditions hold.

Every estimate is reported: coefficient, standard error, 95 percent confidence interval, mean of the group without offer, number of students, number with and without offer.
Null and inconclusive results are reported in the same tables as the others.

## 5. Selection into response

An offer effect among respondents compares offered and non-offered students who respond.
It equals an effect on a fixed population only if the offer does not change who responds.

- Test: the stage effects of Section 2, and balance among respondents.
- Trimming bounds (Lee 2009): for each outcome, bounds on the offer effect for students who would respond with and without an offer. The trimming share is the offer effect on response divided by the response rate of the group with more response. Students are weighted by the inverse of the offer share of their chance group (the paper's weight for complier profiles), so that the two groups are comparable before trimming. Confidence intervals follow Imbens and Manski (2004).
- Worst-case bounds (Horowitz and Manski 2000) for outcomes on a 0 to 100 scale, with the full cohort as population. These bounds are expected to be wide. They are reported once per family, for the main outcome.
- Reweighting: respondents weighted to the lottery cohort on the paper's controls and on-time administrative outcomes. This version assumes that response is as good as random given those variables. It is labeled as such.

## 6. Attendance effects (IV)

The instrument is `OFFER` and the treatment is `D_OD`, as in the paper.
An attendance effect on a survey outcome is reported only if all three conditions hold for the sample and outcome.

1. Exclusion: an offer changes the outcome only through attendance at an over-demanded school. The paper maintains this for college outcomes. For beliefs there is no test. The estimate is labeled as resting on this assumption.
2. Monotonicity: as in the paper.
3. Selection: the 95 percent confidence interval of the offer effect on the relevant stage indicator includes zero, and the trimming bounds of Section 5 have the same sign at both ends. When this fails, only the offer effect and its bounds are reported.

Attendance effects among respondents describe compliers who respond.
They are never described as effects for the lottery sample.

## 7. Families and multiple testing

Families follow `outcome_inventory.md`. Each family has one main outcome, fixed here.

| Family | Main outcome (2023 baseline) | Other outcomes |
|---|---|---|
| A. Beliefs about earnings and progression | Expected monthly income for the planned first preference (`exp_inc_`, groups 1 and 2) | Annual payment, probability of graduating, semesters, position among peers, staying, passing all courses, employment; the same items for the top true program |
| B. Own probability of college attainment | `Q61`, probability of admission to any program of the application | `Q60`; probability of graduating from the planned first preference |
| C. Selectivity of the top true program | Cutoff percentile of the program named in `Q8` (2023 process) | Cutoff percentile with 2022 cutoffs; planned first and last preferences |
| D. Mistakes and strategic reports | Planned first preference differs from the top true program (`Q19 != Q8`) | Top true program listed in the submitted application; listed first; application to a program without meeting requirements; risk of no assignment |
| E. Admission and cutoff beliefs | Expected Mathematics M1 score minus realized score (`Q5_1`) | Reading; NEM; Ranking; absolute values of the four; `Q63`, `Q64`, `Q65` for the planned first preference; cutoff bias |
| F. Application choices (administrative) | Highest cutoff percentile of the submitted list, on time | Number of programs, mean cutoff percentile, cutoffs missed and reached, among respondents and in the full cohort |

Family B depends on a choice the author has not made yet (see Section 3.2 of the inventory). `Q61` is a placeholder until then.

Adjustment:

- Across the six main outcomes: Holm-adjusted p-values.
- Within each family: Benjamini-Hochberg q-values over all its outcomes.
- Unadjusted confidence intervals are always shown next to the adjusted p-values.
- The endline and the 2022 survey are separate sets with the same rules.

## 8. Heterogeneity

None is specified.
The expected sample does not support it (see `feasibility_memo.md`).
Any later analysis by subgroup is labeled as added after the first results.

## 9. Disclosure

- Outputs are aggregates only: counts, shares, coefficients, standard errors.
- No count below 11 students is printed, and no statistic from fewer than 11 students. MINEDUC applies this threshold to its public files. The repository states no other threshold.
- No identifier, chance group of a single child, school code, or program code with fewer than 11 respondents is printed.
- Logs record file names, sizes, checksums, and aggregate results only.

## 10. Changes after the first version

- 11 November 2026, 18:56 UTC, before any estimate. Section 1 now states the rule for students with several baseline responses. The baseline cleaning code has no rule for them (`Cleaning_baseline.R` and `Merge_surveys.R` contain no step that removes repeated students).
- 11 November 2026. The run of `01_lottery_cohort_aggregates.R` was denied by the permission system before execution. No estimate of this project exists yet.
- 11 November 2026, 19:23 UTC. Steps 1 and 2 ran. The stage effects of Section 2 are known (`output/lottery_cohort_aggregates.md`, `output/survey_link_aggregates.md`). No effect on a survey answer has been computed.
- 11 November 2026, 19:40 UTC, before step 3 ran. Definitions fixed for `03_baseline_offer_effects.R`:
  1. Answer for the planned first preference: its own row when the questionnaire shows it, and the row of the top true program when the two programs coincide. The questionnaire shows the second row only when the programs differ.
  2. The random group of questions is identified by the question that holds the answer.
  3. Family E adds the four expected scores in levels to its adjusted set. The realized scores of the same children are shown as companion rows outside the adjusted set.
  4. Cutoff percentile: percentile rank of the program's cutoff among the programs of the 2023 regular process (`cutoffs_and_extras_official_2023.csv`), with the minimum weighted score of `carreras.csv` when the program does not fill its seats. The paper's own formula was not checked. The version with 2022 cutoffs is not computed.
  5. Family D holds the survey item only. The public file of applications of the 2023 process with program codes is not in the data folder of the Mistakes package.
  6. The relevant stage for Section 6 is answering the item.
  7. Trimming bounds use 300 bootstrap draws of children (seed 20261111).
  8. Family F among respondents uses children who started the survey. The whole 2018 cohort is shown next to it.
  9. Application year 2017 is estimated without bounds.
  10. The probability of graduating from the planned first preference appears in families A and B.
- 11 November 2026, 19:45 UTC. The first run of step 3 stopped with an error before any output was written. One item had 27 answering children in 21 chance groups, and the fixed effects exhausted the data. Rule added: no regression with fewer than 50 answering children in either offer group. Those rows show counts only.
- 11 November 2026, 19:55 UTC, after the first complete run of step 3. Two estimators of Section 5 were unstable and are replaced. The offer effects of Section 3 are unchanged.
  1. Trimming bounds. The weights of Section 5 (inverse of the offer share of the chance group) gave trimming shares of 0.15 to 0.36, against 0.07 to 0.12 implied by the stage effects, and weighted differences far from the regression estimates. Chance groups with offer shares near 0 or 1 give a few children very large weights. New weights: an offered child weighs one minus the offer share of the chance group, a non-offered child the offer share. With these weights the weighted difference in means equals the regression on `OFFER` and chance-group effects, and the trimming share equals the offer effect on answering divided by the response rate of the group with more response, as Section 5 states.
  2. Reweighting. The target is now the registered children of the cohort. A child who did not register cannot answer, so the whole cohort gave weights above 1,000 to a few respondents. The estimate assumes that answering is as good as random among registered children given the controls and on-time outcomes. It does not address the offer effect on registration.
- 11 November 2026, 21:23 UTC, before any estimate of step 5. The public files of applications of the 2023 process are outside the Mistakes package, in `~/Dropbox/Mistakes Structural/Data/2023/input/` (three files `C_POSTULANTES_SELECCION_PAES*_2023_PUB_MRUN.csv` in `ABCD/`, and the admission probabilities `applications_and_probs_20230104_1800.csv` and `applications_and_probs_final.csv`). Only totals of these files were tabulated before this entry, with no division by offer. Definitions fixed for `05_application_outcomes.R`, which completes family D:
  1. Applied: the child has a row in the public file of regular applications. One student of the country appears twice. The rule of the Mistakes code keeps one row (`R/data_processing/data_2023.R`, line 38).
  2. Top true program listed: the code of the program named in `Q8` equals one of `COD_CARRERA_PREF_01` to `_20`. Listed first: it equals `COD_CARRERA_PREF_01`. Sample: children who named a program in `Q8` that matches a program code. Each outcome has two versions: among all those children, with 0 for a child without an application, and among those who applied.
  3. Inadmissible application: a listed preference whose status (`ESTADO_PREF`) is not 24, 25 or 26 (annex of the layout document of the file). Outcomes: at least one (both versions of item 2), the share of listed preferences, and every listed preference (equal to `SITUACION_POSTULANTE == "C"`), the last two among applicants.
  4. Risk of no assignment. `overall` in `applications_and_probs_final.csv` is the probability of admission to some program of the final list, computed by the Mistakes project. `risk_label` is 1 when that probability is below 0.01. Outcomes: one minus `overall`, among applicants with a row in that file; `risk_label == 1` in the same file; `risk_label == 1` in `applications_and_probs_20230104_1800.csv`, among children with a list on file on 4 January 18:00; `overall` with 0 for a child without an application; and no selection in any preference of the regular, BEA and PACE files (status 24), among applicants. Applicants without a row in the final file (5,145 of 187,225 in the country) are left out of the rows that use it.
  5. Stated against computed probability of admission: `Q61` minus 100 times `overall`, and its absolute value, among children who answered `Q61` and have a row in the final file. The inventory lists this difference under admission beliefs. It enters family D here, so the adjusted set of family E stays as estimated in step 3.
  6. Samples. Survey-linked rows use the children of application year 2018 who started the baseline (item 2 uses those who named a matched top true program). The administrative rows are repeated for the whole cohort.
  7. Adjustment. Benjamini-Hochberg over the survey-linked rows of family D, including the main outcome of step 3. Whole-cohort rows are outside the adjusted set, as in family F. The Holm p-values of the six main outcomes are those of step 3.
  8. Selection and attendance effects follow Sections 5 and 6 with the estimators of the entry of 19:55 UTC. An outcome defined for every child of the cohort has no selection stage. Its attendance effect is shown, under the paper's exclusion restriction for college outcomes. The reweighted estimate is not computed for whole-cohort rows.
  9. Worst-case bounds are not computed for the added rows.
  10. The estimators and table writers move to `estimators.R`, shared by steps 3, 5 and 6. Step 3 is rerun, and its output must keep the MD5 `e3e14ea4f6b7df70b8ad7275911533d3`.
- 11 November 2026, 21:23 UTC, before step 6 ran. Examination of the Ranking rows of family E (`06_ranking_belief_gap.R`), added after the first results at the author's request. The rows are descriptive and enter no adjusted set. The q-values of the Ranking rows stay those of step 3. Rows fixed before running (items 6 and 8 were completed at 21:30 UTC, after step 5 ran and before step 6):
  1. The Ranking and NEM rows of step 3, with 95 percent confidence intervals and minimum detectable effects (2.80 standard errors: 80 percent power in a two-sided test at 5 percent).
  2. Indicators: expected score above the realized score; absolute difference of 50 points or less; expected score more than 100 points below the realized score.
  3. Ranking score minus NEM score: expected, realized, and expected minus realized.
  4. Expected minus realized Ranking, winsorized at its 1st and 99th percentiles.
  5. Quantiles 10, 25, 50, 75 and 90 of expected minus realized Ranking by offer group, with the weights of the trimming bounds, and bootstrap standard errors of the differences between offer groups.
  6. Realized Ranking and NEM without the survey: every child of the cohort with a score in the registration file, the children among them who started the baseline and those who did not, the difference between these two offer effects (interaction of `OFFER` with starting), and the paper's `SCORE_RANKING_OT` and `SCORE_NEM_OT`.
  7. No analysis by subgroup.
  8. The expected and realized scores use the children who have both, so the effect on the difference equals the effect on the expected score minus the effect on the realized score.
- 11 November 2026, 22:02 UTC, before the commit. Two changes keep student-specific values out of the repository. Step 5 keeps the first of the two rows of the student who appears twice in the public file, in place of the rule of the Mistakes code, which names one preference of that student. Its output is identical (MD5 `930bc5e52d8735af57d231b439a2d502`). The log of step 1 gives the path of the panel relative to the home folder. No estimate changed.
