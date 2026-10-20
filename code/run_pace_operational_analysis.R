# Run only the F08.3 operational-eligibility extension in the central notebook.
args <- commandArgs(FALSE)
script <- sub('^--file=', '', args[grepl('^--file=', args)])
stopifnot(length(script) == 1L)
setwd(dirname(normalizePath(script)))
lines <- readLines('analysis_for_adversarial_report.Rmd')
env <- new.env(parent = globalenv())
run_chunk <- function(name) {
  start <- which(startsWith(lines, paste0('```{r ', name, '}')))
  stopifnot(length(start) == 1L)
  end <- start + which(lines[(start + 1L):length(lines)] == '```')[1L]
  cat('\nRunning', name, '\n')
  eval(parse(text = lines[(start + 1L):(end - 1L)]), envir = env)
}
if ('--tables-only' %in% commandArgs(TRUE)) {
  run_chunk('f08-operational-report-and-table')
} else {
  run_chunk('f30-expanded-setup')
  if ('--from-cache' %in% commandArgs(TRUE)) {
    run_chunk('f08-operational-restore-cache')
  } else {
    for (name in c('input-cache', 'histories', 'history-supplement',
                   'exams-and-use', 'classification')) {
      run_chunk(paste0('f08-operational-', name))
    }
  }
  for (name in c('events', 'inference', 'validation', 'misclassification-stress', 'delivery', 'report-and-table')) {
    run_chunk(paste0('f08-operational-', name))
  }
}
