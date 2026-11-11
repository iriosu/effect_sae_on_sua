# Lottery sample by application year: aggregates

Written by `code/survey_lottery_2023/01_lottery_cohort_aggregates.R`. Source: `mechanisms_panel.rds`, MD5 `8d1b6996f18f2d678b543c4428567709`. Children with every control: 185,970 of 186,440.
No survey file was read. Counts below 11 are suppressed.

## 1. Counts

| Application year | Scheduled college process | Children | With offer | Without offer | Chance groups | Chance groups with both |
|---|---|---|---|---|---|---|
| 2016 | 2021 | 343 | 72 | 271 | 39 | 16 |
| 2017 | 2022 | 10,995 | 4,827 | 6,168 | 101 | 95 |
| 2018 | 2023 | 34,052 | 13,828 | 20,224 | 101 | 99 |
| 2019 | 2024 | 50,111 | 19,066 | 31,045 | 101 | 101 |
| 2020 | 2025 | 43,891 | 17,736 | 26,155 | 101 | 101 |
| 2021 | 2026 | 46,578 | 17,762 | 28,816 | 101 | 101 |

## 2. First stage and offer effects on the stages of observation, by application year

Each row is one regression on the children of one application year: outcome on `OFFER`, the paper's controls, and chance-group effects, with robust standard errors. Units are shares (0 to 1).

| Application year | Outcome | Mean without offer | Offer effect | SE | Children | Residual SD of offer |
|---|---|---|---|---|---|---|
| 2016 | First stage (attendance at an over-demanded school) | 0.1513 | 0.6406 | 0.0635 | 343 | 0.3312 |
| 2016 | Graduated on time | 0.8303 | -0.0660 | 0.0672 | 343 | 0.3312 |
| 2016 | Has a test score on time | 0.5683 | -0.0631 | 0.0666 | 343 | 0.3312 |
| 2016 | Applied on time (a list on file) | 0.2804 | -0.0073 | 0.0611 | 343 | 0.3312 |
| 2017 | First stage (attendance at an over-demanded school) | 0.2027 | 0.5604 | 0.0098 | 10,995 | 0.4034 |
| 2017 | Graduated on time | 0.8043 | -0.0524 | 0.0092 | 10,995 | 0.4034 |
| 2017 | Has a test score on time | 0.5065 | -0.0173 | 0.0106 | 10,995 | 0.4034 |
| 2017 | Applied on time (a list on file) | 0.2532 | -0.0064 | 0.0092 | 10,995 | 0.4034 |
| 2018 | First stage (attendance at an over-demanded school) | 0.1840 | 0.5656 | 0.0056 | 34,052 | 0.3986 |
| 2018 | Graduated on time | 0.8486 | -0.0301 | 0.0048 | 34,052 | 0.3986 |
| 2018 | Has a test score on time | 0.6061 | -0.0153 | 0.0061 | 34,052 | 0.3986 |
| 2018 | Applied on time (a list on file) | 0.4092 | -0.0140 | 0.0061 | 34,052 | 0.3986 |
| 2019 | First stage (attendance at an over-demanded school) | 0.1576 | 0.6048 | 0.0046 | 50,111 | 0.3899 |
| 2019 | Graduated on time | 0.8596 | -0.0149 | 0.0039 | 50,111 | 0.3899 |
| 2019 | Has a test score on time | 0.6283 | -0.0085 | 0.0051 | 50,111 | 0.3899 |
| 2019 | Applied on time (a list on file) | 0.3813 | -0.0083 | 0.0051 | 50,111 | 0.3899 |
| 2020 | First stage (attendance at an over-demanded school) | 0.1462 | 0.6488 | 0.0047 | 43,891 | 0.3907 |
| 2020 | Graduated on time | 0.8594 | -0.0125 | 0.0042 | 43,891 | 0.3907 |
| 2020 | Has a test score on time | 0.6327 | -0.0094 | 0.0055 | 43,891 | 0.3907 |
| 2020 | Applied on time (a list on file) | 0.3965 | -0.0085 | 0.0056 | 43,891 | 0.3907 |
| 2021 | First stage (attendance at an over-demanded school) | 0.1496 | 0.6271 | 0.0047 | 46,578 | 0.3930 |
| 2021 | Graduated on time | 0.8610 | -0.0124 | 0.0040 | 46,578 | 0.3930 |
| 2021 | Has a test score on time | 0.6199 | -0.0004 | 0.0053 | 46,578 | 0.3930 |
| 2021 | Applied on time (a list on file) | 0.3840 | -0.0086 | 0.0054 | 46,578 | 0.3930 |

## 3. Minimum detectable effects by number of responding children (application year 2018)

The standard error is 1 / (sqrt(n) x residual SD of offer), for an outcome with unit standard deviation. The residual SD of offer is that of the 2018 cohort (0.3986). The minimum detectable effect is 2.80 standard errors. The attendance column divides by the 2018 first stage (0.5656). Both columns assume that respondents resemble the cohort in offer variation and first stage. Neither assumption has been tested.

| Responding children | SE (SD units) | Minimum detectable offer effect (SD) | Minimum detectable attendance effect (SD) |
|---|---|---|---|
| 250 | 0.159 | 0.444 | 0.785 |
| 500 | 0.112 | 0.314 | 0.555 |
| 750 | 0.092 | 0.256 | 0.453 |
| 1,000 | 0.079 | 0.222 | 0.393 |
| 1,500 | 0.065 | 0.181 | 0.321 |
| 2,000 | 0.056 | 0.157 | 0.278 |
| 3,000 | 0.046 | 0.128 | 0.227 |
| 4,000 | 0.040 | 0.111 | 0.196 |
