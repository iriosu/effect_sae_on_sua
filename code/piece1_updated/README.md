# Piece 1 - Updated: Entrant Composition with Studentized Randomization Inference

This folder is the updated inference package for Piece 1. It contains one analysis
file, the tables and figures it writes, and a plain-language description. The
data, design, and estimator are the certified Piece 1's; both outcomes cover
2012--2023, and significance is scored by a studentized randomization statistic.
Read `PIECE1_UPDATED_DESCRIPTION.md` first; it explains the piece and carries the
two references (Young 2019 QJE; MacKinnon and Webb 2020 JoE).

## The result

```
Headline (all grades, 2012-2023):
  Entrant prior-GPA (z)    -0.150*** (0.031)    76,702 cell-years
  Share prioritario        +0.035*** (0.009)    97,381 cell-years
Robustness (entrant GPA): all five columns ***.
Event studies: both outcomes flat pre-door (joint lead p 0.81 / 0.86),
  effects at the door year and +1.
Guards: unstarred under both scoring rules.
```

## What's here

| File | Role |
|------|------|
| `1_effect_sae_alloc_updated.Rmd` | **Analysis.** Reads the Piece 1 panel of record (MD5-pinned), replays the certified computation with halting asserts on every certified number, adds the studentized test to every exhibit, writes the three tables and both event-study figures. |
| `PIECE1_UPDATED_DESCRIPTION.md` | The piece in plain language, with the references. |
| `tables/`, `figures/` | Generated outputs. |
| `run_log_2026-08-31.txt` | Console log of the record run. |

## How to run

Requires R 4.5.1 with `did` 2.1.2 (the analysis halts on any other version; install
the pinned version with `remotes::install_version("did", "2.1.2")`). The panel of
record `entrant_composition_panel.rds` is read from a copy next to this file, from
the Piece 1 package folder, or from the shared data folder, in that order; its MD5
is asserted. Knit `1_effect_sae_alloc_updated.Rmd` or run its purled script. The
permutation scoring uses 16 local workers, and the results are worker-count
invariant because every permutation stream is drawn sequentially in the main
process before any scoring is distributed (the analysis halts if the panel
fingerprint, the pinned package versions, or its internal consistency checks
fail).

## Provenance and records

The panel is built by the certified Piece 1 package (`00_build_entrant_panel.Rmd`
there; provenance and raw-data documentation live in that folder's README). The
update's registrations are in `specs/spec_registry.csv` (the 2026-08-30 ALLOC-*
rows), the runs in `logs/run_ledger.csv` (RUN-337 through RUN-345 plus
EXPLORE-090/091), the strategy memo behind the test in
`quality_reports/strategy/2026-08-30_access_power_design.md`, and the development
record (pre-run adversarial reviews, byte-identical determinism rerun, four-attacker
final gate) in `quality_reports/session_logs/2026-08-30_piece1_prio_interaction.md`
and the exploration folders `explorations/2026-08-30_piece1_rit_update/` and
`explorations/2026-08-30_access_quick/`.

## Design in one paragraph

As the certified Piece 1, verbatim: Callaway--Sant'Anna staggered
difference-in-differences on always-over-demanded school-grade cells, treatment at
the region-by-grade SAE door, not-yet-treated controls, universal base period.
Inference is randomization over which regions received which rollout wave, with the
wave-size multiset held fixed; the update's test statistic divides each draw's
simple ATT by its own delete-one-region jackknife standard error, so assignments
that rest a comparison on a single dominant region are scored against their own
instability. Stars come from the studentized two-sided p; the unstudentized p is
printed alongside in the analysis document and run record.
