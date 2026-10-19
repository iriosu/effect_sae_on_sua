# Short historical records: source review, October 19, 2026

## Rules applicable to the study years

1. [DEMRE, Puntaje Ranking — Casos Especiales](https://demre.cl/paes/factores-seleccion/puntaje-ranking). Schools with fewer than 30 graduates across the last three generations are grouped with similar schools using region, educational modality and dependency. Schools with only one or two generations but more than 30 graduates use those generations without grouping. The page does not specify a reproducible membership algorithm or publish group assignments. Its separate annual-score explanation remains inconsistent with the dated context-based descriptions; this note uses only its special-case provisions.

2. [MINEDUC, admission-2021 official instruments](https://acceso.mineduc.cl/wp-content/uploads/2020/08/DOCUMENTO-OFICIAL-N%C2%BA1-17-agosto.pdf), Ranking / III Casos Especiales. Confirms both rules above within the context-based procedure. Already archived as `../instruments_2021.pdf` and `.txt`; the special-case text is near line 438 in the text extraction. The text distinguishes fewer than 30 from more than 30 without explicitly addressing equality. Our retained threshold convention is at least 30; equality is separately audited, not silently presented as a verified boundary.

3. [MINEDUC, Resolución Exenta 4819/2020](https://acceso.mineduc.cl/wp-content/uploads/2022/01/REX_4819_2020.pdf), section c, special cases. Repeats the grouping criteria, available-cohort exception, free-exam reference, and foreign-grade NEM substitution. Viewed through indexed official PDF content; direct local download failed, so no local PDF copy is claimed.

4. [MINEDUC, admission-2024 instruments](https://acceso.mineduc.cl/wp-content/uploads/2023/06/DOC.-Instrumentos-Acceso-Admision-2024.pdf), III Casos Especiales. The same under-30 grouping and one/two-cohort exception persist after the score-scale change. Already archived as `../instruments_2024.pdf` and `.txt`.

## Distinguish the future reform

5. [MINEDUC, Committee session 75, September 10, 2025](https://acceso.mineduc.cl/wp-content/uploads/2025/10/Acta-sesion-N%C2%B075-10-de-septiembre-del-2025.pdf). Annex heading explicitly separates Ranking through admission 2027 from the procedure beginning in 2028. PDF page 60 (printed 55) repeats the existing special cases. PDF page 62 (printed 57) specifies the future minimum of 93 graduates for a level, with grouping expanding commune → province → region, holding dependency and teaching code fixed. These future provisions are **not** applied to the 2021–2026 reconstruction. The document also supports retaining context-based scoring for the study period; it does not explain the current webpage discrepancy.

## Additional lead discovered during the search

6. [MINEDUC, Reglas de cálculo de NEM](https://ayudamineduc.cl/ficha/reglas-de-calculo-de-nem), Case 1. When a grade is passed twice, the first completed instance should be used, irrespective of its GPA. Our earlier cache instead excludes multiple distinct passed records. This is a concrete record-construction difference that could remove target grades or historical peers. A separate first-pass test implements earliest-year selection, preserves conflicts within that earliest year, and distinguishes changes to a student's own grades from changes to historical references. Other cases cover validation of multiple levels, foreign schooling and overlapping adult/youth courses; these require additional record types outside the current regular-youth extract.

7. [MINEDUC, Resolución Exenta 4032/2018, manual](https://www.ayudamineduc.cl/sites/default/files/rex._4032-2018-manual.pdf), printed page 12, clauses a–c; corroborating [calculation-rules PDF](https://ayudamineduc.cl/sites/default/files/reglas_de_calculo_de_nem.pdf). Confirms the first-passed-instance rule predates the study cohorts. Distinguishes repeated passed courses from overlapping enrollment records: same-year school collisions require enrollment dates and administrative reconciliation. The test only resolves different years with a unique earliest record, rather than guessing within-year ordering. Applying this academic-record convention to historical Ranking peers is an explicit inference to be validated, not an independently published DEMRE benchmark roster.

## Search outcome and remaining identification limits

Searched both DEMRE and MINEDUC sites for short/missing generations, fewer than 30 graduates, grouped establishments, region/modality/dependency, and school-group lists. Located the rules above, but no operational assignment table or complete pre-2028 pooling algorithm in the materials reviewed. In particular, the sources do not settle whether donor pools include all comparable schools or only small schools, the exact administrative dependency coding, the counting unit in mixed HC/TP schools, or treatment of missing extracted records versus genuinely absent historical graduates.

The diagnostic therefore tests two counting units (whole school / school-modality) and three responses (no pooling / pool small peers / pool all comparable peers). It uses original region and exact dependency codes from the directory at the student's context-exit year. These are declared approximations, not official group reconstruction. Do not use current observed Ranking to choose donor schools or individual rules.
