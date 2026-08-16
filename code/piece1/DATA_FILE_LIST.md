# Piece 1 — Non-shared data files (move-me list)

**The package now ships its non-shared data as three packed rds files in `data/`
(~0.4 GB), built by `00a_pack_raw_data.R`. The panel built from them is verified
identical, value by value, to the panel built from the raw csv files below
(2026-08-16).** This list locates the 55 original public csv releases (~11.6 GB) that
the packing script reads — needed only to repack from scratch. The packer reads 53 of
them (the two process-2016 C1/D1 files are not ingested — the demand computation begins
at process 2017; for 2016 only the A1 file is read, to time the Magallanes door).
All paths below are relative to `Effect of Centralization/explorations/`.

**If moving into `Piece 1/data/`:** keep the matricula and SEP files inside
per-year folders named exactly `Matricula-por-estudiante-YYYY/` and
`Alumnos-SEP-YYYY/` (the build locates them by folder name and picks the largest
csv). The SAE files can sit flat in one folder. After moving, the three path
variables at the top of `00_build_entrant_panel.Rmd` (`EX`, `EX2`, `DL`) need
repointing — say the word and the repoint + a verification rebuild happens.

## SAE admission files (A1 offers/seats, C1 applications, D1 assignments) — 30 files, 0.8 GB

From `2026-08-05_priority_quota/downloads/extracted/`:

- `2016/A1_Oferta_Establecimientos_etapa_regular_2016_Admisión_2017.csv`
- `2016/C1_Postulaciones_etapa_regular_2016_Admisión_2017_PUBL.csv` (not read by the build)
- `2016/D1_Resultados_etapa_regular_2016_Admisión_2017_PUBL.csv` (not read by the build)
- `2017/A1_Oferta_Establecimientos_etapa_regular_2017_Admisión_2018.csv`
- `2017/C1_Postulaciones_etapa_regular_2017_Admisión_2018_PUBL.csv`
- `2017/D1_Resultados_etapa_regular_2017_Admisión_2018_PUBL.csv`
- `2018/A1_Oferta_Establecimientos_etapa_regular_2018_Admisión_2019.csv`
- `2018/C1_Postulaciones_etapa_regular_2018_Admisión_2019_PUBL.csv`
- `2018/D1_Resultados_etapa_regular_2018_Admisión_2019_PUBL.csv`
- `A1_Oferta_Establecimientos_etapa_regular_2019_Admisión_2020.csv`
- `C1_Postulaciones_etapa_regular_2019_Admisión_2020_PUBL.csv`
- `D1_Resultados_etapa_regular_2019_Admisión_2020_PUBL.csv`
- `SAE 2021/A1_Oferta_Establecimientos_etapa_regular_2020_Admisión_2021.csv`
- `SAE 2021/C1_Postulaciones_etapa_regular_2020_Admisión_2021_PUBL.csv`
- `SAE 2021/D1_Resultados_etapa_regular_2020_Admisión_2021_PUBL.csv`
- `A1_Oferta_Establecimientos_etapa_regular_2021_Admisión_2022.csv`
- `C1_Postulaciones_etapa_regular_2021_Admisión_2022_PUBL.csv`
- `D1_Resultados_etapa_regular_2021_Admisión_2022_PUBL.csv`
- `SAE_2022/A1_Oferta_Establecimientos_etapa_regular_2022_Admisión_2023.csv` (filename carries a mojibake accent on disk — harmless, the build matches it)
- `SAE_2022/C1_Postulaciones_etapa_regular_2022_Admisión_2023_PUBL.csv` (same)
- `SAE_2022/D1_Resultados_etapa_regular_2022_Admisión_2023_PUBL.csv` (same)
- `A1_Oferta_Establecimientos_etapa_regular_2023_Admisión_2024.csv`
- `C1_Postulaciones_etapa_regular_2023_Admisión_2024_PUBL.csv`
- `D1_Resultados_etapa_regular_2023_Admisión_2024_PUBL.csv`

From `2026-08-03_grade7_door/downloads/extracted/`:

- `A1_Oferta_Establecimientos_etapa_regular_2024_Admisión_2025.csv`
- `C1_Postulaciones_etapa_regular_2024_Admisión_2025_PUBL.csv`
- `D1_Resultados_etapa_regular_2024_Admisión_2025_PUBL.csv`
- `A1_Oferta_Establecimientos_etapa_regular_2025_Admisión_2026.csv`
- `C1_Postulaciones_etapa_regular_2025_Admisión_2026_PUBL.csv`
- `D1_Resultados_etapa_regular_2025_Admisión_2026_PUBL.csv`

## Matricula por estudiante (enrolment census) — 13 files, 6.8 GB

All under `2026-08-06_outcome_data_pull/downloads/extracted/Matricula-por-estudiante-YYYY/`:

- 2011: `20140812_matricula_unica_2011_20110430_PUBL.csv` (472 MB)
- 2012: `20140812_matricula_unica_2012_20120430_PUBL.csv` (464 MB)
- 2013: `20140808_matricula_unica_2013_20130430_PUBL.csv` (475 MB)
- 2014: `20140924_matricula_unica_2014_20140430_PUBL.csv` (469 MB)
- 2015: `20150923_matricula_unica_2015_20150430_PUBL.CSV` (521 MB)
- 2016: `20160926_matricula_unica_2016_20160430_PUBL.csv` (515 MB)
- 2017: `20170921_matricula_unica_2017_20170430_PUBL.csv` (530 MB)
- 2018: `20181005_Matrícula_unica_2018_20180430_PUBL.CSV` (527 MB)
- 2019: `20191028_Matrícula_unica_2019_20190430_PUBL.CSV` (551 MB)
- 2020: `20200921_Matrícula_unica_2020_20200430_WEB.CSV` (549 MB)
- 2021: `20210913_Matrícula_unica_2021_20210430_WEB.CSV` (560 MB)
- 2022: `20220908_Matrícula_unica_2022_20220430_WEB.CSV` (564 MB)
- 2023: `20230906_Matrícula_unica_2023_20230430_WEB.CSV` (562 MB)

## Alumnos SEP (prioritario roster) — 12 files, 4.1 GB

All under `2026-08-06_outcome_data_pull/downloads/extracted/Alumnos-SEP-YYYY/`:

- 2012: `20131114_Prioritarios_y_Beneficiarios_2012_20131014_PUBL.csv` (170 MB)
- 2013: `Prioritarios_y_Beneficiarios_2013_20131014_PUBL.csv` (213 MB)
- 2014: `Prioritarios_y_Beneficiarios_2014_20140922_PUBL.csv` (232 MB)
- 2015: `Prioritarios_y_Beneficiarios_2015_20151001_PUBL.csv` (255 MB)
- 2016: `Preferentes_Prioritarios_y_Beneficiarios_2016_20160908_PUBL.csv` (397 MB)
- 2017: `Preferentes_Prioritarios_y_Beneficiarios_2017_20171030_PUBL.csv` (385 MB)
- 2018: `20181211_Preferentes_Prioritarios_y_Beneficiarios_2018_20181106_PUBL.csv` (397 MB)
- 2019: `20191122_Preferentes_Prioritarios_y_Beneficiarios_2019_20191106_PUBL.csv` (407 MB)
- 2020: `20201209_Preferentes_Prioritarios_y_Beneficiarios_2020_20201126_WEB.csv` (403 MB)
- 2021: `20211229_Preferentes_Prioritarios_y_Beneficiarios_2021_20211126_WEB.csv` (391 MB)
- 2022: `20221216_Preferentes_Prioritarios_y_Beneficiarios_2022_20221130_WEB.csv` (409 MB)
- 2023: `20231211_Preferentes_Prioritarios_y_Beneficiarios_2023_20231130_WEB.csv` (412 MB)

All 55 are public MINEDUC releases (datosabiertos.mineduc.cl); the filename is the
official release name, so a coauthor can also re-download any of them directly.
