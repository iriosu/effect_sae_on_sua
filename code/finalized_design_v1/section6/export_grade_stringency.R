# Add the independently estimated grading-stringency outcome to Table V, Panel C.
# `manuscript_root` is the directory containing tables/ (e.g. Initial submission).
# `result` is a named list, vector, or one-row data.frame with mean, est, se, p,
# n (2SLS estimation sample), and n_nooffer (no-offer observations in that sample).
# Existing outcomes, their estimates, and their common-sample N remain untouched.
export_grade_stringency <- function(manuscript_root, result) {
  required <- c("mean", "est", "se", "p", "n", "n_nooffer")
  if (!all(required %in% names(result))) {
    stop("result must contain: ", paste(required, collapse = ", "))
  }
  values <- lapply(required, function(key) result[[key]])
  names(values) <- required
  valid_scalar <- vapply(values, function(x) {
    is.numeric(x) && length(x) == 1L && is.finite(x)
  }, logical(1L))
  if (!all(valid_scalar)) stop("All result fields must be finite numeric scalars.")
  if (values$se < 0 || values$p < 0 || values$p > 1) {
    stop("The standard error must be nonnegative and the p-value must be in [0, 1].")
  }
  counts <- unlist(values[c("n", "n_nooffer")], use.names = FALSE)
  if (any(counts < 0 | counts != floor(counts)) || values$n_nooffer > values$n) {
    stop("Sample counts must be nonnegative integers, with n_nooffer <= n.")
  }

  table_dir <- file.path(manuscript_root, "tables")
  table_path <- file.path(table_dir, "lottery_graduation_part2.tex")
  if (!file.exists(table_path)) stop("Missing existing table: ", table_path)
  original <- rawToChar(readBin(table_path, what = "raw", n = file.info(table_path)$size))
  eol <- if (grepl("\r\n", original, fixed = TRUE)) "\r\n" else "\n"
  if (identical(eol, "\r\n") && grepl("\n", gsub("\r\n", "", original, fixed = TRUE), fixed = TRUE)) {
    stop("The existing table mixes line endings; refusing to normalize its content.")
  }
  trailing_eol <- endsWith(original, eol)
  lines <- strsplit(original, eol, fixed = TRUE)[[1L]]

  c_heading <- "\\multicolumn{5}{l}{\\textit{Panel C: Characteristics of the School They Attend}}\\\\"
  d_heading <- "\\multicolumn{5}{l}{\\textit{Panel D: Performance in the 9th grade}}\\\\"
  boundaries <- function(x) {
    c_index <- which(x == c_heading)
    d_index <- which(x == d_heading)
    if (length(c_index) != 1L || length(d_index) != 1L || c_index >= d_index) {
      stop("Expected exactly one correctly ordered Panel C and Panel D heading.")
    }
    c(c = c_index, d = d_index)
  }
  limits <- boundaries(lines)
  row_input <- "\\input{tables/grade_stringency_row.tex}"
  n_input <- "\\input{tables/grade_stringency_n.tex}"
  known_inputs <- which(trimws(lines) %in% c(row_input, n_input))
  if (any(known_inputs <= limits[["c"]] | known_inputs >= limits[["d"]])) {
    stop("An existing stringency input lies outside Panel C.")
  }
  if (length(known_inputs)) lines <- lines[-known_inputs]
  # Replace only our explicitly marked inline blocks. The legacy sidecar
  # references above are migrated so booktabs sees each row break directly.
  row_begin <- "% BEGIN GENERATED GRADE STRINGENCY OUTCOME"
  row_end <- "% END GENERATED GRADE STRINGENCY OUTCOME"
  n_begin <- "% BEGIN GENERATED GRADE STRINGENCY SAMPLE SIZE"
  n_end <- "% END GENERATED GRADE STRINGENCY SAMPLE SIZE"
  remove_block <- function(x, begin, end, row_count, first_prefix) {
    starts <- which(x == begin)
    ends <- which(x == end)
    if (!length(starts) && !length(ends)) return(x)
    limits <- boundaries(x)
    if (length(starts) != 1L || length(ends) != 1L ||
        starts <= limits[["c"]] || ends >= limits[["d"]] ||
        ends - starts != row_count + 1L ||
        !startsWith(x[starts + 1L], first_prefix)) {
      stop("Malformed or misplaced generated stringency block: ", begin)
    }
    x[-seq.int(starts, ends)]
  }
  lines <- remove_block(lines, row_begin, row_end, 2L, "Grade stringency (GPA points) &")
  lines <- remove_block(lines, n_begin, n_end, 1L, "$N$ (grade stringency) &")
  if (any(grepl("stringency", lines, ignore.case = TRUE))) {
    stop("Unknown existing stringency content; refusing to add a duplicate outcome.")
  }
  limits <- boundaries(lines)
  c_indices <- seq.int(limits[["c"]] + 1L, limits[["d"]] - 1L)
  distance <- c_indices[startsWith(lines[c_indices], "Distance to school (km) &")]
  if (length(distance) != 1L) stop("Expected exactly one distance-to-school row in Panel C.")
  distance_se <- distance + 1L
  se_cells <- strsplit(lines[distance_se], "&", fixed = TRUE)[[1L]]
  if (length(se_cells) != 5L || trimws(se_cells[[1L]]) != "" ||
      trimws(se_cells[[2L]]) != "" ||
      !grepl("^\\([-+0-9.,]+\\)$", trimws(se_cells[[3L]])) ||
      trimws(se_cells[[4L]]) != "" || trimws(se_cells[[5L]]) != "\\\\" ||
      distance_se + 1L >= limits[["d"]] || lines[distance_se + 1L] != "\\midrule") {
    stop("The distance standard-error row or following midrule has changed.")
  }
  n_index <- c_indices[startsWith(lines[c_indices], "$N$ &")]
  if (length(n_index) != 1L || n_index <= distance_se ||
      n_index + 1L >= limits[["d"]] || lines[n_index + 1L] != "\\midrule") {
    stop("Expected one original Panel C N row followed by a midrule.")
  }

  decimal <- function(x) {
    out <- sprintf("%.3f", x)
    if (identical(out, "-0.000")) "0.000" else out
  }
  stars <- if (values$p < 0.01) "***" else if (values$p < 0.05) "**" else if (values$p < 0.10) "*" else ""
  estimate <- paste0(decimal(values$est), if (nzchar(stars)) paste0("$^{", stars, "}$") else "")
  outcome_rows <- c(
    paste0("Grade stringency (GPA points) & ", decimal(values$mean), " & ", estimate, " &  & \\\\"),
    paste0(" &  & (", decimal(values$se), ") &  & \\\\")
  )
  count <- function(x) format(x, big.mark = ",", scientific = FALSE, trim = TRUE, nsmall = 0L)
  sample_row <- paste0("$N$ (grade stringency) & ", count(values$n_nooffer), " & ", count(values$n), " &  & \\\\")
  # Insert from bottom to top so both indices refer to the original table lines.
  updated <- append(lines, c(n_begin, sample_row, n_end), after = n_index)
  updated <- append(updated, c(row_begin, outcome_rows, row_end), after = distance_se)
  new_table <- paste(updated, collapse = eol)
  if (trailing_eol) new_table <- paste0(new_table, eol)

  # All structural and input checks above precede the atomic replacement.
  atomic_write <- function(content, path) {
    stage <- tempfile(pattern = ".grade-stringency-", tmpdir = dirname(path))
    on.exit(unlink(stage), add = TRUE)
    writeBin(charToRaw(content), stage)
    if (!file.rename(stage, path)) stop("Could not replace ", path)
  }
  atomic_write(new_table, table_path)
  invisible(list(table = table_path))
}
