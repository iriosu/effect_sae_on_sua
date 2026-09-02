# Piece 1 - v2, Version A: three weightings side by side

## What Version A estimates

Chile's centralized school admission system (SAE, Sistema de Admision Escolar) reached the regions in waves: one region in 2016, four in 2017, ten in 2018, and the Metropolitan Region in 2019. Version A compares the entering classes of always-over-demanded public schools in regions already under SAE with the entering classes of always-over-demanded public schools in regions not yet under SAE, year by year. A school-grade cell is always over-demanded when, in every year observed, genuine applicants ranking it at least as high as their final placement outnumber its seats (the Piece 1 definition). Private schools are not in Version A.

The unit is the entering class of a school-grade cell in a year: the students enrolled at that school-grade who were not at that school the year before. The causal statement is about the class the lottery formed versus the class the school would have formed itself.

Two clocks. The composition outcomes (entrant prior GPA, share prioritario) sit on the entry-year clock, 2012 to 2023. The college outcomes sit on the college-process clock: an entering class at grade g in year t is followed to its on-time college admission process, t + 13 - g, so every comparison within a process year shares one admission-test regime; processes 2018 to 2026. Graduated on time means promoted out of 12th grade in the year before that process. Applied, assigned a seat, and enrolled are read from the centralized college admission records of that process; a student with no record counts as zero. Dropping out, never registering, and never applying all count as zeros: the denominator is the entering class.

Estimator: Callaway and Sant'Anna (2021) staggered difference-in-differences, not-yet-treated controls, universal base period, no covariates, standard errors from a region-clustered multiplier bootstrap (16 regions, 10,000 draws). The headline is the simple average of the group-time effects over post-treatment cells.

## The three weightings

- **Unweighted.** Every class counts equally. The estimate answers for the average class.
- **Own-year class size.** Each class-year is weighted by its number of entrants in that year. The estimate answers for the average entering student; the weights move with the class size from year to year.
- **Fixed mean class size.** Each cell is weighted by its average number of entrants over the window, the same weight in every year. The estimate answers for the average entering student with weights that do not move when class sizes change.

All three are shown because they answer different questions. When an effect varies across schools, a weighted and an unweighted estimator recover different averages of it, so the choice of weight is a choice of which population the number describes, and a gap between the columns is itself information about how the effect varies with class size (Solon, Haider and Wooldridge 2015). The column shown is never chosen by where its stars land.

## How to read the tables

**Where the stars come from.** Significance on this page comes from randomization inference, and the idea is easiest to see as a game of alternative histories.

SAE arrived region by region on a published schedule: Magallanes in 2016, four regions in 2017, ten regions in 2018, and the Metropolitan Region in 2019. That schedule is the only thing separating a treated class from a control class in this design. So the test asks a direct question: if the reform had reached the regions in a different order, how large a number would this comparison have produced?

To answer it we invent 9,999 alternative schedules. Each one reshuffles which of the sixteen regions received the reform in which year, holding the group sizes at one, four, ten and one, so every invented schedule is a schedule the country could plausibly have followed. There are 240,240 of them in total and we draw 9,999. The whole estimate is recomputed from scratch under each one. A result earns stars when almost none of the invented schedules produces a number as large as the real one.

**Why each schedule is divided by its own steadiness.** One feature of the country shapes the scoring. The Metropolitan Region holds 37 of every 100 school-grade cells in this sample, and the next largest region holds 12. An invented schedule that hands the Metropolitan Region an early year makes the whole computation rest on that one region’s year-to-year luck, and one region’s luck produces large numbers easily. Those schedules would fill the comparison with large numbers and bury a real effect.

Every schedule therefore has to vouch for its own steadiness, the real one included. Drop one region from the data, recompute the estimate, put the region back, and repeat for all sixteen. The spread across those sixteen answers measures how much the estimate leans on any single region. Each schedule’s number is divided by its own spread before any comparison is made. A schedule resting on one region collapses under this rule, because deleting that region guts its number. This is the studentized randomization statistic used throughout Young (2019) and recommended by MacKinnon and Webb (2020) for this exact situation, where the units being reshuffled differ greatly in size.

**Reading the p-value.** The p-value is the share of invented schedules whose number, measured this way, is at least as large as the real one. Size is compared in absolute value, so an effect in either direction counts. The real schedule is counted alongside the invented ones, which is the plus one in (1 + matches) divided by (1 + 9,999). Stars: three for p below 0.01, two for p below 0.05, one for p below 0.10.

**How the test is computed.** Each of the 9,999 schedules needs seventeen recomputations, the full estimate plus the sixteen region deletions. Running the estimation package itself that many times costs about sixty hours per table. The test uses a reimplementation of the same arithmetic instead, which runs in minutes. Before any invented schedule is scored, that reimplementation has to reproduce the package’s own answer on the real data to machine precision, or the run halts. Every column on this page passed that check.

**The standard errors in parentheses.** These come from a separate calculation, a bootstrap that resamples the sixteen regions ten thousand times. They describe how precisely the estimate is measured. They play no part in the stars. Clustering is at the region because that is the level at which the reform was assigned (Abadie, Athey, Imbens and Wooldridge 2023).

**Bold in the event-study tables.** A confidence interval is normally built for one row at a time. Reading a column of a dozen rows, one or two will fall outside their own interval through chance alone. The bands used here are widened so that the entire path stays inside them 95 percent of the time. Bold marks an estimate lying outside that widened band.

**The joint pre-trend test.** The rows above the reference row cover the years before the reform reached the region, where a design that works shows nothing. Judging those rows one at a time runs into the problem just described: check seven rows and one will look unusual by chance. The joint test takes the single largest pre-reform row, measured in the studentized way described above, and asks how often an invented schedule produces a largest pre-reform row that big. One number then covers the whole pre-period. A small p-value says the pre-reform years do not look flat. Taking the largest member of a family this way is the maximum-statistic construction of Romano and Wolf (2005).

## Table 1. Headline effects

| Outcome | Unweighted | Own-year class size | Fixed mean class size | Cell-years | Cells | Schools |
|---|---|---|---|---|---|---|
| Entrant prior GPA (z-score) | -0.1503*** | -0.1656*** | -0.1735*** | 76,702 | 7,158 | 1,386 |
| | (0.0314) | (0.0323) | (0.0234) | | | |
| Share prioritario | +0.0346*** | +0.0213*** | +0.0239*** | 97,381 | 8,958 | 1,513 |
| | (0.0091) | (0.0097) | (0.0090) | | | |
| Graduated on time | -0.0214*** | -0.0423*** | -0.0425*** | 51,679 | 8,707 | 1,494 |
| | (0.0082) | (0.0080) | (0.0078) | | | |
| Applied | -0.0202*** | -0.0429*** | -0.0354*** | 51,679 | 8,707 | 1,494 |
| | (0.0155) | (0.0149) | (0.0126) | | | |
| Assigned a seat | -0.0310** | -0.0442*** | -0.0386*** | 51,679 | 8,707 | 1,494 |
| | (0.0118) | (0.0172) | (0.0147) | | | |
| Enrolled | -0.0216*** | -0.0341*** | -0.0286*** | 51,679 | 8,707 | 1,494 |
| | (0.0085) | (0.0122) | (0.0117) | | | |

Composition outcomes: entry years 2012 to 2023. College outcomes: processes 2018 to 2026. Cell-years, cells, and schools are the same across the three weightings.

## Table 2. College outcomes by admission-test era

Each era cell is the fixed-weight average of the calendar-year effects in that era, with the weights the estimator itself puts on those years. Old exam: processes 2020 to 2022. PAES (Prueba de Acceso a la Educacion Superior): processes 2023 to 2026. Standard errors from the region-clustered multiplier bootstrap of the combined influence function; stars from the randomization test on the era average.

| Era | Outcome | Unweighted | Own-year class size | Fixed mean class size |
|---|---|---|---|---|
| Old exam, 2020-2022 | Graduated on time | +0.0037 | -0.0363 | -0.0373 |
| | | (0.0206) | (0.0208) | (0.0238) |
| Old exam, 2020-2022 | Applied | -0.0117 | -0.0467*** | -0.0354** |
| | | (0.0346) | (0.0184) | (0.0168) |
| Old exam, 2020-2022 | Assigned a seat | -0.0197 | -0.0461*** | -0.0332** |
| | | (0.0330) | (0.0090) | (0.0087) |
| Old exam, 2020-2022 | Enrolled | -0.0298 | -0.0335*** | -0.0245** |
| | | (0.0267) | (0.0092) | (0.0063) |
| PAES, 2023-2026 | Graduated on time | -0.0232*** | -0.0427*** | -0.0428*** |
| | | (0.0090) | (0.0085) | (0.0082) |
| PAES, 2023-2026 | Applied | -0.0208*** | -0.0427*** | -0.0354*** |
| | | (0.0150) | (0.0157) | (0.0132) |
| PAES, 2023-2026 | Assigned a seat | -0.0318** | -0.0441*** | -0.0389*** |
| | | (0.0107) | (0.0180) | (0.0154) |
| PAES, 2023-2026 | Enrolled | -0.0211*** | -0.0342*** | -0.0288*** |
| | | (0.0083) | (0.0129) | (0.0122) |

## Table 3. Joint pre-trend tests

Exact randomization p of the largest studentized lead across all identified pre-treatment event times (the reference period, event time -1, excluded). Number of leads tested in brackets.

| Outcome | Unweighted | Own-year class size | Fixed mean class size |
|---|---|---|---|
| Entrant prior GPA (z-score) | 0.3749 [7] | 0.4878 [7] | 0.8876 [7] |
| Share prioritario | 0.4984 [7] | 0.0920 [7] | 0.1100 [7] |
| Graduated on time | 0.1946 [6] | 0.0122 [6] | 0.0129 [6] |
| Applied | 0.2745 [6] | 0.0045 [6] | 0.0040 [6] |
| Assigned a seat | 0.3235 [6] | 0.0043 [6] | 0.0041 [6] |
| Enrolled | 0.2115 [6] | 0.0002 [6] | 0.0831 [6] |

## Event studies

Dynamic effects by event time, each row comparing treated cells with not-yet-treated cells at that event time against the reference period (event time -1, zero by construction). For the composition outcomes, event time counts years from the year the region's grade entered SAE. For the college outcomes, event time counts college processes from the first process in which the cell's entering class was SAE-assigned. **Bold**: outside the 95% simultaneous band.

### Entrant prior GPA (z-score)

| Event time | Unweighted | Own-year class size | Fixed mean class size |
|---|---|---|---|
| -8 | +0.0166 (0.0377) | +0.0617 (0.0460) | +0.0121 (0.0231) |
| -7 | +0.0072 (0.0290) | -0.0078 (0.0221) | -0.0004 (0.0213) |
| -6 | +0.0241 (0.0229) | +0.0188 (0.0193) | +0.0152 (0.0175) |
| -5 | +0.0123 (0.0236) | +0.0152 (0.0153) | +0.0002 (0.0141) |
| -4 | +0.0263 (0.0245) | +0.0252 (0.0186) | +0.0080 (0.0162) |
| -3 | +0.0169 (0.0268) | +0.0133 (0.0182) | +0.0028 (0.0151) |
| -2 | +0.0280 (0.0312) | +0.0263 (0.0192) | +0.0099 (0.0172) |
| -1 | 0 (reference) | 0 (reference) | 0 (reference) |
| +0 | **-0.1311** (0.0358) | **-0.1365** (0.0152) | **-0.1467** (0.0160) |
| +1 | **-0.1924** (0.0416) | -0.2048 (0.0876) | **-0.2099** (0.0513) |
| +2 | -0.1759 (0.1485) | **-0.2342** (0.0653) | **-0.2313** (0.0560) |
| Joint pre-trend p | 0.3749 | 0.4878 | 0.8876 |

### Share prioritario

| Event time | Unweighted | Own-year class size | Fixed mean class size |
|---|---|---|---|
| -8 | -0.0347 (0.0196) | **-0.0440** (0.0153) | **-0.0320** (0.0095) |
| -7 | -0.0224 (0.0120) | **-0.0289** (0.0100) | **-0.0272** (0.0078) |
| -6 | -0.0165 (0.0081) | **-0.0235** (0.0082) | -0.0196 (0.0094) |
| -5 | -0.0174 (0.0089) | -0.0225 (0.0092) | **-0.0183** (0.0077) |
| -4 | -0.0133 (0.0116) | -0.0175 (0.0089) | -0.0156 (0.0089) |
| -3 | +0.0001 (0.0060) | -0.0138 (0.0065) | -0.0124 (0.0066) |
| -2 | -0.0049 (0.0085) | -0.0043 (0.0052) | -0.0047 (0.0050) |
| -1 | 0 (reference) | 0 (reference) | 0 (reference) |
| +0 | **+0.0330** (0.0096) | **+0.0190** (0.0071) | **+0.0197** (0.0083) |
| +1 | **+0.0385** (0.0141) | +0.0231 (0.0173) | +0.0286 (0.0140) |
| +2 | +0.0310 (0.0236) | **+0.0261** (0.0086) | **+0.0314** (0.0057) |
| Joint pre-trend p | 0.4984 | 0.0920 | 0.1100 |

### Graduated on time

| Event time | Unweighted | Own-year class size | Fixed mean class size |
|---|---|---|---|
| -7 | -0.0221 (0.0192) | -0.0307 (0.0266) | -0.0180 (0.0573) |
| -6 | **-0.0416** (0.0136) | **-0.0560** (0.0136) | **-0.0582** (0.0131) |
| -5 | **-0.0318** (0.0112) | **-0.0374** (0.0106) | **-0.0388** (0.0100) |
| -4 | -0.0313 (0.0137) | **-0.0363** (0.0102) | **-0.0360** (0.0083) |
| -3 | -0.0252 (0.0145) | -0.0222 (0.0117) | -0.0218 (0.0156) |
| -2 | -0.0112 (0.0086) | -0.0134 (0.0061) | **-0.0113** (0.0048) |
| -1 | 0 (reference) | 0 (reference) | 0 (reference) |
| +0 | **-0.0222** (0.0076) | **-0.0365** (0.0086) | **-0.0364** (0.0090) |
| +1 | -0.0163 (0.0123) | **-0.0347** (0.0085) | **-0.0324** (0.0090) |
| +2 | -0.0213 (0.0120) | **-0.0480** (0.0119) | **-0.0474** (0.0135) |
| +3 | -0.0315 (0.0170) | **-0.0572** (0.0156) | **-0.0622** (0.0137) |
| +4 | -0.0233 (0.0280) | -0.0462 (0.0302) | -0.0504 (0.0332) |
| +5 | +0.0097 (0.0585) | -0.0433 (0.1005) | -0.0471 (0.1013) |
| Joint pre-trend p | 0.1946 | 0.0122 | 0.0129 |

### Applied

| Event time | Unweighted | Own-year class size | Fixed mean class size |
|---|---|---|---|
| -7 | -0.0110 (0.0216) | -0.0258 (0.0289) | -0.0193 (0.0157) |
| -6 | -0.0416 (0.0206) | -0.0585 (0.0312) | -0.0601 (0.0312) |
| -5 | -0.0148 (0.0247) | -0.0074 (0.0122) | -0.0093 (0.0172) |
| -4 | -0.0213 (0.0145) | -0.0127 (0.0090) | -0.0126 (0.0113) |
| -3 | -0.0115 (0.0144) | -0.0115 (0.0082) | -0.0102 (0.0081) |
| -2 | -0.0036 (0.0107) | -0.0092 (0.0110) | -0.0055 (0.0109) |
| -1 | 0 (reference) | 0 (reference) | 0 (reference) |
| +0 | -0.0206 (0.0190) | -0.0276 (0.0206) | -0.0281 (0.0213) |
| +1 | -0.0239 (0.0146) | **-0.0397** (0.0146) | -0.0305 (0.0132) |
| +2 | -0.0144 (0.0142) | **-0.0494** (0.0126) | **-0.0374** (0.0140) |
| +3 | -0.0178 (0.0278) | **-0.0649** (0.0230) | **-0.0543** (0.0188) |
| +4 | -0.0235 (0.0402) | -0.0644 (0.0356) | -0.0438 (0.0287) |
| +5 | -0.0423 (0.0785) | +0.0380 (0.1137) | +0.0015 (0.1021) |
| Joint pre-trend p | 0.2745 | 0.0045 | 0.0040 |

### Assigned a seat

| Event time | Unweighted | Own-year class size | Fixed mean class size |
|---|---|---|---|
| -7 | -0.0231 (0.0217) | -0.0364 (0.0263) | -0.0322 (0.0182) |
| -6 | -0.0367 (0.0235) | -0.0558 (0.0337) | -0.0566 (0.0382) |
| -5 | -0.0127 (0.0118) | -0.0107 (0.0080) | -0.0143 (0.0092) |
| -4 | -0.0137 (0.0115) | -0.0124 (0.0086) | -0.0127 (0.0078) |
| -3 | -0.0086 (0.0127) | -0.0125 (0.0101) | -0.0124 (0.0085) |
| -2 | +0.0024 (0.0095) | -0.0069 (0.0087) | -0.0030 (0.0076) |
| -1 | 0 (reference) | 0 (reference) | 0 (reference) |
| +0 | **-0.0340** (0.0125) | **-0.0341** (0.0135) | -0.0342 (0.0150) |
| +1 | **-0.0382** (0.0115) | **-0.0435** (0.0165) | **-0.0397** (0.0142) |
| +2 | **-0.0239** (0.0100) | **-0.0474** (0.0130) | **-0.0379** (0.0145) |
| +3 | -0.0195 (0.0189) | -0.0582 (0.0343) | -0.0466 (0.0290) |
| +4 | -0.0291 (0.0514) | -0.0596 (0.0376) | -0.0427 (0.0344) |
| +5 | -0.0566 (0.1035) | +0.0228 (0.1300) | -0.0105 (0.1213) |
| Joint pre-trend p | 0.3235 | 0.0043 | 0.0041 |

### Enrolled

| Event time | Unweighted | Own-year class size | Fixed mean class size |
|---|---|---|---|
| -7 | -0.0150 (0.0193) | -0.0227 (0.0231) | -0.0203 (0.0108) |
| -6 | -0.0281 (0.0194) | -0.0485 (0.0316) | -0.0463 (0.0382) |
| -5 | -0.0132 (0.0128) | -0.0087 (0.0082) | -0.0119 (0.0106) |
| -4 | -0.0129 (0.0089) | -0.0108 (0.0051) | -0.0110 (0.0067) |
| -3 | -0.0074 (0.0102) | -0.0107 (0.0085) | -0.0102 (0.0077) |
| -2 | +0.0011 (0.0107) | -0.0058 (0.0110) | -0.0014 (0.0108) |
| -1 | 0 (reference) | 0 (reference) | 0 (reference) |
| +0 | -0.0240 (0.0120) | -0.0263 (0.0131) | -0.0249 (0.0147) |
| +1 | **-0.0295** (0.0085) | **-0.0370** (0.0138) | **-0.0335** (0.0103) |
| +2 | -0.0201 (0.0095) | **-0.0376** (0.0112) | -0.0277 (0.0133) |
| +3 | -0.0047 (0.0166) | -0.0395 (0.0229) | -0.0318 (0.0212) |
| +4 | -0.0223 (0.0449) | -0.0488 (0.0422) | -0.0311 (0.0376) |
| +5 | +0.0077 (0.1201) | +0.0926 (0.0913) | +0.0718 (0.0911) |
| Joint pre-trend p | 0.2115 | 0.0002 | 0.0831 |

## Data

Always-over-demanded cells and entrants: the Piece 1 entrant panel (Ministry of Education enrollment census, performance records, and the SAE application files). College outcomes: the centralized college admission records for processes 2018 to 2026 (application, assignment, enrollment) and the school performance records through 2025 for on-time graduation. Sixteen regions form the clusters for the bootstrap and the randomization test.

## References

Abadie, A., Athey, S., Imbens, G. W., and Wooldridge, J. M. (2023). When should you adjust standard errors for clustering? *Quarterly Journal of Economics*, 138(1), 1-35.

Callaway, B., and Sant'Anna, P. H. C. (2021). Difference-in-differences with multiple time periods. *Journal of Econometrics*, 225(2), 200-230.

MacKinnon, J. G., and Webb, M. D. (2020). Randomization inference for difference-in-differences with few treated clusters. *Journal of Econometrics*, 218(2), 435-450.

Romano, J. P., and Wolf, M. (2005). Stepwise multiple testing as formalized data snooping. *Econometrica*, 73(4), 1237-1282.

Solon, G., Haider, S. J., and Wooldridge, J. M. (2015). What are we weighting for? *Journal of Human Resources*, 50(2), 301-316.

Young, A. (2019). Channeling Fisher: Randomization tests and the statistical insignificance of seemingly significant experimental results. *Quarterly Journal of Economics*, 134(2), 557-598.

