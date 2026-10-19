# Run only the adopted-baseline analyses, not the earlier reconstruction notebook.
args <- commandArgs(FALSE)
script <- sub('^--file=', '', args[grepl('^--file=', args)])
if (length(script) != 1L) stop('Run with Rscript code/run_adopted_score_analysis.R')
setwd(dirname(normalizePath(script)))
lines <- readLines('analysis_for_adversarial_report.Rmd')
chunks <- c('f30-expanded-setup', 'f30-expanded-estimates',
            'f30-expanded-coverage-and-gaps', 'f08-adopted-eligibility-setup',
            'f08-adopted-eligibility-validation', 'f08-adopted-eligibility-effects',
            'f30-expanded-report', 'f30-expanded-manuscript-table')
if ('--table-only' %in% commandArgs(TRUE)) chunks <- 'f30-expanded-manuscript-table'
env <- new.env(parent = globalenv())
for (chunk in chunks) {
  start <- which(startsWith(lines, paste0('```{r ', chunk, '}')))
  stopifnot(length(start) == 1L)
  end <- start + which(lines[(start + 1L):length(lines)] == '```')[1L]
  cat('\nRunning', chunk, '\n')
  eval(parse(text = lines[(start + 1L):(end - 1L)]), envir = env)
}
