# The paper's code

Three notebooks write every table file of *Sought-After Schools and College Access: Evidence from Chile* (Marar,
Rios and Larroucau), the event-study figure, and the macro files that hold the numbers the text prints from these
results. The map of Chile (Figure 1) is a separate figure.

| Folder | Notebook | Writes the paper's | Run time |
|---|---|---|---|
| `composition/` | `composition.Rmd` | Section IV and Appendix B: Tables I and II, Figure 2, Appendix Tables B.1 to B.7 | about 3 minutes on 20 cores |
| `outcomes/` | `outcomes.Rmd` | Section V and Appendix C: Tables III and IV, Appendix Tables C.1 to C.5 | about 7 seconds |
| `mechanisms/` | `mechanisms.Rmd` | Section VI and Appendix D: Tables V to X, Appendix Tables D.1 to D.3 | about 17 seconds |

Each folder holds the notebook, a README that lists every file the notebook writes with the exhibit it is, and
`data_manifest.csv`, which lists the notebook's data files with their bytes and MD5.

## What a run needs

- R 4.5.1 with knitr. `composition.Rmd` also needs data.table and did 2.1.2 exactly, since did's bootstrap
  standard errors depend on its version (install it with `remotes::install_version("did", version = "2.1.2")`).
  `outcomes.Rmd` needs fixest, dplyr, tidyr and purrr, and `mechanisms.Rmd` the same with data.table; fixest
  0.14.2 is the version of the paper's numbers, and versions before 0.13.0 compute another robust standard error.
  Each README lists the versions of every package the paper's numbers were run with.
- A notebook stops, with a message, where a run could print a different number: `composition.Rmd` on a did version
  other than 2.1.2 or a missing file of saved reassignments; `outcomes.Rmd` and `mechanisms.Rmd` on a fixest
  version before 0.13.0.
- The shared Dropbox folder *Effect SAE on SUA*. Each notebook reads its own data folder,
  `Effect SAE on SUA/data/finalized_design_v1/<notebook>/`, by default at `<home>/Dropbox/`, where `<home>` is
  `USERPROFILE` on Windows and `~` elsewhere. When Dropbox sits elsewhere (on recent macOS,
  `~/Library/CloudStorage/Dropbox`), give the data folder's full path as `data_dir`. Each data folder holds every
  file its notebook's `data_manifest.csv` lists. These are the panels the notebooks read; the records they were
  built from are not part of this code.

## Running a notebook

From the notebook's folder:

    Rscript -e "knitr::knit('composition.Rmd')"

With the data folder somewhere else, or another output folder:

    Rscript -e "params <- list(data_dir = '<data folder>', out_dir = '<output folder>'); knitr::knit('composition.Rmd')"

With pandoc installed (RStudio includes it), in a fresh R session where no object named `params` exists:

    rmarkdown::render('composition.Rmd', params = list(data_dir = '<data folder>', out_dir = '<output folder>'))

The same three commands run `outcomes.Rmd` and `mechanisms.Rmd`. On Windows, write paths with forward slashes
(`C:/Users/...`). Each notebook writes its files in `output/` beside it unless `out_dir` says otherwise.
`composition.Rmd` uses every core by default; `cores` in `params` sets fewer, about 0.27 GB of memory each.

## Checking the results against the paper

Compare against the paper's current LaTeX source: the Overleaf project of the paper, downloaded with "Download
Source" (an agent without Overleaf access asks a coauthor for that zip). The folder `documents/draft/` in this
repository holds the July draft, an earlier paper. Each table, macro and figure file a notebook writes carries the
path, relative to the paper's `main.tex`, under which the paper reads it: `tables/<file>`, `tables/results/<file>`
or `figures/<file>`. A run reproduces the paper when each of these files equals the paper's file at the same path:

- a table or macro file: the same bytes once Windows line endings (CRLF) are read as LF;
- a figure (PDF): the same bytes apart from the two date entries, `/CreationDate` and `/ModDate`.

The tables carry every estimate, standard error, star and count; the macro files carry the numbers the text prints
from these results. The composition notebook's bootstrap standard errors and randomization tests replay fixed seeds
and the saved reassignments of SAE's rollout in its data folder, and its results do not depend on the number of
cores. The outcomes and mechanisms notebooks have no random step. On 2026-11-11, on Windows 11, each table, macro
and figure file the three notebooks write equaled the paper's in this way, each notebook run from a clean copy of
its folder with `knitr::knit` and with `rmarkdown::render`.
