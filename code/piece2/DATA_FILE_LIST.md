# Piece 2 — Data file list

Everything Piece 2 reads sits in the shared data folder
(`~/Dropbox/Effect SAE on SUA/data`). This list says where each file comes from and,
for the packed files, which raw public releases stand behind it. The packer for all
packed files is Piece 1's `00a_pack_raw_data.R`; the full inventory of the raw
MINEDUC csv releases (with sizes and on-disk locations) is Piece 1's
`DATA_FILE_LIST.md`.

## Read by `00_build_lottery_panel.Rmd` (9th door)

| File | What Piece 2 reads from it | Source |
|------|---------------------------|--------|
| `data_students_2004_2025.rds` | College processes 2018–2025: registration, application, assignment, enrolment per student | DEMRE student file the coauthors hold (arrived 2026; same file the canonical pipeline reads) |
| `paes_2026.rds` | College process 2026: registration + scores (A), selection status (C), enrolment (D) | Packed from three public DEMRE PAES-2026 releases: `A_INSCRITOS_PUNTAJES_PAES_2026_PUB_MRUN.csv`, `C_POSTULANTES_SELECCION_PAES_2026_PUB_MRUN.csv`, `D_MATRICULA_PAES_2026_2026_PUB_MRUN.csv` |
| `entrant_composition_panel.rds` | The school list: always-over-demanded cells at `cod_nivel == 9` | Piece 1's analysis panel (MD5 `8ccec73b5955b723485195d5085b669d`), built by Piece 1's `00_build_entrant_panel.Rmd` |
| `sae_admissions.rds` | C1 applications (lottery number, priority flags, special-admission ordering columns), D1 assignments, B1 applicant register (prioritario, gender), processes 2016–2021 | Packed from the yearly public SAE releases (A1/C1/D1/B1), processes 2016–2025 |
| `panel_performance_2002_2023.rds` | 8th-grade GPA in the application year (z-scored nationally within year); 12th-grade promotion records through 2023 for grad on time | Canonical graded panel the coauthors hold |
| `rendimiento_2024_2025.rds` | 12th-grade promotion records for the on-time years 2024–2025 (grad on time) | Packed from the two public school-record releases `20250212_Rendimiento_2024_20250131_WEB.csv`, `20260210_Rendimiento_2025_20260202_WEB.csv` (resolved by content) |
| `matricula_2011_2023.rds` | Entry-year and persistence enrolment (census years 2017–2023) | Packed from the 13 public annual census releases 2011–2023 |
| `matricula_2024_2025.rds` | Persistence years 2024–2025 for the last cohorts | Packed from the 2024 and 2025 public census releases (supplement file; the 2011–2023 pack is untouched) |

## Read by `00b_build_lottery_panel_7th.Rmd` (7th door)

Six files: `college_outcomes_2018_2026.rds` (built by `00` — run `00` first; this is
how the DEMRE and PAES records reach the 7th door, `00b` never opens them directly),
`entrant_composition_panel.rds` (school list at `cod_nivel == 7`),
`sae_admissions.rds`, `panel_performance_2002_2023.rds` (6th-grade GPA; 12th-grade
promotion through 2023), `rendimiento_2024_2025.rds` (12th-grade promotion 2024–2025),
and `matricula_2011_2023.rds` (the census supplement is not read — entry years
2017–2020 all sit inside the 2011–2023 pack).

## Read by the analysis documents

`1_effect_lottery.Rmd` reads only `lottery_panel.rds`; `1b_effect_lottery_7th.Rmd`
reads only `lottery_panel_7th.rds`. A copy next to the code wins; otherwise the
shared data folder's copy of record is used. MD5s in the README.

## Consistency with Piece 1

One packed SAE file (`sae_admissions.rds`, MD5 `5a55dd9eebe439b6173ac487c0398f0f`)
serves both pieces: Piece 1 reads the seat/application/placement columns for the
over-demand computation, Piece 2 additionally reads the lottery number, the priority
flags, and B1. One over-demand list serves both pieces: Piece 2's school list at each
door is taken from Piece 1's shipped panel.
