# Short historical records and first-passed-grade audit — October 19, 2026

## Official-source findings

The [source review](../../sources/ranking/short_history_2026-10-19/source_review.md) records the DEMRE/MINEDUC URLs, relevant provisions, historical applicability, and unresolved operational choices.

- For the study years, fewer than 30 school graduates across the previous three generations triggers pooling with schools similar in region, modality and dependency. One or two cohorts with more than 30 graduates suffice without pooling. Our current code already averages the available historical cohorts; it does not require all three.
- The public provisions reviewed do not supply exact pre-2028 pool assignments. They also do not explicitly settle equality at 30. The diagnostics retain the existing >=30 convention, audit equality separately and distinguish school-wide graduates from context-reference records.
- The MINEDUC September 2025 committee annex provides a more detailed 93-student/commune-to-province-to-region pooling rule **from admission 2028**. It is not applicable to the 2021–2026 sample. The same annex describes context-based scoring through 2027.
- A separate MINEDUC rule, also documented in its 2018 manual, says to use the first passed instance when a grade was passed in different years. Our earlier cache discarded all such multiple records. This was tested separately as a potential loss of students and historical peers. Earliest-year conflicts remain unknown because we lack within-year enrollment dates.

## Size of the short-history problem

Among 15,330 validated students with one/two usable context cohorts and more than 30 records, the accepted context candidate matches 80.82% exactly. They account for 2,941 remaining mismatches (3.06% of all mismatches), but 13.32% of remaining absolute error. Most remaining mismatches therefore occur with all three observed cohorts.

Among complete own histories, 10,144 students have at least one context with fewer than 30 usable records and 15,342 have no usable reference for at least one context. These categories concern the observed extract; they do not establish true absence in DEMRE’s administrative records. A further 48,349 have incomplete own histories.

## Pooling and threshold experiments

All specifications preserve the accepted narrow same-school HHTT convention, the existing score formula and rounding, and the independent NEM floor. The two threshold units are whole-school graduates and school-modality graduates, observed from passed fourth-grade records. Directory region and exact dependency codes refer to the student’s context-exit year. Within each matching group, tests either pool only small schools or all comparable schools. Each historical year is aggregated first, then the existing mean-of-cohort-means and mean-of-cohort-maxima convention is applied. These are declared approximations, not verified official pools.

| Candidate, common observed-score sample | N | Exact | MAE | Resolved | Introduced |
|---|---:|---:|---:|---:|---:|
| modality_all_similar | 1,033,587 | 89.47% | 0.641 | 272 | 13,008 |
| modality_none | 999,528 | 91.01% | 0.384 | 0 | 0 |
| modality_small_only | 1,033,587 | 89.52% | 0.597 | 339 | 12,596 |
| school_all_similar | 1,033,587 | 90.55% | 0.456 | 27 | 1,628 |
| school_none | 1,029,712 | 90.72% | 0.420 | 0 | 0 |
| school_small_only | 1,033,587 | 90.57% | 0.441 | 35 | 1,398 |

The `none` variants do not improve any existing prediction: their apparent aggregate gains reflect dropping difficult observations. All pooling variants introduce more errors than they resolve. Newly available cases must be assessed separately:

| Candidate, newly available observed-score sample | N | Exact | MAE | Resolved | Introduced |
|---|---:|---:|---:|---:|---:|
| modality_all_similar | 18,516 | 35.58% | 28.637 | 0 | 0 |
| school_all_similar | 11,635 | 36.94% | 32.215 | 0 | 0 |
| school_none | 2,230 | 50.72% | 22.074 | 0 | 0 |
| school_small_only | 9,332 | 41.38% | 22.561 | 0 | 0 |
| modality_small_only | 16,154 | 38.51% | 19.874 | 0 | 0 |
| modality_none | 601 | 52.08% | 15.511 | 0 | 0 |

No pooling or threshold variant is adopted. Coverage tables include lost cases and graduates without observed scores; comparison metrics never treat missing predictions as matches.

## First-passed-grade experiment

The implementation selects the earliest year with a unique passed record for each student/grade. A unique later record is not substituted for conflicts in the first year. Only regular youth-secondary teaching codes are included. Complete target histories must be chronological and end in the target graduation year. Reference cohorts always precede the relevant context-exit year; the available raw grade window remains 2010–2025. Historical graduation-GPA reconciliation is retained, and the new grades never use current observed Ranking to choose a record.

Three fixed variants separate recovery of the student’s own history from recovery of historical peers. Previously complete own histories and their independent NEM remain unchanged.

| First-pass candidate, common observed-score sample | N | Exact | MAE | Resolved | Introduced |
|---|---:|---:|---:|---:|---:|
| first_pass_own_only | 1,033,587 | 90.70% | 0.421 | 0 | 0 |
| first_pass_reference_only | 1,033,587 | 90.71% | 0.420 | 173 | 52 |
| first_pass_both | 1,033,587 | 90.71% | 0.420 | 173 | 52 |

| First-pass candidate, newly available observed-score sample | N | Exact | MAE | Resolved | Introduced |
|---|---:|---:|---:|---:|---:|
| first_pass_own_only | 85 | 48.24% | 35.188 | 0 | 0 |
| first_pass_both | 85 | 48.24% | 35.188 | 0 | 0 |

Independent NEM for newly reconstructible observed-score histories matches 56.52% exactly over 92 cases; MAE is 32.359 points. These are recovered-history cases, not a same-sample gain in accuracy over previously complete histories.

**Decision:** the reference-only first-pass variant is a small promising refinement: exact agreement changes from 90.7017% to 90.7134% on the same 1,033,587 cases, resolving 173 errors and introducing 52 (net 121). Keep it as a separate provisional candidate. The own-history recovery is not adopted: low validation accuracy suggests that repeated passed entries in these extracts can represent unresolved record revisions or other cases beyond genuine repeat completions; that explanation is a hypothesis, not established by the test.

The private candidates and original deliveries remain separate. The full-year/PACE breakdown, gained/lost counts and error metrics are in the accompanying CSVs. Exact agreement for the reference-only first-pass variant improves in every admission year, but these are exploratory in-sample checks, not a held-out validation. This refinement does not recover the official school pools or establish full PACE qualification.

## Checks, files and reproduction

- Baseline reconstruction reproduces the accepted narrow HHTT candidate exactly, including its missingness. The local diagnostic scorer separately reproduces that baseline. Checks also cover earliest-year uniqueness, unchanged NEM on previously complete histories, score bounds, unique graduate/variant keys and preservation of prior score-delivery hashes.
- Statistical code is exclusively in `code/analysis_for_adversarial_report.Rmd`. From `code/`, run `f08-score-reconstruction-functions`, `f08-ranking-short-history-setup`, `f08-ranking-short-history-candidates`, `f08-ranking-first-pass-history`, `f08-ranking-first-pass-validation`, then `f08-ranking-short-history-report`. The first-pass history chunk rebuilds its versioned caches; the validation and report chunks may be run against saved outputs.
- Besides the private inputs named in the chunks, pooling uses the local `panel_ee_2004_2025_homogenized.rds` school directory. Edit `sh_directory_path` on another machine. Its current hash is recorded below. No student-level records are committed to Git.
- New private files are `ranking_short_history_contexts_2026-10-19.rds`, `ranking_short_history_candidates_2026-10-19.rds`, `ranking_first_pass_histories_2026-10-19.rds`, `ranking_first_pass_targets_2026-10-19.rds`, `ranking_first_pass_reference_2026-10-19.rds`, and `ranking_first_pass_candidates_2026-10-19.rds` under `input/f08/`.
- F08.3 remains open: official reference populations/pools, exact arithmetic, adult/foreign/free-exam histories, full PACE percentile/tie/carryover rules and resulting mechanism estimates are unresolved. No manuscript estimates are changed.
