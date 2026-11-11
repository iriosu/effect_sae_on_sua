# Expected against realized Ranking and NEM scores: offer effects, application year 2018

Written by `code/survey_lottery_2023/06_ranking_belief_gap.R`. Added after the first results. The rows were fixed in the entry of 11 November 2026, 21:23 UTC, of `specification_log.md`. They are descriptive and enter no adjusted set. The q-values of the Ranking rows are those of `baseline_offer_effects.md` (0.167).
Expected scores are the answers to `Q41` of the 2023 baseline (NEM and Ranking, 100 to 1000). Realized scores are `PTJE_NEM` and `PTJE_RANKING` of the public registration file of the 2023 process.

## 1. Children who answered: offer effects

Each row is one regression: outcome on `OFFER`, the paper's controls, and chance-group effects, robust standard errors. Expected and realized scores use the children who have both, so the effect on the difference equals the effect on the expected score minus the effect on the realized score.

| Family | Outcome | With offer | Without offer | Mean without offer | SD without offer | Offer effect | SE | Effect in SD | p | Holm p (main outcomes) | q within family | Offer effect, no controls | SE |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| E | Expected minus realized Ranking score | 1187 | 1887 | -131.8 | 185.0 | 18.2 | 8.3 | 0.098 | 0.028 |  |  | 19.7 | 8.3 |
| E | Absolute difference, Ranking | 1187 | 1887 | 161.6 | 159.7 | -16.9 | 7.0 | -0.106 | 0.016 |  |  | -18.7 | 7.1 |
| E | Expected Ranking score, same children | 1187 | 1887 | 624.7 | 220.1 | -2.4 | 8.9 | -0.011 | 0.788 |  |  | 1.6 | 9.7 |
| E | Realized Ranking score, same children | 1187 | 1887 | 756.4 | 159.8 | -20.6 | 5.7 | -0.129 | 0.000 |  |  | -18.1 | 7.3 |
| E | Expected minus realized NEM score | 1187 | 1887 | -78.0 | 142.9 | 6.2 | 6.4 | 0.043 | 0.336 |  |  | 7.5 | 6.4 |
| E | Absolute difference, NEM | 1187 | 1887 | 107.4 | 122.4 | -5.9 | 5.5 | -0.048 | 0.282 |  |  | -7.4 | 5.5 |
| E | Expected NEM score, same children | 1187 | 1887 | 648.4 | 194.0 | -6.6 | 7.5 | -0.034 | 0.386 |  |  | -3.0 | 8.5 |
| E | Realized NEM score, same children | 1187 | 1887 | 726.5 | 140.0 | -12.7 | 5.0 | -0.091 | 0.011 |  |  | -10.5 | 6.5 |
| E | Expected Ranking above realized Ranking | 1187 | 1887 | 0.202 | 0.402 | 0.022 | 0.019 | 0.054 | 0.252 |  |  | 0.022 | 0.019 |
| E | Absolute difference of 50 points or less, Ranking | 1187 | 1887 | 0.312 | 0.463 | 0.032 | 0.021 | 0.070 | 0.133 |  |  | 0.039 | 0.022 |
| E | Expected Ranking more than 100 points below realized | 1187 | 1887 | 0.477 | 0.500 | -0.045 | 0.023 | -0.090 | 0.052 |  |  | -0.048 | 0.023 |
| E | Expected Ranking minus expected NEM | 1187 | 1887 | -23.8 | 121.2 | 4.2 | 5.5 | 0.034 | 0.452 |  |  | 4.6 | 5.6 |
| E | Realized Ranking minus realized NEM, same children | 1187 | 1887 | 29.975 | 33.787 | -7.872 | 1.298 | -0.233 | 0.000 |  |  | -7.594 | 1.374 |
| E | Expected minus realized, Ranking minus NEM | 1187 | 1887 | -53.7 | 126.9 | 12.0 | 5.7 | 0.095 | 0.034 |  |  | 12.2 | 5.7 |
| E | Expected minus realized Ranking, winsorized at percentiles 1 and 99 | 1187 | 1887 | -131.7 | 180.1 | 17.9 | 8.1 | 0.100 | 0.027 |  |  | 19.4 | 8.2 |

## 2. Children who answered: precision

The minimum detectable effect is 2.80 standard errors (80 percent power in a two-sided test at 5 percent).

| Outcome | Children | Offer effect | SE | 95% confidence interval | Minimum detectable effect | Same, in SD | p |
|---|---|---|---|---|---|---|---|
| Expected minus realized Ranking score | 3074 | 18.2 | 8.3 | [2.0, 34.4] | 23.2 | 0.125 | 0.028 |
| Absolute difference, Ranking | 3074 | -16.9 | 7.0 | [-30.7, -3.2] | 19.7 | 0.123 | 0.016 |
| Expected Ranking score, same children | 3074 | -2.4 | 8.9 | [-19.7, 15.0] | 24.8 | 0.113 | 0.788 |
| Realized Ranking score, same children | 3074 | -20.6 | 5.7 | [-31.7, -9.4] | 15.9 | 0.100 | 0.000 |
| Expected minus realized NEM score | 3074 | 6.2 | 6.4 | [-6.4, 18.7] | 18.0 | 0.126 | 0.336 |
| Absolute difference, NEM | 3074 | -5.9 | 5.5 | [-16.6, 4.8] | 15.3 | 0.125 | 0.282 |
| Expected NEM score, same children | 3074 | -6.6 | 7.5 | [-21.3, 8.2] | 21.1 | 0.109 | 0.386 |
| Realized NEM score, same children | 3074 | -12.7 | 5.0 | [-22.5, -3.0] | 13.9 | 0.100 | 0.011 |
| Expected Ranking above realized Ranking | 3074 | 0.022 | 0.019 | [-0.015, 0.058] | 0.053 | 0.131 | 0.252 |
| Absolute difference of 50 points or less, Ranking | 3074 | 0.032 | 0.021 | [-0.010, 0.074] | 0.060 | 0.130 | 0.133 |
| Expected Ranking more than 100 points below realized | 3074 | -0.045 | 0.023 | [-0.090, 0.000] | 0.064 | 0.129 | 0.052 |
| Expected Ranking minus expected NEM | 3074 | 4.2 | 5.5 | [-6.7, 15.0] | 15.5 | 0.128 | 0.452 |
| Realized Ranking minus realized NEM, same children | 3074 | -7.872 | 1.298 | [-10.415, -5.329] | 3.633 | 0.108 | 0.000 |
| Expected minus realized, Ranking minus NEM | 3074 | 12.0 | 5.7 | [0.9, 23.2] | 15.9 | 0.125 | 0.034 |
| Expected minus realized Ranking, winsorized at percentiles 1 and 99 | 3074 | 17.9 | 8.1 | [2.1, 33.8] | 22.7 | 0.126 | 0.027 |

## 3. Children who answered: selection, bounds, and reweighting

Columns as in `baseline_offer_effects.md`, Section 2.

| Family | Outcome | Stage effect | SE | Share trimmed | Weighted difference | Lower bound | Upper bound | 95% interval for the bounds | Worst-case bounds | Reweighted offer effect | SE | Largest weight share |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| E | Expected minus realized Ranking score | -0.0074 | 0.0038 | 0.085 | 18.8 | -18.8 | 45.3 | [-45.6, 65.3] |  | 35.6 | 10.9 | 0.003 |
| E | Absolute difference, Ranking | -0.0074 | 0.0038 | 0.085 | -16.3 | -31.3 | 18.6 | [-47.2, 43.5] |  | -27.4 | 9.2 | 0.003 |
| E | Expected Ranking score, same children | -0.0074 | 0.0038 | 0.085 | -1.9 | -41.5 | 30.8 | [-72.6, 58.4] |  | 11.7 | 10.7 | 0.003 |
| E | Realized Ranking score, same children | -0.0074 | 0.0038 | 0.085 | -20.7 | -48.2 | 1.8 | [-70.6, 22.3] |  | -23.9 | 7.1 | 0.003 |
| E | Expected minus realized NEM score | -0.0074 | 0.0038 | 0.085 | 6.8 | -24.4 | 26.1 | [-45.0, 40.9] |  | 12.6 | 9.0 | 0.003 |
| E | Absolute difference, NEM | -0.0074 | 0.0038 | 0.085 | -5.7 | -15.6 | 23.1 | [-27.4, 42.1] |  | -8.6 | 7.4 | 0.003 |
| E | Expected NEM score, same children | -0.0074 | 0.0038 | 0.085 | -6.2 | -42.9 | 21.6 | [-69.9, 45.3] |  | -3.3 | 9.5 | 0.003 |
| E | Realized NEM score, same children | -0.0074 | 0.0038 | 0.085 | -12.9 | -37.7 | 7.6 | [-57.4, 25.3] |  | -15.9 | 6.4 | 0.003 |
| E | Expected Ranking above realized Ranking | -0.0074 | 0.0038 | 0.085 | 0.025 | 0.007 | 0.100 | [-0.028, 0.171] |  | 0.060 | 0.025 | 0.003 |
| E | Absolute difference of 50 points or less, Ranking | -0.0074 | 0.0038 | 0.085 | 0.034 | 0.005 | 0.098 | [-0.040, 0.162] |  | 0.043 | 0.027 | 0.003 |
| E | Expected Ranking more than 100 points below realized | -0.0074 | 0.0038 | 0.085 | -0.044 | -0.088 | 0.005 | [-0.139, 0.059] |  | -0.080 | 0.026 | 0.003 |
| E | Expected Ranking minus expected NEM | -0.0074 | 0.0038 | 0.085 | 4.3 | -21.7 | 23.6 | [-38.6, 37.4] |  | 14.9 | 7.9 | 0.003 |
| E | Realized Ranking minus realized NEM, same children | -0.0074 | 0.0038 | 0.085 | -7.769 | -10.576 | -0.158 | [-13.962, 4.870] |  | -8.039 | 1.343 | 0.003 |
| E | Expected minus realized, Ranking minus NEM | -0.0074 | 0.0038 | 0.085 | 12.0 | -14.9 | 32.1 | [-32.4, 46.2] |  | 23.0 | 8.0 | 0.003 |
| E | Expected minus realized Ranking, winsorized at percentiles 1 and 99 | -0.0074 | 0.0038 | 0.085 | 18.6 | -18.2 | 44.1 | [-44.8, 63.7] |  | 35.5 | 10.5 | 0.003 |

## 4. Quantiles of expected minus realized Ranking by offer group

Children are weighted as in the trimming bounds (an offered child weighs one minus the offer share of the chance group, a non-offered child the offer share). Standard errors of the differences come from 300 bootstrap draws of children. No controls.

| Quantile | With offer | Without offer | Difference | SE |
|---|---|---|---|---|
| 10 | -349.0 | -395.0 | 46.0 | 19.9 |
| 25 | -206.0 | -228.0 | 22.0 | 12.5 |
| 50 | -71.0 | -88.0 | 17.0 | 9.6 |
| 75 | 0.0 | -1.0 | 1.0 | 1.7 |
| 90 | 55.0 | 46.0 | 9.0 | 15.6 |

## 5. Realized scores without the survey: offer effects

Realized scores of the registration file for every child of the cohort who has one, and the scores on time of the paper's panel.

| Family | Outcome | With offer | Without offer | Mean without offer | SD without offer | Offer effect | SE | Effect in SD | p | Holm p (main outcomes) | q within family | Offer effect, no controls | SE |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| E | Realized Ranking score, children with a score in the registration file | 9141 | 14012 | 716.6 | 160.9 | -21.1 | 2.0 | -0.131 | 0.000 |  |  | -19.3 | 2.6 |
| E | Realized NEM score, children with a score in the registration file | 9141 | 14012 | 692.5 | 141.4 | -13.5 | 1.8 | -0.096 | 0.000 |  |  | -11.9 | 2.3 |
| E | Realized Ranking score, children who started the baseline | 1419 | 2260 | 749.7 | 160.5 | -24.4 | 5.3 | -0.152 | 0.000 |  |  | -21.4 | 6.7 |
| E | Realized Ranking score, children who did not start the baseline | 7722 | 11752 | 710.2 | 160.2 | -20.1 | 2.2 | -0.126 | 0.000 |  |  | -18.1 | 2.8 |
| E | `SCORE_RANKING_OT` of the paper's panel | 11294 | 17132 | -0.104 | 0.987 | -0.113 | 0.011 | -0.115 | 0.000 |  |  | -0.100 | 0.014 |
| E | `SCORE_NEM_OT` of the paper's panel | 11294 | 17132 | -0.134 | 0.955 | -0.082 | 0.011 | -0.086 | 0.000 |  |  | -0.069 | 0.014 |

## 6. Realized scores without the survey: precision

| Outcome | Children | Offer effect | SE | 95% confidence interval | Minimum detectable effect | Same, in SD | p |
|---|---|---|---|---|---|---|---|
| Realized Ranking score, children with a score in the registration file | 23153 | -21.1 | 2.0 | [-25.0, -17.2] | 5.6 | 0.035 | 0.000 |
| Realized NEM score, children with a score in the registration file | 23153 | -13.5 | 1.8 | [-17.0, -10.0] | 4.9 | 0.035 | 0.000 |
| Realized Ranking score, children who started the baseline | 3679 | -24.4 | 5.3 | [-34.7, -14.1] | 14.7 | 0.092 | 0.000 |
| Realized Ranking score, children who did not start the baseline | 19474 | -20.1 | 2.2 | [-24.4, -15.9] | 6.1 | 0.038 | 0.000 |
| `SCORE_RANKING_OT` of the paper's panel | 28426 | -0.113 | 0.011 | [-0.135, -0.092] | 0.031 | 0.031 | 0.000 |
| `SCORE_NEM_OT` of the paper's panel | 28426 | -0.082 | 0.011 | [-0.103, -0.061] | 0.030 | 0.031 | 0.000 |

## 7. Realized scores without the survey: selection and bounds

The stage effect is the offer effect on having the score. The reweighted effect is not computed for these rows.

| Family | Outcome | Stage effect | SE | Share trimmed | Weighted difference | Lower bound | Upper bound | 95% interval for the bounds | Worst-case bounds | Reweighted offer effect | SE | Largest weight share |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| E | Realized Ranking score, children with a score in the registration file | -0.0268 | 0.0058 | 0.041 | -19.4 | -33.3 | -7.2 | [-39.7, -1.1] |  |  |  |  |
| E | Realized NEM score, children with a score in the registration file | -0.0268 | 0.0058 | 0.041 | -12.0 | -24.8 | -0.7 | [-30.6, 4.5] |  |  |  |  |
| E | Realized Ranking score, children who started the baseline | -0.0096 | 0.0041 | 0.091 | -24.6 | -53.6 | -0.1 | [-74.0, 18.9] |  |  |  |  |
| E | Realized Ranking score, children who did not start the baseline | -0.0172 | 0.0064 | 0.032 | -18.0 | -28.9 | -8.5 | [-36.3, -1.3] |  |  |  |  |
| E | `SCORE_RANKING_OT` of the paper's panel | -0.0303 | 0.0048 | 0.037 | -0.101 | -0.177 | -0.031 | [-0.207, 0.001] |  |  |  |  |
| E | `SCORE_NEM_OT` of the paper's panel | -0.0303 | 0.0048 | 0.037 | -0.069 | -0.147 | 0.000 | [-0.177, 0.031] |  |  |  |  |

## 8. Offer effect on realized Ranking by whether the child started the baseline

One regression of realized Ranking on `OFFER`, starting the baseline, their interaction, the controls, and chance-group effects, among the 23,153 children with a score.

| Term | Coefficient | SE | p |
|---|---|---|---|
| `OFFER` | -21.2 | 2.1 | 0.000 |
| `STARTED` | 24.3 | 2.9 | 0.000 |
| `OFFER:STARTED` | 2.4 | 4.6 | 0.603 |

## 9. Attendance effects (IV)

Shown only under the conditions of the specification log, Section 6.

| Family | Outcome | First stage among answering children | Attendance effect | SE | Shown |
|---|---|---|---|---|---|
| E | Expected minus realized Ranking score | 0.570 | | | no |
| E | Absolute difference, Ranking | 0.570 | | | no |
| E | Expected Ranking score, same children | 0.570 | | | no |
| E | Realized Ranking score, same children | 0.570 | | | no |
| E | Expected minus realized NEM score | 0.570 | | | no |
| E | Absolute difference, NEM | 0.570 | | | no |
| E | Expected NEM score, same children | 0.570 | | | no |
| E | Realized NEM score, same children | 0.570 | | | no |
| E | Expected Ranking above realized Ranking | 0.570 | 0.038 | 0.033 | yes |
| E | Absolute difference of 50 points or less, Ranking | 0.570 | 0.057 | 0.038 | yes |
| E | Expected Ranking more than 100 points below realized | 0.570 | | | no |
| E | Expected Ranking minus expected NEM | 0.570 | | | no |
| E | Realized Ranking minus realized NEM, same children | 0.570 | -13.806 | 2.242 | yes |
| E | Expected minus realized, Ranking minus NEM | 0.570 | | | no |
| E | Expected minus realized Ranking, winsorized at percentiles 1 and 99 | 0.570 | | | no |
| E | Realized Ranking score, children with a score in the registration file | 0.568 | | | no |
| E | Realized NEM score, children with a score in the registration file | 0.568 | | | no |
| E | Realized Ranking score, children who started the baseline | 0.570 | | | no |
| E | Realized Ranking score, children who did not start the baseline | 0.567 | | | no |
| E | `SCORE_RANKING_OT` of the paper's panel | 0.566 | | | no |
| E | `SCORE_NEM_OT` of the paper's panel | 0.566 | | | no |

