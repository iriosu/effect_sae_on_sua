# Piece 1 — Effect of SAE on Allocation (Entrant Composition)

This folder is a self-contained, reproducible package for the first result of the paper:
Chile's centralized school-choice system (SAE) changed **who enrols** at persistently
over-demanded schools. When a school-grade came under SAE and could no longer select its
applicants, its entering class shifted toward students with weaker prior academic records.
The low-income share moves in the same direction and is not independently significant on
this design.

## The result

**Headline** (`tables/alloc_headline.tex`): entrant prior-GPA falls **−0.150** SD
(region-clustered SE 0.031), significant at 1% by randomization inference. The prioritario
(low-income) share moves **+0.035** (SE 0.009) and does not clear its randomization bar.
Significance stars come from randomization inference over the region-to-wave assignment
(9,999 permutations). The bootstrap SE is reported for scale only.

**Robustness** (`tables/alloc_robustness.tex`): six columns, one specification change
each — dropping Santiago entirely, requiring at least five graded entrants per cell-year,
excluding cells whose pre-SAE fill test flags slack, weighting by entrant counts, and
shifting the base period one year before the door. The entrant-GPA effect is negative
and significant in every column, between −0.087 (drop Santiago) and −0.180. Each
column's purpose is explained in `1_effect_sae_alloc.Rmd`.

**Parallel trends** (`figures/alloc_event_study.pdf`): the pre-adoption leads sit on
zero — every lead is under 0.03 SD with its confidence interval straddling zero — and
the exact randomization joint test of the leads does not reject (p = 0.81; seeded,
reproduces exactly). The estimator's own Wald pre-test rejects through one channel: the
single-region Magallanes cohort's disaggregated cells against its door-year base, the
kind of single-region t-statistic this project's inference standard rejects; the
anticipation-1 robustness column addresses that base directly. The analysis document
prints both statistics and the full dynamic path.

**Interpretation guards** (`tables/alloc_guards.tex`): the number of entrants per cell
and the share of entrants carrying a prior GPA, estimated identically to the headline.
Seats are fixed by the school, so the count should not move; the GPA share should not
move with the rollout or the headline could reflect who is measurable (the 2017--2019
migration wave) instead of who is admitted.

## Measurement note (2026-08-16)

An earlier version of this package identified entrants from the graded-performance panel.
That construction implies enrolment from year-end academic records; the census records
enrolment at the annual snapshot. The two registers classify mid-year movers differently,
and that disagreement class nearly doubled between 2013 and 2019, which put a spurious
drift into the entrant definition and broke the pre-trends at non-entry grades. The panel
now identifies entrants from the matricula enrolment census — one fixed instrument,
uniform across years and regions, and the construction of the project's validated original
result. The diagnosis (event study of the discrepancy between the two constructions;
student-level audit classifying every disagreement) is documented in
`00_build_entrant_panel.Rmd` Stage 4 and in `explorations/2026-08-05_priority_quota/R/`
(`_delta_did_diag.R`, `_phantom_audit.R`).

## What's here

| File | Role |
|------|------|
| `00a_pack_raw_data.R` | **Packing.** Reads the 55 raw MINEDUC csv files once → the three rds files in `data/`. Only needed to repack from the original public releases. |
| `data/` | Fallback location for the three packed inputs: `sae_admissions.rds`, `matricula_2011_2023.rds`, `alumnos_sep_2012_2023.rds` (~0.4 GB; the copies of record live in the shared data folder). |
| `00_build_entrant_panel.Rmd` | **Build.** The three packed files + canonical panels → `entrant_composition_panel.rds`. Documents every input and construction step. |
| `entrant_composition_panel.rds` | The analysis panel (one row per always-over-demanded school-grade cell × year; 97,381 rows, 8,958 cells, 2012–2023). Shipped so the analysis runs without rebuilding. Built 2026-08-16 by the shipped build code; MD5 `8ccec73b5955b723485195d5085b669d`. |
| `run_log_2026-08-16.txt` | Console log of the record analysis run: every table, the full dynamic path, and both pre-trend statistics as printed. |
| `1_effect_sae_alloc.Rmd` | **Analysis.** Reads only the panel → the headline table, the robustness table, the guards table, the event-study figure, and the pre-trend statistics. No intermediate CSVs. |
| `tables/`, `figures/` | Generated outputs. |

## Data provenance

**Shared canonical panels** — in `~/Dropbox/Effect SAE on SUA/data/` (identical to the
project `code/data/`), which the coauthors already hold:

- `panel_performance_2002_2023.rds` — the canonical graded panel. Supplies each entrant's
  prior-year GPA (z-scored nationally within year) and the pre-SAE enrolment for the fill
  test.
- `sae_data_2016_2023.rds` — the (COD_ENSE, COD_GRADO) → SAE-level map and declared capacity.
- `panel_ee_2004_2025_homogenized.rds` — school region.

**Packed raw MINEDUC files** — three rds files (~0.4 GB total), built once from the
public releases by `00a_pack_raw_data.R`. They live in the shared data folder alongside
the canonical panels (this package's `data/` folder works as a fallback location; the
build checks the shared folder first). They keep exactly the columns the pipeline reads;
the packing script documents the sources and is the place to repoint if you re-download
the originals. The panel built from these three files is verified identical, value by
value, to the panel built directly from the 55 raw csv files (2026-08-16).

- `sae_admissions.rds` — the SAE offer (A1, processes 2016–2025; the 2016 table times
  the Magallanes door), application (C1) and assignment (D1) tables, processes
  2017–2025. Needed for the over-demand tag. A1 seats verified identical to the
  canonical `sae_data` `VACANTES` (100%, 2026-08-15). These are tables from the same
  yearly SAE release the coauthors read for B1/B2.
- `matricula_2011_2023.rds` — the annual enrolment census. Identifies entrants (see the
  measurement note). Verified a clean superset of the canonical panels' enrolment
  (2026-08-15).
- `alumnos_sep_2012_2023.rds` — the annual SEP-prioritario (low-income) roster
  (`PRIORITARIO_ALU` from 2016, beneficiary roster through 2015). Needed because the
  canonical `panel_9-12` prioritario flag exists only for SAE applicants and cannot tag
  the pre-SAE baseline. Verified against that flag: same concept, ~85% year-aligned
  agreement, the remainder a snapshot-timing difference between two official files.

## How to run

Requires **R 4.5.1 with the `did` package at version 2.1.2** — the analysis pins this
version, because the region-clustered bootstrap standard error is version-specific. It
halts on any other `did` version. Current CRAN carries a later release, so install the
pinned version with `remotes::install_version("did", "2.1.2")`.

The intended workflow: clone the repo (this folder lives under `code/`), have the shared
Dropbox data folder synced at `~/Dropbox/Effect SAE on SUA/data`, and run. All data —
the three packed MINEDUC files, the canonical panels, and the analysis panel
`entrant_composition_panel.rds` (MD5 above) — lives in the shared folder; nothing in the
repo is required beyond the code. Do not commit `data/` or generated outputs to git.

- **Reproduce the tables and figures**: knit `1_effect_sae_alloc.Rmd`. It reads the
  panel from the shared data folder (a copy sitting next to the code, from a local
  rebuild, takes precedence).
- **Rebuild the panel**: knit `00_build_entrant_panel.Rmd` (reads the packed files and
  canonical panels from the shared folder); the rebuilt panel lands next to the code and
  should match the MD5 above.
- **Repack from the original public csv releases**: point the paths at the top of
  `00a_pack_raw_data.R` at your copies, run it, then rebuild.

## Design in one paragraph

Callaway–Sant'Anna staggered difference-in-differences. The unit is a school-grade cell. A
cell is "always over-demanded" when, in every year we observe it, the children who made a
genuine (non-continuity) application ranking the cell at least as high as their final
placement outnumber the seats offered — computed exactly under deferred acceptance and
cross-checked two ways. Treatment is the region-by-grade SAE door; controls are cells whose
door has not yet opened. The entering class of year t is the students enrolled in the cell
in t with no enrolment at that school the year before, per the matricula census. The
outcome is the entering class's mean prior-year GPA, standardised nationally within year.
Inference is by randomization over which regions received which rollout wave. SAE rolled
out by region — Magallanes first, then four regions, then ten, then Santiago — so the
identifying comparisons live in the middle years, each treated wave against the regions
still waiting.

## Panel columns

`entrant_composition_panel.rds`: `rbd, cod_nivel, yr, region, is_entry, door, n_ent,
n_gpa, gpa_z, sh_prio, slack_fail, door_year_tag`. Five robustness columns are filters
on this one file (`slack_fail`, `door_year_tag`, `n_gpa >= 5`, `region != 13`,
`cod_nivel %in% c(7, 9)`); the other two reweight by entrant count and shift the base
period.
