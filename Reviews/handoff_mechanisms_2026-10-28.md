# October 28, 2026: mechanisms tables and code integration

This handoff records Ignacio's October 28 changes to Section VI and Appendix D of the submission manuscript and delivers the new analysis/export code to the **GitHub code repository**. Overleaf sync and GitHub sync are separate. The manuscript contains newer tables than the last committed core code. Incorporate the implementations and output contracts below into the collaborators' current core workflow; do not overwrite newer unpublished work with the older notebook in this checkout.

## Versions and scope

| Component | Version checked |
| --- | --- |
| GitHub repository and working branch | `iriosu/effect_sae_on_sua`, `finalized-design-v1` |
| Core-code starting commit | `58ca4c8` (October 22): Section V notebook and its outputs |
| Other fetched GitHub branches | `origin/main` = `e935f36` (July 18); `origin/updated-spine` = `f0878ac` (September 2). No newer published mechanisms generator was found. This cannot establish what exists in a collaborator's unpushed checkout. |
| Overleaf project | `69a2123ea80b773202356077`, separate repository, `main` |
| Start-of-day manuscript baseline | `29e42248ad5ae5a56034da18a23584a8a9e11323`, the last commit before October 28, 00:00 America/Indiana/Indianapolis |
| Manuscript snapshot used here | `25af621d2e20ae0004fc6cc186e9cdb1314eebc2`, October 28, 14:18:15 local time; matched fetched Overleaf `origin/main` |

The [frozen manuscript reference](../code/finalized_design_v1/section6/reference/manuscript_2026-10-28/) contains all 15 files changed over that interval, five unchanged dependency/reference tables, a file-hash manifest, and the complete day's source diff. These are reference copies, **not a second live manuscript or numerical inputs to the estimators**. Paths below beginning with `tables/` or `sections/` are relative to the submission manuscript's `Initial submission/` directory. Prefer labels and filenames over table numbers when integrating.

Two new estimation implementations are delivered: historical school grade stringency and direct assignment effects by admission track. The application-list, individual-score, weighted-score, and reserved-seat estimates already existed in the starting manuscript; their reorganization is not a new estimation exercise. The graduation/failure exhibits were added to the manuscript today, but their underlying generator was not found in the checked code repository. The BEA back-of-the-envelope comparison is arithmetic, not an additional regression or mediation estimate.

## Final table map to reproduce

| Current table / label | Final contents | Manuscript output files | Code status |
| --- | --- | --- | --- |
| V, `tab: lottery graduation` | Top row: graduation. A: reasons accompanying nongraduation. B: failure classifications. Continued page C: school characteristics and new stringency row. D: ninth-grade outcomes. | `tables/lottery_graduation_part1.tex`, `tables/lottery_graduation_part2.tex`; both wrappers in `sections/6_mechanisms.tex` | New stringency module supplied; remaining rows require the coauthor's generator. |
| VI, `tab: lottery admission tracks` | Total assignment, then regular, BEA, PACE, and gender-quota routes. **Assignment only**, no application or cutoff panels. | `tables/lottery_admission_tracks.tex`, `tables/results/lottery_admission_tracks.tex` | `section6/export_admission_tracks.R` supplied. |
| VII, `tab: lottery application choices` | Four application-list characteristics, formerly Panel A of `lottery_application_scores.tex`. | `tables/lottery_application_choices.tex`, `tables/results/lottery_application_choices.tex` | `section6/merge_admission_tables.py` supplied; numerical source generator still needed. |
| VIII, `tab: lottery scores` | A: individual Math-Verbal, NEM, Ranking. B: application score and its weighted components at listed programs. **Only A and B are active.** | `tables/lottery_admission_scores.tex`, `tables/results/lottery_admission_scores.tex` | Same assembly script; numerical source generators still needed. |
| IX, `tab:reserved_seats` | A: PACE grade rule first, school condition second, then both. B: BEA grade rule. | `tables/pace_bea_access.tex`; wrapper in `sections/6_mechanisms.tex` | Existing estimates unchanged today; row order changed. Current point-classification generator still needed. |
| Appendix D, `tab: promotion rules` | Regular/adult promotion rules by school year. | `tables/appendix_promotion_rules.tex`; wrapper in `sections/9_appendix_mechanisms.tex` | Policy-reference table, not an estimated outcome. |
| Appendix D, `tab: failing by year` | Failed in each of the first four school years and in any of them. | `tables/appendix_failing_by_year.tex`; wrapper in `sections/9_appendix_mechanisms.tex` | New manuscript exhibit; generator not located. |

Table VIII's old cutoff panel is commented out in the final afternoon manuscript, and its discussion is commented out too. Its two outcomes remain in the preserved numerical source `lottery_application_scores.tex`. During handoff preparation, the assembly script was updated to preserve that final choice instead of reintroducing the panel. The earlier morning arrangement that merged assignment, lists, and cutoffs into one table is superseded. Do not regenerate `lottery_admission_selection.tex` or reinsert the old combined `tab: lottery application scores` exhibit.

The revised wrappers and bodies retain the paper's no-offer mean / 2SLS / standard-error presentation, horizon columns, stars, and relevant sample counts. Tables VII and VIII retain different estimation populations from Table VI; moving their panels must not change those populations.

## New analysis 1: historical grading stringency

Use the detailed [stringency handoff](handoff_grade_stringency_2026-10-28.md), [module README](../code/finalized_design_v1/section6/README.md), and [dated numerical reference](../code/finalized_design_v1/section6/reference/2026-10-28_results.md). This delivery includes `run_grade_stringency.R`, `prepare_grade_stringency.R`, `fit_grade_stringency.R`, and `export_grade_stringency.R`.

The index uses 2014–2016 tenth-grade GPA and contemporaneous SIMCE mathematics/reading, before SAE secondary-school entry. It keeps passing and failing students, matches student/year/school exactly, restricts to stable publicly funded schools, and requires at least 20 matched records across two cohorts. The calibration has **455,436 students, 2,399 schools, and 15,172 failing students**, with no overlap with lottery students.

Regress GPA on school effects, historical-year effects, sex, year-specific four-degree-of-freedom natural splines in each standardized SIMCE score, and their year-specific product. Center school effects with equal school weights, shrink using their centered HC0 variances, recenter, and reverse the sign. Larger values mean stricter historical grading, **in GPA points, not SD or percentage points**. Attach the index to the actual April entry school (`ENTRY_RBD`), not the offered school.

The attendance IV estimate is **+0.1200897725** (SE **0.0020768369**), from a no-offer mean of **0.0033739662**. Its own sample is **163,470**, including **103,483 without an offer**. Keep the first three Panel C rows' separate sample of 171,223 / 109,433. Missing indices must remain missing. The offer raises index availability by **2.8754 pp** (SE **0.1518 pp**) in the full 175,869-person sample. Preserve the availability qualification and the fact that lottery-stage SEs treat the estimated index as fixed.

The module includes unshrunk effects, leave-one-historical-cohort-out fits, a coarse math/reading support check, and an independent centered-FE covariance verification. Unshrunk effect: 0.1218443; leave-out effects: 0.1190632–0.1227498. The support check retained all cells and is not independent robustness evidence. Detailed input hashes and package versions are in the dated reference.

It also generates `tables/grade_stringency_facts.tex`, including all `GS...` numerical macros used in the prose and new appendix subsection `app:grade-stringency`. Keep the section's `\input{tables/grade_stringency_facts.tex}`. The exporter adds only its marked row and sample-count blocks to an existing Panel C/D body. Run it **after** the generator of the other Table V rows, or incorporate its formatting into that generator.

## New analysis 2: assignment by admission track

The [direct-track exporter](../code/finalized_design_v1/section6/export_admission_tracks.R) estimates indicators for assignment through each route. This is **not** the older ordered accounting in `lottery_steps_accounting.tex`. That file's track components sum to the admission-step effect (−1.19 pp on time, −0.64 ever), not the total assignment effect requested for the new top row (−2.23 / −1.04 pp). Do not rescale or reuse those accounting components.

### Sample, assignment events, and estimator

- Start with `finalized_design_v1/section5/section5_panel.rds`: 304,547 rows and 38 columns. Keep `LOTTERY_SAMPLE == TRUE` and complete `GPA8_Z`, `ES_MUJER`, `PRIORITARIO`, `ALTO`, `ORIGIN_OD`. The sample has **175,869 unique students**, **112,796 without an offer**. Do not condition on graduation, exam taking, application, observed scores, or eligibility.
- Recover selected routes from the harmonized 2018–2025 `pref_seleccion_reg`, `_bea`, `_pace`, and `_genero` fields; positive positions identify selection status 24. The upstream file incorporates the earlier separate BEA/PACE files. For 2026, use `ESTADO_PREF == 24` and `TIPO_PREF` in the raw selection file. Do not infer selection from a BEA/PACE eligibility flag.
- Retain each student's **first recorded assignment**, ordered by process. Classify it into exactly one route. On time ends at admission process `YEAR + 5`; ever ends at 2026. A later assignment through another route does not reclassify the first assignment.
- In each horizon, the four binary indicators sum exactly to `ASSIGNED_OT` or `ASSIGNED_EVER`. The recorded audit has zero total mismatches for all 175,869 students at both horizons and zero multiple selected routes within a student/process.
- Instrument `D_OD` with `OFFER`, include the five baseline controls above, `i(YEAR, ref = 2016)`, and `CHANCE_GROUP` fixed effects. Use `fixest`, `vcov = "hetero"`, `ssc(K.adj = FALSE)`, `fixef.rm = "none"`, and normal-reference p-values. Multiply binary-outcome means, estimates, and SEs by 100 for presentation.

| Outcome | On-time no-offer mean (%) | On-time IV (pp) | Ever no-offer mean (%) | Ever IV (pp) |
| --- | ---: | ---: | ---: | ---: |
| Total assignment | 30.10 | −2.23 | 38.35 | −1.04 |
| Regular | 28.10 | −1.01 | 36.18 | +0.20 |
| BEA | 0.54 | −0.30 | 0.55 | −0.30 |
| PACE | 1.22 | −0.99 | 1.31 | −1.03 |
| Gender quota | 0.24 | +0.08 | 0.32 | +0.09 |

The [aggregate output folder](../code/finalized_design_v1/section6/output/admission_tracks/) includes full-precision estimates/SEs/p-values, route audits, horizon reconciliation, additivity checks, input hashes, and environment. Coefficients add before rounding: maximum observed error is below `1e-12`. Rounded on-time route rows sum to −2.22; retain the independently rounded total −2.23. Gender quotas start in 2024.

### Dependencies and execution

The exporter reads the shared Section V panel plus these ignored, private local inputs beneath `code/analysis_for_adversarial_report_output/input/f08/`:

| File | Bytes | MD5 |
| --- | ---: | --- |
| `data_students_2004_2025.rds` | 1,149,992,822 | `0b1f751400d77cd21930ab508073f983` |
| `operational_2026/C_POSTULANTES_SELECCION_PAES_2026_PUB_MRUN.csv` | 75,324,027 | `74df0ecd710bc99502512d12ead6ded3` |
| Shared `section5_panel.rds` | 7,726,071 | `a6cbc82cd7fe68b88bc2d55f6e3f359d` |

The shared data tree also has a file named `data_students_2004_2025.rds`; check its hash before substituting it. The 2026 file is an additional dependency, not part of a Git clone. Obtain matching inputs through the shared data workflow; do not commit student records.

With the reference layout, run `Rscript --vanilla code/finalized_design_v1/section6/export_admission_tracks.R`. It uses the tracked memory-bounded `code/f08_extract_rds_columns.py` (Python with NumPy) instead of loading the roughly 28 GB uncompressed upstream frame into R. The projection's zero-based indices are 1 year, 2 mrun, 327 regular, 328 BEA, 329 PACE, 330 gender, 342 assigned; names are checked against serialized metadata.

Optional positional arguments are `[existing-projection-directory] [manuscript-directory]`. This first delivery uses the original author's home/Dropbox layout and default manuscript location. Before wiring it into another machine's core runner, configure those input/output locations or provide both arguments; do not run its default publication path blindly. The projection is a private temporary artifact. The saved track run records R 4.6.0, `fixest` 0.14.2, `data.table` 1.18.4, and `jsonlite` 2.0.0. The stringency reference instead records R 4.5.1 / `fixest` 0.13.2; do not conflate these environments. Verify numerical parity when adopting one final environment.

## Table assembly and analyses that must come from the core code

`merge_admission_tables.py` is an **export adapter**, not an estimator. Run it after the core code has generated these two numerical sources:

1. `tables/lottery_scores_horizons.tex`: individual scores, preserving Math-Verbal availability and the common NEM/Ranking graduate sample.
2. `tables/lottery_application_scores.tex`: the original three-panel application/list/score/cutoff table. Preserve it as a numerical source even though it is no longer directly included in the paper.

The script extracts old application Panel A into VII, combines individual scores with old application Panel B in VIII, adds the correct applicant Ns to weighted-score rows, and retains old Panel C only as comments. It copies estimates, SEs, stars, and means without re-estimating. Run:

```sh
python3 code/finalized_design_v1/section6/merge_admission_tables.py '/path/to/Initial submission'
```

During this handoff, its two wrappers and two bodies were aligned with the final author-edited files and checked byte for byte in a scratch directory. The direct-track wrapper was likewise aligned with the final caption/markup. No estimation specification or saved coefficient was changed in these presentation updates.

### Samples and numerical anchors

| Exhibit | Full / no-offer N | Values to preserve |
| --- | --- | --- |
| VII application lists and VIII.B weighted scores | On time 67,132 / 43,815; ever 79,522 / 51,607 | First regular-track list within the horizon; no new all-student restriction. |
| VII list length | Same applicant samples | Means 7.54 / 7.56; effects −0.08 / −0.05. |
| VII mean cutoff percentile | Same | Means 65.58 / 64.91; effects −0.05 / −0.26. |
| VII highest cutoff percentile | Same | Means 86.34 / 85.93; effects −0.03 / −0.09. |
| VII NEM + Ranking weight (%) | Same | Means 43.33 / 43.27; effects −0.12 / −0.11 pp. None of the eight list effects is significant. |
| VIII.A Math-Verbal | 108,292 on time; 117,718 ever | Effects +0.032 / +0.033 SD. |
| VIII.A NEM and Ranking | Both 149,595 on time; both 161,310 ever | NEM −0.163 / −0.164 SD; Ranking −0.208 / −0.206 SD. 137,487 ever scores are official; remaining scores reconstructed. |
| VIII.B total application score | Applicant samples above | −0.113 / −0.111 SD; NEM part −0.037 / −0.036; Ranking −0.122 / −0.118; exams +0.046 / +0.043. |
| Commented cutoff panel | Same applicant samples | Missed listed cutoffs +2.56 / +2.16 pp; reached a listed cutoff −2.64 / −2.04 pp. Preserve the source; do not print it as an active panel. |
| IX reserved-seat conditions | 175,869 / 112,796 at both horizons | PACE grade rule: means 25.50 / 26.11, effects −9.00 / −9.03; PACE school condition: 26.30 / 28.03, −14.63 / −14.55; both: 8.16 / 8.31, −5.83 / −5.81; BEA grade rule: 10.47 / 10.67, −4.86 / −4.99. |

Weighted application scores must be reconstructed at **all listed programs**, not just the records where DEMRE publishes a score. Preserve program-specific weights, the treatment of required tests, and the original common centering/scaling of additive components. Do not independently standardize each component and thereby break coefficient additivity. The existing source's numerical generator was not found in the checked branch, so this handoff cannot certify its reconstruction from raw inputs.

Do not use `Section5_IV.Rmd`'s older skeleton `lottery_scores.tex` or the October 19 expanded-score export as substitutes for the current two-horizon source. Their names, samples, and vintages differ. Existing older README/HANDOFF entries about the score table are historical and are superseded by this table map for Section VI.

## Graduation and failure exhibits added today

The new Table V and appendix replace the earlier first-choice offer/path/attendance discussion with the attendance-IV design. The removed appendix sections were First-Choice Offer Comparisons; Academic Performance, Standing, and Days Attended; Records Supporting Academic Performance and Standing; and Failure and School Paths behind Delayed Graduation. Their old source files remain historical artifacts; removal from the active manuscript does not authorize deleting those analyses.

For Table V.A/B, the denominator remains the full controls-complete lottery population. Outcomes combine nongraduation within the horizon with the stated event; they are **not regressions conditioned on nongraduation**. Failure includes adult secondary education. Withdrawal includes a year enrolled nowhere. A student can appear in more than one event row, so these effects are not an additive partition.

| Row | On-time mean / IV (pp) | Ever mean / IV (pp) |
| --- | --- | --- |
| Graduation total | 85.67 / −2.72 | 91.84 / −0.86 |
| Failed a year and did not graduate | 9.25 / +3.24 | 4.44 / +1.02 |
| Withdrew and did not graduate | 7.44 / −0.07 | 6.58 / +0.40 |
| Other nongraduate | 0.39 / 0.00 | 0.10 / +0.02 |
| Failure classified as Grades | 7.28 / +3.14 | 3.50 / +1.00 |
| Attendance alone | 0.10 / +0.01 | 0.06 / −0.01 |
| Attendance, grades unknown | 2.60 / +0.53 | 1.46 / +0.30 |

The table note classifies a failed year as Grades if attendance met the promotion minimum **or** GPA was below 4.0; Attendance alone if attendance fell short and GPA was at least 5.0 (5.5 in grades 11–12 through 2019); Attendance, grades unknown otherwise. Implement from the underlying policy/record logic and preserve unknowns; the prose alone is not a sufficient data dictionary. The promotion-rule appendix records the regular/adult and pre/post-2020 distinctions, including discretionary promotion and the 2020 attendance exception.

Panel C's non-stringency rows: class size **39.08 / +3.76**; students per teacher **22.79 / +3.88**; distance **8.13 / −0.35 km**. The common N is **171,223**, with **109,433 no-offer students**. Use the April entry school and joint measure availability; straight-line distance from the application address is capped at its 99th percentile, **193 km**. Stringency has its own N as specified above.

Panel D uses **164,196** students graded in ninth grade at their entry school (**104,696 no-offer**). Preserve: failed ninth grade **4.36 / +2.98 pp**; end-of-year percentile **53.33 / −11.61**; percentile change **−1.76 / −4.86**; bottom-fifth share **16.83 / +11.93 pp**. The implied entry-position effect is −6.75 percentile points. The prose also reports that 93.7% of ninth-grade failures finish in the bottom fifth; have the core workflow generate that descriptive statistic and its exact sample.

Appendix `tab: failing by year` uses all **175,869** students, graduates or not, and includes regular/adult failure. Year 1–4 effects are **+2.84, +1.32, +0.84, +0.24 pp**, with means **4.39, 3.48, 3.81, 1.99%**. Any-year failure is **11.03% / +3.93 pp**. These are overlapping annual events, not additive contributions. The **2.84** first-year effect and Panel D's **2.98** ninth-grade effect use different samples/outcomes; do not make them match artificially.

## Reserved seats and today's BEA clarification

Table IX's estimates were not re-estimated today. The PACE grade row moved above the school-condition row. The main text now leads with grade-rule declines, **35.3%** for PACE and **46.4%** for BEA relative to their on-time no-offer means.

The grade indicator is not full administrative eligibility. PACE's grade rule is evaluated even at non-PACE schools; its joint row additionally requires the school condition. BEA uses MINEDUC's top-10%-by-GPA record. Noncompletion within the horizon and undetermined conditions count as zero in the current table. Keep this explicit convention separate from the October 19 interval/uncertainty-based PACE analysis; that earlier runner is not established as the generator of these current point estimates.

The added footnote distinguishes eligibility from allocation of limited reserved seats and explains that eligible students assigned regularly count under Regular. Both IX and VI use the same full sample; an applicant-only denominator does **not** explain their different percentage-point effects. The illustration is `0.464 * 0.54 = 0.25056` pp (about 0.25), compared with the reported BEA assignment effect of about −0.30 pp. Using the unrounded ratio `4.86/10.47` gives 0.250659 pp. Neither calculation estimates a mediation share or a conditional conversion effect. A 0.30-point decline from a roughly 0.54% baseline is itself about a 56% relative decline.

## Other manuscript changes and editorial reconciliation

- The lower-assignment introduction now reports total and route-specific effects, describes regular/BEA/PACE eligibility and selection, and introduces three channels. The active subsection order is **Preferences → Admission Scores → Eligibility for Reserved Seats**. The introduction's enumerated order currently differs; reconcile prose rather than changing estimation order.
- Appendix D now has promotion rules, annual failure, the new stringency construction and caveats, followed by the retained annual PACE rules and PACE/BEA construction/validation. Existing PACE/BEA validation counts were not newly recomputed for this handoff.
- `sample.bib` gained `betts_2003`, `Krueger1999`, `AngristLavy1999`, `CordesRickSchwartz2022`, `MurphyWeinhardt2020`, `promotionDecree112`, `promotionDecree83`, `promotionDecree67`, `promotionDecree2169`, and `promotionCriteria2020`.
- The afternoon manuscript still contains two active versions of the individual-score paragraph and two active versions of the weighted-score paragraph. The snapshot preserves these edits for the authors to reconcile; the code should produce each table once.
- Table VIII's caption still says “and Cutoff Attainment” despite its removed panel, and its note has “Panels B” where only B remains. The adapter deliberately matches the current author-edited reference, including these outstanding wording issues; update both the wrapper generator and manuscript when deciding final wording.
- Table VII's shortened note no longer spells out the applicant/first-list restriction. Preserve that restriction in code and restore the note if needed; the narrative edit does not authorize a sample change.
- Check Table V.B's prose against the classifications: the Grades event is broader than GPA below 4.0 alone, and “Attendance, grades unknown” does not establish a specific failed-subject mechanism. Likewise, “2.84 of these points come from the first year” is not an additive decomposition of overlapping annual failures.
- The new footnote refers jointly to BEA and PACE. When editing the institutional explanation, retain the distinction between the regular/BEA weighted score and PACE's PPP; the numerical benchmark is specifically for BEA.

These are concrete reconciliation items found while recording the changes, not changes to the estimates or a claim that the latest prose has received a new substantive review. The live Overleaf files were not modified while preparing this handoff.

## Integration order and acceptance checks

1. Obtain the coauthor's latest unpushed core code and record its commit/input vintage before merging. Compare against the frozen manuscript, not an older draft under `documents/draft/`.
2. Regenerate the Section V panel and confirm its hash or document intended changes; verify the unchanged 175,869 / 112,796 baseline counts and attendance specification.
3. Recover/integrate the generators of Table V's non-stringency rows, the annual-failure appendix, the two numerical score/application source tables, and current PACE/BEA point classifications. These are the outstanding raw-data-to-table gaps in this checkout.
4. Integrate the historical-index preparation, fitting, attachment, diagnostics, row-specific N, and macros. Run the stringency exporter after the rest of Table V.
5. Integrate direct route outcomes and 2SLS; require student/process exclusivity, exact total reconciliation, and coefficient/mean additivity before rounding. Preserve the first-assignment convention.
6. Run the application/score adapter after its source estimators. Compare both bodies and wrappers with the reference. Require two active score panels, no restored combined assignment/list table, the PACE grade row first, and correctly separated samples.
7. Compare full-precision stored estimates when available (e.g. `1e-7` absolute tolerance with unchanged data/specification), all counts exactly, and all published cells/stars/SEs. If input vintages differ, explain the numerical changes; do not edit output numbers to match the snapshot.
8. Resolve the explicit prose/caption items above, then compile the **current** manuscript from scratch and inspect Table V's continuation and Tables VI–IX. Preserve labels, avoid duplicated tables, and verify references. A prior PDF/preview is not evidence that the latest afternoon text was compiled.

## Checks completed for this delivery

- Fetched both repositories and recorded the exact code/manuscript revisions. The 15-file day diff and 20-file snapshot are attached with SHA-256 hashes.
- Parsed all delivered Section VI R scripts; checked the Python adapter's execution.
- Regenerated the two application/score bodies and wrappers in a scratch manuscript tree: all four matched the final snapshot byte for byte, with the cutoff panel commented out.
- Ran the independent centered-FE HC0 covariance check: maximum absolute difference `1.387779e-16`, below `1e-9`.
- Re-exported the saved stringency row twice into a scratch copy: exact match, one row and one N block, all surrounding cells preserved.
- Regenerated the direct-track body and wrapper from the stored full-precision coefficients: both matched the manuscript snapshot. Rechecked sample counts, coefficient/mean additivity, and the saved zero-mismatch route/total audits. This checks the delivered formatting and saved results, without rerunning the raw-data estimation.

This packaging pass does not re-estimate every empirical result, certify the unavailable coauthor generators, or rebuild the live manuscript PDF. Its purpose is to deliver the actual new code, preserve the final requested outputs, and make the remaining integration work explicit.
