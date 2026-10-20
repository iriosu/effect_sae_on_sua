# Reproducing the operational PACE analysis

Run commands from the analysis repository root. Statistical construction and estimation live in the central `code/analysis_for_adversarial_report.Rmd`; the runner executes its named chunks. R needs `data.table`, `fixest`, and `digest`.

## Reestimate from the delivered private caches

1. Sync the established private Dropbox data workspace. Under `data/finalized_design_v1/section3/`, retain the three dated folders `score_baseline_v1_2026-10-19`, `expanded_score_analysis_2026-10-19`, and `pace_operational_eligibility_2026-10-19`.
2. Run `Rscript code/run_pace_operational_analysis.R --from-cache`. Missing operational caches are copied automatically into the ignored input directory. The prior academic-classification file is restored from the expanded-score folder when needed. The score baseline is read locally or directly from its shared folder.
3. Read `operational_pace_report_2026-10-19.md`, the estimates CSV, and the validation/sensitivity outputs in this directory. No student records enter Git.

`shared_private_delivery.csv` lists the 13 delivered operational RDS files, sizes and MD5s. The runner verifies private delivery and refuses to overwrite an existing file with a different hash. For a deliberately revised analysis, choose a new export directory using `SAE_PACE_OPERATIONAL_EXPORT_DIR`; preserve the dated baseline.

## Rebuild histories and classifications from source inputs

Omit `--from-cache`. In addition to the score baseline and prior academic-classification file, the ignored `code/analysis_for_adversarial_report_output/input/f08/` directory must contain these earlier source projections:

| Input | Purpose |
|---|---|
| `graduates_pace_audit.rds` | Old school-history/classification comparison; shared in the expanded-score folder |
| `performance_master_high_school_2026-10-19.rds` | National grade histories and candidate graduation schools |
| `college_pace_audit.rds` | 2021 exam subjects and earlier PACE application/selection records |

The compact `higher_enrollment_2023_2024.rds` and `school_enrollment_upper.rds` projections are included in the operational delivery. Copy them into its matching ignored input subfolder to avoid rebuilding the large enrollment panels. Otherwise the input-cache chunk reads `data/panel_enrollment_2007_2024.rds`, `data/matricula_2011_2023.rds`, and `data/matricula_2024_2025.rds` from the private data workspace. The full rebuild also reads the 2025 higher-education CSV under `data/enrollment_mineduc_2025/`. These original inputs are part of the existing project data workspace, not the Git repository.

Run `python3 code/fetch_pace_operational_sources.py` to download and extract the public 2022–2026 admissions sources. This needs network access and `bsdtar`. Raw files stay in ignored `input/f08/operational_raw/` and `input/f08/operational_2026/`; official annual school rosters and policy sources are committed separately. Building the enrollment projection from the original large SIES panel can require about 15 GB of memory.

## Regenerate manuscript tables only

Run `Rscript code/run_pace_operational_analysis.R --tables-only`; no private inputs are needed. Set `SAE_PAPER_ROOT` to the manuscript's `Initial submission` directory to copy the two dated TeX files into `tables/results/`. Existing score/accounting tables are preserved. The manuscript inputs the operational table and classification-error sensitivity in Appendix D.10; Section VI discusses the results and limits.

The complete cached analysis passed coefficient/robust-SE checks against direct 2SLS, exhaustive small-design completion checks, and unchanged-score-baseline checks. All 104 R chunks parse; the 93-page manuscript compiles without LaTeX warnings, and both new tables were visually inspected.
