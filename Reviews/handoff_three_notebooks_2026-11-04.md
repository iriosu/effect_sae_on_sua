# Handoff: the three notebooks of the submission draft (2026-11-04)

From Abhijit, for whoever works on this branch next.

## What this commit adds

Three notebooks, one per part of the submission draft (`Initial submission/main.tex` on Overleaf), each in its own folder under `code/finalized_design_v1/` with its `README.md` and `data_manifest.csv`:

| Folder | Paper | Writes |
|---|---|---|
| `composition/` | Section III (who enters the over-demanded schools before and after SAE's rollout) and Appendix B | Tables I and II, Figure 2, Appendix Tables B.1 to B.8, and three macro files: two of the numbers the text quotes, among them `tables/composition_text_macros.tex`, and one of Appendix Table B.7's estimates, which the paper inputs without printing |
| `outcomes/` | Section IV (the lottery design: high-school graduation and the college outcomes) and Appendix C | Tables III and IV, Appendix Tables C.1 to C.6, and `tables/outcomes_text_macros.tex` |
| `mechanisms/` | Section V (graduation and the college seat explained from the records) and Appendix D | Tables V to IX, Appendix Tables D.1 to D.3, and `tables/mechanisms_text_macros.tex` |

All three use the 1,020 over-demanded schools (10,027 over-demanded school-grades in Section III).

- Each notebook reads one data folder and the `data_manifest.csv` beside it, and nothing else: `<home>/Dropbox/Effect SAE on SUA/data/finalized_design_v1/composition/`, `outcomes/` and `mechanisms/`, now in the shared Dropbox folder (`<home>` is `USERPROFILE` on Windows, the home folder elsewhere; where Dropbox sits elsewhere, give the folder as `data_dir`). Before reading any file, it checks that the data folder's manifest is the one beside the notebook and each file's bytes and MD5 against it. It stops when a manifest or a file is missing or differs.
- To run one, open it in RStudio and press Knit, or call `rmarkdown::render("<name>.Rmd")` from its folder; `rmarkdown::render` needs pandoc, which RStudio includes, and each README also gives a `knitr::knit` command that needs none. The outputs go to `output/` beside the notebook, under the names and relative paths the paper uses (`tables/`, `tables/results/`, `figures/`). The numbers behind them are in `output/numbers/`. Each README gives the versions, the run time and the other ways to run the notebook. On a computer with 20 logical cores, composition takes about four minutes, outcomes about ten seconds and mechanisms 20 to 30 seconds.
- `main.tex` inputs the three `*_text_macros.tex` files, `sections/4_access.tex` inputs composition's two other macro files and `sections/6_mechanisms.tex` inputs `tables/grade_stringency_facts.tex`, which mechanisms writes; the text prints its numbers from them. After a rerun, copy the changed files of `output/tables/` and `output/figures/` into the paper's `tables/` and `figures/`, and the numbers in the text follow. Copy only from a knit that ran to its end: a knit that stops leaves the files it wrote before the stop.
- Each notebook also checks the statements the text makes in words about its results (a sign, a significance call, a comparison) and writes them to `output/numbers/` with whether each holds. When one does not hold, the knit names it and stops. A change in the code or the data then shows which sentences have to change with it.
- The tables of Sections III to V and Appendices B to D, Figure 2, and the numbers the text prints from the macro files come from these notebooks' runs. Rendered from a copy of these folders that reads the shared data folder, each notebook gives those outputs byte for byte (the figures apart from their creation dates).

## What stays

- `code/finalized_design_v1/section2/`, `section5/` and `section6/`, their data folders in the shared folder, `code/finalized_design_v1/data_manifest.csv` and `environment/` are unchanged. The paper's tables of Sections III to V and Appendices B to D, Figure 2 and the numbers its text prints from the macro files come from the three new notebooks. `code/analysis_for_adversarial_report.Rmd` and `code/f04_entrant_counts.R` read `section2/`'s data through that manifest; nothing they read changes.
- The older entries of `HANDOFF.md` describe `section2/` and `section5/`, which ran on the earlier design (8,891 school-grades in Section III, 1,045 schools in the lottery design); their tables are no longer the paper's.
