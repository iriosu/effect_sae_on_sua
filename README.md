# Effect of SAE on University Admissions Outcomes

This repository contains the code and documents for a research project studying the causal effect of Chile's centralized school-choice system (SAE, *Sistema de Admisión Escolar*) on students' university admissions outcomes (SUA, *Sistema Único de Admisión*). The analysis exploits the staggered rollout of SAE across Chilean municipalities to identify treatment effects using difference-in-differences methods, focusing on students who remained in the same school throughout secondary education.

---

## Repository Structure

```
.
├── code/               # R Markdown analysis scripts and outputs
├── documents/          # Paper drafts, notes, and reviewer feedback
├── literature/         # Reference PDFs
└── LICENSE
```

---

## Code (`code/`)

### Scripts

| File | Description |
|------|-------------|
| `1a_data_processing_primary_secondary.Rmd` | Constructs a longitudinal panel of students tracked by their unique identifier (MRUN) across primary and secondary education. Merges enrollment, performance, graduation, SAE application, and university admissions records. Produces the main analysis datasets. |
| `2_effect_sae.Rmd` | Estimates the effect of SAE adoption on university admissions outcomes using two-way fixed effects (TWFE) and staggered difference-in-differences (Callaway–Sant'Anna). Includes parallel trends tests and heterogeneity analyses by gender, school quality, vulnerability, SIMCE scores, and school value-added. |

### Data (`code/data/`)

Data files are excluded from version control (see `.gitignore`). The following files are required to run the analysis:

| File | Description |
|------|-------------|
| `panel_9-12_2010_2021.rds` | Main analysis panel. Student-level observations for grades 9–12 (2010–2021), including secondary school characteristics, SAE treatment status, and university admissions outcomes. |
| `panel_ee_2004_2025_homogenized.rds` | School-level enrollment panel (2004–2025), homogenized across registry versions. Used to merge school-level covariates. |
| `panel_simce_4b.rds` | Student-level SIMCE (national standardized test) scores for 4th grade. Used as a baseline academic ability measure. |
| `value_added_simce_2m_relative_8b_2016.rds` | School value-added estimates based on SIMCE results (2nd grade scores relative to 8th grade baseline, 2016). Used for heterogeneity analysis by school quality. |

### Tables (`code/tables/`)

Regression output tables (`.tex`) produced by `2_effect_sae.Rmd`:

| File | Description |
|------|-------------|
| `twfe_sae_on_outcomes.tex` | Two-way fixed effects estimates of SAE on university admissions outcomes. |
| `staggered_did_sae_on_outcomes_never_sae.tex` | Staggered DiD estimates using never-treated schools as the control group. |
| `staggered_did_sae_on_outcomes_no_private.tex` | Staggered DiD estimates excluding private schools. |
| `staggered_did_sae_on_outcomes_only_private.tex` | Staggered DiD estimates for private schools only. |
| `parallel_trends_sae_on_outcomes.tex` | Pre-treatment parallel trends test (baseline specification). |
| `parallel_trends_pre_sae_on_outcomes.tex` | Parallel trends test using pre-SAE period only. |
| `parallel_trends_all_sae_on_outcomes.tex` | Parallel trends test across all available pre-periods. |
| `parallel_trends_allpre_sae_on_outcomes.tex` | Parallel trends test including all pre-treatment years. |

### Plots (`code/plots/`)

| File | Description |
|------|-------------|
| `sae_chile_map.pdf` | Map of Chile showing the rollout of SAE across municipalities over time. |
| `pct_mistakers_per_year.pdf` | Share of students making application mistakes in SAE, by year. |
| `pct_retakers_per_year.pdf` | Share of students retaking university admissions tests, by year. |
| `rdd_retakes.pdf` | Regression discontinuity plot for test retaking behavior. |
| `cl.json` | GeoJSON file with Chilean commune boundaries used for the map. |

---

## Documents (`documents/`)

### Paper Draft (`documents/draft/`)

LaTeX source for the main paper manuscript.

| File | Description |
|------|-------------|
| `main.tex` | Main paper source file. |
| `main.pdf` | Compiled PDF of the paper. |
| `sample.bib` | BibTeX bibliography. |
| `informs4.cls` | INFORMS journal document class. |
| `informs2014.bst` | INFORMS bibliography style. |
| `eqndefns-center.sty` / `eqndefns-left.sty` | Custom equation formatting style files. |
| `figures/` | Figures included in the paper (maps, event-study plots, etc.). |
| `tables/` | Final versions of regression tables included in the paper. |

#### Standalone Literature Review (`documents/draft/lit_review_standalone/`)

A self-contained LaTeX document containing the paper's literature review section, compiled independently.

### Feedback (`documents/feedback/`)

Reviewer and discussant comments on the paper:

| File | Description |
|------|-------------|
| `Effect_of_Centralized_School_Choice_on_College_Outcomes_AM.pdf` | Reviewer feedback (AM). |
| `Effect_of_Centralized_School_Choice_on_College_Outcomes_comments_TL.pdf` | Reviewer comments (TL). |

### VAM Notes (`documents/vam_notes/`)

| File | Description |
|------|-------------|
| `value_added_match_effects_note.tex` / `.pdf` | Technical note discussing the estimation of value-added models and match effects between students and schools. |

### Other

| File | Description |
|------|-------------|
| `documents/E20-0001.pdf` | Additional project document. |

---

## Literature (`literature/`)

Reference PDFs on school choice, centralized admissions, information frictions, and related topics used in the paper.

---

## Requirements

The analysis is implemented in **R** using R Markdown (`.Rmd`). Key packages include:

- `did` — Callaway–Sant'Anna staggered difference-in-differences
- `fixest` — Two-way fixed effects estimation (`feols`)
- `dplyr`, `tidyr`, `purrr` — Data manipulation
- `ggplot2` — Visualization

---

## License

See [LICENSE](LICENSE).
