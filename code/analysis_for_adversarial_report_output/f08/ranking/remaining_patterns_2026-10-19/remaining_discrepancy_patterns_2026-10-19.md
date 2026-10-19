# Remaining Ranking discrepancies — October 19, 2026

**Conclusion:** small-school pooling is not the main pattern among observed-score students whose Ranking can be reconstructed. Most remaining mismatches are small and occur despite matching NEM and adequate observed historical references. Disagreement in NEM identifies a much smaller group with disproportionately large Ranking errors. The data identify diagnostic patterns, not the exact administrative cause.

The latest first-pass-reference candidate is validated on 1,033,587 students, with 95,985 mismatches (90.71% exact). The accepted narrow HHTT baseline is reported alongside it in `overall_comparison.csv`; the tiny reference refinement does not materially change this diagnosis.

## Pooling, reference size and coverage

99.41% of mismatches occur where every relevant school has at least 30 observed prior fourth-grade graduates. Even counting graduates separately by HC/TP modality, 93.45% of mismatches have counts of at least 30 in every context. These are observed-extract proxies for the pooling criterion, not verified official rosters.

96.93% of mismatches have all three usable historical cohorts. Students with a smallest usable context reference of 30–59 have a higher mismatch rate (14.22%) than those with at least 300 (7.85%), but the 30–59 group accounts for only 5.90% of mismatches.

**Coverage caveat:** the scoring rule leaves contexts below 30 usable reference records unresolved. The validation sample therefore omits many genuinely small or incomplete references. Pooling still matters for recovering those unavailable scores; the statistics above describe remaining errors in scores we can already calculate. `coverage.csv` retains the excluded and unobserved-score categories.

## Two distinct residual problems

**Numerous small differences:** 57.67% of all mismatches are exactly one point and 79.65% are at most five points. Among mismatches with exact NEM, 87.94% are at most five points. Even the clean one-context group, with exact NEM, three usable cohorts and school/modality counts of at least 30, contains 62,772 mismatches, 65.40% of the total. This directs attention to historical benchmark construction, grade versions and arithmetic precision. It does not establish that rounding alone is responsible.

**Large differences linked to NEM disagreement:** NEM differs for only 1.02% of validated students. In that group, 97.39% also have a Ranking mismatch; the group contributes 31.92% of total absolute Ranking error and 47.06% of errors exceeding five points. This is consistent with an upstream academic-record discrepancy affecting both scores, although NEM and Ranking also share conversion and floor mechanics.

The following decomposition is mutually exclusive, prioritizing NEM disagreement, then small/unknown school counts, small/unknown modality counts, short histories, and finally number of contexts. Its ordering is stated so shares are not mistaken for independent causal contributions.

| Diagnostic group | Mismatches | Within-group mismatch rate | Share of mismatches | Share of absolute error |
|---|---:|---:|---:|---:|
| One context; NEM matches; three cohorts; counts >=30 | 62,772 | 7.45% | 65.40% | 42.27% |
| Multiple contexts; NEM matches; three cohorts; counts >=30 | 15,715 | 11.48% | 16.37% | 10.02% |
| NEM differs | 10,263 | 97.39% | 10.69% | 31.92% |
| Short history; NEM matches; counts >=30 | 1,188 | 12.69% | 1.24% | 4.95% |
| Small/unknown modality count; NEM matches | 5,532 | 18.44% | 5.76% | 10.35% |
| Small/unknown school count; NEM matches | 515 | 13.47% | 0.54% | 0.49% |

## Other recurring patterns

- Technical graduates have a 13.09% mismatch rate, versus 7.78% for scientific-humanistic graduates. This association is not an adjusted causal comparison.
- Rates are 13.84% for students who changed school, 14.09% for within-school modality changes, and 7.38% for the same school and modality throughout. Nevertheless, the stable-school/modality group contains 56.35% of all mismatches because it is much larger.
- School-year concentration is reported in `school_year_concentration.csv`. Concentration by itself cannot distinguish reference-data errors from differences in student histories or school composition.

**Next diagnostic priority:** reconcile academic records for NEM-mismatched students to address large errors, and inspect historical means/maxima and precision among exact-NEM students with one context and full references to address the bulk of mismatch counts. Pursue official pooling assignments in parallel as a coverage task, rather than assume they explain the majority of currently observed score errors.

## Reproduction and checks

Run from `code/` the notebook chunks `f08-score-reconstruction-functions`, `f08-ranking-remaining-patterns`, and `f08-ranking-remaining-patterns-report`. Inputs are the saved diagnostic records, accepted context candidate, first-pass reference candidate and reference summaries, plus the accepted-context cache. Historical counts and context counts are recomputed for the latest candidate; the old two-context classification of narrow HHTT histories is not reused.

Checks ensure unique graduate keys, the expected same-sample count, and the minimum usable context size in the scored sample. Aggregate decomposition totals are checked against the overall score errors. No predictions, observed scores or manuscript estimates are changed. Only aggregate diagnostics are shared.
