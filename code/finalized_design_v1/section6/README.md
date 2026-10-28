# Section VI: mechanisms analysis and table exports

The [October 28 integration handoff](../../../Reviews/handoff_mechanisms_2026-10-28.md) maps the current manuscript's Tables V–IX and Appendix D to these modules and the coauthor code still needed. The [frozen manuscript reference](reference/manuscript_2026-10-28/) preserves the author-edited outputs and the day's diff. These modules are delivered in the GitHub code repository; Overleaf syncing does not publish them.

## Historical grade stringency

`run_grade_stringency.R` constructs a pre-SAE school grading index, links it to the Section 5 lottery sample, estimates the attendance specification, and adds the grade-stringency outcome to Table V, Panel C. The manuscript appendix describes the construction.

For incorporation into the final code, read the [collaborator handoff](../../../Reviews/handoff_grade_stringency_2026-10-28.md). It gives input schemas, exact specifications, integration steps, and acceptance checks. The [dated reference run](reference/2026-10-28_results.md) preserves estimates, coverage, and provenance from the saved outputs.

## Run

From this directory, with R packages `data.table` and `fixest` installed:

```sh
Rscript --vanilla run_grade_stringency.R \
  '--manuscript=/path/to/Initial submission'
```

Replace the example manuscript path with the local directory containing `tables/`. Omit `--manuscript` to run without updating the paper. All options use `--name=value`; quote the entire argument when its value contains spaces.

| Option | Default |
| --- | --- |
| `--data-dir` | `~/Dropbox/Effect SAE on SUA/data` |
| `--panel` | `<data-dir>/finalized_design_v1/section5/section5_panel.rds` |
| `--schools` | `<data-dir>/finalized_design_v1/section5/table_a3_panel.rds` |
| `--cache-dir` | `<data-dir>/finalized_design_v1/section6/grade_stringency` |
| `--output-dir` | `section6/output/grade_stringency`, beside the script |
| `--manuscript` | Empty; supply the directory containing `tables/` |

The data directory must contain nonempty local copies of `panel_simce_2m.rds`, `panel_performance_2002_2023.rds`, and `panel_ee_2004_2025_homogenized.rds`. The two Section 5 files are prebuilt shared inputs, also read by `../section5/Section5_IV.Rmd`; that notebook does not build them. Preparation checks the historical performance and SIMCE file sizes against the reference vintage. The runner also checks the current 175,869-student complete-controls lottery sample and 1,045-school over-demanded catalogue, and stops if these change. Review those checks deliberately when updating the upstream data or design. Exact source hashes and the verified R/package versions appear in the dated reference.

The current generator of the other Panel C outcomes was not present in the synced repository. This exporter therefore extends the existing `lottery_graduation_part2.tex` and preserves its other estimates and sample counts. Run this script **after** any script that regenerates that table. It replaces its own marked rows on rerun and checks the surrounding table structure before publishing changes. It also generates `grade_stringency_facts.tex`, which the mechanisms section inputs for the numerical statements in the text and appendix.

## Construction

1. `prepare_grade_stringency.R` selects regular secondary grade 10 in 2014–2016. It reconciles exact duplicate records, retains valid annual GPA (1–7) for both passing and failing students, removes ambiguous student-years, and requires the same student, year, and school in the GPA and SIMCE records. Both mathematics and reading scores and sex must be observed. The preparation writes merge diagnostics and source hashes.
2. The runner keeps publicly funded schools that were never recorded as fee-paying private during 2012–2025, using both performance records and the school directory. Each school must have at least 20 matched students across at least two cohorts. Historical students must not overlap the lottery sample.
3. `fit_grade_stringency.R` regresses GPA on school effects, year effects, sex, and year-specific achievement controls. For each subject and year, scores are standardized and entered through a natural cubic spline with four degrees of freedom. A year-specific product of standardized mathematics and reading scores is also included.
4. School effects are centered with equal school weights. Their HC0 variances include uncertainty in the common coefficients, conditional on observed covariates and spline knots. The estimated between-school variance subtracts sampling noise. Scalar empirical Bayes weights shrink imprecise effects toward zero; the effects are recentered after shrinkage. The index reverses the sign, so a larger value means lower grades conditional on measured achievement, in GPA points. The scalar shrinkage weights do not use cross-school covariances or propagate uncertainty in the estimated prior variance.
5. The index is attached by `ENTRY_RBD` to the school attended in April of the lottery entry year. The outcome regression instruments `D_OD` with `OFFER`, includes chance-group and year effects, and controls for `GPA8_Z`, `ES_MUJER`, `PRIORITARIO`, `ALTO`, and `ORIGIN_OD`. It uses the Section 5 heteroskedasticity-robust convention (`ssc(K.adj = FALSE)`) and normal-reference p-values. Missing indices remain missing; the row reports its own sample size and no-offer mean.

The index is a historical grading-environment proxy. Overall GPA and the two SIMCE subjects do not measure identical skills; curriculum, effort, selection into schools and into test-taking, and changes between tenth-grade historical grading and ninth-grade lottery outcomes may matter. The runner estimates the effect of an offer on index availability in the full lottery sample. Conditioning on observed index values can change the randomized comparison. Lottery-stage standard errors treat the historical index as fixed. These qualifications are stated in the appendix; this outcome does not decompose the causal effect on grades or failure.

## Outputs and verification

Aggregate CSVs and `session_info.txt` are written to `output/grade_stringency/`. They include source and code hashes, calibration selection and merge audits, school indices, lottery coverage, the availability regression, main and sensitivity estimates, and cohort stability. The repository's existing ignore rules exclude CSVs from version control; retain these generated files with the analysis outputs.

Student-level calibration and lottery links, school fits, and metadata are saved in `--cache-dir`, under the private data tree by default. Preparation caches are reused only when both raw-input hashes and the preparation-script hash match. Subsequent fits are recomputed on each run.

The covariance calculation is checked against full-dummy OLS HC0 on a deterministic unbalanced numerical example. Empirical checks include unique identifiers, no historical/lottery overlap, valid coverage, centered indices, reliability weights in [0,1], and no silent regression observation drops. Sensitivity outputs report unshrunk effects and each leave-one-cohort-out fit on common lottery coverage. A coarse year-specific 5-by-5 mathematics/reading support check requires at least 20 students in both over-demanded and other schools in each retained cell. If every cell passes, this check does not change the sample and is not independent robustness evidence or proof of school-level overlap.

The paper's effect, sample sizes, availability result, and sensitivity range are generated from these outputs; do not edit their numerical values manually.

## Admission channels tables

The mechanisms section presents assignment by track, then three channels: application choices, admission scores, and reserved-seat eligibility. Assignment uses the `lottery_admission_tracks.tex` body and wrapper generated by `export_admission_tracks.R`. That exporter estimates mutually exclusive first-assignment route outcomes on the full 175,869-student lottery sample; its components add to the overall −2.23 / −1.04 pp effects before rounding. It does not reuse the old ordered admission-step accounting. See the integration handoff for raw-input paths, hashes, projection dependencies, execution options, and the saved `output/admission_tracks/` audits.

`merge_admission_tables.py` assembles the application-choices table and the admission-score table from the preserved source tables `lottery_scores_horizons.tex` and `lottery_application_scores.tex`. It copies estimates, standard errors, and significance markers; keeps sample sizes by outcome; and writes `lottery_application_choices.tex` and `lottery_admission_scores.tex` plus their wrappers under `tables/results/`. The score table has individual scores in Panel A and weighted application scores in Panel B. As in the final October 28 afternoon manuscript, the cutoff panel is preserved only as commented rows. It is not an active Panel C. The handoff records remaining author-edited caption/note issues, which the adapter preserves for exact comparison.

Run it after regenerating either source table:

```sh
python3 merge_admission_tables.py '/path/to/Initial submission'
```

The mechanisms section inputs the separate assignment, application-choices, and admission-score wrappers. The numerical source tables remain available for regeneration and comparison. This Python module formats existing results; it does not estimate the score, list, or eligibility outcomes. Their current core generators, and those for the non-stringency graduation/failure rows, were not located in this checkout and must be reconciled with the coauthor's latest code.
