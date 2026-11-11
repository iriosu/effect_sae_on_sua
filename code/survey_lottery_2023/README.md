# Survey-lottery project

Exploratory project of issue #22 (https://github.com/iriosu/effect_sae_on_sua/issues/22).
It links the surveys of the Mistakes project to the paper's lottery sample and estimates what the school lottery does to beliefs, strategic reports, and application choices measured there.

Branch `survey-lottery-2023`, created from `finalized-design-v1` at commit `251e9ef20ebdd1836737df8651100d1730b2aba3`.
Status on 11 November 2026: the analysis is complete and is kept on this branch. The authors decided not to add it to the paper now. The branch is not merged.
The manuscript and the three notebooks of `code/finalized_design_v1/` are unchanged.

## Files

| File | Content | State on 11 November 2026 |
|---|---|---|
| `feasibility_memo.md` | Sources, timing, linkage, overlap, selection, power, first results, items not done | Written with actual results |
| `outcome_inventory.md` | Survey items by family: wording, timing, who answers, definitions, items that do not exist | Written before any survey row was opened |
| `specification_log.md` | Samples, stages of observation, equations, bounds, conditions for attendance effects, families, multiple testing, disclosure, dated changes | Written before any estimate; dated entries since, the last two before steps 5 and 6 |
| `estimators.R` | Estimators and table writers shared by steps 3, 5 and 6 | Sourced by those scripts |
| `00_power_from_committed_aggregates.R` | Projected overlap and minimum detectable effects from committed October aggregates | Ran. Superseded by the actual numbers of steps 1 to 4 |
| `01_lottery_cohort_aggregates.R` | Counts, first stage, and offer effects on graduation, score, and application on time, by application year | Ran |
| `02_survey_link_aggregates.R` | Coverage of the key, overlap, and response by offer for the 2023 baseline | Ran |
| `03_baseline_offer_effects.R` | Offer effects on the baseline outcomes, selection into answering, trimming bounds, reweighting, attendance effects where allowed | Ran. Rerun after the estimators moved to `estimators.R`, with identical output |
| `04_endline_overlap.R` | Overlap of the 2023 endline with the lottery sample and response by offer | Ran |
| `05_application_outcomes.R` | Rest of family D: top true program in the final list, inadmissible applications, risk of no assignment, for survey-linked children and the whole cohort | Ran |
| `06_ranking_belief_gap.R` | Expected against realized Ranking and NEM: estimates, precision, quantiles, realized scores without the survey. Added after the first results | Ran |
| `output/*.md` | Aggregate tables written by the scripts | Written |
| `logs/*.txt` | Run time, commit, versions, and checksums of inputs and outputs | Written |

## How to run

From the repository root, with R 4.5 and fixest 0.14.2 (the versions of `code/finalized_design_v1/README.md`):

    Rscript code/survey_lottery_2023/00_power_from_committed_aggregates.R
    Rscript code/survey_lottery_2023/01_lottery_cohort_aggregates.R
    Rscript code/survey_lottery_2023/02_survey_link_aggregates.R
    Rscript code/survey_lottery_2023/03_baseline_offer_effects.R
    Rscript code/survey_lottery_2023/04_endline_overlap.R
    Rscript code/survey_lottery_2023/05_application_outcomes.R
    Rscript code/survey_lottery_2023/06_ranking_belief_gap.R

Steps 1 to 6 read `~/Dropbox/Effect SAE on SUA/data/finalized_design_v1/mechanisms/mechanisms_panel.rds` (set `SAE_MECHANISMS_DATA` for another folder) and check its MD5 against the manifest.
Steps 2 to 6 read the Mistakes replication package at `~/Dropbox/mistakes_replication/replication_package` (set `MISTAKES_PACKAGE` for another folder).
Step 5 also reads the public files of applications of the 2023 process and the admission probabilities of the Mistakes project in `~/Dropbox/Mistakes Structural/Data/2023/input` (set `MISTAKES_2023_INPUT` for another folder).
Steps 2, 3, 5 and 6 check the SHA-256 of their survey and administrative inputs.
Steps 3, 5 and 6 draw 300 bootstrap samples with a fixed seed. Each takes one to three minutes.

## Rules

- Data stay where they are. The scripts write aggregates only, and no count below 11 children.
- No regression is run with fewer than 50 answering children in either offer group.
- Logs go to `logs/` as `.txt` files. The repository ignores `*.log` and `*.csv`, so outputs are Markdown tables.
- Survey answers are outcomes of the lottery. They never enter a regression as controls.
- The specification log is changed only by dated entries in its last section.
