# Adversarial report: analysis and revision checklist

**Status reviewed: October 17, 2026.** Covers every finding F01–F32 in the October 14 adversarial report (`PAPER/Reviews/sections_I_V_referee_audit_2026-10-14.tex`). The report reviewed manuscript revision `bd2d4db`; this checklist inspected the current manuscript at `5cf9b1a`, the analysis repository, and saved diagnostic outputs. Manuscript files may subsequently change through Overleaf synchronization.

**Targeted update: October 18, 2026.** F02.3/F02.5 author decisions recorded; F02.4 analysis implemented and run; appendix Tables B.5–B.6 added and compiled, with the approved main-text paragraph and table references integrated. Other findings retain their previously reviewed status except where explicitly noted below.

The main framing corrections are in place. Offer-effect estimation and substantial diagnostics for the pooled attendance treatment have also been completed. Most remaining empirical concerns require additional analysis: rollout inference and sample selection, lottery conditioning and control timing, outcome definitions and follow-up, and institutional eligibility rules. Completing a diagnostic does not establish an identifying assumption.

## How to use this checklist

- `[x]` means the **specific task described** has supporting manuscript text, code, or saved output. It does not close every concern in its finding.
- `[ ]` means unfinished, not verified in the inspected material, or awaiting integration. An existing discussion of a limitation is not evidence that the requested analysis has been done.
- **Reviewed — not pursued for now** records an author decision to retain a suggestion for discussion but remove it from the active work queue. These items use an ordinary bullet, not a completion checkbox: the proposed work has not been performed. Preserve the suggestion, decision date, and reason so coauthors can revisit it.
- Completed numerical tasks below were checked against saved outputs; this review did **not** rerun the empirical pipeline. The October 15 handoff's execution and matching claims are identified as reported execution, not independent replication here.
- Priorities follow the report: **P0** immediate errors; **P1** identification, interpretation, or central contribution; **P2** supporting evidence, precision, and presentation. They are not estimates of task duration.
- Stable task IDs identify work across agents. Record ownership, code/output paths, run date, and a short conclusion when updating a checkbox. Do not delete an unresolved item because a related prose caveat has been added.
- Tasks labeled **conditional** require a feasibility check. If the required data do not exist, record what was searched, what cannot be identified, and the corresponding narrower claim. Tasks labeled **optional** are not prerequisites for closing the report.
- Each finding that is tracked on GitHub lists its issue in a **GitHub issue:** line under its priority line. The issue (on the *initial submission* Project board) mirrors that finding's task IDs; when you check off a task, update both the checklist and the issue.
- Keep the baseline design reproducible. Run proposed changes as explicitly labeled sensitivities before changing the preferred specification. The code handoff's baseline conventions should be preserved for replication; their existence does not resolve this report's requests to examine those conventions.

## Files, designs, and starting points

This checklist is maintained in `CODE/Reviews/`. The current manuscript and adversarial report remain in the separate `PAPER` project; its paths below are relative to that project, not to the older draft under `CODE/documents/draft/`.

Use these root aliases when exchanging work between machines:

| Alias | Location on this machine |
|---|---|
| `PAPER` | `/Users/iriosu/Projects/Effect of Centralized School Choice on College Admissions Outcomes` |
| `CODE` | `/Users/iriosu/Dropbox/Effect SAE on SUA - repo` |
| `DATA` | `/Users/iriosu/Dropbox/Effect SAE on SUA` |

**Numbering warning:** the handoff's **Section 2** is the current paper's **Section IV, access/composition**; its **Section 3** is the current paper's **Section V, lottery outcomes**. These are not the manuscript's literature and background sections.

| Evidence / entry point | Location |
|---|---|
| Report and original priorities | Report source (`PAPER/Reviews/sections_I_V_referee_audit_2026-10-14.tex`); PDF (`PAPER/output/pdf/sections_I_V_referee_audit_2026-10-14.pdf`) |
| Current abstract and introduction | Abstract (`PAPER/Initial submission/sections/0_front.tex`); Introduction (`PAPER/Initial submission/sections/1_introduction.tex`) |
| Literature and institutional descriptions | Literature (`PAPER/Initial submission/sections/2_literature.tex`); Background (`PAPER/Initial submission/sections/3_background.tex`) |
| Rollout design and supporting material | Section IV (`PAPER/Initial submission/sections/4_access.tex`); Access appendix (`PAPER/Initial submission/sections/9_appendix_access.tex`) |
| Lottery design and supporting material | Section V (`PAPER/Initial submission/sections/5_outcomes.tex`); Outcomes appendix (`PAPER/Initial submission/sections/9_appendix_outcomes.tex`) |
| Mechanism evidence and pending analyses | Section VI (`PAPER/Initial submission/sections/6_mechanisms.tex`); Mechanisms appendix (`PAPER/Initial submission/sections/9_appendix_mechanisms.tex`) |
| Baseline code handoff | [HANDOFF.md](../HANDOFF.md) |
| Rollout notebook and instructions | `CODE/code/finalized_design_v1/section2/section2_cs_did.Rmd`, adjacent `README.md` |
| Lottery notebook and instructions | `CODE/code/finalized_design_v1/section3/Section3_IV.Rmd`, adjacent `README.md` |
| Data checksums and package versions | `CODE/code/finalized_design_v1/data_manifest.csv`, `environment/renv.lock`, `environment/package_versions.csv` |
| Completed adversarial-report diagnostics | `CODE/code/analysis_for_adversarial_report.Rmd` |
| Saved diagnostic outputs; abbreviated **DIAG** below | `CODE/code/analysis_for_adversarial_report_output/` |
| Rendered diagnostic report | `DIAG/analysis_for_adversarial_report.md` (HTML also available) |

**Shared-file availability:** the October 17 diagnostic notebook, rendered report, and aggregate outputs were committed and pushed as `0ab344c`. Raw input caches remain excluded from Git. The October 18 F02.4 additions are local working changes until separately committed; another clone still needs access to the checksum-matched input panels and the required package versions.

### Baseline and completed diagnostics to preserve

- Rollout panel: 1,324,477 entrant child-years and 8,891 school-grade cells. The displayed C&S estimator and the paired-cell permutation statistic are different; see F13 before interpreting their inference.
- Lottery panel: 304,547 applicants; 176,321 with nondeterministic offers; 175,869 with complete main controls. The 128,226 deterministic-probability applicants are outside the lottery sample. The 452-control loss does not measure outcome linkage completeness.
- Main treatment: entry-year attendance at any of the fixed 1,045 over-demanded schools. Main instrument: an offer at any of these schools. The baseline conditions on hundredth propensity groups, application-year effects, and five controls.
- Completed diagnostic run: October 17, 2026, 07:47:24 EDT. Panel MD5 `3390a0487374564a5350a98be299f1a2`, 6,753,877 bytes. `DIAG/paper_reproduction_checks.csv` contains **44 TRUE comparisons**. Across 13 outcomes, `estimator_identity_checks.csv` records RF/FS/IV and FWL/HC1 checks agreeing to numerical precision. These checks validate implementation against the baseline, not identification.
- The diagnostic used `DIAG/input/section3_panel.rds` when the shared Dropbox location was an empty placeholder. Resolve and hash-check the real input before running; never treat an empty placeholder as data. The notebook supports `SAE_ADVERSARIAL_PANEL` and `SAE_PAPER_ROOT` overrides.
- Main first stage: **62.572 percentage points**, SE **0.245**. Directly estimated on-time offer effects: regular-secondary graduation **−1.95 pp**, SUA assignment **−1.40 pp**, SUA enrollment **−1.47 pp**. Conditional observed-score offer effects are also saved. Use full-precision CSVs, not these rounded values, for comparisons.
- Predetermined simpler-list samples are already built: **39,187** applicants with one distinct over-demanded school listed and a non-over-demanded origin; **10,319** with exactly two choices at two distinct schools, over-demanded first/non-over-demanded second, and a non-over-demanded origin. First stages are **66.747** and **66.614 pp**. These samples have different populations and need not estimate the main LATE.
- Actual submitted lists and placements were recovered from `sae_admissions.rds`, not from simulator draws. `DIAG/upstream_reconciliation.csv` reports zero list/count/first-choice/offer/attendance discrepancies in every application year 2016–2021. Automatically added continuity options were excluded when reconstructing submitted lists. Provenance is in `upstream_provenance.csv`.

To reproduce the diagnostics, follow the notebook's input checks and run from `CODE/code/`:

```sh
Rscript -e 'rmarkdown::render("analysis_for_adversarial_report.Rmd", output_dir = "analysis_for_adversarial_report_output", envir = new.env())'
```

For baseline rollout and lottery runs, use their respective READMEs. The rollout run requires R 4.5.1 and `did` 2.1.2; preserve saved schedules and the order of fitting/aggregation because bootstrap RNG state matters. A successful process exit alone is insufficient for knitting workflows that continue after chunk errors: inspect the rendered log and output timestamps.

## Suggested execution order

| Work package | Findings | Dependencies / deliverable |
|---|---|---|
| Immediate factual corrections | F05–F08, F10, F16, F30 | Correct literature/rules; recover event-study numerical output; keep unsupported mechanism claims out of headlines. |
| Data and design audit | F09–F12, F22–F23, F32 | Dates, linkage, classifications, exact/simulated probabilities, control timing; preserve baseline manifests. |
| Lottery credibility | F20–F24, F28–F29 | Build on completed diagnostics; same-sample conditioning checks, pre-offer controls, inference, weights. |
| Outcome interpretation | F25–F27 | Requires linkage audit and longitudinal records; any credential, any HE, fixed horizons. |
| Rollout credibility | F13–F17 | Requires sample/support audit; align estimator/test, review pretrend null, region influence. F16 can start immediately. |
| Contribution and mechanisms | F03, F06, F08, F18, F28, F30 | Historical rules before eligibility coding; main design before mechanism heterogeneity. |
| Final integration | F01–F04, F07, F19, F29, F31–F32 | Regenerate estimates/text and reconcile claims after empirical choices stabilize. |

Each package should finish with a short conclusion stating whether the **estimate, uncertainty, population, or interpretation changed**. Additional tables alone do not close a concern. The findings below preserve the report's full scope, including literature and presentation tasks needed to use the analyses correctly.

## F01 — Abstract describes a different paper

**Priority: P0. Status: core correction completed; final synchronization remains.**

- [x] **F01.1** Replace the contradictory abstract with the two empirical designs and the actual negative lottery estimates. The current abstract reports the composition effects and attendance effects of −3.12, −2.23, and −2.36 pp; the old unsupported subgroup/program-selectivity results are absent. Evidence: `0_front.tex`.
- [x] **F01.2** Qualify mechanism language as evidence consistent with potential channels rather than identified causal mediation. The current abstract uses that qualification.
- [ ] **F01.3** After F25–F30, synchronize the abstract with the final outcome labels, follow-up horizon, uncertainty, and completed mechanism exhibits. In particular, verify support for “weaker relative standing” and “reduced access to reserved college seats”; softer language does not substitute for an exhibit.

**Closure:** every abstract claim maps to a final estimate or completed descriptive exhibit; regular-secondary completion and finite follow-up are accurately described.

## F02 — Reform effects and lottery attendance effects are different estimands

**Priority: P1. Status: addressed within the agreed scope. Framing, F02.4 analysis, appendix tables, and approved main-text discussion are complete; F02.3/F02.5 remain documented as reviewed and not pursued for now.**

- [x] **F02.1** Separate the rollout's effect on entrant composition from the lottery attendance effect. The introduction and literature contribution now explicitly say lottery compliers need not be students whose access changed because of the reform.
- [x] **F02.2** Align the title and research question with access/attendance. Current title: *Sought-After Schools and College Access: Evidence from Chile*; the introduction poses the two complementary questions.
- **F02.3 — Reviewed — not pursued for now (author decision, October 18, 2026).** Original suggestion: add or consolidate a compact estimand table covering treatment/instrument, unit, comparison, cohorts/grades/regions, horizon, identifying assumptions, population, and aggregation weights for each design; recheck conclusion and policy interpretation against it. **Decision:** the author considers the additional table unnecessary for now, given the framing revisions already made, and prefers the empirical extension in F02.4. Retained here for coauthor discussion; no table has been implemented.
- [x] **F02.4 — addressed October 18, 2026.** Estimate ninth-grade composition effects on documented support (also F17.4), and compare entrant changes with the characteristics/support of lottery applicants and compliers. Implemented in `CODE/code/analysis_for_adversarial_report.Rmd`, section **F02.4**; outputs `DIAG/f02_composition_effects.csv`, `f02_composition_support.csv`, `f02_population_profiles.csv`, and accompanying input/scale/overlap/inference audits. **Conclusion:** ninth-grade prior GPA falls by 0.136 SD (region-bootstrap SE 0.063; pointwise 95% CI −0.259 to −0.013); the low-income share rises by 4.41 pp (SE 2.34; CI −0.19 to 9.00). Estimates cover supported entering classes in 2017–2019, with the Metropolitan Region serving only as a comparison. The direction matches the all-grade results, with reduced precision and different population/weights. On the common GPA scale and aligned region-cohort window, estimated compliers have lower GPA and a higher low-income share than entrants overall. The notebook documents a newly specified complier-profile estimator, outcome-specific overlap exclusions, and differing income measurement dates; it does not claim to reproduce the appendix's unavailable upstream complier-weighting code. No composition effect is multiplied by a LATE, and no reform-on-college effect is inferred. The original all-grade point estimates and independent post-adoption contrast/weight reconstructions pass numerical checks. **Appendix integration:** generated standalone tables `PAPER/Initial submission/tables/appendix_ninth_grade_composition.tex` and `appendix_ninth_grade_profiles.tex`, included in the access appendix as Tables B.5–B.6 with methods and sample notes. Generated copies remain in DIAG; the notebook contains their export code. The manuscript compiles and both tables were visually checked. **Main-text integration:** the author-approved paragraph is inserted after the composition robustness discussion in `PAPER/Initial submission/sections/4_access.tex`, with references to both appendix tables. Numerical values come from the generated `tables/ninth_grade_macros.tex`. No further F02.4 action remains in the agreed scope. The new CIs are bootstrap intervals, not the paper's permutation-test p-values; F13–F14 remain open.
- **F02.5 — Reviewed — not pursued for now (author decision, October 18, 2026).** Original optional suggestion: assess feasibility of a rollout ATT on later outcomes for early regions, documenting untreated comparisons, exposure, horizons, and missing Metropolitan-region support. **Decision:** the author will not undertake this extension; it expands the present attendance-centered research question and is not required to retain it. Retained for coauthor discussion; no feasibility study or estimates have been implemented.

**Closure:** the paper makes no unsupported national reform-on-college claim; any bridge is explicitly descriptive or has its own identification argument.

## F03 — Contribution: interacting school and college admission rules

**Priority: P1. Status: F03.1–F03.2 completed; F03.3–F03.4 reviewed and postponed for later, not critical for now (author decision, October 18, 2026).**

- [x] **F03.1** Refocus the opening on access to sought-after schools and make the attendance question explicit. The current introduction retains economic and political centralization context, consistent with the authors' chosen framing.
- [x] **F03.2** State the main negative estimates and explain why school-dependent college rules may matter. Evidence: introduction and literature contribution.
- **F03.3 — Reviewed — postponed for later (author decision, October 18, 2026).** Original suggestion: write a concise contribution comparison after completing F05–F07: what the paper adds to selective-school attendance, ordinal rank, and school-dependent college admission rules. Do not claim to be first to examine long-run school-choice outcomes. **Decision:** not critical for now; retained for later consideration, with no additional comparison implemented.
- **F03.4 — Reviewed — postponed for later (author decision, October 18, 2026).** Original suggestion: map separate candidate channels to observable implications: learning/test performance; grading and grade failure; ordinal position/behavior; official Ranking-score benchmarks; school-specific eligibility. Identify which can be distinguished with current data and which cannot. Use this map to organize F28/F30. **Decision:** not critical for now; the proposed channel map and follow-up analyses are postponed. No manuscript changes or new analyses were implemented for this item.

**Deferred deliverable:** a one-page estimand/contribution/channel memo and corresponding introduction revisions, if F03.3–F03.4 are resumed. A structural model is not required by this report.

## F04 — Centralization, screening, demand, quality, and welfare

**Priority: P1. Status: addressed within the agreed scope. Approved wording revisions and F04.4 entrant-count analysis are complete. The political discussion is retained unchanged by author decision (October 18, 2026).**

- [x] **F04.1** Qualify access gains as depending on screening restrictions, priorities, and tie-breaking. The opening now describes these features together rather than attributing all access gains to coordination alone.
- [x] **F04.2** Replace the introductory assertion that historical academic advantages establish why families demand schools with a descriptive account of historical advantages.
- [x] **F04.3 — addressed within the agreed scope, October 18, 2026.** Section IV retains the historical value-added estimate but replaces the causal-effectiveness and demand explanation with the author-approved wording that these academic advantages may be associated with families' demand. The introduction and conclusion now describe the rollout result as a change in entrant composition rather than a general broadening of access. The conclusion identifies the rollout treatment as centralized assignment together with the accompanying school admission rules. No subgroup admission-probability or welfare estimates are inferred. No separate welfare sentence was added, as the conclusion does not claim a welfare comparison.
- [x] **F04.4 — addressed October 18, 2026.** Implemented `code/f04_entrant_counts.R`, called from the F04.4 section of `code/analysis_for_adversarial_report.Rmd`; outputs are in `code/analysis_for_adversarial_report_output/f04/`. The common positive-entry sample gives unbalanced-panel effects of −0.398 total entrants (SE 0.390; pointwise 95% CI −1.162 to 0.367), +0.121 low-income entrants (SE 0.205; CI −0.281 to 0.522), −0.518 other entrants (SE 0.327; CI −1.160 to 0.123), and +3.504 pp in the low-income share (SE 0.936; CI 1.669 to 5.339). Counts are per school-grade-year. The input's low-income flag is complete and binary. Missing cell-years cannot be distinguished from true zero-entry years or nonoperating grades from the finalized entrant panel, so no zeros were imputed. No pre-SAE applicant denominator was constructed. **Inference:** the baseline paired estimator and regional permutation tests are reported separately from the unbalanced-panel estimates and bootstrap intervals; the paired low-income count effect is +0.250 (jackknife SE 0.131; permutation p=0.079). Counts reuse 2,999 saved intake-count schedules; the share reuses 9,999 headline schedules. The 10,000-draw region bootstrap, schedules, checksums, sample/support audits, covariance, and verification outputs are documented. Count additivity and baseline point-estimate reproduction checks pass. **Conclusion:** the evidence supports a change in entrant composition more clearly than an increase in low-income entrant numbers; subgroup admission probabilities and national totals remain unmeasured. F13–F14's inference issues remain open. **Manuscript:** generated Table B.7 (`tables/appendix_entrant_counts.tex`), numerical macros, and the approved Section IV discussion are integrated; the access appendix explains sample and estimator differences. Compilation and visual checks pass.
- **F04.5 — Reviewed — political-discussion revision not pursued (author decision, October 18, 2026).** Original suggestion: distinguish policy components and welfare interpretation in the centralization paragraph while preserving the political discussion. **Decision:** the author explicitly retains the existing political paragraph, including its framing of centralization's political fragility and the Chile and San Francisco episodes. The proposed replacement of its first two sentences with language about contested screening, lottery, and geographic-priority rules was declined. The author approved the separate conclusion clarification that rollout estimates capture centralized assignment and the accompanying school admission rules; that edit is implemented. F07.6's factual source verification remains a separate task.

**Closure:** access, composition, effectiveness, and welfare claims each match the estimand and evidence supporting them.

## F05 — Correct descriptions of cited studies

**Priority: P0/P1. Status: partial; several inaccuracies remain active.**

**GitHub issue:** [#5](https://github.com/iriosu/effect_sae_on_sua/issues/5) (Literature review: QJE-readiness fixes and additions). Assignee: Tomas Larroucau (@tlarroucau).

- [x] **F05.1** Remove the claim that earlier lottery studies do not examine longer educational trajectories. The current literature acknowledges postsecondary outcomes and distinguishes reform from attendance studies.
- [ ] **F05.2** Build a claim-to-source matrix for substantive literature claims: exact version, treatment, population, design, outcome, finding, and relation to this paper. Read primary papers, using the report's source list as a starting point.
- [ ] **F05.3** Correct Hastings–Kane–Staiger and Agarwal–Somaini: the cited studies are not the information experiments currently attributed to them. Replace the claim or cite actual interventions (e.g., Hastings–Weinstein, Arteaga et al., appropriate Larroucau et al. version).
- [ ] **F05.4** Correct Narita's learning/inertia design and Kapor–Neilson–Zimmerman's structural beliefs/preferences and welfare counterfactuals. Do not describe them as the stated staggered information rollout or quasi-experimental mechanism-change outcome effect.
- [ ] **F05.5** Reposition Gazmuri and Neilson's voucher studies under their actual policy margins. Describe Kutscher–Nath–Urzúa's district dissimilarity measure as segregation across schools within districts; the misleading active within-school claim has been removed, but the precise comparison still needs to be supplied.
- [ ] **F05.6** Correct Abdulkadiroğlu–Sönmez (2003) to include student-proposing DA and top trading cycles. Move secondary-school studies out of the college-admissions subsection unless the connection is made explicit.

**Deliverables:** source matrix and revised literature prose; each corrected sentence must be traceable to the cited version.

## F06 — Closest literature and novelty

**Priority: P1. Status: partial.**

**GitHub issue:** [#5](https://github.com/iriosu/effect_sae_on_sua/issues/5) (Literature review: QJE-readiness fixes and additions). Assignee: Tomas Larroucau (@tlarroucau).

- [x] **F06.1** Restore selective-school evidence in the opening: Abdulkadiroğlu et al., Dobbie–Fryer, and Pop-Eleches–Urquiola now appear in the second paragraph.
- [ ] **F06.2** Add substantive comparisons to the highest-priority omitted work: Dustan–de Janvry–Sadoulet (2017), *Flourish or Fail?*; Cullen–Long–Reback (2013), strategic high-school choice under Texas rank rules; Murphy–Weinhardt (2020) and Denning–Murphy–Weinhardt (2023), ordinal rank; Beuermann–Jackson (2022), preferred schools and longer-run outcomes. Explain the difference in treatment/design/channel rather than merely adding citations.
- [ ] **F06.3** Evaluate complementary comparisons: Black–Denning–Rothstein (2023), gaining/losing selective-college access; Beuermann et al. (2023), multidimensional school output; Elacqua–Kutscher (2025), preferences/segregation in Chile. Use them where they materially qualify demand, welfare, or access claims.
- [ ] **F06.4** Obtain the current Botbol–Gazmuri paper and compare entry grade, quota, target population, and estimand. Do not substitute a thesis chapter for verified claims about the latest standalone version.
- [ ] **F06.5** Seek the current Neilson *A Decade of Centralized School Choice Admission in Chile* draft before finalizing novelty. The report found a seminar listing but did not retrieve the draft; do not attribute results to an unread paper. If unavailable, document that and use a narrower novelty claim.
- [ ] **F06.6** Organize Deming, Campos–Kearns, Kutscher et al., and Terrier et al. around their actual estimands. Explicitly distinguish current class rank from Chile's official Ranking score.

**Closure:** a concise comparison explains what interacting admission rules add to existing evidence of test-score gains, dropout, rank effects, and long-run school outcomes.

## F07 — Bibliography and source precision

**Priority: P0/P2. Status: open, with some earlier problematic prose already removed.**

**GitHub issue:** [#5](https://github.com/iriosu/effect_sae_on_sua/issues/5) (Literature review: QJE-readiness fixes and additions). Assignee: Tomas Larroucau (@tlarroucau).

- [ ] **F07.1** Verify and correct Agarwal–Somaini (2018): *Econometrica* 86(2):391–444, **Paulo** Somaini; correct the Hastings–Kane–Staiger title/version rather than retaining mismatched AER metadata.
- [ ] **F07.2** Update Terrier–Pathak–Ren to the verified published version (report identifies AEJ: Applied 18(1):44–87, 2026) and include its finding about the achievement gap. Align Larroucau et al. dates, titles, and working-paper metadata with the version actually used.
- [ ] **F07.3** Consolidate duplicate Deming, Cullen–Jacob–Levitt, and Kutscher–Nath–Urzúa records; check rendered author names, year suffixes, and active citation keys.
- [ ] **F07.4** Check active source claims about Chetty/social capital, Light–Strayer, and the Billings integration evidence. Do not turn associations or a distinct intervention into causal evidence about replacing screening with lotteries; verify population-specific wording.
- [ ] **F07.5** Verify the denominator and scope of the “nearly 40% of countries” statistic, which is present in the current opening. Distinguish coordinated systems from national coverage or universal lottery priorities.
- [ ] **F07.6** Verify the current Chilean bill and San Francisco policy descriptions against official dated records. Distinguish proposal, vote, adoption, and implementation; clarify whether centralized allocation persists while screening or geography changes. The current introduction again contains these episodes, so earlier removal is not a completed resolution.

**Deliverables:** corrected bibliography plus source/version/status notes. The report's S01–S35 references are starting points, not fresh verification of later developments.

## F08 — Cohort-specific PACE rules

**Priority: P1. Status: F08.1, F08.2, and F08.4 revised; official school linkage, selection estimates, and grade-based Ranking reconstruction/validation completed; full academic eligibility remains open under F08.3. Dependency: resolve before interpreting eligibility mechanisms.**

**Handoff:** [Abhijit continuation guide, October 19, 2026](handoff_abhijit_pace_nem_ranking_2026-10-19.md) identifies the latest private score files, validation results, code chunks, reproduction steps, and remaining tasks. The refined Ranking proxy is provisional; earlier cached outputs are distinguished explicitly.

**Author baseline decision, later October 19:** adopt the independent NEM/Ranking reconstruction, including `first_pass_reference_only`, and proceed to expanded NEM/Ranking 2SLS and PACE eligibility classification. Perfect exact-score matching is no longer a prerequisite. All lottery students remain in the design population regardless of exam participation; score availability and remaining missingness must be reported. The [adopted baseline package](../code/analysis_for_adversarial_report_output/f08/ranking/baseline_v1_2026-10-19/baseline_readme.md) supersedes the morning score delivery for new work. Peer-calibrated scores remain a sensitivity. See F30.8–F30.10 for the expanded-score execution tasks.

- [x] **F08 baseline adoption/export:** freeze a versioned cohort-keyed national score file and a linked full Section 3 panel, preserving all original panel rows/columns. Retain available positive official scores and reconstruct otherwise; export independent validation, coverage, normalization moments and source/output hashes. National missing-score coverage is 185,216 NEM and 178,638 Ranking fills; 24,533/31,111 remain unresolved. The expanded controls-complete lottery sample has 154,620 NEM and 154,170 Ranking outcomes. No new effect estimates or full eligibility classification have been asserted.
- [ ] **F08.3 next — decision-focused eligibility validation:** use the adopted score baseline, correct full school reference roster, cohort-specific percentile OR absolute threshold, and explicit ties/quota/missing-peer treatment. Report false positives/negatives and near-cutoff disagreement by year/offer, and sensitivity of eligibility effects to plausible score errors. Apply school history, examinations and carryover separately; preserve unknowns. Further exact-score matching is optional unless these results are sensitive.

- [x] **F08.1** Build an official-rule matrix for every relevant college admission year (scheduled processes 2021–2026 and any additional process used): percentile alternative, absolute Ranking threshold/scale, required exams, participating-school attendance in grades 11/12, graduation cohort, eligibility duration, and selection rules. Record official source and effective date in each row. **Revised 2026-10-19:** `analysis_for_adversarial_report.Rmd`, chunk `f08-rules`, generates `f08/pace_rules_2021_2026.csv` and Appendix Table D.11 (`tab: pace annual rules`). Verified 2021–2026 academic alternatives are 15%/710, 15%/749, 20%/863, 20%/851, 25%/815, and 25%/830. Matrix records cohort, scale, exams, school history, validity/carryover, selection-score rules, effective process, source pages/URL, and retrieval date. Official PDFs and checksums are retained under `f08/`. Longer horizons end in 2026; 2027 appears only as a validity endpoint, not an observed admission process. REX 4042/2026 updates the rules for admission 2027 while preserving the original 2026 rule.
- [x] **F08.2** Trace each PACE outcome to **official recorded eligibility** or a **constructed eligibility rule**. Distinguish eligibility, application, selection, and enrollment; document missing records and school participation by year. **Revised 2026-10-19:** recovered the upstream harmonization script and original P167 dictionary. Through 2022, `pace` comes from registration-stage P167; in 2023–2025 the script replaces it with first-preference PACE-program presence, then constructs `is_pace`. It is not a comparable eligibility flag. Any PACE preference with status 24 exactly reproduces `assigned_pace` in all 2020–2025 rows. Extracted independent official school rosters for 2019–2025, with source pages and OCR corrections. The MRUN-linked 2026 extract omits route, so that process is excluded from the common selection analysis.
- [ ] **F08.3** If constructed, implement year-specific rules and compare old/new eligibility by cohort, offer status, and school. Report disagreement counts/reasons, then rerun affected estimates. If official recorded eligibility is used correctly, document that and limit changes to erroneous exposition as appropriate. **In progress 2026-10-19:** the central notebook implements annual absolute thresholds, an explicitly provisional observed-score percentile OR rule, and conservative classifications that retain unknown scores/reference ranks. It estimates PACE selection, official school-attendance events, coverage, and academic diagnostics using the finalized Section 3 design on a common 2016–2020 SAE sample. Aggregate outputs and a review report are in `code/analysis_for_adversarial_report_output/f08/`. Complete eligibility is not identified: missing graduate Ranking scores, operational percentile-reference/tie rules, nonconsecutive histories, carryover use, and the 2026 selection route remain unresolved. Existing manuscript tables have not been replaced with provisional eligibility estimates.
- [x] **F08.4** Update background, mechanism text, appendix, and table notes together. **Revised 2026-10-19:** background and Section VI now use cohort-specific Ranking alternatives and exam/school requirements. Replaced the pending top-10%/top-25% task note with a statement of what the current estimates do and do not establish. Added annual-rules appendix and citations. Reconciliation prose and notes disclose the individual PACE-record override, missing-school treatment, post-offer sample restrictions, and partial official-list coverage. Main funnel notes clarify that PACE is recorded selection, not constructed eligibility. No empirical estimates changed. Paper compiled and changed tables visually inspected.

**Coding audit, updated 2026-10-19:** The notebook documents current exhibits and source provenance (`f08/code_provenance.csv`; archived piece4 code at commit `79fc4771123fadef963f5bcbb6b2e2b2f9b2a24f`). The old `L_PACE` is record appearance; `S_PACE` is selected preference status. The old school link is inferred from applicants and forced to one by each student's own PACE record, including in the partial official-list variant. Its second accounting component is not academic eligibility. The new school measures use independent historical ministry rosters, with no individual-record override. Upstream `1_data_processing.Rmd` lines 1102–1105 confirm that the stored `pace` definition changes in 2023; the 2026 preselection dictionary does not describe that constructed column. See the generated `f08/pace_findings_2026-10-19.md` for estimates and precise limitations. The exact updated old horizon exporter remains unavailable; new estimates use the finalized Section 3 design rather than claim to reproduce that exporter. F08.3 remains unchecked. Preserve missingness and carryover, and do not interpret conditional accounting as causal mediation.

**Author wording decision, 2026-10-19:** the user approved a shorter background paragraph. Implemented it verbatim with a footnote stating that the qualifying percentage ranged from 15% to 25% and referring to `tab: pace annual rules`. The detailed criteria remain in the appendix.
**Ranking reconstruction update, 2026-10-19:** at the author's request, the `f08-ranking-*` chunks in `analysis_for_adversarial_report.Rmd` construct an independent proxy from national passed-grade histories and historical school contexts. Annual guides for admission 2021–2026, the older NEM conversion tables, and the 2023 scale change were checked. The reference uses all observed school-grade records, including nonregistrants, and averages the three previous cohorts' maxima. Published worked examples reproduce correctly. Validation covers score errors, annual absolute thresholds, relative-order diagnostics, school transfers, PACE schools, lottery offer groups, and rounding/reference sensitivities. Recorded scores remain unchanged; only missing scores are augmented. Small contexts needing official pooling and incomplete histories remain unknown. Aggregate results and the reproducible report are in `code/analysis_for_adversarial_report_output/f08/ranking/`. This substantially addresses the missing-score problem but does not certify the official PACE percentile population or tie rules, nor establish that proxy errors are identical among nonregistrants. F08.3 remains open for the final eligibility construction and affected-table updates; no manuscript estimates were changed in this step.

**Iterative score audit, 2026-10-19:** the new `f08-score-*`, NEM-record, and subsequent Ranking audit chunks remove the historical cache's 2013 restriction, distinguish broad HC/TP contexts, reconcile historical graduation GPAs, and test cohort weighting and arithmetic precision. On the same 1,032,921 observed-score records, the uniform rounded-cohort candidate raises exact Ranking agreement from 48.83% to 84.57% and lowers mean absolute error from 2.783 to 1.458 points. Among 26,433 reconstructible records from the original 26,469-case clean small-difference subset, 95.26% now match exactly; 36 remain unknown under the modality-specific reference requirement. The candidate averages rounded annual cohort means equally and rounds context scores before weighting. **This remains provisional:** the dated guides explicitly describe truncation at some stages, so better empirical replication does not certify the official implementation. The original and refined proxies are both retained. Independent four-grade NEM reconstruction matches 98.98% of 1,052,561 observed scores; 185,216 missing NEM scores are now filled with source labels, while 24,533 remain unresolved. Reusable functions, private student-level NEM/Ranking outputs, annual rule checks, and `ranking_iterative_report_2026-10-19.md` are generated from the central notebook. F08.3 and the manuscript's eligibility mechanism estimates remain open.
**Deliverables:** rules CSV/table, coding audit, affected-estimate comparison, and corrected text. Do not declare a coding error from the textual error alone.

**Follow-up by year and context, later 2026-10-19:** the four `f08-score-followup-*` chunks show that mismatches occur in all six admission years. A targeted same-school HHTT context candidate raises exact Ranking agreement from 84.56% to 90.71% on the same 1,033,342 observed-score graduates, and from 73.34% to 85.82% in PACE schools. It improves all years, resolves 64,347 mismatches, and introduces 801; the operational context mapping still needs official confirmation. NEM remains 98.98% exact; truncation fixes no NEM mismatches, and later registration records resolve very few. Near-cutoff and common-sample offer diagnostics are saved; differential measurement error remains. See [the follow-up report](../code/analysis_for_adversarial_report_output/f08/ranking/followup_2026-10-19/score_mismatch_followup_2026-10-19.md). The morning score delivery is preserved; the new candidate is saved separately in ignored private inputs. F08.3 remains open; neither full eligibility nor mechanism estimates are finalized.

- [x] **F08.3 diagnostic — annual Ranking averaging, 2026-10-19:** implemented four grade-specific scores and their equal average; compared with the latest context candidate on identical students, by admission year, modality transition, PACE exposure and same-school history. For 21,139 TP-to-HC switchers, exact agreement falls from 88.45% to 28.38% (MAE 0.502 to 3.833) when changing temporal aggregation alone; all six years worsen. Seven annual specifications, with/without the independent NEM floor, are retained as diagnostics. Four-single-year-context equivalence passes on 2,988 histories. See [annual-score report](../code/analysis_for_adversarial_report_output/f08/ranking/annual_test_2026-10-19/annual_ranking_test_2026-10-19.md). This hypothesis has been tested and rejected as an empirical refinement; it does **not** complete F08.3.
- [ ] **F08.3 next — reconcile annual versus context rules:** confirm the operational procedure and reference benchmarks for admission 2021–2026 against dated official documentation/DEMRE data; reconcile the current webpage's annual-score description with the archived context-based guides. Retrieve and inspect the embedded equation before treating a converted-score formula as verified. Resolve small-school pooling and academic-record versions. Keep annual candidates separate and preserve existing score deliveries until this is resolved.

- [x] **F08.3 diagnostic — short historical records, 2026-10-19:** searched DEMRE and MINEDUC; confirmed the under-30 pooling rule and one/two-cohort exception, distinguished the future 2028 rule, and tested six threshold/pooling approximations. All pooling variants worsen existing-score replication. Short histories account for 3.06% of remaining mismatches and 13.32% of absolute error. [Report and source review](../code/analysis_for_adversarial_report_output/f08/ranking/short_history_2026-10-19/short_history_report_2026-10-19.md).
- [x] **F08.3 diagnostic — repeated passed-grade records:** implemented MINEDUC's first-completion rule for distinct years, preserving earliest-year conflicts as unknown. Historical-peer recovery fixes 173 errors and introduces 52 (net 121; a slight exact-match improvement in all years). Own-history recovery validates poorly (56.52% NEM; 48.24% Ranking in newly scored observed cases), so it is not adopted. Three separately labeled private candidates preserve the accepted narrow HHTT reconstruction.
- [ ] **F08.3 next — operational reference records:** obtain or reconstruct official pre-2028 grouping assignments; resolve the graduate-count unit, dependency categories, exactly-30 boundary, and record versions. Validate the promising `first_pass_reference_only` sensitivity before using it for mechanism estimates. Reconcile genuine repeated completion versus administrative corrections in newly recovered own histories; enrollment dates are required for same-year conflicts.

- [x] **F08.3 diagnostic — remaining-error decomposition:** distinguish mismatch counts, error size and unreconstructed coverage. In the latest candidate, 93.45% of mismatches have adequate observed school-modality graduate counts; 65.40% arise in the exact-NEM, one-context, three-cohort group with adequate counts. NEM disagreement is only 1.02% of the sample but contributes 31.92% of absolute Ranking error. [Report](../code/analysis_for_adversarial_report_output/f08/ranking/remaining_patterns_2026-10-19/remaining_discrepancy_patterns_2026-10-19.md) documents the denominator, exclusions, joint patterns, non-overlapping decomposition and next priorities. Pooling remains a coverage task; neither administrative causes nor full eligibility are established.
- [x] **F08.3 diagnostic — mixed matches within identical contexts/classrooms:** restrict to exact NEM, complete histories, one context, three usable reference cohorts and adequate counts. Hold all four school IDs, actual years and exact teaching codes fixed; recover raw classroom letter/session for graduation 2023. Find 2,188 mixed classroom-context groups, including 1,516 after excluding floors/caps. None of 21,236 same-class/context/GPA groups has differing recorded Ranking; across six cohorts, only one of 176,079 same-context/GPA groups differs. Changing only the shared maximum can reconcile 18.34% of mixed classroom groups with the current mean/formula. [Report, aggregate checks and reproduction](../code/analysis_for_adversarial_report_output/f08/ranking/within_context_2026-10-19/within_context_report_2026-10-19.md). All raw/student/classroom records remain private; score deliveries and manuscript estimates are unchanged.
- [ ] **F08.3 next — shared score curve and isolated anomaly:** in the exact-NEM/full-history sample, examine historical-mean construction and arithmetic jointly with the maximum, using same-context GPA-to-Ranking curves as diagnostics. A common wrong benchmark can cause mixed integer matches at different GPAs; do not interpret this alone as a person-specific error. Validate refinements against independent references and held-out cohorts/schools, preserving exploratory outcome-implied benchmarks separately. Trace the one equal-GPA/different-Ranking group in admission 2021 to its source records and context mapping; do not generalize from this isolated exception.
- [x] **F08.3 diagnostic — full performance-panel refresh and reference construction:** independently retrieved the newer 2002–2025 panel, compared seven scoring fields with current inputs and checked the raw 2023 file. The current calculation already uses national performance data. All grade/passed-status information agrees; 1,365 differences are blank/missing status labels only. Source refresh leaves NEM/Ranking accuracy unchanged. Extending histories to 2002 slightly worsens both scores. Performance-only historical references reduce Ranking exact agreement to 87.92% from 90.73% on the same sample (clean exact-NEM/full-history subset: 89.15% versus 92.56%); mean-only, maximum-only and full-precision alternatives also worsen matching. Preserve the current version; all candidates remain separate. [Report and reproduction](../code/analysis_for_adversarial_report_output/f08/ranking/performance_panel_2026-10-19/performance_panel_report_2026-10-19.md). This resolves the proposed source/refinement diagnostic, not F08.3 or the shared-score-curve investigation.
- [x] **F08.3 diagnostic — one-point errors and mean/anchor feasibility:** tested 34 input-based arithmetic/interpolation/scale alternatives; none improves development-school matching. In the 842,942-student exact-NEM/full-history/one-context sample, 42,007 errors are one point. A historical-mean adjustment of at most 0.02, with its corresponding published NEM anchor and unchanged maximum, can reconcile all interior scores in 3,300/3,394 mixed contexts with only one-point errors (97.23%); a maximum-only adjustment of at most 0.01 works in 24. Only 404/40,106 interior one-point errors sit at a final half-point boundary. NEM-cell checks find no systematic table replacement supported by the recorded precise-GPA years. These are diagnostics, not outcome-based benchmark corrections. [Report, comparisons and reproduction](../code/analysis_for_adversarial_report_output/f08/ranking/one_point_2026-10-19/one_point_report_2026-10-19.md).
- [x] **F08.3 diagnostic — held-out peer anchor calibration:** split students by MRUN parity within strict contexts, estimate a common anchor interval using only the other half's recorded Ranking, and change a prediction only when the entire interval implies the same integer. The conservative diagnostic resolves 24,316 one-point errors and 27,473 total mismatches, with zero introduced or worsened errors in this evaluation. Clean-sample exact agreement rises from 92.5532% to 95.8124%; all six years improve. The 632,385 uniquely implied predictions match 99.8901%. Private predictions and intervals remain separate; the midpoint alternative introduces 814 errors and is not preferred. This is empirical calibration from peers' scores, not independent reconstruction from grades.
- [ ] **F08.3 optional refinement — independently reconcile historical means:** under the author's baseline decision, this no longer blocks analysis. If useful for sensitivity, prioritize contexts with tight inferred intervals; recover official school-context means or audit historical-peer inclusion, missing GPAs, late registrations and grade revisions. Explain shifts using inputs alone and validate on separate schools/cohorts before replacing the baseline. Do not select a mean to fit observed Ranking.
- [ ] **F08.3 optional sensitivity — validate peer calibration beyond this clean sample:** preserve the independent candidate and observed scores; test additional fixed cross-fitting folds, coverage, NEM-mismatched and multiple-context histories, and applicability to missing-score students. Check lottery-offer differences and selection into observed scores before constructing PACE eligibility or reporting mechanism estimates. Zero newly introduced errors in the current held-out evaluation is not a guarantee of transportability. Full matching and F08.3 remain unresolved.




## F09 — Anticipation and the policy bundle

**Priority: P1. Status: open.**

- [ ] **F09.1** Construct a region/grade timeline of announcement, application, assignment, entry, and implementation of screening, copayment, and legal-status changes. Identify plausible periods of anticipatory response.
- [ ] **F09.2** State the rollout treatment as the implemented admission regime. Central scheduling alone does not establish no anticipation or isolate a pure DA effect.
- [ ] **F09.3** Run targeted anticipation sensitivities justified by the timeline: alternative exposure/base periods or exclusion of announcement-exposed comparisons. Report changed support/estimands; do not select windows by significance.
- [ ] **F09.4 — conditional on records.** Describe copayment transitions, closures, capacities, and status changes by wave; test whether composition patterns track these changes using explicitly labeled comparisons. Avoid controlling mechanically for variables that respond to SAE as though they were baseline confounders.

**Deliverables:** institutional timeline and a sensitivity table with a written interpretation of what policy margin remains identified.

## F10 — Calendar, linkage, and outcome coverage

**Priority: P2. Status: partial documentation; verification remains.**

- [x] **F10.1** Document the basic process-to-entry-to-college calendar and binary-versus-score missing-record conventions. Evidence: background/outcomes appendices; handoff panel dictionaries also document variables and sample counts.
- [ ] **F10.2** Replace the inaccurate alternating SIMCE description with a grade-by-year availability table for the cohorts actually used in historical value added. Identify canceled/missing test years and resulting sample restrictions.
- [ ] **F10.3** Produce a data dictionary and linkage flow with source, unit, key, dates, duplicates, valid IDs, linked counts, and unmatched reasons. Separate no participation, absent registry records, unlinked IDs, migration, adult education, and true missingness where distinguishable.
- [ ] **F10.4** Estimate offer effects on linkage/coverage indicators by cohort; distinguish actual outcome nonparticipation from administrative match failure. Audit zero coding against registry coverage, rather than interpreting the 452 missing-control cases as the entire missingness problem.
- [ ] **F10.5** Record extraction dates and completeness of 2025 school and 2026 college/enrollment records; flag provisional vintages. Use these dates to define valid horizons in F27.
- [ ] **F10.6** Audit the Ñuble/Biobío geographic crosswalk across years. Document whether historically common units are treated as independent rollout schedules and the implications for F14.

**Deliverables:** source/coverage dictionary, linkage flow, cohort-by-offer coverage table, and reproducible geographic crosswalk.

## F11 — Future-defined school selection and lottery-dependent classification

**Priority: P1. Status: open; baseline definition documented.**

- [x] **F11.1** Record the baseline construction: persistent excess effective demand through 2025 and exclusion of funding-status changers. The handoff and access appendix expose these restrictions; documenting them does not remove their selection implications.
- [ ] **F11.2** Produce a classification audit: number and characteristics of schools/cells retained/excluded under persistent demand, funding-status stability, and each alternative. Label the main target as conditional on a later-observed school set.
- [ ] **F11.3** Re-estimate composition outcomes using earliest-available-process classification, leave-cohort-out classification, and an application-based definition independent of realized placements where feasible. Add an all-SAE-school benchmark. Report each definition's timing, support, population, estimates, and uncertainty; none automatically reconstructs pre-SAE demand.
- [ ] **F11.4** Investigate status-changer exclusions separately from demand classification. Provide an expanded-sample sensitivity where a defensible school/year definition is possible, preserving the baseline for comparison.
- [ ] **F11.5** Audit whether effective-demand school membership changes when lottery numbers change. Effective demand uses rank relative to realized assignment, so recover/recompute classification under representative simulator draws. If not invariant, determine a defensible pre-randomization classification or justify the conditioning before re-estimating probabilities/outcomes.

**Closure:** disclose future selection and show its empirical importance; lottery simulation conditions on a defensible set. This precedes definitive randomization inference in F24.

## F12 — The purported pre-SAE demand restriction uses post-SAE data

**Priority: P1. Status: open.**

- [ ] **F12.1** Relabel the check as an enrollment-pattern sensitivity: it compares `g−4:g−1` with `g:g+2` and removes 728 cells. It is not validation of a predetermined pre-reform demand sample.
- [ ] **F12.2** Recover the restriction flags and show included/excluded cell characteristics, enrollment changes, and composition effects on comparable support. Explain whether the filter preferentially removes cells with larger SAE responses.
- [ ] **F12.3 — conditional.** Construct a genuinely pre-adoption demand/capacity proxy if records exist; state its limitations and compare results. If unavailable, retain the current sensitivity with limited interpretation and document the unavailable pre-reform applications.

**Deliverable:** correctly labeled comparison table and an explicit account of what the filter can and cannot establish.

## F13 — Displayed estimates and permutation tests use different estimators

**Priority: P1. Status: unresolved; code now available.**

- [x] **F13.1** Locate both implementations. The finalized rollout notebook contains the displayed unbalanced C&S estimator and the paired-cell randomization statistic; their difference is already disclosed in the appendix/handoff.
- [ ] **F13.2** Export a reconciliation table for every main/robustness specification: C&S estimate, paired estimate, cell sample, aggregation weights, SE/CI, exact permutation p-value, null, and draw count. Reproduce the reported differences rather than assuming equivalence.
- [ ] **F13.3** Align displayed estimate, interval, and test where feasible. Otherwise show the two estimators side by side and attach each p-value only to its own statistic. Update stars and notes accordingly.
- [ ] **F13.4** State whether each test targets a sharp no-effect null or a zero average ATT under heterogeneity. Explain why the chosen test supports the attached claim; do not use a sharp-null rejection as an unqualified test of a zero average.

**Deliverable:** one estimation/inference reconciliation output feeding all access tables. Coordinate with F14–F16 rather than applying cosmetic star changes first.

## F14 — Justification and sensitivity of regional inference

**Priority: P1. Status: open.**

- [ ] **F14.1** State the reference model: actual randomized schedules, an exchangeability approximation, or another justified sampling argument. Address selected pilot, size-based Metropolitan delay, unequal regions, and only one region in first/last waves.
- [ ] **F14.2** Export region contributions, cluster sizes, adoption groups, exact p-values and draw counts; show leave-one-region-out effects **with the resulting support and weights**, not just coefficient ranges.
- [ ] **F14.3** Assess defensible restricted schedule reassignments based on institutional timing/baseline information. Explain which schedules are admissible, how many exist, and how restrictions change the reference distribution. Do not search over restrictions to retain significance.
- [ ] **F14.4** Benchmark with a justified few-cluster procedure and state its limitations under sparse treated clusters. Neither a wild-bootstrap command nor jackknife studentization supplies the missing assignment/exchangeability argument.
- [ ] **F14.5** Incorporate the historical geographic audit from F10.6 before finalizing independent units and schedule counts.

**Closure:** an inference memo and table explain what randomness supports uncertainty and whether conclusions survive plausible alternatives.

## F15 — The pretrend test may impose the wrong null

**Priority: P1. Status: open; implementation located.**

- [ ] **F15.1** Review `ri_pretrend_y` in the finalized rollout notebook. Trace whether reassigned schedules place actually treated observations into pseudo-preperiods while holding their outcomes fixed. Save a concrete support/exposure audit.
- [ ] **F15.2** Implement a lead test allowing post-adoption effects, or use a common genuinely untreated window with justified inference. Document lost cohorts/event times and the precise null.
- [ ] **F15.3** Report individual lead estimates, covariance, intervals, and a joint test. Replace or qualify the current 0.78/0.88 p-values if they do not test the stated pretrend proposition.
- [ ] **F15.4** Evaluate economically meaningful trend deviations. **Conditional:** use Rambachan–Roth-type sensitivity only with appropriate coefficients/covariance and an explanation of small-cluster uncertainty; otherwise provide a transparent calibrated sensitivity without claiming unavailable guarantees.

**Closure:** the pretrend evidence addresses pre-adoption differences without assuming away the post-treatment effects of interest.

## F16 — Reconcile the low-income event-study numbers

**Priority: P0. Status: unresolved discrepancy; numerical-output code located.**

- [x] **F16.1** Locate a reproducible output route. The finalized rollout notebook's `event-studies` chunk saves fitted/dynamic objects to `event_studies.rds`, prints coefficients/SEs, and writes both figures. Local saved results from that baseline run were not found in the inspected notebook folder.
- [ ] **F16.2** Obtain the actual run's numerical output or rerun with the pinned environment, panel, schedules, seeds, and aggregation order. Export full-precision leads/lags, SEs, covariance and support for both outcomes.
- [ ] **F16.3** Resolve the mismatch between text/table **2.8 and 4.1 pp** and the graph's approximate **3.4 and 3.9 pp**. The latter are the report's visual readings, **not** replacement estimates. Trace whether the sources differ in run, estimator, aggregation, or transcription.
- [ ] **F16.4** Generate the figure, numerical appendix, and text macros from one verified output. Label fractions versus percentage points and pointwise versus simultaneous intervals. Remove the appendix note retaining unverified income numbers.

**Closure:** exact output reproduces every plotted point/interval and every corresponding text/table value; GPA and income figures both pass the check.

## F17 — Support, changing observed cells, and spillovers

**Priority: P1. Status: limitations documented; requested diagnostics remain.**

- [ ] **F17.1** Export adoption-cohort × calendar-year support: treated/comparison regions, grades, cells, entrants, missing-outcome counts, and aggregation weights. Highlight Metropolitan-only comparisons in 2020 and unavailable later contrasts.
- [ ] **F17.2** Estimate cell observability and GPA availability as outcomes; compare stable-membership and baseline-observable cell samples. Report how conditioning on observed entrants/grades changes sample and estimates.
- [ ] **F17.3** Compare the full and no-Metropolitan estimates on common supported contrasts before interpreting their difference. Separate removal of influential observations from changing the target ATT.
- [ ] **F17.4** Run comparisons using regions not yet exposed at **any** grade, and a ninth-grade-only composition specification connecting to the attendance analysis. Document reduced support and precision. Later grades in an already-treated region are not automatically spillover-free controls.
  **Partial completion, October 18, 2026:** F02.4 implements the ninth-grade-only component and exports its region/cohort support and weights. Its controls are not-yet-exposed regions because ninth grade is an entry grade. The separate all-grade sensitivity excluding controls in already-exposed regions remains open.
- [ ] **F17.5** Check GPA normalization within year × grade; harmonize low-income/SEP coding around 2015–2016; compare predetermined entrant-size weights with weights using observed, potentially treatment-responsive class sizes.

**Deliverables:** support/weight tables, observability results, and sensitivities with population changes explained. Fee-paying schools are not automatically unaffected controls, and TWFE is not a default remedy.

## F18 — Historical value added and ancillary null results

**Priority: P2. Status: interpretation partly corrected; replication/precision work open.**

- [x] **F18.1** Qualify historical profiles in the introduction and document selected historical value-added coverage in the appendix. These profiles are not lottery-validated effectiveness for current applicants.
- [ ] **F18.2** Carry that qualification into Section IV's remaining “more effective for comparable students” and demand interpretations. Explicitly describe selection into graduation, linked SIMCE, and observed PSU.
- [ ] **F18.3** Recover the upstream historical value-added code, which is not fully reproduced by the finalized entrant panel. Document exact score functions/polynomials, fixed effects, normalization, weights, missing-control treatment, sample, and school/group uncertainty calculation.
- [ ] **F18.4** Audit control dates, especially income reported at PSU registration. Compare a baseline-controls-only specification with the current one; propagate estimated school-effect uncertainty appropriately.
- [ ] **F18.5** Report justified confidence intervals for entrant counts and grade coverage. Explain changes still compatible with the data; the coverage estimate −0.011 (SE 0.010) is not evidence that selection is absent. Use the final inference approach from F13–F14.

**Deliverables:** reproducible historical-profile specification and coverage/precision table, with claims limited to what those data establish.

## F19 — Why lotteries: a different target, not a blanket rejection of DiD

**Priority: P2. Status: core framing addressed.**

- [x] **F19.1** Motivate lotteries as identifying attendance effects for offer-responsive applicants. Current Section V and the background appendix separate that target from the rollout's limited later-outcome support, including the Metropolitan Region.
- [x] **F19.2** Remove the blanket argument that national entrance-exam changes make all staggered DiD unusable. The active lottery motivation does not rely on that argument.
- [ ] **F19.3** In the final estimand/calendar pass, explicitly preserve the distinction between unavailable nationwide coverage and potentially identifiable early-region ATTs. If discussing exam regimes, treat differential exposure as a heterogeneity/identification question rather than an automatic failure of either design.

**Closure:** maintain this framing while integrating new analyses; no new policy-outcome design is required solely to close F19.

## F20 — Exclusion with attendance pooled across 1,045 schools

**Priority: P1. Status: substantial new analysis completed; interpretation and manuscript integration remain.**

- [x] **F20.1** State the substantive exclusion restriction, including school changes that leave pooled attendance unchanged. Current Section V covers both within-set and outside-set school changes. The first-choice appendix now states that changing the instrument does not remove pooled-treatment exclusion/monotonicity assumptions.
- [x] **F20.2** Estimate offer effects directly on the main outcome-specific samples, with the same controls and fixed effects as 2SLS. `DIAG/offer_and_attendance_effects.csv` contains RF, first stage, IV, SEs, pointwise intervals, and p-values. OLS RF uncertainty is estimated directly, not obtained by multiplying the IV SE by the first stage. Numerical reproduction and estimator identities pass as documented above.
- [x] **F20.3** Add the offer table to the paper and cite it in the main results. Evidence: offer table (`PAPER/Initial submission/tables/results/lottery_college_offer.tex`), appendix subsection `app:lottery-offer-effects`, and Section V's main-estimates footnote. The footnote reports the −1.95/−1.40/−1.47 pp on-time offer effects and distinguishes their assumptions from attendance LATE assumptions.
- [x] **F20.4** Recover submitted choices and placements, validate the join against finalized variables, and construct the two predetermined simpler-list samples described above. Evidence: `upstream_reconciliation.csv`, `sample_counts.csv`, `choice_sample_support.csv`. Restrictions use submitted choices and origin status, not realized destination, compliance, or outcomes.
- [x] **F20.5** Estimate balance, first stages, RF and IV outcomes in both restricted samples at both horizons. Evidence: `choice_sample_balance.csv`, `choice_sample_balance_joint.csv`, `choice_sample_first_stages.csv`, `choice_sample_outcomes.csv`. Joint balance p-values are 0.874 and 0.536. On-time graduation offer effects are −2.68/−3.93 pp and SUA enrollment effects −1.94/−2.18 pp; these are significant at pointwise 5%. Eventual assignment is not significant in either restricted sample; eventual SUA enrollment is significant only in the single-OD sample. Report the complete pattern rather than selecting the strongest results.
- [x] **F20.6** Tabulate observed destinations and estimate unconditional offer effects on target attendance, other-OD attendance, listed/unlisted non-OD attendance, and no enrollment record. Evidence: `observed_school_destinations.csv`, `target_and_alternative_offer_effects.csv`. These are observed distributional changes, not identified individual counterfactual school switches.
- [x] **F20.7** Estimate target-school-attendance IV sensitivity in the simpler-list samples. `target_school_attendance_effects.csv` shows changes of at most about 0.021 pp from the corresponding pooled-treatment estimates. The instrument is still the original pooled offer; the single-OD sample has one offer outside the designated target, the two-choice sample zero. Do not describe this as a newly simulated school-specific instrument.
- [ ] **F20.8** Integrate the simpler-list results and destination diagnostics into an appendix exhibit with a concise main-text interpretation: exact restrictions, share of main sample (22.3%/5.9%), balance/support, first stages, full outcome pattern, and changed baseline characteristics. These samples have lower GPA/more low-income students and need not identify the main population's effect.
- [ ] **F20.9** Determine whether school-specific assignment simulation draws can be recovered or regenerated. **Conditional:** use them to characterize assignment identity/type changes under redraws. Separate these from subsequent enrollment behavior: simulator counterfactual assignments do not identify individuals' counterfactual attendance or always-/never-taker outcome effects.
- [ ] **F20.10** Write the remaining identification argument and limits. The completed diagnostics reduce some treatment-version complexity but do not prove exclusion. Decide whether maintaining a qualified pooled LATE plus prominent RF evidence is defensible; **conditional alternative:** develop a school-specific/multiple-treatment specification if needed and supported by the data. Apply F22–F24 to any preferred specification.

**Closure:** completed diagnostics are visible and interpreted accurately, remaining assumptions are explicit, and the manuscript does not claim that offer randomness or similar restricted-sample estimates establishes exclusion.

## F21 — Monotonicity and the pooled offer intervention

**Priority: P1. Status: prose corrected; diagnostic coverage incomplete.**

- [x] **F21.1** State individual attendance monotonicity separately from fixed submitted preferences and a positive average first stage. Current Section V recognizes later applications/enrollment choices and labels the aggregate first stage as relevance evidence.
- [x] **F21.2** Estimate first stages for the main and two predetermined simpler-list samples. Saved results are in `choice_sample_first_stages.csv`; these are not the full subgroup audit requested by the report.
- [ ] **F21.3** Define the counterfactual change in underlying random assignment represented by the pooled binary offer, and explain the assignment/behavioral conditions needed for monotone attendance responses. Address subsequent applications, sibling choices, and outside options.
- [ ] **F21.4** Report first stages and intervals by application year, propensity/support group, baseline achievement, priority category, and relevant pre-assignment school/choice types. Include counts and overlap; avoid post-treatment subgroup definitions. Investigate negative or weak subgroup estimates without treating positive subgroup averages as proof of individual monotonicity.

**Deliverable:** explicit assumption statement plus subgroup first-stage/support table, coordinated with F22/F28.

## F22 — Exact versus rounded propensity-score conditioning

**Priority: P1. Status: baseline balance exists; requested outcome sensitivities open.**

- [x] **F22.1** Document that exact-score randomization is approximated by simulated rounded groups, and report existing hundredth/thousandth balance. Current text acknowledges the approximation. The finer-score balance column changes sample from 176,321 to 167,348 before the main complete-control restriction.
- [ ] **F22.2** Build the common eligible complete-case sample for hundredth and thousandth specifications. Explain the 8,973-applicant finer-score loss, including singleton/lack-of-overlap handling. Estimate the primary RF/FS/IV outcomes on this same sample under both groupings; also report each specification on its full eligible sample so specification and population changes are separated.
- [ ] **F22.3** Estimate propensity-group × application-year fixed effects and a defensible smooth/exact-probability adjustment, if unrounded probabilities can be recovered. Report functional form, support, balance, and outcome sensitivity; do not label rounded probabilities “exact.”
- [ ] **F22.4** Audit near-zero/one probabilities and rounding. Some genuinely randomized applicants round to 0 or 100; do not silently treat rounded endpoints as deterministic. Report exact/simulated support, arm counts, trimming rules, and resulting population changes.
- [ ] **F22.5** Document simulation error and reconstruction: one million draws imply a maximum binomial Monte Carlo SE near 0.0005 when draws are independent; assess uncertainty near support/bin boundaries and dependence across simulated assignment probabilities. Verify cohort-specific quotas, sibling rules, priorities, capacity, seeds, and algorithm version. Distinguish replaying observed placements from validating probabilities across redraws.

**Deliverable:** same-sample specification table plus support/simulation audit. The completed F20 diagnostics retain hundredth conditioning and do not close these tasks.

## F23 — Controls may be measured after the offer

**Priority: P1/P2. Status: open.**

- [ ] **F23.1** Build a year-specific timing table: applications, frozen priorities, lottery draw, notification, and measurement dates for each control. Distinguish application-time eligibility rank from subsequently observed year-end GPA/rank.
- [ ] **F23.2** On a common sample, compare main RF/FS/IV estimates using (a) propensity/year effects only, (b) unquestionably pre-offer controls, and (c) all current controls. Show available-sample versions separately if dropping controls changes N. An application-year variable is not automatically pre-offer.
- [ ] **F23.3** Check the top-20% indicator coded zero in 2016 because it is unavailable. Compare dropping that control, using comparable later years, and a transparent missingness treatment where appropriate. Do not interpret unavailable as substantively outside the top group.
- [ ] **F23.4** Decide and document the preferred specification after the timing evidence. Update balance descriptions, tables, notes, and diagnostic scripts consistently if the baseline changes.

**Closure:** the preferred control set has defensible timing, and readers can see how potentially post-instrument adjustment affects the conclusions.

## F24 — Lottery inference must reflect the assignment design

**Priority: P1. Status: baseline variance conventions documented; design benchmark open.**

- [x] **F24.1** Document existing conventions. The diagnostic RF uses HC1 with finite-sample adjustment and t-based inference; baseline IV uses heteroskedasticity-robust inference without the finite-sample correction and normal critical values. Saved direct-SE/FWL checks confirm implementation. This is not a validation of sampling coverage under matching dependence.
- [ ] **F24.2** Obtain/regenerate algorithm-preserving lottery redraws with fixed capacities, submitted preferences, priorities, sibling rules, and year-specific algorithms. First resolve the school-set classification issue in F11 and support/conditioning in F22. Never replace this with independent Bernoulli offer draws or unconstrained label shuffles.
- [ ] **F24.3** Benchmark offer-effect inference under a clearly stated sharp null, specifying the statistic, conditioning, allowable assignments, Monte Carlo p-value calculation, and uncertainty from finite draws. Compare with reported robust intervals/p-values.
- [ ] **F24.4** For attendance effects, choose inference valid for the stated compliance/treatment model, potentially by test inversion where justified. Do not permute outcomes or offers and treat the resulting distribution as generic IV inference while ignoring compliance and multiple treatment versions.
- [ ] **F24.5** Assess family and pre-assignment-school dependence using available links; justify the relevant unit of uncertainty and any clustering sensitivity. Realized destination is post-offer, and the sixteen rollout regions are not automatically the lottery's sole independent units. State the interference assumptions for interpreting offer effects.

**Deliverables:** inference memo, simulator provenance, and primary-outcome comparison. Heteroskedasticity-robust inference is a verification concern, not an established error.

## F25 — Regular-secondary graduation versus all secondary completion

**Priority: P1. Status: definition documented; broader outcome analysis open.**

- [x] **F25.1** Specify that the reported outcome requires regular twelfth-grade promotion; preserve the original lottery sample and entry-year attendance definition after transfers. Evidence: outcome footnote and appendix; the introduction already calls the main estimate regular-secondary graduation.
- [ ] **F25.2** Audit adult-education and other recognized completion records. **Conditional on coverage:** construct any recognized secondary completion alongside regular completion, with mutually interpretable dates and fixed horizons. Report record coverage if comprehensive completion cannot be observed.
- [ ] **F25.3** Estimate RF/IV effects on adult-education participation/completion and trajectories distinguishing delayed regular graduation, grade repetition/failure, transfer, and absence from registries where the data permit. Do not condition the main outcome sample on post-offer graduation or continued attendance.
- [ ] **F25.4** Update abstract, results, headings and notes consistently. Do not equate absence of regular graduation with dropout or assume it mechanically precludes every college route without verifying credential requirements.

**Deliverable:** completion/trajectory table with definitions, coverage, and common horizons (F10/F27).

## F26 — Total higher-education enrollment and substitution

**Priority: P1. Status: open.**

- [ ] **F26.1** Validate that SUA and outside-SUA first-enrollment categories are mutually exclusive and exhaustive among observed enrollments on the analysis sample, including the same-year SUA tie rule. Construct `ANY_HE = INSUA + OUTSIDE` for each horizon and verify against raw enrollment records.
- [ ] **F26.2** Directly estimate RF/FS/IV effects on any higher-education enrollment, with SEs, confidence intervals, exact p-values, and means. Use the same sample/specification as the component rows. Baseline rounded IV sums are **−2.90 pp on time** and **−0.90 pp through last record**; comparison means sum to **46.99%/67.93%**. These are arithmetic checks, not inferential results.
- [ ] **F26.3** Save the joint covariance of component effects and test the total/offset claims. Assess whether outside-SUA gains could meaningfully offset SUA losses; an insignificant outside coefficient does not establish no substitution. Avoid unstable offset ratios without appropriate uncertainty.
- [ ] **F26.4 — conditional on longitudinal records.** If discussing later sector transfers, estimate any observed enrollment in each sector regardless of first route. Keep these potentially overlapping outcomes distinct from the mutually exclusive first-route decomposition.
- [ ] **F26.5** Replace the current no-offset interpretation with the directly estimated total and uncertainty. Incorporate total enrollment into the primary-outcome family in F29.

**Closure:** conclusions about total enrollment and substitution follow from estimated joint uncertainty, not significance stars on separate rows.

## F27 — Unequal follow-up and fixed-horizon effects

**Priority: P1. Status: existing first-choice evidence; main-design analysis remains.**

- [x] **F27.1** Document finite follow-up and existing fixed-horizon first-choice evidence. The main outcomes end in 2025/2026; 2021 applicants have no additional follow-up beyond the scheduled horizon. Section VI compares the same 23,754 first-choice applications from 2016–2019 across three horizons. This does not substitute for the requested main propensity-score analysis.
- [ ] **F27.2** Build a cohort × outcome × calendar-horizon availability matrix using verified extraction dates. Select common cohorts observed through scheduled, +1-year, and +2-year horizons for the **main propensity-score design**. Use the same applicants across compared horizons and show attrition/coverage handling.
- [ ] **F27.3** Estimate cumulative regular/any graduation, application, assignment, SUA enrollment, and any HE on that common sample. Save cross-horizon covariance and test differences, not just whether one coefficient is significant and another is not.
- [ ] **F27.4** Report cohort-specific or defensibly grouped effects by pandemic school exposure and exam regime, with counts, first stages, and uncertainty. Treat this as possible heterogeneity; do not assume national exam changes invalidate within-cohort random offers.
- [ ] **F27.5** Replace lifetime/permanent interpretations of “ever” with “observed by [date]” or explicit horizons. Distinguish evidence consistent with catch-up from a statistically demonstrated cross-horizon change.

**Deliverables:** fixed-horizon main-design table/figure, covariance-based contrast tests, and revised follow-up language.

## F28 — Complier characteristics, weights, and heterogeneity

**Priority: P2. Status: weighted-LATE prose corrected; weighting audit open.**

- [x] **F28.1** Describe the coefficient as a weighted LATE and label without-offer means as the benchmark for reported proportional declines. Current Section V does this; those means are not automatically compliers' untreated means.
- [ ] **F28.2** Recover the complier-characteristics construction, which is outside the finalized two-notebook handoff. Derive the weighting induced by the actual rounded-score, additive-year, covariate-adjusted IV model. Do not apply the exact saturated-strata formula `n_s p_s(1−p_s) π_s` without checking its conditions.
- [ ] **F28.3** Present either a profile using the estimate's relevant weights or a clear distinction between equal-complier characteristics and the main estimand. Export probability/support/weight distributions by cohort and region, including excluded deterministic applicants and influential/sparse groups.
- [ ] **F28.4 — conditional on emphasis.** If proportional causal effects are central, estimate appropriately identified complier untreated means and their uncertainty. Otherwise retain without-offer means as descriptive benchmarks and say so.
- [ ] **F28.5** Specify a limited set of motivated heterogeneity analyses: pre-offer achievement, low-income status, and baseline PACE-school exposure. Report subgroup first stages, RF/IV estimates, tests of differences, and multiplicity treatment. Do not define groups by realized destination, graduation, or eligibility; distinguish heterogeneous effects from changes in complier populations.

**Deliverables:** weighting derivation/profile table and a focused heterogeneity table, linked to F03/F21/F30.

## F29 — Primary outcomes, reduced forms, and joint uncertainty

**Priority: P2. Status: RF estimation and manuscript reference completed; combined presentation/joint inference open.**

- [x] **F29.1** Estimate and save RF/first-stage/IV results with direct SEs, pointwise CIs and p-values; verify RF/FS equals IV on identical outcome-specific samples. The 13-outcome diagnostic includes score outcomes on their observed-score samples, with the appropriate outcome-specific first stages.
- [x] **F29.2** Add a ten-outcome, two-horizon offer table to the appendix and explain key RF estimates in the Section V footnote. This is actual estimated offer evidence, not merely the arithmetic approximation −2.36 × 0.6257.
- [ ] **F29.3** Present RF, first stage, and IV together for a concise primary set: regular-secondary graduation, any HE, SUA assignment and enrollment. Add confidence intervals/exact p-values; identify the sample and inference method for each row. Include F25's broader credential outcome where available.
- [ ] **F29.4** Define defensible outcome families and joint/multiplicity procedures that respect dependence and the final assignment/inference design. Report unadjusted and adjusted/family-level evidence, including the less decisive eventual assignment result. State that these are retrospective analytical choices; do not invent a preregistration.
- [ ] **F29.5** Update headline significance claims after F22–F24/F26–F27. Distinguish a stable point estimate from stable uncertainty, and distinguish a numerical identity from independent evidence of robustness.

**Closure:** readers can assess assignment effects, attendance assumptions, and joint uncertainty without reconstructing them across tables.

## F30 — Mechanism claims and unfinished relative-standing analysis

**Priority: P1. Status: several claim corrections completed; key analyses remain.**

- [x] **F30.1** Remove the specific unsupported introductory finding that BEA top-10% eligibility falls. The current introduction describes eligibility as a potential channel. The abstract now uses “evidence consistent with” potential channels rather than identified channels; its remaining relative-standing claim still needs the exhibit check in F01.3.
- [x] **F30.2** Qualify score effects as conditional on observed scores, and describe the regular-cutoff exercise as accounting/sensitivity rather than causal mediation. Current mechanism text/appendix already includes score availability, balance, a common-score sample, trimming sensitivity, and accounting qualifications. These analyses predate this checklist and do not identify effects for always-observed students automatically.
- [ ] **F30.3** Complete the visible relative-standing task in Section VI. Establish BEA and PACE year-specific criteria first (F08); distinguish GPA rank, current class rank, official Ranking score, and percentile/absolute eligibility alternatives. Estimate effects on the relevant indicators with explicit denominators, coverage and uncertainty, or remove the corresponding empirical claim if it cannot be supported.
- [ ] **F30.4** Audit the school-participation-in-PACE channel separately from rank eligibility and actual reserved-seat selection. Show how offer-induced attendance changes school exposure and subsequent recorded eligibility; do not condition outcome effects on realized eligibility to claim mediation.
- [ ] **F30.5** Report score participation effects alongside conditional score effects. Review existing trimming assumptions and, where feasible, bound effects for a meaningful common observation population under explicit selection assumptions. State what remains unidentified when observation monotonicity or comparable support fails.
- [ ] **F30.6** Audit the program-specific score accounting using the correct scales, weights, eligibility, applications, and cutoffs by year. Do not infer that −0.180/−0.227 SD grade-based changes outweigh +0.033 SD test performance merely by comparing SD units. Holding post-offer program lists fixed yields an accounting exercise, not a causal mediation share or equilibrium policy simulation.
- [ ] **F30.7** Test predicted main-outcome differences by predetermined exposure to school-based rules, coordinating with F28.5. Discuss competing explanations such as academic mismatch, grading/failure, effort, and travel where observable; retain descriptive language when the channels cannot be separately identified.

- [x] **F30.8 — Adopt the expanded score baseline (author decision, October 19).** New private `section3_score_baseline_v1_2026-10-19.rds` retains all 304,547 finalized panel rows and original columns; `score_analysis_design_sample` selects the unchanged 175,869-student controls-complete lottery population before score availability. Main `NEM_ANALYSIS_Z`/`RANKING_ANALYSIS_Z` retain available latest official scores through 2026 and otherwise use independent reconstruction. Outcomes are available for 154,620/154,170 students, versus 137,480 each originally. The cohort-keyed national export, source labels, frozen normalization moments, hashes and by-year/offer coverage are generated by the central notebook's four `f08-adopted-score-*` chunks. Peer-based calibration is excluded from the main baseline. Original private files and manuscript estimates are preserved.
- [ ] **F30.9 — Estimate expanded-sample score effects.** Read the linked baseline panel; use `D_OD` instrumented by `OFFER`, hundredth `CHANCE_GROUP` fixed effects, application-year indicators and the original five controls/inference conventions. Do not select on exams, original scores, realized PACE school, or graduation. Estimate RF/FS/2SLS on each outcome's available sample, and availability effects on the full design population. Report N, first stage, non-offered mean, uncertainty and cohort/offer coverage. Compare original Table 4, the new definition on a common observed sample, and the expanded sample to separate changes in units/vintage from sample expansion. Uniform reconstruction and graduation-cohort/fixed-horizon outcomes are sensitivities. Save coefficients and covariance matrices before updating exhibits.
- [ ] **F30.10 — Remaining linkage and observation selection.** The full design sample has 68 original NEM and 98 original Ranking standardized observations with no positive raw counterpart in either available source and no usable reconstruction. Original columns are preserved and `*_RAW_SOURCE_UNRESOLVED` flags these cases; recover their source or report explicit common-sample/bounded sensitivity. Do not fill by mixing old and new SD units. Report the 21,249/21,699 remaining missing expanded outcomes, their offer effects and reasons. Including non-exam takers does not by itself identify an unconditional score effect for every lottery applicant or remove graduation-related selection.

**Closure:** every mechanism claim has a completed exhibit, correct institutional rule, explicit selection/conditioning treatment, and appropriate causal or descriptive interpretation.

## F31 — Presentation and terminology

**Priority: P2. Status: title/roadmap corrected; final consistency pass remains.**

- [x] **F31.1** Update title and introduction roadmap to match the attendance focus and Sections IV–VI. Evidence: `main.tex` and `1_introduction.tex`.
- [ ] **F31.2** Standardize terms across text, tables and notes: offer versus attendance; college application versus assignment versus enrollment; regular-secondary graduation; SUA membership versus selectivity; mathematics–reading mean with historical exam names explained; first observed route versus any sector enrollment.
- [ ] **F31.3** Remove Table I's orphan “Panel A” if still present and make its sample, equal-school weighting, and essential descriptive notes self-contained.
- [ ] **F31.4** Label map dates as application process or school entry. Label event-study share units, pointwise intervals, reference period, and joint tests consistently; preserve the documented three-adoption-group display rule where applicable.
- [ ] **F31.5** Resolve/remove visible author notes after moving their substantive tasks to this checklist. A fee-paying-school placebo proposal must be interpreted as a potential spillover analysis, not a guaranteed untreated comparison. Complete terminology and cross-reference checks after substantive revisions stabilize.

**Deliverable:** compiled manuscript with consistent outcome/estimand labels, readable notes, no unresolved public author comments, and accurate references.

## F32 — Reproducible path from data and code to claims

**Priority: P1/P2. Status: substantial infrastructure added since the report; end-to-end coverage incomplete.**

- [x] **F32.1** Provide finalized access/lottery notebooks, READMEs, input checksums, package versions, and environment lockfile. `CODE/HANDOFF.md` reports successful October 15 execution and byte-identical tables, with event-study PDFs differing only in date metadata. This review verified the files exist, not that historical execution claim independently.
- [x] **F32.2** Provide an executable adversarial-diagnostic notebook with rendered report, input/runtime provenance, aggregate CSVs, upstream reconciliation, estimator checks, and the generated offer table. The saved October 17 outputs support completed F20/F29 tasks.
- [ ] **F32.3** Extend the manifest to **every** main/appendix exhibit and factual number: raw/source vintage, construction script, analysis script/chunk, sample definition, options, output, manuscript destination, and run status. Explicit gaps include upstream historical value added, complier characteristics, first-choice IV, mechanism construction, and full simulation provenance; the two finalized notebooks are not the entire project.
- [ ] **F32.4** Preserve seeds/schedules/draw counts, algorithm and package versions, C&S options (unbalanced panel, universal `g−1` base, not-yet-treated controls, no anticipation, aggregation), institutional rule tables, and geographic crosswalks. Distinguish 9,999 versus 2,999 permutation schedules and bootstrap iterations in each output; do not assume all specifications use the same counts.
- [ ] **F32.5** Save machine-readable coefficients, covariance matrices, sample flags/counts and contrasts for all new analyses. Generate paper tables, figures, and quoted values from these outputs. Record changes from the baseline without silently overwriting it.
- [ ] **F32.6** Complete a record-level construction audit for duplicate applicants/IDs, repeated processes, earliest-application rules, missing controls, school changes, outcome dates, and linked-record conflicts. Release only aggregate diagnostics or disclosure-safe examples; document restricted-data access and local path setup.
- [ ] **F32.7** Have a coauthor reproduce the final package from documented inputs/environment. Inspect logs for swallowed errors, checksum real input files, compare numeric outputs across platforms, and explain any differences due to package versions, collation, RNG order, or line endings. The handoff documents platform-specific issues that should not be mistaken for substantive replication failures.
- [ ] **F32.8** Create a final report-response crosswalk: each F01–F32 finding, decision, evidence/table, manuscript location, and any remaining limitation. A resolved concern can end in a narrower claim if the stronger claim is not identified; it need not end in a statistically significant robustness result.

- [ ] **F32.9** Add the diagnostic notebook and the aggregate, disclosure-safe outputs needed to inspect the completed tasks to the shared repository, or document their shared location. Check output contents and exclude input records/caches before publishing; confirm that a fresh clone can locate the evidence. These files were still untracked when this checklist was moved into the repository.

**Closure:** another authorized researcher can reproduce the final claims and understand deviations from the audited baseline without relying on undocumented conversation history.

## Standard deliverable for each empirical task

Unless a task specifies otherwise, save one machine-readable results file and a short interpretation note containing:

1. Task ID(s), author/agent, date, input hashes/vintage, script/chunk, environment and command.
2. Treatment/instrument, outcome definition and units, horizon, population, eligibility restrictions, comparison support, fixed effects/controls, weights, and missingness conventions.
3. Sample/arm counts, first stage when applicable, estimate, SE, confidence interval, exact p-value, inference method/null, and relevant covariance/contrasts. Save full precision and label pointwise versus joint inference.
4. Baseline comparison: whether estimate, uncertainty, population, or interpretation changed; why the analysis addresses the specific report concern; what it cannot establish.
5. Manuscript table/figure/text destination, plus remaining dependency or limitation. Preserve negative/null results and failed checks with an explanation.

Use the existing code repository for new analyses and aggregate outputs; use this `Reviews` file to track progress. Do not put individual administrative records in the manuscript repository. Proposed diagnostic filenames may follow `Fxx_short_description`; they are not evidence of completion until outputs exist.

## Final integration gates

- [ ] **G01 — Evidence reconciliation.** All headline estimates, horizons, labels, and uncertainty match generated outputs; F16 discrepancy is resolved and unfinished BEA/PACE claims are removed or supported.
- [ ] **G02 — Lottery credibility.** F20–F24 have completed evidence or an explicit documented limitation and correspondingly narrowed interpretation. RF results remain distinguished from attendance effects.
- [ ] **G03 — Outcomes and population.** F10/F25–F28 establish what completion/enrollment, follow-up, linkage, and complier population mean. Any HE and common-horizon results are visible.
- [ ] **G04 — Rollout credibility.** F09/F11–F17 establish the population/support and a coherent estimator/test/null; remaining selection/anticipation limits are stated.
- [ ] **G05 — Contribution and sources.** F01–F08/F18/F19/F30 align claims with designs, institutional years, completed exhibits, and correctly described prior work.
- [ ] **G06 — Reproduction and presentation.** F29/F31/F32 are integrated; compile the manuscript, inspect tables/figures and references, and update the report-response crosswalk.

### Update log

| Date | Update | Evidence basis |
|---|---|---|
| 2026-10-17 | Initial checklist covering F01–F32; completed framing, code handoff, offer effects, and simpler-list diagnostics distinguished from remaining work. | Current manuscript, finalized notebooks/READMEs, handoff, and saved diagnostic outputs; no fresh empirical re-estimation in this review. |

| 2026-10-17 | Moved the canonical checklist to the shared analysis repository, added a README entry, replaced manuscript-relative links with portable `PAPER` paths, and recorded pending publication of local diagnostic artifacts. | Repository status at relocation; checklist content and completion evidence otherwise preserved. |
