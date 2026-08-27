# record-run driver: execute the PACKAGE analysis document (Piece 4) via
# knitr::purl + source (the certified launcher pattern), so tables/ lands in
# the piece folder. Afterwards: (1) the gate-split values must be identical to
# the exploratory record of the registered definition (g12, both-tests column);
# (2) a second full run must reproduce every values CSV byte-identically
# (determinism check, run this driver twice and compare run logs / CSVs).
suppressPackageStartupMessages({ library(knitr); library(data.table) })
home <- ifelse(Sys.getenv("USERPROFILE") != "", Sys.getenv("USERPROFILE"), path.expand("~"))
ROOT <- file.path(home, "Dropbox", "Effect of Centralization")
P4 <- file.path(ROOT, "Updated Paper Spine", "Piece 4")
setwd(P4)
purl("1_decompose_assignment.Rmd", output = "_tmp_an.R", documentation = 0L, quiet = TRUE)
source("_tmp_an.R", echo = FALSE)
invisible(file.remove("_tmp_an.R"))

cat("\n=== gate values vs the exploratory record (both-tests definition) ===\n")
# the sourced document runs rm(list = ls()); work from the (unchanged) working
# directory and re-derive ROOT rather than trusting any surviving variable
home <- ifelse(Sys.getenv("USERPROFILE") != "", Sys.getenv("USERPROFILE"), path.expand("~"))
ROOT <- file.path(home, "Dropbox", "Effect of Centralization")
a <- data.table::fread(file.path("tables", "decomp_gates_values.csv"))
b <- data.table::fread(file.path(ROOT, "explorations", "2026-08-25_sheet_clarifications",
                     "output", "gate2_both_tests_values.csv"))[def == "both-tests"]
a4 <- a[seq_len(4)]   # the four gate rows; row 5 is the total row
stopifnot("the exploratory record has exactly the four gate rows" = nrow(b) == 4L,
          "gate pieces identical to the exploratory record" =
            all(abs(a4$contribution_per100 - b$per100) < 1e-9),
          "gate RI p identical to the exploratory record" =
            all(abs(a4$ri_p - b$ri_p) < 1e-12))
cat("IDENTICAL\nDRIVER DONE\n")
