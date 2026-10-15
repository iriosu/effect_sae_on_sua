# Section 2: the reviewers' package

This package reproduces Section 2 of *Effect of Centralized School Choice on College Admissions
Outcomes* (Rios, Larroucau and Marar): Table 1, Figure 1, Appendix Tables A1 and A2, and the numbers
Section 2's text quotes.

## Files and layout

    section2/
      README.md                         this file
      section2_cs_did.Rmd            the notebook

The data are in the coauthors' shared Dropbox folder, where `<home>` is `USERPROFILE` on Windows
and `~` on macOS and Linux:

    <home>/Dropbox/Effect SAE on SUA/data/finalized_design_v1/section2/
      section2_panel.rds                Section 2's panel (MD5 3104b4b2b1b6998941311667fa0ab785)
      draws/did/regional/               14 files of saved reassignments of SAE's rollout across the
                                        regions, 9,999 or 2,999 each:
        headline.rds
        gpa_robustness_2.rds  gpa_robustness_3.rds  gpa_robustness_4.rds  gpa_robustness_5.rds
        prioritario_robustness_2.rds  prioritario_robustness_3.rds
        prioritario_robustness_4.rds  prioritario_robustness_5.rds
        pretrends_gpa_z.rds  pretrends_sh_prio.rds
        intake_count.rds  intake_gpa_coverage.rds
        prior_gpa.rds

The notebook checks the panel and the files in `draws/did/` by their MD5s before it reads them and
reads nothing else.

## Command

From `code/finalized_design_v1/section2/`:

    Rscript -e "knitr::knit('section2_cs_did.Rmd')"

This writes `section2_cs_did.md` (the code with its printed results, warnings and messages) and
`section2_output/`: `tables/` (the three table files the paper inputs), `figures/` (Figure 1's two
panels), `staggered_did/` (every intermediate file and result) and `draws/bootstrap/` (the bootstrap
draws, drawn anew; the folder must start empty). To run it again, remove `section2_output/` first.

## Requirements

R 4.5.1 and did 2.1.2 are required (the notebook stops otherwise), plus data.table and knitr:

    Rscript -e "install.packages(c('data.table', 'knitr', 'remotes')); remotes::install_version('did', '2.1.2')"

## Run time

On a Windows 11 machine with 20 cores and 64 GB: 2.5 minutes with every core, the knit and its worker
processes holding 5.4 GB together at the peak; 4.3 minutes and 1.9 GB on 4 processors; 14.2 minutes
and 1.1 GB with one core. The notebook uses every core it finds; to use fewer (here 4):

    Rscript -e "home <- ifelse(Sys.getenv('USERPROFILE') != '', Sys.getenv('USERPROFILE'), path.expand('~')); data_dir <- file.path(home, 'Dropbox', 'Effect SAE on SUA', 'data', 'finalized_design_v1', 'section2'); params <- list(panel_file = file.path(data_dir, 'section2_panel.rds'), schedules_dir = file.path(data_dir, 'draws', 'did'), output_dir = 'section2_output', cores = 4L); knitr::knit('section2_cs_did.Rmd')"
