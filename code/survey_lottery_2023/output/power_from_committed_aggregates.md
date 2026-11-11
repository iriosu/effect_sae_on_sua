# Expected overlap and minimum detectable effects from committed aggregates

Written by `code/survey_lottery_2023/00_power_from_committed_aggregates.R`. No student-level file was read.
Lottery counts come from the October vintage (176,321 children). The current vintage has 186,440.

## Inputs

| Quantity | Value | Source |
|---|---|---|
| Lottery sample, application year 2018 | 31,535 | `f02_lottery_support_audit.csv`, entry year 2019 |
| Lottery sample, application year 2017 | 9,833 | `f02_lottery_support_audit.csv`, entry year 2018 |
| Lottery sample, application year 2016 | 260 | `f02_lottery_support_audit.csv`, entry year 2017 |
| SE of an offer effect in SD units, times sqrt(n) | LM_Z_MAX 1.930; NEM_Z_LATEST 2.038; RANK_Z_LATEST 2.071; mean 2.013 | `offer_and_attendance_effects.csv` |
| The same factor for an outcome that the controls do not predict | at least 2.488 | `offer_and_attendance_effects.csv`, binary outcomes GRAD_OT 2.488; APPLIED_OT 2.382 |
| First stage, pooled | 0.6257 | `offer_and_attendance_effects.csv` (the current paper reports 0.6104) |
| Applied on time, without offer, pooled | 0.3965 | `offer_and_attendance_effects.csv` |
| Share with a test score ever observed, pooled | 0.6691 | `offer_and_attendance_effects.csv` |
| Registered for the tests of the 2023 process | 296,812 | Data rows of the public registration file |
| 2023 baseline: started, completed | 39,051, 15,726 | Mistakes README |
| 2023 endline: started, completed | 19,147, 7,926 | Mistakes README |
| 2022 survey: applicants, started, completed | 148,819, 31,791, 15,057 | Mistakes README |
| Share of the 2018 application year registered for the 2023 tests | 0.55 and 0.70 | Assumed |

## Expected children and minimum detectable effects

Expected children = cohort x share reaching the survey population x survey response rate of that population.
The response rate is the rate of all invited students. Lottery children may respond at another rate.
Minimum detectable effect = 2.80 x 2.013 / sqrt(n), at 80 percent power and a 5 percent two-sided test.
The second effect column uses the factor 2.488, for an outcome that the paper's controls do not predict.
The attendance column divides the first effect column by the pooled first stage. The last column is for a binary outcome with mean 0.5 and uses the second factor.
The endline rows divide by the 132,893 applicants of the first half of the window, fewer than all applicants.

| Sample | Expected children | Offer effect (SD) | Offer effect (SD), controls do not predict the outcome | Attendance effect (SD) | Offer effect, binary outcome (pp) |
|---|---|---|---|---|---|
| 2023 baseline, started, 55% registered | 2,282 | 0.118 | 0.146 | 0.189 | 7.3 |
| 2023 baseline, started, 70% registered | 2,904 | 0.105 | 0.129 | 0.167 | 6.5 |
| 2023 baseline, completed, 55% registered | 919 | 0.186 | 0.230 | 0.297 | 11.5 |
| 2023 baseline, completed, 70% registered | 1,170 | 0.165 | 0.204 | 0.263 | 10.2 |
| 2023 baseline, completed, item in 2 of 4 groups, 55% registered | 459 | 0.263 | 0.325 | 0.420 | 16.3 |
| 2023 baseline, completed, item in 2 of 4 groups, 70% registered | 585 | 0.233 | 0.288 | 0.372 | 14.4 |
| 2023 endline, started (upper bound) | 1,802 | 0.133 | 0.164 | 0.212 | 8.2 |
| 2023 endline, completed (upper bound) | 746 | 0.206 | 0.255 | 0.330 | 12.8 |
| 2022 survey, started | 833 | 0.195 | 0.241 | 0.312 | 12.1 |
| 2022 survey, completed | 394 | 0.284 | 0.351 | 0.453 | 17.5 |
