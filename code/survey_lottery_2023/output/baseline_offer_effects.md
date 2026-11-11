# 2023 baseline survey: offer effects in the lottery sample

Written by `code/survey_lottery_2023/03_baseline_offer_effects.R`. Exploratory. Specifications are in `specification_log.md`.
Rows with fewer than 11 answering children in either offer group are suppressed. Rows with fewer than 50 in either group show counts and no estimate.
Share of named programs matched to a program code: top true 1.000, planned first 1.000, planned last 0.999.

## 1. Application year 2018: offer effects among children who answered each item

Each row is one regression: outcome on `OFFER`, the paper's controls, and chance-group effects (plus effects for the random group of questions where the item sits in one), robust standard errors. The estimate compares offered and non-offered children who answered. It is an effect on a fixed population only if the offer does not change who answers (Section 2 below).

| Family | Outcome | With offer | Without offer | Mean without offer | SD without offer | Offer effect | SE | Effect in SD | p | Holm p (main outcomes) | q within family | Offer effect, no controls | SE |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| A | Expected monthly income, planned first preference (pesos) (main) | 306 | 508 | 1,224,206 | 780,229 | 24,414 | 84,689 | 0.031 | 0.773 | 1.000 | 0.925 | 39,109 | 85,208 |
| A | Expected annual payment, planned first preference (pesos) | 102 | 133 | 2,566,648 | 2,254,720 | -328,881 | 406,717 | -0.146 | 0.420 |  | 0.840 | -68,235 | 424,901 |
| A | Probability of graduating, planned first preference | 277 | 473 | 87.945 | 19.771 | 3.588 | 1.985 | 0.181 | 0.071 |  | 0.390 | 3.220 | 2.018 |
| A | Semesters to graduate, planned first preference | 303 | 488 | 9.641 | 3.761 | -0.472 | 0.347 | -0.125 | 0.174 |  | 0.557 | -0.418 | 0.350 |
| A | Position among 100 peers, planned first preference | 380 | 691 | 66.450 | 20.931 | -1.140 | 1.701 | -0.054 | 0.503 |  | 0.842 | -1.084 | 1.691 |
| A | Probability of staying, planned first preference | 368 | 634 | 87.274 | 21.659 | 3.093 | 1.723 | 0.143 | 0.073 |  | 0.390 | 3.457 | 1.709 |
| A | Probability of passing all first-year courses, planned first preference | 389 | 699 | 79.721 | 21.609 | -0.114 | 1.966 | -0.005 | 0.954 |  | 0.957 | -0.028 | 1.947 |
| A | Probability of employment, planned first preference | 301 | 509 | 74.866 | 22.600 | 0.677 | 2.224 | 0.030 | 0.761 |  | 0.925 | 0.784 | 2.201 |
| A | Expected monthly income, top true program (pesos) | 309 | 511 | 1,217,424 | 785,913 | -20,183 | 83,617 | -0.026 | 0.809 |  | 0.925 | -4,795 | 84,232 |
| A | Expected annual payment, top true program (pesos) | 104 | 134 | 2,492,972 | 2,224,381 | -411,294 | 388,318 | -0.185 | 0.291 |  | 0.666 | -157,313 | 389,345 |
| A | Probability of graduating, top true program | 281 | 477 | 89.379 | 18.473 | 2.469 | 2.122 | 0.134 | 0.245 |  | 0.653 | 2.017 | 2.114 |
| A | Semesters to graduate, top true program | 307 | 489 | 9.693 | 3.842 | -0.496 | 0.342 | -0.129 | 0.148 |  | 0.557 | -0.451 | 0.346 |
| A | Position among 100 peers, top true program | 382 | 695 | 66.578 | 21.066 | -0.835 | 1.803 | -0.040 | 0.643 |  | 0.925 | -0.711 | 1.792 |
| A | Probability of staying, top true program | 372 | 638 | 88.017 | 21.580 | 3.354 | 1.797 | 0.155 | 0.062 |  | 0.390 | 3.625 | 1.776 |
| A | Probability of passing all first-year courses, top true program | 391 | 701 | 80.265 | 21.238 | -0.101 | 1.863 | -0.005 | 0.957 |  | 0.957 | 0.003 | 1.846 |
| A | Probability of employment, top true program | 305 | 511 | 75.879 | 22.236 | 1.361 | 2.147 | 0.061 | 0.526 |  | 0.842 | 1.471 | 2.133 |
| B | Q61: probability of admission to any program of the application (main) | 937 | 1523 | 69.840 | 26.015 | -0.750 | 1.413 | -0.029 | 0.596 | 1.000 | 0.805 | -0.722 | 1.416 |
| B | Q60: probability of applying | 949 | 1539 | 84.892 | 25.760 | -0.339 | 1.371 | -0.013 | 0.805 |  | 0.805 | -0.201 | 1.376 |
| B | Probability of graduating, planned first preference | 277 | 473 | 87.945 | 19.771 | 3.588 | 1.985 | 0.181 | 0.071 |  | 0.214 | 3.220 | 2.018 |
| C | Cutoff percentile of the top true program (2023 process) (main) | 834 | 1330 | 69.489 | 26.680 | 1.195 | 1.491 | 0.045 | 0.423 | 1.000 | 0.693 | 1.145 | 1.544 |
| C | Cutoff percentile of the planned first preference | 792 | 1254 | 69.694 | 26.338 | 0.260 | 1.496 | 0.010 | 0.862 |  | 0.862 | 0.047 | 1.550 |
| C | Cutoff percentile of the planned last preference | 761 | 1192 | 65.804 | 26.215 | -1.132 | 1.538 | -0.043 | 0.462 |  | 0.693 | -1.331 | 1.568 |
| D | Planned first preference differs from the top true program (main) | 824 | 1325 | 0.236 | 0.425 | 0.003 | 0.024 | 0.008 | 0.886 | 1.000 | 0.886 | 0.003 | 0.024 |
| E | Expected minus realized Mathematics M1 score (main) | 1207 | 1916 | -22.9 | 139.7 | -0.6 | 6.6 | -0.004 | 0.931 | 1.000 | 0.931 | 0.3 | 6.6 |
| E | Expected minus realized Reading score | 1220 | 1949 | 19.9 | 149.2 | -1.9 | 6.9 | -0.013 | 0.784 |  | 0.847 | -1.6 | 6.9 |
| E | Expected minus realized NEM score | 1187 | 1887 | -78.0 | 142.9 | 6.2 | 6.4 | 0.043 | 0.336 |  | 0.642 | 7.5 | 6.4 |
| E | Expected minus realized Ranking score | 1187 | 1887 | -131.8 | 185.0 | 18.2 | 8.3 | 0.098 | 0.028 |  | 0.167 | 19.7 | 8.3 |
| E | Absolute difference, Mathematics M1 | 1207 | 1916 | 107.810 | 91.771 | 6.629 | 4.286 | 0.072 | 0.122 |  | 0.457 | 5.628 | 4.320 |
| E | Absolute difference, Reading | 1220 | 1949 | 115.293 | 96.755 | 3.384 | 4.504 | 0.035 | 0.453 |  | 0.679 | 2.782 | 4.522 |
| E | Absolute difference, NEM | 1187 | 1887 | 107.4 | 122.4 | -5.9 | 5.5 | -0.048 | 0.282 |  | 0.635 | -7.4 | 5.5 |
| E | Absolute difference, Ranking | 1187 | 1887 | 161.6 | 159.7 | -16.9 | 7.0 | -0.106 | 0.016 |  | 0.167 | -18.7 | 7.1 |
| E | Expected Mathematics M1 score | 1212 | 1918 | 499.1 | 163.9 | 2.6 | 7.2 | 0.016 | 0.716 |  | 0.847 | 6.4 | 7.4 |
| E | Expected Reading score | 1221 | 1950 | 633.1 | 156.1 | 3.9 | 6.9 | 0.025 | 0.571 |  | 0.790 | 6.8 | 7.0 |
| E | Expected NEM score | 1188 | 1887 | 648.4 | 194.0 | -7.0 | 7.6 | -0.036 | 0.356 |  | 0.642 | -3.4 | 8.5 |
| E | Expected Ranking score | 1188 | 1887 | 624.7 | 220.1 | -2.7 | 8.9 | -0.012 | 0.757 |  | 0.847 | 1.3 | 9.7 |
| E | Q63: probability of admission if listed first, planned first preference | 727 | 1195 | 68.780 | 25.138 | -1.692 | 1.545 | -0.067 | 0.274 |  | 0.635 | -1.733 | 1.545 |
| E | Q64: cutoff belief, planned first preference | 720 | 1183 | 621.3 | 159.8 | -11.6 | 9.8 | -0.073 | 0.236 |  | 0.635 | -12.2 | 9.9 |
| E | Q65: probability own score above the cutoff, planned first preference | 675 | 1137 | 60.596 | 25.384 | -3.378 | 1.518 | -0.133 | 0.026 |  | 0.167 | -3.222 | 1.528 |
| E | Q63: probability of admission if listed first, top true program | 735 | 1203 | 68.883 | 25.450 | -0.392 | 1.546 | -0.015 | 0.800 |  | 0.847 | -0.514 | 1.541 |
| E | Cutoff belief minus realized cutoff, planned first preference | 692 | 1120 | -73.2 | 163.2 | -14.9 | 9.8 | -0.092 | 0.127 |  | 0.457 | -14.5 | 9.7 |
| E | Absolute difference, cutoff of the planned first preference | 692 | 1120 | 137.7 | 114.1 | -5.4 | 6.8 | -0.047 | 0.425 |  | 0.679 | -6.1 | 6.8 |
| E | Realized Mathematics M1 score, same children (companion row) | 1207 | 1916 | 522.438 | 99.694 | 3.041 | 4.066 | 0.031 | 0.454 |  |  | 6.092 | 4.476 |
| E | Realized Reading score, same children (companion row) | 1220 | 1949 | 613.2 | 117.5 | 6.2 | 4.8 | 0.052 | 0.198 |  |  | 8.8 | 5.3 |
| E | Realized NEM score, same children (companion row) | 1187 | 1887 | 726.5 | 140.0 | -12.7 | 5.0 | -0.091 | 0.011 |  |  | -10.5 | 6.5 |
| E | Realized Ranking score, same children (companion row) | 1187 | 1887 | 756.4 | 159.8 | -20.6 | 5.7 | -0.129 | 0.000 |  |  | -18.1 | 7.3 |
| F | Highest cutoff percentile of the submitted list, on time, children who started (main) | 1031 | 1686 | 88.036 | 15.125 | 0.340 | 0.749 | 0.022 | 0.650 | 1.000 | 0.987 | 0.277 | 0.761 |
| F | Number of listed programs, on time, children who started | 1031 | 1686 | 7.686 | 5.262 | -0.153 | 0.259 | -0.029 | 0.555 |  | 0.987 | -0.140 | 0.259 |
| F | Mean cutoff percentile of the list, on time, children who started | 1031 | 1686 | 69.656 | 18.015 | 0.340 | 0.863 | 0.019 | 0.693 |  | 0.987 | 0.103 | 0.883 |
| F | Listed cutoffs missed, on time, children who started | 1031 | 1686 | 59.294 | 36.649 | 0.384 | 1.674 | 0.010 | 0.819 |  | 0.987 | -0.455 | 1.788 |
| F | Reached a listed cutoff, on time, children who started | 1031 | 1686 | 70.225 | 45.740 | -0.034 | 2.172 | -0.001 | 0.987 |  | 0.987 | 0.862 | 2.259 |

## 2. Application year 2018: selection into answering, bounds, and reweighting

The stage effect is the offer effect on answering the item, in the whole cohort (34,052 children). The trimming bounds (Lee 2009) weight children so that the weighted difference in means equals the regression on `OFFER` and chance-group effects (an offered child weighs one minus the offer share of the chance group, a non-offered child the offer share). The column before the bounds is that weighted difference. The interval is that of Imbens and Manski (2004), from 300 bootstrap draws of children. Worst-case bounds use the range of the outcome and the whole cohort. The reweighted effect weights answering children by the inverse of their estimated probability of answering among the registered children of the cohort (logit on the controls and on-time graduation, score, and application, by offer group). The last column is the largest share of the total weight held by one child.

| Family | Outcome | Stage effect | SE | Share trimmed | Weighted difference | Lower bound | Upper bound | 95% interval for the bounds | Worst-case bounds | Reweighted offer effect | SE | Largest weight share |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| A | Expected monthly income, planned first preference (pesos) | -0.0031 | 0.0021 | 0.131 | 49,859 | -105,945 | 283,596 | [-288,002, 496,880] |  | -33,092 | 90,861 | 0.022 |
| A | Expected annual payment, planned first preference (pesos) | 0.0014 | 0.0012 | 0.165 | -161,442 | -839,404 | 298,359 | [-1,671,292, 1,021,001] |  | -314,881 | 441,496 | 0.027 |
| A | Probability of graduating, planned first preference | -0.0028 | 0.0020 | 0.125 | 2.151 | -4.417 | 3.995 | [-9.955, 7.731] |  | 2.387 | 2.599 | 0.019 |
| A | Semesters to graduate, planned first preference | -0.0019 | 0.0020 | 0.085 | -0.369 | -1.038 | 0.386 | [-1.967, 1.254] |  | -0.303 | 0.412 | 0.043 |
| A | Position among 100 peers, planned first preference | -0.0069 | 0.0023 | 0.211 | -1.970 | -9.668 | 5.775 | [-13.816, 10.177] |  | 0.287 | 1.954 | 0.017 |
| A | Probability of staying, planned first preference | -0.0044 | 0.0023 | 0.147 | 2.776 | -4.801 | 5.047 | [-9.650, 8.284] |  | 2.474 | 1.904 | 0.021 |
| A | Probability of passing all first-year courses, planned first preference | -0.0072 | 0.0023 | 0.215 | -1.480 | -11.396 | 4.356 | [-15.998, 9.267] |  | -0.558 | 2.284 | 0.017 |
| A | Probability of employment, planned first preference | -0.0030 | 0.0021 | 0.127 | 0.787 | -5.543 | 4.647 | [-11.279, 10.244] |  | 0.579 | 2.512 | 0.028 |
| A | Expected monthly income, top true program (pesos) | -0.0031 | 0.0021 | 0.127 | 21,683 | -130,518 | 250,070 | [-314,146, 469,750] |  | -69,862 | 90,398 | 0.021 |
| A | Expected annual payment, top true program (pesos) | 0.0015 | 0.0012 | 0.170 | -277,952 | -912,530 | 163,030 | [-1,711,163, 826,360] |  | -425,078 | 404,318 | 0.026 |
| A | Probability of graduating, top true program | -0.0028 | 0.0020 | 0.126 | 1.115 | -5.402 | 2.851 | [-10.802, 6.672] |  | 2.014 | 2.618 | 0.020 |
| A | Semesters to graduate, top true program | -0.0017 | 0.0021 | 0.076 | -0.395 | -1.002 | 0.320 | [-1.924, 1.208] |  | -0.460 | 0.403 | 0.043 |
| A | Position among 100 peers, top true program | -0.0071 | 0.0023 | 0.215 | -1.493 | -9.693 | 6.556 | [-13.874, 11.092] |  | 0.985 | 2.012 | 0.017 |
| A | Probability of staying, top true program | -0.0044 | 0.0023 | 0.147 | 3.072 | -4.743 | 5.351 | [-9.492, 8.791] |  | 2.868 | 2.132 | 0.021 |
| A | Probability of passing all first-year courses, top true program | -0.0072 | 0.0023 | 0.214 | -1.305 | -11.031 | 4.378 | [-15.618, 8.980] |  | -0.629 | 2.195 | 0.017 |
| A | Probability of employment, top true program | -0.0030 | 0.0021 | 0.123 | 1.532 | -4.426 | 5.201 | [-9.990, 10.541] |  | 1.537 | 2.532 | 0.028 |
| B | Q61: probability of admission to any program of the application | -0.0064 | 0.0035 | 0.091 | -0.356 | -5.882 | 2.803 | [-10.029, 6.318] | [-92.943, 92.637] | 0.074 | 1.893 | 0.005 |
| B | Q60: probability of applying | -0.0063 | 0.0035 | 0.089 | -0.071 | -6.320 | 1.521 | [-10.962, 4.237] |  | 0.937 | 1.914 | 0.005 |
| B | Probability of graduating, planned first preference | -0.0028 | 0.0020 | 0.125 | 2.151 | -4.417 | 3.995 | [-9.955, 7.731] |  | 2.387 | 2.599 | 0.019 |
| C | Cutoff percentile of the top true program (2023 process) | -0.0063 | 0.0033 | 0.100 | 1.027 | -4.926 | 4.452 | [-9.516, 8.455] | [-93.705, 93.576] | 3.733 | 1.967 | 0.007 |
| C | Cutoff percentile of the planned first preference | -0.0049 | 0.0032 | 0.086 | 0.156 | -4.862 | 3.027 | [-9.485, 6.822] |  | 2.989 | 2.108 | 0.008 |
| C | Cutoff percentile of the planned last preference | -0.0034 | 0.0031 | 0.064 | -1.577 | -5.409 | 0.686 | [-9.850, 4.548] |  | 1.070 | 1.810 | 0.009 |
| D | Planned first preference differs from the top true program | -0.0048 | 0.0033 | 0.081 | 0.007 | -0.014 | 0.075 | [-0.057, 0.156] | [-0.936, 0.939] | 0.019 | 0.028 | 0.008 |
| E | Expected minus realized Mathematics M1 score | -0.0073 | 0.0039 | 0.084 | -0.2 | -25.1 | 23.5 | [-44.5, 40.4] |  | -4.6 | 6.9 | 0.038 |
| E | Expected minus realized Reading score | -0.0083 | 0.0039 | 0.093 | -0.9 | -28.4 | 27.0 | [-47.7, 45.6] |  | 3.9 | 8.5 | 0.005 |
| E | Expected minus realized NEM score | -0.0074 | 0.0038 | 0.085 | 6.8 | -24.4 | 26.1 | [-45.0, 40.9] |  | 12.6 | 9.0 | 0.003 |
| E | Expected minus realized Ranking score | -0.0074 | 0.0038 | 0.085 | 18.8 | -18.8 | 45.3 | [-45.6, 65.3] |  | 35.6 | 10.9 | 0.003 |
| E | Absolute difference, Mathematics M1 | -0.0073 | 0.0039 | 0.084 | 5.956 | -3.339 | 25.191 | [-12.290, 39.798] |  | 3.677 | 4.524 | 0.038 |
| E | Absolute difference, Reading | -0.0083 | 0.0039 | 0.093 | 4.084 | -6.772 | 26.219 | [-16.688, 40.422] |  | 5.506 | 5.175 | 0.005 |
| E | Absolute difference, NEM | -0.0074 | 0.0038 | 0.085 | -5.7 | -15.6 | 23.1 | [-27.4, 42.1] |  | -8.6 | 7.4 | 0.003 |
| E | Absolute difference, Ranking | -0.0074 | 0.0038 | 0.085 | -16.3 | -31.3 | 18.6 | [-47.2, 43.5] |  | -27.4 | 9.2 | 0.003 |
| E | Expected Mathematics M1 score | -0.0071 | 0.0039 | 0.081 | 4.3 | -23.9 | 32.6 | [-45.8, 53.6] |  | 19.3 | 12.3 | 0.023 |
| E | Expected Reading score | -0.0082 | 0.0039 | 0.091 | 6.3 | -23.4 | 33.1 | [-43.8, 51.9] |  | 5.2 | 8.8 | 0.005 |
| E | Expected NEM score | -0.0073 | 0.0038 | 0.084 | -6.7 | -43.1 | 20.7 | [-70.0, 44.4] |  | -5.2 | 9.6 | 0.003 |
| E | Expected Ranking score | -0.0073 | 0.0038 | 0.084 | -2.4 | -41.6 | 29.9 | [-72.6, 57.5] |  | 9.8 | 10.8 | 0.003 |
| E | Q63: probability of admission if listed first, planned first preference | -0.0062 | 0.0031 | 0.112 | -1.613 | -7.870 | 2.431 | [-12.139, 6.362] |  | -1.095 | 1.973 | 0.010 |
| E | Q64: cutoff belief, planned first preference | -0.0062 | 0.0031 | 0.113 | -10.3 | -44.4 | 26.5 | [-68.5, 52.8] |  | -24.6 | 13.6 | 0.010 |
| E | Q65: probability own score above the cutoff, planned first preference | -0.0071 | 0.0030 | 0.133 | -3.016 | -9.665 | 3.032 | [-13.854, 7.512] |  | -3.277 | 1.745 | 0.010 |
| E | Q63: probability of admission if listed first, top true program | -0.0062 | 0.0031 | 0.111 | -0.259 | -6.528 | 3.776 | [-10.851, 7.747] |  | 1.586 | 2.023 | 0.010 |
| E | Cutoff belief minus realized cutoff, planned first preference | -0.0062 | 0.0030 | 0.118 | -13.4 | -50.5 | 26.6 | [-75.0, 50.9] |  | -32.3 | 15.3 | 0.010 |
| E | Absolute difference, cutoff of the planned first preference | -0.0062 | 0.0030 | 0.118 | -5.6 | -22.2 | 28.3 | [-38.5, 46.7] |  | -18.8 | 10.6 | 0.010 |
| E | Realized Mathematics M1 score, same children (companion row) | -0.0073 | 0.0039 | 0.084 | 4.625 | -7.711 | 26.616 | [-18.328, 40.871] |  | 8.474 | 4.218 | 0.038 |
| E | Realized Reading score, same children (companion row) | -0.0083 | 0.0039 | 0.093 | 7.6 | -11.8 | 30.5 | [-27.0, 46.6] |  | 5.9 | 6.7 | 0.005 |
| E | Realized NEM score, same children (companion row) | -0.0074 | 0.0038 | 0.085 | -12.9 | -37.7 | 7.6 | [-57.4, 25.3] |  | -15.9 | 6.4 | 0.003 |
| E | Realized Ranking score, same children (companion row) | -0.0074 | 0.0038 | 0.085 | -20.7 | -48.2 | 1.8 | [-70.6, 22.3] |  | -23.9 | 7.1 | 0.003 |
| F | Highest cutoff percentile of the submitted list, on time, children who started | -0.0079 | 0.0036 | 0.102 | 0.438 | -3.719 | 1.790 | [-6.133, 3.446] |  | 0.400 | 0.772 | 0.001 |
| F | Number of listed programs, on time, children who started | -0.0079 | 0.0036 | 0.102 | -0.074 | -0.766 | 1.255 | [-1.437, 2.144] |  | -0.089 | 0.263 | 0.001 |
| F | Mean cutoff percentile of the list, on time, children who started | -0.0079 | 0.0036 | 0.102 | 0.331 | -3.700 | 3.181 | [-6.485, 5.404] |  | 0.295 | 0.881 | 0.001 |
| F | Listed cutoffs missed, on time, children who started | -0.0079 | 0.0036 | 0.102 | 0.250 | -6.565 | 4.822 | [-12.497, 9.394] |  | 0.563 | 1.685 | 0.001 |
| F | Reached a listed cutoff, on time, children who started | -0.0079 | 0.0036 | 0.102 | 0.588 | -7.387 | 4.000 | [-14.867, 8.826] |  | 0.516 | 2.164 | 0.001 |

## 3. Application year 2018: attendance effects (IV)

An attendance effect is shown only when the 95 percent interval of the stage effect includes zero and both trimming bounds have the same sign (specification log, Section 6). It describes compliers who answer.

| Family | Outcome | First stage among answering children | Attendance effect | SE | Shown |
|---|---|---|---|---|---|
| A | Expected monthly income, planned first preference (pesos) | 0.572 | | | no |
| A | Expected annual payment, planned first preference (pesos) | 0.505 | | | no |
| A | Probability of graduating, planned first preference | 0.547 | | | no |
| A | Semesters to graduate, planned first preference | 0.523 | | | no |
| A | Position among 100 peers, planned first preference | 0.557 | | | no |
| A | Probability of staying, planned first preference | 0.580 | | | no |
| A | Probability of passing all first-year courses, planned first preference | 0.558 | | | no |
| A | Probability of employment, planned first preference | 0.521 | | | no |
| A | Expected monthly income, top true program (pesos) | 0.574 | | | no |
| A | Expected annual payment, top true program (pesos) | 0.523 | | | no |
| A | Probability of graduating, top true program | 0.550 | | | no |
| A | Semesters to graduate, top true program | 0.524 | | | no |
| A | Position among 100 peers, top true program | 0.554 | | | no |
| A | Probability of staying, top true program | 0.580 | | | no |
| A | Probability of passing all first-year courses, top true program | 0.558 | | | no |
| A | Probability of employment, top true program | 0.521 | | | no |
| B | Q61: probability of admission to any program of the application | 0.562 | | | no |
| B | Q60: probability of applying | 0.566 | | | no |
| B | Probability of graduating, planned first preference | 0.547 | | | no |
| C | Cutoff percentile of the top true program (2023 process) | 0.544 | | | no |
| C | Cutoff percentile of the planned first preference | 0.541 | | | no |
| C | Cutoff percentile of the planned last preference | 0.548 | | | no |
| D | Planned first preference differs from the top true program | 0.542 | | | no |
| E | Expected minus realized Mathematics M1 score | 0.572 | | | no |
| E | Expected minus realized Reading score | 0.570 | | | no |
| E | Expected minus realized NEM score | 0.570 | | | no |
| E | Expected minus realized Ranking score | 0.570 | | | no |
| E | Absolute difference, Mathematics M1 | 0.572 | | | no |
| E | Absolute difference, Reading | 0.570 | | | no |
| E | Absolute difference, NEM | 0.570 | | | no |
| E | Absolute difference, Ranking | 0.570 | | | no |
| E | Expected Mathematics M1 score | 0.572 | | | no |
| E | Expected Reading score | 0.570 | | | no |
| E | Expected NEM score | 0.570 | | | no |
| E | Expected Ranking score | 0.570 | | | no |
| E | Q63: probability of admission if listed first, planned first preference | 0.545 | | | no |
| E | Q64: cutoff belief, planned first preference | 0.546 | | | no |
| E | Q65: probability own score above the cutoff, planned first preference | 0.555 | | | no |
| E | Q63: probability of admission if listed first, top true program | 0.547 | | | no |
| E | Cutoff belief minus realized cutoff, planned first preference | 0.546 | | | no |
| E | Absolute difference, cutoff of the planned first preference | 0.546 | | | no |
| E | Realized Mathematics M1 score, same children (companion row) | 0.572 | | | no |
| E | Realized Reading score, same children (companion row) | 0.570 | | | no |
| E | Realized NEM score, same children (companion row) | 0.570 | | | no |
| E | Realized Ranking score, same children (companion row) | 0.570 | | | no |
| F | Highest cutoff percentile of the submitted list, on time, children who started | 0.556 | | | no |
| F | Number of listed programs, on time, children who started | 0.556 | | | no |
| F | Mean cutoff percentile of the list, on time, children who started | 0.556 | | | no |
| F | Listed cutoffs missed, on time, children who started | 0.556 | | | no |
| F | Reached a listed cutoff, on time, children who started | 0.556 | | | no |

## 4. Application year 2017 in the 2023 process: offer effects among children who answered

These children reach the 2023 process one year after their scheduled process. Reported separately, without bounds.

| Family | Outcome | With offer | Without offer | Mean without offer | SD without offer | Offer effect | SE | Effect in SD | p | Holm p (main outcomes) | q within family | Offer effect, no controls | SE |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| A | Expected monthly income, planned first preference (pesos) (main) | 35 | 41 | not estimated | | | | | | | | | |
| A | Expected annual payment, planned first preference (pesos) | 12 | 15 | not estimated | | | | | | | | | |
| A | Probability of graduating, planned first preference | 30 | 44 | not estimated | | | | | | | | | |
| A | Semesters to graduate, planned first preference | 35 | 40 | not estimated | | | | | | | | | |
| A | Position among 100 peers, planned first preference | 38 | 51 | not estimated | | | | | | | | | |
| A | Probability of staying, planned first preference | 42 | 60 | not estimated | | | | | | | | | |
| A | Probability of passing all first-year courses, planned first preference | 42 | 50 | not estimated | | | | | | | | | |
| A | Probability of employment, planned first preference | 34 | 47 | not estimated | | | | | | | | | |
| A | Expected monthly income, top true program (pesos) | 35 | 41 | not estimated | | | | | | | | | |
| A | Expected annual payment, top true program (pesos) | 12 | 15 | not estimated | | | | | | | | | |
| A | Probability of graduating, top true program | 30 | 44 | not estimated | | | | | | | | | |
| A | Semesters to graduate, top true program | 35 | 40 | not estimated | | | | | | | | | |
| A | Position among 100 peers, top true program | 38 | 51 | not estimated | | | | | | | | | |
| A | Probability of staying, top true program | 42 | 60 | not estimated | | | | | | | | | |
| A | Probability of passing all first-year courses, top true program | 42 | 50 | not estimated | | | | | | | | | |
| A | Probability of employment, top true program | 34 | 47 | not estimated | | | | | | | | | |
| B | Q61: probability of admission to any program of the application (main) | 100 | 112 | 68.929 | 28.655 | 8.089 | 6.307 | 0.282 | 0.202 | 0.808 | 0.404 | 8.523 | 6.162 |
| B | Q60: probability of applying | 101 | 115 | 87.304 | 25.674 | 3.471 | 6.115 | 0.135 | 0.571 |  | 0.571 | 2.630 | 5.949 |
| B | Probability of graduating, planned first preference | 30 | 44 | not estimated | | | | | | | | | |
| C | Cutoff percentile of the top true program (2023 process) (main) | 85 | 99 | 71.810 | 24.006 | -4.721 | 5.197 | -0.197 | 0.366 | 1.000 | 0.703 | -4.807 | 5.895 |
| C | Cutoff percentile of the planned first preference | 81 | 97 | 69.325 | 25.679 | 2.280 | 5.970 | 0.089 | 0.703 |  | 0.703 | 1.945 | 6.381 |
| C | Cutoff percentile of the planned last preference | 84 | 90 | 60.278 | 26.153 | 4.121 | 6.033 | 0.158 | 0.496 |  | 0.703 | 3.972 | 6.266 |
| D | Planned first preference differs from the top true program (main) | 90 | 104 | 0.279 | 0.451 | -0.005 | 0.095 | -0.010 | 0.962 | 1.000 | 0.962 | -0.024 | 0.096 |
| E | Expected minus realized Mathematics M1 score (main) | 124 | 143 | -11.4 | 128.4 | 16.3 | 28.3 | 0.127 | 0.567 | 1.000 | 0.729 | 18.1 | 29.1 |
| E | Expected minus realized Reading score | 123 | 141 | -3.9 | 130.0 | 72.0 | 26.4 | 0.554 | 0.007 |  | 0.119 | 69.3 | 27.7 |
| E | Expected minus realized NEM score | 130 | 153 | -45.5 | 109.5 | 23.4 | 23.4 | 0.214 | 0.318 |  | 0.440 | 23.2 | 23.2 |
| E | Expected minus realized Ranking score | 130 | 153 | -84.3 | 156.1 | 51.5 | 29.1 | 0.330 | 0.078 |  | 0.224 | 49.2 | 29.4 |
| E | Absolute difference, Mathematics M1 | 124 | 143 | 95.070 | 86.717 | 22.479 | 18.689 | 0.259 | 0.231 |  | 0.346 | 22.411 | 19.677 |
| E | Absolute difference, Reading | 123 | 141 | 97.752 | 85.344 | -7.219 | 19.137 | -0.085 | 0.706 |  | 0.795 | -3.384 | 19.527 |
| E | Absolute difference, NEM | 130 | 153 | 74.092 | 92.509 | 1.459 | 19.765 | 0.016 | 0.941 |  | 0.941 | 3.724 | 19.111 |
| E | Absolute difference, Ranking | 130 | 153 | 118.5 | 131.9 | -41.6 | 23.9 | -0.315 | 0.084 |  | 0.224 | -38.4 | 23.4 |
| E | Expected Mathematics M1 score | 125 | 148 | 509.2 | 151.2 | 16.2 | 33.0 | 0.107 | 0.624 |  | 0.749 | 16.4 | 32.6 |
| E | Expected Reading score | 125 | 146 | 607.3 | 152.4 | 74.5 | 29.8 | 0.489 | 0.013 |  | 0.119 | 69.1 | 29.2 |
| E | Expected NEM score | 130 | 153 | 609.9 | 159.3 | 51.9 | 28.6 | 0.326 | 0.071 |  | 0.224 | 44.5 | 30.1 |
| E | Expected Ranking score | 130 | 153 | 594.6 | 191.1 | 79.2 | 35.1 | 0.414 | 0.025 |  | 0.150 | 69.0 | 36.9 |
| E | Q63: probability of admission if listed first, planned first preference | 82 | 98 | 66.969 | 24.665 | 8.470 | 6.489 | 0.343 | 0.195 |  | 0.319 | 8.754 | 6.582 |
| E | Q64: cutoff belief, planned first preference | 80 | 96 | 611.5 | 146.3 | 56.7 | 41.7 | 0.388 | 0.176 |  | 0.319 | 63.2 | 42.6 |
| E | Q65: probability own score above the cutoff, planned first preference | 79 | 93 | 58.624 | 23.773 | 10.303 | 6.165 | 0.433 | 0.098 |  | 0.224 | 10.420 | 5.918 |
| E | Q63: probability of admission if listed first, top true program | 82 | 98 | 65.296 | 26.014 | 10.623 | 6.395 | 0.408 | 0.100 |  | 0.224 | 9.761 | 6.362 |
| E | Cutoff belief minus realized cutoff, planned first preference | 71 | 90 | -75.7 | 136.8 | 50.2 | 37.6 | 0.367 | 0.185 |  | 0.319 | 52.5 | 36.4 |
| E | Absolute difference, cutoff of the planned first preference | 71 | 90 | 122.949 | 96.093 | -5.797 | 28.928 | -0.060 | 0.842 |  | 0.891 | -0.442 | 28.141 |
| E | Realized Mathematics M1 score, same children (companion row) | 124 | 143 | 523.629 | 88.771 | -2.492 | 16.560 | -0.028 | 0.881 |  |  | -2.386 | 17.730 |
| E | Realized Reading score, same children (companion row) | 123 | 141 | 612.6 | 102.5 | 2.7 | 18.3 | 0.026 | 0.882 |  |  | 1.4 | 20.4 |
| E | Realized NEM score, same children (companion row) | 130 | 153 | 655.4 | 126.0 | 28.5 | 17.8 | 0.226 | 0.110 |  |  | 21.3 | 22.4 |
| E | Realized Ranking score, same children (companion row) | 130 | 153 | 678.9 | 145.5 | 27.7 | 20.6 | 0.190 | 0.181 |  |  | 19.8 | 25.2 |
| F | Highest cutoff percentile of the submitted list, on time, children who started (main) | 38 | 50 | not estimated | | | | | | | | | |
| F | Number of listed programs, on time, children who started | 38 | 50 | not estimated | | | | | | | | | |
| F | Mean cutoff percentile of the list, on time, children who started | 38 | 50 | not estimated | | | | | | | | | |
| F | Listed cutoffs missed, on time, children who started | 38 | 50 | not estimated | | | | | | | | | |
| F | Reached a listed cutoff, on time, children who started | 38 | 50 | not estimated | | | | | | | | | |

## 5. Application year 2018, whole cohort: application choices on time (no survey)

| Outcome | With offer | Without offer | Mean without offer | Offer effect | SE |
|---|---|---|---|---|---|
| LIST_MAX_CUTOFF_OT | 5281 | 8275 | 87.395 | 0.493 | 0.315 |
| LIST_PROGRAMS_OT | 5281 | 8275 | 7.288 | 0.057 | 0.108 |
| LIST_MEAN_CUTOFF_OT | 5281 | 8275 | 69.005 | 0.474 | 0.369 |
| LIST_MISSED_OT | 5281 | 8275 | 59.307 | 2.483 | 0.716 |
| LIST_REACHED_OT | 5281 | 8275 | 70.248 | -1.835 | 0.940 |
