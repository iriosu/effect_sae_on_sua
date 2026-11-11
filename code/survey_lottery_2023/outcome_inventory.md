# Outcome inventory: Mistakes surveys and the school-lottery sample

Written 11 November 2026, before any survey row was opened and before any effect estimate was computed.
Issue: https://github.com/iriosu/effect_sae_on_sua/issues/22.

Every item below was read from the questionnaires, the export dictionaries, the codebook, and the cleaning code of the Mistakes replication package (`mistakes_replication/replication_package`, git `master` at `11ec15fbe445b56f5544e1e9b5d9a0b1e48d6825`).
No response file was read to write this inventory.
The numbers of children who answered each item are in `output/survey_link_aggregates.md` and `output/baseline_offer_effects.md`, computed afterwards.

Question numbers are the export tags of the Qualtrics files (for example `Q61`).
English wording comes from `IRB/Baseline_survey_mistakes_2023_english.pdf`, `IRB/Endline_survey_mistakes_2023_english.pdf`, and `IRB/2022-mistakes-survey_english.pdf`.

## 1. Timing of each survey relative to the school lottery

All survey responses are collected four to five years after the school lottery.
Every response is an outcome of the lottery.
No response may enter a regression as a pre-lottery control.

| Survey | Invited | Field dates | Position in the college process | Application year scheduled for this process (paper, Table C.6) |
|---|---|---|---|---|
| 2023 baseline | Students registered for the tests of the 2023 process | 27 Dec 2022 to 2 Jan 2023 | After the tests, before results (3 Jan 08:00) and before applications (3 to 6 Jan) | 2018 |
| 2023 endline | Applicants of the 2023 process | 13 to 16 Jan 2023 | After the application deadline and after the personalized websites of 5 Jan, before assignment results | 2018 |
| 2022 survey | All 148,819 applicants of the 2022 process | 18 to 22 Jan 2022 | After the application deadline and after the 2022 websites of 13 Jan, before assignment results | 2017 |
| 2020 survey | Applicants of the 2020 process with a regular application | 1 to 8 Mar 2020 | After applications | None (the first lottery cohort is scheduled for the 2021 process) |

Students of application years 2016 and 2017 appear in the 2023 process only if they are delayed or apply again.
Their presence in the 2023 process is itself an outcome of the lottery.

## 2. 2023 baseline survey: flow and who answers each item

1. Consent (`Q17`). The cleaning code keeps `Q17 == "Acepto"` and responses started after 27 Dec 2022 10:00.
2. Months of preparation (`Q3`), expected test scores (`Q5`), expected NEM and Ranking scores (`Q41`).
3. Probabilities of score intervals around the expected score. Each respondent sees one of two versions, drawn at random.
4. Probability of applying (`Q60`) and probability of admission (`Q61`).
5. The survey ends for respondents who answer `Q60 = 0`.
6. Top true program (`Q8`), planned first preference (`Q19`), planned last preference (`Q20`).
7. One module by admission path. The embedded fields `regular`, `bea`, and `pace` decide the module. These fields come from administrative records of the 2023 process. PACE status depends on the school attended, so the module shown is an outcome of the lottery.
8. Knowledge of degree programs. Regular respondents see one of four groups of questions, drawn at random. BEA and PACE respondents see one of two groups. The cleaning code names the group `block` (1 to 4 regular, 5 and 6 BEA or PACE). The code infers `block` from the questions answered. `block` is missing for respondents who stopped earlier.

Program-specific questions show up to three rows: the top true program (`Q8`), the planned first preference (`Q19`), and the planned last preference (`Q20`).
The rows for `Q19` and `Q20` appear only when the programs differ.
The programs are chosen by the respondent after the lottery.
A difference in a program-specific belief between offer groups therefore combines a change in the program named and a change in the belief about a given program.

## 3. Inventory by family

### 3.1 Beliefs about earnings and progression (2023 baseline)

All items are program-specific and sit in the randomized groups of step 8.

| Item | Wording | Scale | Export tags by group | Cleaned prefix | Share of regular respondents asked |
|---|---|---|---|---|---|
| Expected income | "If you enrolled in and graduated from each of the following degree programs, what do you think your monthly income would be in the fourth year after graduating?" | Slider, 0 to 3,000,000 pesos or more | `Q186` (1), `Q74` (2), `Q78` (5) | `exp_inc_` | 2 of 4 groups |
| Income interval probabilities | Probability that income is below, within, or above 20 percent of the respondent's answer | Three shares that add to 100 | `Q68` and variants (1), `Q102` and variants (2), `Q123` and variants (5) | (interval fields) | 2 of 4 groups, one program per respondent |
| Expected annual payment | "Considering your student financial aid, how much do you think you will have to pay per year for your degree program?" | Slider, 0 to 8,000,000 pesos or more | `Q72` (1) | `mat_` | 1 of 4 groups |
| Probability of graduating | "How likely do you think it is that you would graduate from these degree programs?" | 0 to 100 | `Q47` (1), `Q112` (3), `Q119` (5) | `grad_prob_` | 2 of 4 groups |
| Semesters to graduate | "How many SEMESTERS would it take you to graduate from these degree programs?" | Slider | `Q73` (1), `Q77` (4), `Q71` (6) | `sem_` | 2 of 4 groups |
| Position among peers | "Assuming there are 100 students in total, in which position, relative to your peers, do you think your first-year grade average would be?" | 0 to 100 | `Q95` (2), `Q52` (3), `Q276` (6) | `rel_grade_` | 2 of 4 groups |
| Probability of staying | "How likely is it that you would stay in the same degree program the following year if you enrolled in these degree programs?" | 0 to 100 | `Q100` (2), `Q111` (3), `Q56` (4), `Q117` (5) | `prob_remain_` | 3 of 4 groups |
| Probability of passing all first-year courses | "How likely do you think it is that you will pass all your first-year courses in these degree programs?" | 0 to 100 | `Q101` (2), `Q57` (4), `Q118` (5), `Q70` (6) | `apr_all_` | 2 of 4 groups |
| Probability of employment | "What would your probability of being employed be in the fourth year after graduating from these degree programs?" | 0 to 100 | `Q69` (3), `Q76` (4), `Q75` (6) | `prob_emp_` | 2 of 4 groups |

Sources of missing answers: no consent, `Q60 = 0`, dropout before step 8, group not drawn, row not shown (programs coincide), "slider not moved".
The income and payment sliders have a top value ("or more").

Defensible definitions.
The answer for the planned first preference (`Q19`) is the main version of each item.
The planned first preference is defined for every respondent who reaches step 6.
The answer for the top true program is the second version.
Bias relative to a benchmark (for example observed graduate income of the program) needs program-level data that the Mistakes package holds for some items (`pct_bias_income_avg_*` exists for 2022 only).
No 2023 benchmark is defined here.

### 3.2 Own probability of college attainment

No survey asks the respondent's unconditional probability of obtaining a college degree.
The items that exist are these.

| Item | Wording | Scale | Asked of |
|---|---|---|---|
| `Q60` (baseline) | "How likely is it that you will apply to at least one degree program in the 2023 Admission Process?" | 0 to 100 | Every consenting respondent |
| `Q61` (baseline) | "How likely is it that you will be admitted to any of the degree programs in your application?" | 0 to 100 | Every consenting respondent |
| `grad_prob_` (baseline) | Probability of graduating from a named program, conditional on enrolling (Section 3.1) | 0 to 100 | Groups 1, 3, 5 |
| `QID61` (endline) | "How likely is it that you will be admitted to at least one degree program in your application?" | 0 to 100 | Endline respondents |
| `QID131` (2022) | "How likely do you think that you will be admitted to any of the preferences of your application?" | 0 to 100 | 2022 respondents |

I do not define a combined measure.
A product of `Q61` and `grad_prob_` would be a construct that no respondent was asked about.
The author needs to choose the item that stands for this outcome.
My recommendation is `Q61` as the main item and `grad_prob_` for the planned first preference as the second.

### 3.3 Selectivity of the stated top true program

The top true program is measured.
Selectivity is not a survey item and comes from administrative program data.

| Item | Wording | Asked of |
|---|---|---|
| `Q8` (baseline) | "If you could be admitted to any degree program of your choice, regardless of your scores, to which degree program would you apply?" Drop-down lists, university then program, 2,059 entries. | Respondents with `Q60 > 0` |
| `QID329` (endline) | Where the respondent would apply "if you were admitted with complete certainty to any degree program you wanted, regardless of your scores". The wording differs from the baseline. | Endline respondents |
| `QID12` (2022) | Where the respondent would have applied "if your admission did not depend on your scores". | 2022 respondents |

Defensible definition of selectivity.
The paper's Table IX uses the cutoff percentile of a program.
The notebook `mechanisms.Rmd` defines it as the rank of the program's cutoff among the programs of the same admission process.
The same definition applies to the program named in `Q8`, with the cutoffs of the 2023 regular process (`Data/survey_2023/cutoffs_and_extras_official_2023.csv`).
A second version uses the cutoff of the 2022 process, the latest cutoff a respondent could know when answering.
Programs without a binding cutoff need a rule.
The Mistakes code uses the minimum weighted score required when a program does not fill its seats (`cutoffs_reg_*` in the 2022 codebook).
The same rule is the default here.

Related outcomes measured directly: whether the planned first preference equals the top true program (`Q19 = Q8`), and the selectivity of the planned first and last preferences (`Q19`, `Q20`).

### 3.4 Mistakes and strategic reports

| Outcome | Source | Definition on file | Limits |
|---|---|---|---|
| Planned first preference differs from the top true program | Baseline `Q8`, `Q19` | Indicator `Q19 != Q8` | A plan stated before scores are known |
| Top true program listed in the submitted application | Baseline `Q8` and the public file of applications of the 2023 process | The 2022 codebook defines `applied_to_top_true_fin` this way. The 2020 codebook defines `truth_teller` (top true listed first), `misreport_order`, and `misreport_exclude`. | The website policy of 5 Jan sits between the first and the final application |
| Application to a program whose requirements the student does not meet | Public file of applications (status codes by preference) | 2020 codebook, `some_mistake`: more listed programs than valid applications (status 24 to 26) | Needs the status codes of the 2023 file. No survey answer is needed, so the outcome exists for every applicant in the lottery cohort |
| Risk of no assignment | 2023 policy file (`risk_label`: 1 high, 2 medium, 3 low; `overall_int`, `overall_fin`) | Computed by the policy for the application on file on 4 Jan 18:00 | Defined only for students who applied in the first half of the window. Applying early is an outcome of the lottery |
| Knowledge of requirements | 2022 survey, block "Errors" (`QID19`, `QID25` to `QID27`); 2020 survey | Shown only to applicants who listed a program without meeting a requirement | Not asked in the 2023 baseline |
| Reasons for not listing the ideal program first | 2022 survey `QID87`, `QID125` | Multiple answers | Not asked in 2023 |

Inputs located on 11 November 2026, after this inventory was written.
The public files of applications of the 2023 process are outside the Mistakes package, in `~/Dropbox/Mistakes Structural/Data/2023/input/ABCD/` (regular, BEA and PACE seats, with a layout document for each).
Status 24 is selected, 25 is on the waiting list, and 26 is selected in an earlier preference. Every other status of a listed preference is a requirement not met.
The admission probabilities are in the same folder: `applications_and_probs_final.csv` for the final list and `applications_and_probs_20230104_1800.csv` for the list on file on 4 Jan 18:00.
In both files `overall` is the probability of admission to some program of the list, and `risk_label` is 1 when it is below 0.01, 2 between 0.01 and 0.99, and 3 above 0.99.
`overall` is stored with three decimals, and the label was assigned before rounding.
The definitions used are in the entry of 21:23 UTC of `specification_log.md`, and the results in `output/application_outcomes.md`.

### 3.5 Admission and cutoff beliefs

| Item | Wording | Scale | Asked of |
|---|---|---|---|
| `Q5_1` to `Q5_5` (baseline) | "If you took the PAES, what score do you think you will obtain (approximately) in each of the tests?" Mathematics M1, Mathematics M2, Reading, History and Social Sciences, Science | 100 to 1000, with "I did not take this test" | Every consenting respondent |
| `Q41_1`, `Q41_2` (baseline) | "What do you think your scores will be?" NEM, Ranking | 100 to 1000 | Every consenting respondent |
| Score interval probabilities (baseline) | Probability that each score is below, within, or above 50 points of the expected score | Shares that add to 100 | One of two versions at random |
| `Q63_1` to `Q63_3` (baseline) | "Imagine that you applied to each of them as your first preference: how likely is it that you would be admitted to that degree program?" | 0 to 100 | Regular module |
| `Q64_1` to `Q64_3` (baseline) | "What do you think the score of the last person admitted will be?" | 0 to 1000 | Regular module |
| `Q65_1` to `Q65_3` (baseline) | "How likely is it that your weighted score is above the score of the last person admitted?" | 0 to 100 | Regular module |
| `Q30_*`, `Q33_*` (baseline) | Probability of admission through the regular and BEA paths, or regardless of path for PACE | 0 to 100 | BEA module, PACE module |
| `Q28`, `Q29`, `Q31`, `Q32` (baseline) | Whether the respondent expects to meet BEA or PACE requirements; knowledge of BEA seats and of the PACE process | Categories | BEA module, PACE module |
| Endline families `puntpond`, `cutoff`, `prob_over_cutoff`, `prob_reg_bea`, `prob` | Weighted score, cutoff, and admission beliefs for programs chosen by the survey | Sliders | Endline respondents. Programs shown depend on `progress_baseline` and `grupo_baseline` |
| 2022 `QID8`, `QID131`, `QID136` to `QID138`, `QID139` to `QID145` | Admission probabilities, cutoff beliefs, probability above the cutoff, weights or minimum score | Sliders | 2022 respondents; weights and minimum score at random |

Defensible definitions.
The Mistakes codebook defines the bias in expected scores as the belief minus the realized score (`bias_mate1`, `bias_clec`, with baseline beliefs `ptje_M1_bl`, `ptje_lect_bl`).
The same definition extends to NEM and Ranking with the official scores of the public registration file.
The bias in a cutoff belief is the belief minus the realized cutoff of the regular process (`bias_cutoff_*` in the 2022 codebook, `cbias_*` in 2023).
The bias in an admission probability needs the admission probability computed by the Mistakes project (`exante`, `overall`), available for the lists on file and not for every program named in the survey.

## 4. Application choices from administrative records

These outcomes need no survey response.
The paper's mechanisms panel already holds them for the whole lottery sample, on time and ever: number of listed programs, mean and highest cutoff percentile of the list, weight of NEM and Ranking, application score, cutoffs missed and reached.
The survey adds beliefs and the top true program.
For the respondents, the administrative outcomes allow a comparison of respondents with the full cohort.

## 5. Survey features that act after the lottery

| Feature | Timing | Assignment | Treatment in this project |
|---|---|---|---|
| WhatsApp reminder of the baseline | 31 Dec 2022 | Random among students who had not opened the survey | A determinant of response. The assignment file has not been located |
| Version of the score-interval questions | Baseline | Random | Fixed effect when those items are used |
| Group of knowledge questions (`block`) | Baseline | Random within admission path | Fixed effect; sample restricted to the groups that hold the item |
| Module by admission path | Baseline | Administrative status | An outcome of the lottery; reported as such |
| Personalized websites | 5 Jan 2023 | Every student who applied in the first half of the window | Applying early is an outcome of the lottery |
| WhatsApp encouragement to open the website | 5 Jan 2023, 10:00 | Random within the target group (35,968 of 132,893) | Balance by offer is checked; it affects only final applications and the endline |
| Endline program lists (`grupo_baseline`, A or B) | Endline | Stored assignment | Fixed effect |
| 2022 websites (T1 to T4) and SMS | 13 Jan 2022 | Random within cells | Balance by offer is checked; they precede the 2022 survey |

## 6. Items that do not exist

- An unconditional probability of obtaining a college degree.
- Any belief measured before the school lottery.
- Beliefs of students who did not register for the tests.
- Questions about the secondary school attended or about the school lottery.
- Knowledge of application requirements in the 2023 baseline.
