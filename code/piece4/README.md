# Piece 4 — Where the Seats Are Lost

Decomposes the certified Piece 2 effect (winning a contested 9th-grade seat
lowers on-time university assignment — a seat — by 1.84 per 100 children) into
the four steps of the road to a seat, splits the selection step into its two
doors (the score contest and the special routes), and shows the mechanism behind
each door with direct counts. Full prose description with every headline number:
`PIECE4_DESCRIPTION.md`.

## Contents

```
1_decompose_assignment.Rmd         the analysis document (specs GATES/ROUTES/COUNT/PACE)
checks/90_run_package_analysis.R   launcher (knitr::purl + source) + identity check
checks/91_count_ri.R               permutation test on the transcript swap (DECOMP-COUNT-RI)
checks/92_pace_seat_chain.R        three-link PACE seat chain (DECOMP-PACE-SEAT)
data/                              six DEMRE special-route files (2021-2023) +
                                   extracted official PACE school lists (DATA_FILE_LIST.md)
tables/                            four .tex tables; six unrounded values CSVs
                                   (decomp_gates / decomp_routes / decomp_count /
                                   decomp_pace / decomp_count_ri / decomp_pace_seat);
                                   the derived PACE school flag
run_log_2026-08-26.txt             the analysis-document record run
run_log_count_ri_2026-08-26.txt    the permutation-test record run
run_log_pace_seat_2026-08-26.txt   the seat-chain record run
```

Repo note: under the repository's ignore rules (`.rds`, `.csv`, `.pdf` stay out
of git), the `data/` CSVs and the values CSVs do not ship in the repo; they stay
in the Dropbox package folder. `DATA_FILE_LIST.md` carries every file's MD5 and
the public re-download route, so the repo copy is fully reconstructible.

## Governance

Six specs in `specs/spec_registry.csv`, each registered before its record run:
`DECOMP-GATES-2026-08-26`, `DECOMP-ROUTES-2026-08-26`, `DECOMP-COUNT-2026-08-26`,
`DECOMP-PACE-2026-08-26`, `DECOMP-COUNT-RI-2026-08-26`,
`DECOMP-PACE-SEAT-2026-08-26`. Ledger rows RUN-324 to RUN-327 record the
analysis-document record run; RUN-328, RUN-329, and RUN-331 record its
verification reruns and prose-only table fixes — every values CSV byte-identical
across every regeneration, with the shipped `tables/` and run log designated by
RUN-331 (and the subsequent hardening regeneration logged in the closing row);
RUN-330 records the permutation test; RUN-332 the seat chain. The panel of
record is `lottery_panel_mech.rds`, MD5
`6296a6de9feb98a18b5fc850e7b3a275`, asserted in-document (the run halts on any
drift); the panel is certified in the Piece 3 package.

## To rerun

```
Rscript checks/90_run_package_analysis.R    # the analysis document + tables
Rscript checks/91_count_ri.R                # the transcript-swap permutation test
Rscript checks/92_pace_seat_chain.R         # the PACE seat chain
```

run from this folder (on the record machine, PowerShell with the full path:
`& "$env:LOCALAPPDATA\Programs\R\R-4.5.1\bin\x64\Rscript.exe" --vanilla checks\90_run_package_analysis.R`).
The document anchors all paths at `%USERPROFILE%/Dropbox`, so the two Dropbox
folders (`Effect of Centralization` and `Effect SAE on SUA`) must sit there.
Inputs resolve package-local `data/` first, then the Piece 3 and Piece 2
packages, then the mechanism exploration record
(`explorations/2026-08-17_piece3_mechanism/output/` — required for the
scoring-world files and the school-records supplement), then the shared data
folder (`~/Dropbox/Effect SAE on SUA/data`). The launcher's identity check
additionally needs
`explorations/2026-08-25_sheet_clarifications/output/gate2_both_tests_values.csv`
(the exploratory gate record it asserts against). Every input's MD5 is printed
at the top of the run log. Requires R 4.5.1 with `data.table`, `fixest`,
`knitr`; every results chunk re-seeds (20260919), so all numbers including the
randomization-inference stars reproduce exactly.
