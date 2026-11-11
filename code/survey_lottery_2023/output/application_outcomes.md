# Applications of the 2023 process: offer effects in the lottery sample (family D)

Written by `code/survey_lottery_2023/05_application_outcomes.R`. Exploratory. Definitions are in the entry of 11 November 2026, 21:23 UTC, of `specification_log.md`.
Rows with fewer than 50 children in either offer group show counts and no estimate. An indicator with fewer than 11 children in a cell of offer by value is not estimated.

## 1. Files and checks

| Quantity | Value |
|---|---|
| Applicants in the public file of regular applications | 187,225 |
| Share with at least one inadmissible application | 0.125 |
| Share with every listed preference inadmissible | 0.039 |
| Share not selected in any preference (regular, BEA and PACE seats) | 0.235 |
| Students in the file of final probabilities | 182,104 |
| Of them, in the public file | 182,080 |
| Students in the file of 4 January 18:00 | 132,975 |
| Children of application year 2018 with every control | 34,052 |
| Of them, in the public file of regular applications | 13,526 |
| Of them, with a row in the file of final probabilities | 13,229 |
| Children of the cohort with a list on file on 4 January 18:00 | 10,370 |
| Children who started the baseline | 3,680 |
| Of them, in the public file | 2,717 |
| Children who named a matched top true program | 2,278 |
| Of them, in the public file | 1,811 |

Application on time in the paper's panel (`LIST_PROGRAMS_OT` observed) against a row in the public file, children of the cohort:

| | Not in the public file | In the public file |
|---|---|---|
| No application on time in the panel | 20,496 | fewer than 11 |
| Application on time in the panel | 30 | 13,526 |

## 2. Stages: offer effect on reaching each sample

Each row is one regression of the indicator on `OFFER`, the paper's controls, and chance-group effects, among the children named in the row.

| Stage | Children with offer | Without offer | Yes, with offer | Yes, without offer | Share without offer | Offer effect | SE |
|---|---|---|---|---|---|---|---|
| Applied to the 2023 process (public file), whole cohort | 13828 | 20224 | 5271 | 8255 | 0.408 | -0.0139 | 0.0061 |
| Applied, registered children | 9191 | 14092 | 5271 | 8255 | 0.586 | -0.0008 | 0.0077 |
| Applied, children who started the baseline | 1420 | 2260 | 1031 | 1686 | 0.746 | -0.0031 | 0.0180 |
| Applied, children who named a matched top true program | 867 | 1411 | 673 | 1138 | 0.807 | -0.0238 | 0.0217 |
| List on file on 4 January 18:00, whole cohort | 13828 | 20224 | 4033 | 6337 | 0.313 | -0.0123 | 0.0059 |
| List on file on 4 January 18:00, children who started the baseline | 1420 | 2260 | 847 | 1391 | 0.615 | -0.0029 | 0.0205 |
| Row in the file of final probabilities, applicants of the cohort | 5271 | 8255 | 5162 | 8067 | 0.977 | 0.0013 | 0.0030 |

## 3. Survey-linked rows: offer effects

Each row is one regression: outcome on `OFFER`, the paper's controls, and chance-group effects, robust standard errors. Rows on the top true program use children who named a program that matches a program code. Rows that end in "children who started" use every child who started the baseline. A row marked "applicants" uses the children of its sample with a row in the public file of regular applications. The q-values adjust over the rows of this table. The Holm p-value of the main outcome is in `baseline_offer_effects.md`.

| Family | Outcome | With offer | Without offer | Mean without offer | SD without offer | Offer effect | SE | Effect in SD | p | Holm p (main outcomes) | q within family | Offer effect, no controls | SE |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| D | Planned first preference differs from the top true program (main outcome of step 3) | 824 | 1325 | 0.236 | 0.425 | 0.003 | 0.024 | 0.008 | 0.886 |  | 0.992 | 0.003 | 0.024 |
| D | Top true program in the final list (0 without an application) | 867 | 1411 | 0.703 | 0.457 | -0.023 | 0.024 | -0.050 | 0.340 |  | 0.802 | -0.022 | 0.025 |
| D | Top true program listed first (0 without an application) | 867 | 1411 | 0.490 | 0.500 | 0.001 | 0.027 | 0.002 | 0.964 |  | 0.992 | 0.003 | 0.027 |
| D | Top true program in the final list, applicants | 673 | 1138 | 0.872 | 0.335 | -0.002 | 0.019 | -0.005 | 0.936 |  | 0.992 | 0.000 | 0.019 |
| D | Top true program listed first, applicants | 673 | 1138 | 0.607 | 0.489 | 0.022 | 0.030 | 0.045 | 0.458 |  | 0.802 | 0.025 | 0.030 |
| D | Applied with at least one inadmissible application (0 without an application), children who started | 1420 | 2260 | 0.134 | 0.340 | -0.008 | 0.013 | -0.022 | 0.569 |  | 0.802 | -0.012 | 0.013 |
| D | At least one inadmissible application, applicants, children who started | 1031 | 1686 | 0.179 | 0.384 | -0.009 | 0.017 | -0.024 | 0.593 |  | 0.802 | -0.013 | 0.018 |
| D | Share of listed preferences that are inadmissible, applicants, children who started | 1031 | 1686 | 0.099 | 0.265 | -0.012 | 0.012 | -0.045 | 0.326 |  | 0.802 | -0.015 | 0.012 |
| D | Every listed preference inadmissible, applicants, children who started | 1031 | 1686 | 0.067 | 0.250 | -0.017 | 0.012 | -0.066 | 0.152 |  | 0.802 | -0.019 | 0.012 |
| D | Probability of admission of the final list (0 without an application), children who started | 1404 | 2231 | 0.547 | 0.488 | -0.022 | 0.020 | -0.045 | 0.266 |  | 0.802 | -0.014 | 0.021 |
| D | Risk of no assignment (one minus the probability of admission), applicants, children who started | 1015 | 1657 | 0.264 | 0.426 | 0.024 | 0.021 | 0.056 | 0.253 |  | 0.802 | 0.015 | 0.022 |
| D | Probability of admission below 0.01, final list, applicants, children who started | 1015 | 1657 | 0.216 | 0.412 | 0.023 | 0.020 | 0.056 | 0.248 |  | 0.802 | 0.015 | 0.021 |
| D | Probability of admission below 0.01, list on file on 4 January 18:00, children who started | 847 | 1391 | 0.264 | 0.441 | 0.020 | 0.023 | 0.045 | 0.390 |  | 0.802 | 0.013 | 0.024 |
| D | Not selected in any preference (regular, BEA and PACE seats), applicants, children who started | 1031 | 1686 | 0.284 | 0.451 | 0.011 | 0.022 | 0.025 | 0.601 |  | 0.802 | 0.003 | 0.022 |
| D | Q61 minus 100 times the probability of admission of the final list | 688 | 1164 | -4.363 | 45.857 | -0.029 | 2.839 | -0.001 | 0.992 |  | 0.992 | -1.066 | 2.870 |
| D | Absolute difference, Q61 and the probability of admission of the final list | 688 | 1164 | 35.981 | 28.743 | 1.303 | 1.772 | 0.045 | 0.462 |  | 0.802 | 0.800 | 1.794 |

## 4. Survey-linked rows: precision

The minimum detectable effect is 2.80 standard errors (80 percent power in a two-sided test at 5 percent).

| Outcome | Children | Offer effect | SE | 95% confidence interval | Minimum detectable effect | Same, in SD | p |
|---|---|---|---|---|---|---|---|
| Planned first preference differs from the top true program (main outcome of step 3) | 2149 | 0.003 | 0.024 | [-0.043, 0.050] | 0.066 | 0.156 | 0.886 |
| Top true program in the final list (0 without an application) | 2278 | -0.023 | 0.024 | [-0.070, 0.024] | 0.068 | 0.148 | 0.340 |
| Top true program listed first (0 without an application) | 2278 | 0.001 | 0.027 | [-0.052, 0.054] | 0.076 | 0.151 | 0.964 |
| Top true program in the final list, applicants | 1811 | -0.002 | 0.019 | [-0.039, 0.036] | 0.054 | 0.161 | 0.936 |
| Top true program listed first, applicants | 1811 | 0.022 | 0.030 | [-0.036, 0.080] | 0.083 | 0.170 | 0.458 |
| Applied with at least one inadmissible application (0 without an application), children who started | 3680 | -0.008 | 0.013 | [-0.033, 0.018] | 0.037 | 0.109 | 0.569 |
| At least one inadmissible application, applicants, children who started | 2717 | -0.009 | 0.017 | [-0.044, 0.025] | 0.049 | 0.128 | 0.593 |
| Share of listed preferences that are inadmissible, applicants, children who started | 2717 | -0.012 | 0.012 | [-0.036, 0.012] | 0.034 | 0.129 | 0.326 |
| Every listed preference inadmissible, applicants, children who started | 2717 | -0.017 | 0.012 | [-0.039, 0.006] | 0.032 | 0.129 | 0.152 |
| Probability of admission of the final list (0 without an application), children who started | 3635 | -0.022 | 0.020 | [-0.061, 0.017] | 0.055 | 0.114 | 0.266 |
| Risk of no assignment (one minus the probability of admission), applicants, children who started | 2672 | 0.024 | 0.021 | [-0.017, 0.064] | 0.058 | 0.136 | 0.253 |
| Probability of admission below 0.01, final list, applicants, children who started | 2672 | 0.023 | 0.020 | [-0.016, 0.062] | 0.056 | 0.136 | 0.248 |
| Probability of admission below 0.01, list on file on 4 January 18:00, children who started | 2238 | 0.020 | 0.023 | [-0.026, 0.065] | 0.065 | 0.147 | 0.390 |
| Not selected in any preference (regular, BEA and PACE seats), applicants, children who started | 2717 | 0.011 | 0.022 | [-0.031, 0.053] | 0.060 | 0.134 | 0.601 |
| Q61 minus 100 times the probability of admission of the final list | 1852 | -0.029 | 2.839 | [-5.593, 5.534] | 7.948 | 0.173 | 0.992 |
| Absolute difference, Q61 and the probability of admission of the final list | 1852 | 1.303 | 1.772 | [-2.170, 4.776] | 4.961 | 0.173 | 0.462 |

## 5. Survey-linked rows: selection, bounds, and reweighting

The stage effect is the offer effect on being in the sample of the row, in the whole cohort. The trimming bounds (Lee 2009), their interval (Imbens and Manski 2004, 300 bootstrap draws of children), and the reweighted effect are those of `baseline_offer_effects.md`, Section 2.

| Family | Outcome | Stage effect | SE | Share trimmed | Weighted difference | Lower bound | Upper bound | 95% interval for the bounds | Worst-case bounds | Reweighted offer effect | SE | Largest weight share |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| D | Planned first preference differs from the top true program (main outcome of step 3) | -0.0048 | 0.0033 | 0.081 | 0.007 | -0.014 | 0.075 | [-0.057, 0.156] |  | 0.019 | 0.028 | 0.008 |
| D | Top true program in the final list (0 without an application) | -0.0063 | 0.0033 | 0.097 | -0.024 | -0.100 | 0.007 | [-0.177, 0.056] |  | -0.005 | 0.031 | 0.007 |
| D | Top true program listed first (0 without an application) | -0.0063 | 0.0033 | 0.097 | -0.005 | -0.059 | 0.049 | [-0.121, 0.112] |  | 0.011 | 0.028 | 0.007 |
| D | Top true program in the final list, applicants | -0.0068 | 0.0030 | 0.129 | 0.002 | -0.116 | 0.019 | [-0.169, 0.056] |  | -0.002 | 0.020 | 0.002 |
| D | Top true program listed first, applicants | -0.0068 | 0.0030 | 0.129 | 0.016 | -0.075 | 0.073 | [-0.157, 0.137] |  | 0.026 | 0.030 | 0.002 |
| D | Applied with at least one inadmissible application (0 without an application), children who started | -0.0095 | 0.0042 | 0.091 | -0.011 | -0.023 | 0.076 | [-0.048, 0.135] |  | -0.002 | 0.012 | 0.002 |
| D | At least one inadmissible application, applicants, children who started | -0.0079 | 0.0036 | 0.102 | -0.012 | -0.032 | 0.082 | [-0.066, 0.157] |  | -0.013 | 0.017 | 0.001 |
| D | Share of listed preferences that are inadmissible, applicants, children who started | -0.0079 | 0.0036 | 0.102 | -0.015 | -0.027 | 0.071 | [-0.050, 0.112] |  | -0.015 | 0.012 | 0.001 |
| D | Every listed preference inadmissible, applicants, children who started | -0.0079 | 0.0036 | 0.102 | -0.019 | -0.028 | 0.053 | [-0.048, 0.081] |  | -0.020 | 0.011 | 0.001 |
| D | Probability of admission of the final list (0 without an application), children who started | -0.0096 | 0.0041 | 0.093 | -0.020 | -0.076 | 0.027 | [-0.130, 0.076] |  | -0.013 | 0.021 | 0.002 |
| D | Risk of no assignment (one minus the probability of admission), applicants, children who started | -0.0080 | 0.0036 | 0.106 | 0.017 | -0.014 | 0.104 | [-0.058, 0.180] |  | 0.018 | 0.021 | 0.001 |
| D | Probability of admission below 0.01, final list, applicants, children who started | -0.0080 | 0.0036 | 0.106 | 0.018 | -0.008 | 0.110 | [-0.048, 0.188] |  | 0.020 | 0.020 | 0.001 |
| D | Probability of admission below 0.01, list on file on 4 January 18:00, children who started | -0.0070 | 0.0033 | 0.110 | 0.014 | -0.018 | 0.105 | [-0.067, 0.190] |  | 0.020 | 0.023 | 0.069 |
| D | Not selected in any preference (regular, BEA and PACE seats), applicants, children who started | -0.0079 | 0.0036 | 0.102 | 0.007 | -0.026 | 0.088 | [-0.072, 0.164] |  | 0.006 | 0.021 | 0.001 |
| D | Q61 minus 100 times the probability of admission of the final list | -0.0069 | 0.0030 | 0.128 | 0.337 | -8.174 | 13.221 | [-15.024, 22.194] |  | -0.622 | 2.844 | 0.002 |
| D | Absolute difference, Q61 and the probability of admission of the final list | -0.0069 | 0.0030 | 0.128 | 1.228 | -4.106 | 8.830 | [-8.674, 13.939] |  | 1.172 | 1.770 | 0.002 |

## 6. Whole cohort, no survey: offer effects

The same administrative outcomes for every child of application year 2018. These rows are outside the adjusted set. A row with "0 without an application" is defined for every child of the cohort.

| Family | Outcome | With offer | Without offer | Mean without offer | SD without offer | Offer effect | SE | Effect in SD | p | Holm p (main outcomes) | q within family | Offer effect, no controls | SE |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| D | Applied with at least one inadmissible application (0 without an application), whole cohort | 13828 | 20224 | 0.068 | 0.252 | -0.005 | 0.003 | -0.019 | 0.154 |  |  | -0.005 | 0.003 |
| D | At least one inadmissible application, applicants, whole cohort | 5271 | 8255 | 0.167 | 0.373 | -0.007 | 0.008 | -0.019 | 0.358 |  |  | -0.005 | 0.008 |
| D | Share of listed preferences that are inadmissible, applicants, whole cohort | 5271 | 8255 | 0.091 | 0.255 | -0.007 | 0.005 | -0.028 | 0.167 |  |  | -0.006 | 0.005 |
| D | Every listed preference inadmissible, applicants, whole cohort | 5271 | 8255 | 0.060 | 0.237 | -0.008 | 0.005 | -0.033 | 0.110 |  |  | -0.007 | 0.005 |
| D | Probability of admission of the final list (0 without an application), whole cohort | 13719 | 20036 | 0.294 | 0.450 | -0.020 | 0.006 | -0.046 | 0.000 |  |  | -0.022 | 0.006 |
| D | Risk of no assignment (one minus the probability of admission), applicants, whole cohort | 5162 | 8067 | 0.271 | 0.430 | 0.025 | 0.009 | 0.058 | 0.006 |  |  | 0.026 | 0.010 |
| D | Probability of admission below 0.01, final list, applicants, whole cohort | 5162 | 8067 | 0.223 | 0.417 | 0.021 | 0.009 | 0.050 | 0.018 |  |  | 0.022 | 0.009 |
| D | Probability of admission below 0.01, list on file on 4 January 18:00, whole cohort | 4033 | 6337 | 0.263 | 0.440 | 0.033 | 0.011 | 0.074 | 0.002 |  |  | 0.033 | 0.011 |
| D | Not selected in any preference (regular, BEA and PACE seats), applicants, whole cohort | 5271 | 8255 | 0.286 | 0.452 | 0.023 | 0.009 | 0.050 | 0.015 |  |  | 0.025 | 0.010 |

## 7. Whole cohort: precision

| Outcome | Children | Offer effect | SE | 95% confidence interval | Minimum detectable effect | Same, in SD | p |
|---|---|---|---|---|---|---|---|
| Applied with at least one inadmissible application (0 without an application), whole cohort | 34052 | -0.005 | 0.003 | [-0.011, 0.002] | 0.009 | 0.037 | 0.154 |
| At least one inadmissible application, applicants, whole cohort | 13526 | -0.007 | 0.008 | [-0.022, 0.008] | 0.021 | 0.057 | 0.358 |
| Share of listed preferences that are inadmissible, applicants, whole cohort | 13526 | -0.007 | 0.005 | [-0.018, 0.003] | 0.015 | 0.058 | 0.167 |
| Every listed preference inadmissible, applicants, whole cohort | 13526 | -0.008 | 0.005 | [-0.017, 0.002] | 0.014 | 0.058 | 0.110 |
| Probability of admission of the final list (0 without an application), whole cohort | 33755 | -0.020 | 0.006 | [-0.031, -0.010] | 0.015 | 0.034 | 0.000 |
| Risk of no assignment (one minus the probability of admission), applicants, whole cohort | 13229 | 0.025 | 0.009 | [0.007, 0.042] | 0.025 | 0.059 | 0.006 |
| Probability of admission below 0.01, final list, applicants, whole cohort | 13229 | 0.021 | 0.009 | [0.004, 0.038] | 0.025 | 0.059 | 0.018 |
| Probability of admission below 0.01, list on file on 4 January 18:00, whole cohort | 10370 | 0.033 | 0.011 | [0.012, 0.053] | 0.029 | 0.067 | 0.002 |
| Not selected in any preference (regular, BEA and PACE seats), applicants, whole cohort | 13526 | 0.023 | 0.009 | [0.005, 0.041] | 0.026 | 0.058 | 0.015 |

## 8. Whole cohort: selection and bounds

An outcome defined for every child has no stage, and its bounds equal the weighted difference. The reweighted effect is not computed for these rows.

| Family | Outcome | Stage effect | SE | Share trimmed | Weighted difference | Lower bound | Upper bound | 95% interval for the bounds | Worst-case bounds | Reweighted offer effect | SE | Largest weight share |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| D | Applied with at least one inadmissible application (0 without an application), whole cohort | 0.0000 | 0.0000 | 0.000 | -0.005 | -0.005 | -0.005 | [-0.011, 0.001] |  |  |  |  |
| D | At least one inadmissible application, applicants, whole cohort | -0.0139 | 0.0061 | 0.040 | -0.006 | -0.013 | 0.029 | [-0.026, 0.055] |  |  |  |  |
| D | Share of listed preferences that are inadmissible, applicants, whole cohort | -0.0139 | 0.0061 | 0.040 | -0.006 | -0.010 | 0.031 | [-0.019, 0.058] |  |  |  |  |
| D | Every listed preference inadmissible, applicants, whole cohort | -0.0139 | 0.0061 | 0.040 | -0.007 | -0.010 | 0.032 | [-0.018, 0.058] |  |  |  |  |
| D | Probability of admission of the final list (0 without an application), whole cohort | 0.0008 | 0.0012 | 0.001 | -0.022 | -0.023 | -0.022 | [-0.035, -0.009] |  |  |  |  |
| D | Risk of no assignment (one minus the probability of admission), applicants, whole cohort | -0.0131 | 0.0060 | 0.039 | 0.027 | 0.016 | 0.056 | [-0.002, 0.084] |  |  |  |  |
| D | Probability of admission below 0.01, final list, applicants, whole cohort | -0.0131 | 0.0060 | 0.039 | 0.022 | 0.013 | 0.053 | [-0.004, 0.082] |  |  |  |  |
| D | Probability of admission below 0.01, list on file on 4 January 18:00, whole cohort | -0.0123 | 0.0059 | 0.045 | 0.034 | 0.021 | 0.069 | [0.000, 0.102] |  |  |  |  |
| D | Not selected in any preference (regular, BEA and PACE seats), applicants, whole cohort | -0.0139 | 0.0061 | 0.040 | 0.025 | 0.013 | 0.054 | [-0.006, 0.082] |  |  |  |  |

## 9. Attendance effects (IV)

An attendance effect is shown only when the 95 percent interval of the stage effect includes zero and both trimming bounds have the same sign (specification log, Section 6). An outcome defined for every child of the cohort has no stage. Its attendance effect rests on the paper's exclusion restriction for college outcomes.

| Family | Outcome | First stage among answering children | Attendance effect | SE | Shown |
|---|---|---|---|---|---|
| D | Planned first preference differs from the top true program (main outcome of step 3) | 0.542 | | | no |
| D | Top true program in the final list (0 without an application) | 0.545 | | | no |
| D | Top true program listed first (0 without an application) | 0.545 | | | no |
| D | Top true program in the final list, applicants | 0.541 | | | no |
| D | Top true program listed first, applicants | 0.541 | | | no |
| D | Applied with at least one inadmissible application (0 without an application), children who started | 0.570 | | | no |
| D | At least one inadmissible application, applicants, children who started | 0.556 | | | no |
| D | Share of listed preferences that are inadmissible, applicants, children who started | 0.556 | | | no |
| D | Every listed preference inadmissible, applicants, children who started | 0.556 | | | no |
| D | Probability of admission of the final list (0 without an application), children who started | 0.567 | | | no |
| D | Risk of no assignment (one minus the probability of admission), applicants, children who started | 0.552 | | | no |
| D | Probability of admission below 0.01, final list, applicants, children who started | 0.552 | | | no |
| D | Probability of admission below 0.01, list on file on 4 January 18:00, children who started | 0.551 | | | no |
| D | Not selected in any preference (regular, BEA and PACE seats), applicants, children who started | 0.556 | | | no |
| D | Q61 minus 100 times the probability of admission of the final list | 0.547 | | | no |
| D | Absolute difference, Q61 and the probability of admission of the final list | 0.547 | | | no |
| D | Applied with at least one inadmissible application (0 without an application), whole cohort | 0.566 | -0.008 | 0.006 | yes |
| D | At least one inadmissible application, applicants, whole cohort | 0.549 | | | no |
| D | Share of listed preferences that are inadmissible, applicants, whole cohort | 0.549 | | | no |
| D | Every listed preference inadmissible, applicants, whole cohort | 0.549 | | | no |
| D | Probability of admission of the final list (0 without an application), whole cohort | 0.565 | -0.036 | 0.010 | yes |
| D | Risk of no assignment (one minus the probability of admission), applicants, whole cohort | 0.548 | | | no |
| D | Probability of admission below 0.01, final list, applicants, whole cohort | 0.548 | | | no |
| D | Probability of admission below 0.01, list on file on 4 January 18:00, whole cohort | 0.558 | | | no |
| D | Not selected in any preference (regular, BEA and PACE seats), applicants, whole cohort | 0.549 | | | no |

