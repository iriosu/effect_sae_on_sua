# Piece 3 — Data file list

Every input resolves through a documented search chain, and all five build
inputs sit in the shared data folder (`~/Dropbox/Effect SAE on SUA/data`),
verified present there on 2026-08-18. The chains differ slightly by program and
are stated exactly here:

- `00_build_mech_panel.Rmd`: shared data folder, then the project `code/data`
  mirror, then the Piece 2 folder, then the Piece 1 `data/` folder, then this
  folder.
- `1_effect_mech.Rmd`: this folder, then the shared data folder (it reads only
  the panel, and pins its MD5).
- `checks/88_mech_panel_validation.R`: this folder, then the shared data folder,
  then `code/data`, then Piece 2, then Piece 1 `data/`. Its `RAW_DIR` constant
  additionally points at the two raw Rendimiento csvs, which are not shipped;
  the script stops with a repoint instruction if they are absent.
- `00a_pack_rendimiento_grades.R`: `SRC_DIRS`, the folders holding the raw
  public releases; it writes its output into the working directory.

The raw public releases behind the Piece 1/2 packed files are inventoried in
Piece 1's `DATA_FILE_LIST.md`.

## Read by `00a_pack_rendimiento_grades.R` (the supplement packer)

| File | What is read | Source |
|------|--------------|--------|
| `20250212_Rendimiento_2024_20250131_WEB.csv` | MRUN, AGNO, RBD, COD_ENSE, COD_GRADO, PROM_GRAL, SIT_FIN_R for academic year 2024 | Public MINEDUC school-records release, resolved by content (the file whose AGNO column carries 2024) |
| `20260210_Rendimiento_2025_20260202_WEB.csv` | Same columns for academic year 2025 | Public MINEDUC school-records release, resolved by content |

Output: `rendimiento_grades_2024_2025.rds` (7,109,910 rows, MD5
`5f222bbc8ad544f9863aab63cf1c949f`). Piece 2's certified promotion-only pack
(`rendimiento_2024_2025.rds`) and the canonical graded panel are untouched;
this is a NEW file because Piece 3 needs the grade and school-id columns those
files do not carry for 2024–2025.

## Read by `00_build_mech_panel.Rmd` (the panel build)

| File | What Piece 3 reads from it | Source |
|------|---------------------------|--------|
| `lottery_panel.rds` | The entire stamped Piece 2 panel (MD5 `acb5b2fff844f8692f234442273ab4c8`, asserted; 27 columns re-asserted byte-identical in the output) | Piece 2's panel of record |
| `college_outcomes_2018_2026.rds` | exam_lm, nem, ranking per student per process (MD5 `28dd1874092a0835bbcb11839ff2e57c`, asserted); national within-process z's and the per-process exam floor computed from it | Piece 2's stamped outcome table |
| `panel_performance_2002_2023.rds` | 8th-grade GPA 2016–2021 (the certified gpa8_z convention, recomputed and asserted equal to the stamped panel); media-grade records 2014–2023 (grades, school, promotion status) | Canonical graded panel the coauthors hold |
| `rendimiento_grades_2024_2025.rds` | Media-grade records 2024–2025 (grades, school, promotion status) | This piece's supplement (above) |
| `matricula_2011_2023.rds` | 9th-grade census rooms, entry years 2017–2022 (the peer measure) | Piece 1's packed census |

Output: `lottery_panel_mech.rds` (395,950 rows, 49 columns, MD5
`6296a6de9feb98a18b5fc850e7b3a275`; record rebuild byte-identical).

## Read by `1_effect_mech.Rmd` (the analysis)

Only `lottery_panel_mech.rds` (a copy next to the code wins, else the shared
data folder; MD5 pinned in the document).

## Read by `checks/88_mech_panel_validation.R`

All of the build's inputs plus the two raw Rendimiento csvs (independent
re-read, compared to the supplement row for row) and the panel of record.

## Consistency with Pieces 1 and 2

Piece 3 estimates on Piece 2's certified frame: the analysis asserts the frame
equals the certified 45,123 applications / 1,215 strata, `make_frame` and the
estimator are copied verbatim from Piece 2's analysis document, and the stamped
panel columns pass through the build byte-identical. The 8th-grade GPA
convention, the media school-type list, the [1,7] grade filter, national
within-year z-scoring, and the promoted-if-any-record rule all match the
certified constructions; the build asserts the first of these against the
stamped `gpa8_z` at every run.
