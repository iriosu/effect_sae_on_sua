# Adopted score baseline v1 — October 19, 2026

Author-approved baseline for the expanded NEM/Ranking 2SLS analysis. See `Reviews/handoff_abhijit_pace_nem_ranking_2026-10-19.md` for the analysis contract and next tasks.

Version: 2026-10-19 baseline v1: observed scores plus independent reconstruction; narrow HHTT and first-pass historical references

- Private cohort-keyed baseline: `input/f08/score_analysis_baseline_v1_2026-10-19.rds`.
- Private full finalized panel with score links: `input/f08/section3_score_baseline_v1_2026-10-19.rds`.
- Private originally missing-score extract: `input/f08/missing_scores_baseline_v1_2026-10-19.rds`.
- The same three RDS files are also placed in the existing shared Dropbox data folder `Effect SAE on SUA/data/finalized_design_v1/section3/score_baseline_v1_2026-10-19/`. `shared_private_delivery.csv` verifies their byte counts and hashes. Override the destination with `SAE_SCORE_BASELINE_EXPORT_DIR` when needed; differing files at a versioned destination are never silently overwritten.
- Aggregate national coverage, independent validation, standardization moments and Section 3 linkage/coverage are in this folder. Fingerprints cover inputs and new private outputs.

Observed scores are preserved; missing NEM uses the established GPA/history reconstruction, and missing Ranking uses `first_pass_reference_only` (narrow same-school HHTT contexts and first-passed historical references). The independent reconstruction is also retained for observed students to validate accuracy and support a common-measurement sensitivity. Peer-based corrections are excluded from this baseline.

The national export covers regular youth graduates in 2020–2025. Its key is `(MRUN, grad_year)`; five students have multiple cohort records. The linked panel retains all 304,547 finalized rows and every original column. It labels ambiguous histories rather than choosing by score. The design sample remains the 175,869 lottery students with the original five controls, before outcome availability filtering.

**Use `NEM_ANALYSIS_Z` and `RANKING_ANALYSIS_Z` for the expanded main score regressions.** Their raw counterparts are `NEM_ANALYSIS_RAW` and `RANKING_ANALYSIS_RAW`; each has `*_ANALYSIS_YEAR`, `*_ANALYSIS_SOURCE` and `HAS_*_ANALYSIS` provenance. They retain the latest valid official score through admission 2026, including already-scored students without a target regular-secondary graduation, and otherwise use the linked cohort baseline. The outcome extract has priority over the registration projection for conflicting positive records in the same process. `section3_expanded_coverage.csv` is the relevant main-outcome coverage table.

The source audit identifies a small number of old standardized outcomes with no positive raw score in either available source and no usable reconstruction. Their original standardized columns remain unchanged, but `*_RAW_SOURCE_UNRESOLVED` explicitly flags the unavailable new raw/standardized value. Do not mix the old standardized units with new cohort-based units to fill these cases; reconcile their original source or report their exclusion/sensitivity. Counts are in `original_raw_linkage_gaps.csv` and `section3_expanded_coverage.csv`.

The separate `*_BASELINE_BY2025` fields use a unique linked graduation within 2020–2025, with its following-admission-year scale. `*_BASELINE_OT` additionally requires graduation no later than `YEAR + 4`. They are graduation-cohort comparisons and can be missing even when an official score exists outside the target. `section3_coverage.csv` describes these narrower fields, not the expanded main outcomes. No score is set to zero. The original Table 4 score columns remain unchanged for comparison.

SD outcomes for admissions 2021–2026 use the frozen national graduation-cohort/admission-year mean and SD of available observed-plus-reconstructed scores, including nonregistrants. Reconstruction-only checks use the same moments. Retained official scores from earlier processes use explicitly labeled process-level observed-score reference moments because earlier graduate cohorts have not been reconstructed. All moments and sample sizes are exported in `analysis_standardization.csv`; missing scores are excluded from moments rather than assigned a value. This differs from the original standardization; report raw-score checks by cohort and separate changes in coverage from changes in measurement/units. `official_vs_graduation_vintage.csv` documents score-vintage differences.

Run from `code/`: `f08-score-reconstruction-functions`, `f08-adopted-score-baseline`, `f08-adopted-score-panel`, `f08-adopted-score-expanded-panel`, `f08-adopted-score-manifest`. Upstream reconstruction caches must exist; see the handoff for rebuilding them. Private files are excluded from Git and shared through the existing private data workspace.

Validation checks cover unique cohort/student keys, preservation of recorded scores and all original panel columns, unchanged NEM versus the previous delivery, score bounds, expected national reconstruction/validation counts, finalized-panel checksum, fixed lottery/design counts and unresolved ambiguous joins. No new 2SLS effect or full PACE eligibility indicator is asserted by this export.
