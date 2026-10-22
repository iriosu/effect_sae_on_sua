# Handoff: Section V's notebook moves to `section5/` (2026-10-22)

From Abhijit, for whoever works on this branch next. Line numbers refer to the files at commit `8252c75`, the branch's tip before this commit.

## What changed

- The folder `code/finalized_design_v1/section3/` is now `code/finalized_design_v1/section5/`, named after Section V of the submission draft (`Initial submission/main.tex`). Its notebook is `Section5_IV.Rmd`, with its `README.md`.
- `Section5_IV.Rmd` writes Tables III and IV and Appendix Tables C.1 to C.6 to `output/` exactly as the paper prints them: once the first comment line of each file and the paper's `\marar{}` markup are set aside, each file equals the paper's table line for line. It prints the numbers of Section V's text and Appendix C's prose, and writes them to `output/section5_text_numbers.csv`, each with its file, its line and the words just before it. It also writes the working draft's admission-scores table and Table A3's three files, as before.
- The notebook reads four data files from the shared folder `<home>/Dropbox/Effect SAE on SUA/data/finalized_design_v1/section5/`. In `code/finalized_design_v1/data_manifest.csv`, four rows with each file's bytes and MD5 replace the two `section3` rows.
  - `section5_panel.rds`: one row per child, the 304,547 children of `section3_panel.rds` in the same order, 38 columns. Its first 34 columns are those of `section3_panel.rds`, with 63,820 missing outcome values filled in for the 6,382 children of Table C.5's first-choice sample who are outside the lottery sample. The four new columns are `FIRST_CHOICE_SAMPLE`, `FIRST_CHOICE_OFFER` and `FIRST_CHOICE_LOTTERY` (Table C.5) and `ENTRY_SCHOOL_TYPE` (Table C.3).
  - `section5_applications.rds`: one row per 9th-grade application of the 2016-2021 processes by a child who ranked one of the 1,045 schools or was enrolled at one; 321,463 rows (Table C.1, and Section V.A's footnote on the placements at the 1,045 schools).
  - `section5_entrants.rds`: one row per 9th-grade entry at the 1,045 schools under SAE; 106,627 rows (Table C.2, column 3).
  - `table_a3_panel.rds`: the same file as before (MD5 `572f4faba00263d249abc267b41146e2`), one row per school.
- `section3_panel.rds` and `table_a3_panel.rds` leave the shared `section3/` folder. Its other folders (`score_baseline_v1_2026-10-19/`, `expanded_score_analysis_2026-10-19/`, `pace_operational_eligibility_2026-10-19/`) stay where they are.
- `HANDOFF.md` describes the new folder, its files and its command. Section 3 of `Reviews/handoff_ignacio_section5_adult_graduation_2026-10-22.md` names the old panel and notebook; their places are now the ones above.

## What other code needs

`code/analysis_for_adversarial_report.Rmd` names the old folder, notebook or panel on 17 lines (`git grep -n -i "section3/\|Section3_IV\|section3_panel\|'section3'" 8252c75 -- code/analysis_for_adversarial_report.Rmd`):

| Line | Now | Change |
|---|---|---|
| 17 | `finalized_design_v1/section3/Section3_IV.Rmd` (scope text) | `finalized_design_v1/section5/Section5_IV.Rmd` |
| 47 | `analysis_for_adversarial_report_output/input/section3_panel.rds` (scope text) | `analysis_for_adversarial_report_output/input/section5_panel.rds` |
| 72 | `file.exists("finalized_design_v1/section3/Section3_IV.Rmd")` | `"finalized_design_v1/section5/Section5_IV.Rmd"` |
| 77 | `endsWith(manifest$path_in_dropbox, "/section3/section3_panel.rds")` | `"/section5/section5_panel.rds"`; the manifest has no `section3` row, so line 78 stops until this changes |
| 82 | `file.path(output_dir, "input", "section3_panel.rds")` | `"section5_panel.rds"` |
| 92 | `source_file <- "finalized_design_v1/section3/Section3_IV.Rmd"` | `"finalized_design_v1/section5/Section5_IV.Rmd"` |
| 412 | `"/Effect SAE on SUA/data/finalized_design_v1/section3/table_a3_panel.rds"` | `"/Effect SAE on SUA/data/finalized_design_v1/section5/table_a3_panel.rds"`, the path written to `upstream_provenance.csv`; the cached file and its MD5 at line 406 stay the same |
| 1841 | `readRDS('analysis_for_adversarial_report_output/input/section3_panel.rds')` | `'analysis_for_adversarial_report_output/input/section5_panel.rds'`, a copy of the shared `section5_panel.rds`; this read has no MD5 check |
| 5806 | `endsWith(path_in_dropbox,'/section3/section3_panel.rds')` | `'/section5/section5_panel.rds'`, as at line 77 |
| 5812 | `'analysis_for_adversarial_report_output/input/section3_panel.rds')` | `'analysis_for_adversarial_report_output/input/section5_panel.rds')` |
| 6009, 6029, 6061, 6062, 6603, 7125, 7215 | the notebook's own folders in the shared `section3/` folder (`score_baseline_v1_2026-10-19`, `expanded_score_analysis_2026-10-19`, `pace_operational_eligibility_2026-10-19`) | none: those folders stay |

- Table C.4 now comes from `Section5_IV.Rmd` (chunks `table-C4` and `table-C4-tex`). The notebook's `offer-table-tex` chunk (lines 761-824) writes its own `lottery_college_offer.tex`, a duplicate; at `8252c75` it has one graduation row.
- Section 5 of `Reviews/handoff_ignacio_section5_adult_graduation_2026-10-22.md` (the frozen score baseline) still applies. From `section5_panel.rds`, the `f08-adopted-score-panel` chunk (line 5801) builds a `section3_score_baseline_v1_2026-10-19.rds` that differs from the v1 file, so a full render stops at "Shared baseline differs" (lines 6016-6017) until the choice described there is made. A v2 baseline built from `section5_panel.rds` carries the four new columns and the 6,382 children's filled outcome values; the tabulation by `GRAD_OT` at lines 5874-5875 covers every child of the panel.
- `sections/9_appendix_outcomes.tex` of the submission draft can `\input` the notebook's `lottery_sample_construction.tex`, `complier_alternatives.tex` and `lottery_followup.tex`, copied into `tables/results/` as the paper's other tables are, in place of the typed Tables C.1 (lines 10-31), C.3 (lines 58-77) and C.6 (lines 99-122) of the version of 2026-10-22.
