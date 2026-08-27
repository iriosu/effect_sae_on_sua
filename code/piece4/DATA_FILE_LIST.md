# Piece 4 — data files

## In `data/` (packaged with the piece)

| File | What it is | Source | MD5 |
|------|-----------|--------|-----|
| `C_POSTULANTES_SELECCION_PDT_CUPOS_PACE_2021_PUB_MRUN.csv` | PACE-quota applications and selection, process 2021 | datosabiertos.mineduc.cl (Prueba de Transición Universitaria 2021, Postulantes Cupos PACE) | `044466502d5b6aa6466999e2c11bf519` |
| `C_POSTULANTES_SELECCION_PDT_CUPOS_PACE_2022_PUB_MRUN.csv` | PACE-quota applications and selection, process 2022 | datosabiertos.mineduc.cl (2022) | `390b3bb15dea38768668fabb6c582c7a` |
| `C_POSTULACIONES_SELECCION_CUPOS_PACE_2023_PAES_MRUN.csv` | PACE-quota applications and selection, process 2023 | datosabiertos.mineduc.cl (PAES 2023) | `7da866a46c9a4721c9509f7ab7caf0e3` |
| `C_POSTULANTES_SELECCION_PDT_CUPOS_SUPERNUMERADOS_2021_PUB_MRUN.csv` | BEA (supernumerario) applications and selection, process 2021 | datosabiertos.mineduc.cl (2021) | `3ac2bd0a5ae164068ddde5f5033875f5` |
| `C_POSTULANTES_SELECCION_PDT_CUPOS_SUPERNUMERADOS_2022_PUB_MRUN.csv` | BEA applications and selection, process 2022 | datosabiertos.mineduc.cl (2022) | `7d673e853457f711ee1435344184f679` |
| `C_POSTULACIONES_SELECCION_CUPOS_SUPERNUMERARIOS_2023_PAES_PUB_MRUN.csv` | BEA applications and selection, process 2023 | datosabiertos.mineduc.cl (PAES 2023) | `9a52d267e5784463fead56b345e9681d` |
| `pace_pdf_rbds.csv` | RBDs extracted from the official PACE school-list PDFs, admissions 2022 / 2023 / 2025 (580 / 638 / 638 schools) | acceso.mineduc.cl PDFs, extracted 2026-08-26 (extractor in the exploration record) | `c745d44083c6dfd563408c1674344471` |

Processes 2024 onward need no separate files: the regular selection data carry
the route labels from 2024. Official PACE school lists exist for admissions
2022, 2023, and 2025 only; no official list exists for 2021, 2024, or 2026.

Repo note: the repository's ignore rules keep `.csv` files out of git, so the
`data/` files above live in the Dropbox package folder; each is re-downloadable
from the named public source and verifiable against its MD5 here.

## Read from the certified packages, the exploration record, and the shared data folder (MD5s asserted or printed in the run log)

| File | Role | Where it resolves |
|------|-----------|--------|
| `lottery_panel_mech.rds` | panel of record (MD5 `6296a6de9feb98a18b5fc850e7b3a275`, asserted in-document) | Piece 3 package |
| `lottery_headline_values.csv` | certified anchor for the assignment effect | Piece 2 package, `tables/` |
| `score_students.rds`, `score_prefs.rds`, `pref_scores_final.rds`, `program_weights_final.rds`, `panel_programs_2007_2026.rds`, `f1_selection_check.rds` | the reconstructed-score world (built and verified in the runs the ledger records as RUN-322/323) | mechanism exploration record, `explorations/2026-08-17_piece3_mechanism/output/` |
| `rendimiento_grades_2024_2025.rds` | 12th-grade school location, years 2024-2025 (MD5 `5f222bbc8ad544f9863aab63cf1c949f`) | mechanism exploration record, `output/` |
| `panel_performance_2002_2023.rds` | 12th-grade school location through 2023 (MD5 `78f4b9d975976c33ace9c85629e84ae6`) | shared data folder, `~/Dropbox/Effect SAE on SUA/data` |
| `gate2_both_tests_values.csv` | exploratory gate record the document and launcher assert identity against (MD5 `c315b99ed497c3524ec7fca9262bc816`) | `explorations/2026-08-25_sheet_clarifications/output/` |
