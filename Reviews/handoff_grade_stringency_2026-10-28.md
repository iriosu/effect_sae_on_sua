# Handoff: grade stringency for Table V, Panel C

October 28, 2026. This handoff describes the implemented analysis and the work needed to incorporate it into the final code. It concerns the submission manuscript in `Effect of Centralized School Choice on College Admissions Outcomes/Initial submission`, which is a separate project from this repository's older `documents/draft/`.

## Current status and entry points

The historical index, lottery estimates, coverage checks, sensitivities, and manuscript export have run successfully. The manuscript includes the stringency row, its separate sample counts, generated numerical macros, and Appendix D.3 (`app:grade-stringency`). The table and appendix were compiled and visually checked. The current module is a standalone addition; it has not been folded into the collaborators' final mechanisms notebook.

Start with [the module README](../code/finalized_design_v1/section6/README.md). Compare an integrated implementation against the [dated reference run](../code/finalized_design_v1/section6/reference/2026-10-28_results.md), which records full-precision estimates, coverage, source and code hashes, and package versions directly from the saved outputs. The reference is documentation, not an estimation input.

| File in `code/finalized_design_v1/section6/` | Responsibility |
| --- | --- |
| `run_grade_stringency.R` | Orchestrates input checks, calibration eligibility, fitting, lottery attachment, regressions, sensitivities, diagnostics, and optional manuscript publication. Run with `Rscript`; it is not a function to `source()` inside a notebook. |
| `prepare_grade_stringency.R` | Cleans and matches historical GPA and SIMCE; exports candidate student records, school ownership history, and merge audits. It does not enforce final school eligibility or fit the index. |
| `fit_grade_stringency.R` | Defines `fit_grade_stringency(data, shrink = TRUE)` and the deterministic HC0 covariance verification. Returns `schools` and `metadata`; does not choose the calibration sample or write files. |
| `export_grade_stringency.R` | Defines `export_grade_stringency(manuscript_root, result)`. Adds or replaces only the marked stringency outcome and sample-count blocks in the existing Panel C table. |

## Reproduce the analysis

From the repository root, with the shared input files downloaded locally:

```sh
Rscript --vanilla code/finalized_design_v1/section6/run_grade_stringency.R
```

This computes the outputs without changing the manuscript. To publish, supply the directory containing `tables/`, replacing the example path:

```sh
Rscript --vanilla code/finalized_design_v1/section6/run_grade_stringency.R "--manuscript=/path/to/Initial submission"
```

For another Dropbox location, add `"--data-dir=/path/to/Effect SAE on SUA/data"`. The `--panel`, `--schools`, `--cache-dir`, and `--output-dir` options override individual paths; all take `--name=value`. Defaults and quoting are listed in the module README. Keep `--cache-dir` in the private data tree because it contains student identifiers. Allow memory for loading the annual performance panel in full; its compressed file size understates memory use.

The verified run used R 4.5.1, `fixest` 0.13.2, and `data.table` 1.18.2.1; `splines` is supplied with R. Section V's README records `fixest` 0.14.2. Do not describe the environments as identical: compare results against the reference when adopting the final environment. An OpenMP warning on a single-threaded R build affects parallelism, not the intended estimator.

Preparation uses version checks for the two historical files' byte sizes, and the runner checks the current lottery and OD-catalogue counts. The exact versions are recorded in the reference. If upstream data change, review these guards and document the new input vintage rather than deleting the checks to make the script run. The runner records MD5 hashes of all inputs; it does not enforce every input hash against the dated reference. Compare those hashes before claiming exact replication.

## Inputs and identifiers

Paths below are relative to `Effect SAE on SUA/data/`. These are required existing data artifacts. In particular, `Section5_IV.Rmd` **reads**, rather than builds, the two Section V RDS inputs. Their data dictionary is in [Section V's README](../code/finalized_design_v1/section5/README.md); this module does not rebuild the underlying lottery design.

| Input | Fields used |
| --- | --- |
| `panel_performance_2002_2023.rds` | `MRUN`, `AGNO`, `RBD`, `COD_ENSE`, `COD_GRADO`, `COD_DEPE`, `PROM_GRAL`, `SIT_FIN_R`. Preparation uppercases column names. |
| `panel_simce_2m.rds` | `mrun`, `agno`, `rbd`, `idalumno`, `gen_alu`, `ptje_mate2m_alu`, `ptje_lect2m_alu`. These names are case-sensitive. |
| `panel_ee_2004_2025_homogenized.rds` | `year`, `rbd`, `cod_depe`; supplements historical ownership records through 2025. |
| `finalized_design_v1/section5/section5_panel.rds` | `MRUN`, `LOTTERY_SAMPLE`, `ENTRY_RBD`, `YEAR`, `OFFER`, `D_OD`, `CHANCE_GROUP`, `ENTRY_SCHOOL_TYPE`, `GPA8_Z`, `ES_MUJER`, `PRIORITARIO`, `ALTO`, `ORIGIN_OD`. |
| `finalized_design_v1/section5/table_a3_panel.rds` | `RBD`, `IS_OD`. Used to label over-demanded schools for score-support diagnostics. |

Preserve the shared `MRUN` and `RBD` identifier conventions across files. Historical records match on student, calendar year, and school; lottery students receive the index by `ENTRY_RBD`, their April entry-school identifier. `YEAR` in the lottery panel is the application year, not the historical calibration year. Do not attach the index using the offered school, eighth-grade school, or graduation school.

The reference input manifest contains filenames, byte sizes, and MD5s. The original run read temporary downloads because local Dropbox copies were online-only. Those temporary paths are not a collaborator dependency; obtain the matching files from the shared data folder and use the default paths or overrides.

## Historical calibration to preserve

1. Use 2014–2016 regular secondary grade 10: `COD_GRADO == 2`, with `COD_ENSE` in `310, 410, 510, 610, 710, 810, 910`. Parse decimal-comma GPA values and trim final-status codes. Keep both passing (`P`) and failing (`R`) students with GPA in [1, 7]. Do not impose graduation or promotion as an additional condition.
2. Remove exact substantive duplicates and invalid identifiers. Assess conflicting performance records after restricting to valid graded P/R records; an ungraded transfer record does not displace a unique valid annual grade. Drop ambiguous student-years instead of selecting an arbitrary record. Apply the corresponding uniqueness checks to SIMCE.
3. Match GPA and SIMCE exactly on `MRUN`, `AGNO`, and `RBD`. Require finite positive scores in both subjects and known sex. SIMCE sex codes `2`/`Mujeres` map to female = 1 and `1`/`Hombres` to 0. School mismatches and missing scores are audited separately.
4. Retain publicly funded observations (`COD_DEPE` in `1, 2, 3, 5, 6`) and exclude any school recorded as fee-paying private (`4`) during 2012–2025 in either the performance history or directory. Require at least 20 matched student-year records across at least two historical cohorts per school. In the reference calibration there are no repeated students across years, so this also counts distinct students.
5. Fit on **all qualifying publicly funded schools**, not just OD schools, the historical table's catalogue, or the lottery destinations. Assert no overlap of historical students and the lottery sample. The preparation's `calibration_candidates.rds` precedes these final eligibility restrictions and must not be passed directly to the fitter as the final sample.

The regression is

```text
GPA_ist = year_t + f_t(math_it, reading_it) + gamma * female_i + school_s + error_ist.
```

Within the final calibration sample, standardize each subject separately by historical year using the sample mean and SD. Use `splines::ns(z, df = 4, intercept = FALSE)` for each subject, with separate coefficients by year, plus a year-specific product of standardized mathematics and reading scores. The product is a single regressor per year, not another spline. Year effects and a common female coefficient are also included. These are contemporaneous test scores, so this is a grading-environment proxy rather than a conventional learning value-added model using prior scores.

For school effects `theta_s`, define `a_s = theta_s - mean_school(theta)`, with **equal school weights**. Let `v_s` be the HC0 variance of this centered effect, including estimation of the common coefficients. The fitter computes it without building a dense observation-by-school matrix. With `J` schools:

```text
tau2    = max((sum(a_s^2) - sum(v_s)) / (J - 1), 0)
lambda_s = tau2 / (tau2 + v_s)
S_s      = -(lambda_s * a_s - mean_school(lambda * a))
```

The zero-variance case is handled in the fitter. Preserve recentering after shrinkage. Larger `S_s` means stricter grading, in GPA points; do not standardize it to SD or multiply it by 100. The unshrunk sensitivity uses `-a_s`. The scalar shrinkage weights do not use cross-school covariances, and uncertainty in the estimated prior variance and weights is not propagated.

## Lottery sample and inference

Start from `section5_panel.rds`, retain `LOTTERY_SAMPLE == TRUE`, and require complete baseline controls `GPA8_Z`, `ES_MUJER`, `PRIORITARIO`, `ALTO`, and `ORIGIN_OD`. Join the one-row-per-school lookup by `ENTRY_RBD`. Leave absent indices missing; zero is a meaningful centered index value, not a missing-value code.

The `fixest` attendance specification is:

```r
GRADE_STRINGENCY ~ GPA8_Z + ES_MUJER + PRIORITARIO + ALTO + ORIGIN_OD +
  i(YEAR, ref = 2016) | CHANCE_GROUP | D_OD ~ OFFER
```

Estimate on observations with a nonmissing index, using `vcov = "hetero"`, `ssc = ssc(K.adj = FALSE)`, and `fixef.rm = "none"`. Report the `fit_D_OD` coefficient, normal-reference two-sided p-values and confidence intervals, and the no-offer mean **within that same estimation sample**. The row's N is its own observed-index sample. Keep the original three Panel C outcomes and their existing common-sample N unchanged unless the final code explicitly redefines that analysis.

Also regress `HAS_STRINGENCY` on `OFFER`, the same controls, year effects, and chance-group effects in the full controls-complete lottery sample. This is an OLS availability diagnostic using `fixest`'s default small-sample correction and t-reference p-values. It does not use the IV's `K.adj = FALSE` convention. Its coefficient is a proportion; multiply by 100 only when reporting percentage points.

## Sensitivities and interpretation

- Unshrunk school effects, keeping the main coverage.
- Leave each historical cohort out in turn. Start with the baseline-eligible schools and keep schools with at least two remaining records; do **not** reapply the baseline 20-record/two-cohort threshold to these fits. Refit all score transformations and shrinkage, then compare effects on lottery students covered by the pooled and all three leave-out indices.
- Restrict calibration to year-specific 5-by-5 mathematics/reading quantile cells with at least 20 observations in both OD and other schools, then reapply the main school-size/cohort rule. This is a coarse overlap check. Every cell passed in the reference run, so the unchanged result is not independent robustness evidence or proof of overlap for each individual school.

The positive coefficient describes exposure to a stricter **historical grading environment**. It corresponds to a lower adjusted historical school component of GPA at comparable measured achievement. It is not an estimate of how much the lottery students' own GPA falls because of grading standards, and it does not identify the share of the failure effect due to stringency. Overall GPA covers more subjects than SIMCE, and applying historical grade-10 practices to later grade-9 cohorts requires persistence across grades and time.

Index coverage responds to the offer. Conditioning on a measured index may therefore compromise the full sample's randomized comparison; do not label it an unconditional full-sample LATE. Report the separate coverage and availability results. Lottery-stage standard errors condition on the historical index and do not incorporate its estimation or shrinkage uncertainty. These limitations remain documented in Appendix D.3.

## Outputs and integration into the final code

By default, private files go to `data/finalized_design_v1/section6/grade_stringency/` in the shared data tree. These include the calibration candidates, ownership histories, fitted school indices and metadata, each sensitivity fit, and `lottery_stringency_link.rds`. That linked file contains `MRUN`, `YEAR`, `ENTRY_RBD`, `HAS_STRINGENCY`, the baseline/unshrunk indices, and the sensitivity indices. It is an auxiliary link for the controls-complete lottery sample, not a replacement for the full Section V panel.

Aggregate outputs go to the module's `output/grade_stringency/`. The key files are `stringency_estimates.csv`, `availability_effect.csv`, `calibration_selection.csv`, `merge_audit.csv`, `coverage_by_destination_type.csv`, `lottery_coverage.csv`, `cohort_stability.csv`, `school_stringency.csv`, the score-support diagnostics, both manifests, `session_info.txt`, and `grade_stringency_facts.tex`. The root ignore rules exclude CSV and RDS files. The dated Markdown reference preserves the central diagnostics and provenance in a Git-trackable form; retain the live outputs with the analysis delivery and keep student-level files in the private data tree.

The smallest integration is to invoke the runner from the final workflow after upstream inputs are ready. Ensure the five inputs and the required packages are represented in the final workflow's common data manifest and environment configuration. If incorporating its steps directly, retain the preparation/fitting helpers and transplant the runner's sample selection, joins, IV, availability regression, and diagnostics together. Sourcing the helpers is supported; sourcing the command-line runner inside an R Markdown chunk is not. For an already regenerated school fit, the attachment is:

```r
school_index <- readRDS(file.path(cache_dir, "grade_stringency_fit.rds"))$schools
stopifnot(!anyDuplicated(school_index$RBD))
panel[school_index, on = .(ENTRY_RBD = RBD),
      GRADE_STRINGENCY := i.GRADE_STRINGENCY]
```

Here `panel` must be a `data.table` with the controls-complete lottery sample, and the fit must correspond to the intended source/code versions. Preparation caches are reusable only when the recorded two raw-input hashes and preparation-code hash match; later eligibility and fitting are recomputed on each run.

The original generator of the remaining Panel C rows was not found in the synced repository when this module was implemented. The exporter therefore requires the existing `tables/lottery_graduation_part2.tex` and its current Panel C/D headings and row anchors. **Run it after the other table generator**, or incorporate its formatted row and separate sample count directly in that generator. It does not rebuild class size, students per teacher, distance, or Panel D. It writes inline rows within marked comment blocks and is idempotent; structural checks deliberately stop if the surrounding layout changes.

The exporter accepts `mean`, `est`, `se`, `p`, `n`, and `n_nooffer` from the main estimate. The runner also copies `grade_stringency_facts.tex` into the manuscript's `tables/`. Keep `\input{tables/grade_stringency_facts.tex}` in the mechanisms section, the `app:grade-stringency` appendix label, the separate-N table note, and the positive-means-stricter convention. Regenerate numerical macros from the output instead of typing results into the prose. Rebuild the manuscript and check the continued Table V page after any table integration.

## Acceptance checks for the integrated version

1. Input hashes match the dated reference, or a documented new input vintage explains their changes. Match the R environment or verify parity under the final package versions.
2. Calibration selection, school count, no-overlap checks, lottery coverage, and destination-type missingness match the reference. Counts should match exactly; investigate numerical estimate differences exceeding the tolerance stated there.
3. The efficient centered-FE HC0 calculation passes `verify_grade_stringency_covariance()`, which compares it with full-dummy OLS on a deterministic unbalanced example. This checks algebra, not empirical identification.
4. The baseline, unshrunk, and leave-out effects and the availability regression reproduce. Preserve units, sign, inference conventions, and the row-specific N.
5. Regenerating Panel C twice gives one stringency outcome and one stringency N row, with all other table content preserved. The manuscript macros and appendix remain consistent with the exported results.

No new statistical specification is proposed in this handoff. The outstanding work is to incorporate the implemented module into the collaborators' final workflow and verify that integration against the recorded reference.
