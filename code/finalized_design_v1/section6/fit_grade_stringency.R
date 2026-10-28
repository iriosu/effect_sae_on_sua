# Historical grading stringency. This file fits an already filtered calibration
# sample; it does not select schools, merge files, or write manuscript outputs.
# Numerical diagnostics are returned separately from all empirical data.

.stringency_centered_fe_hc0 <- function(X, residual, group, n_group) {
  # OLS with school indicators Z and nuisance regressors X. After centering the
  # school effects with equal school weights, the influence of observation i on
  # school s is 1{g_i=s}/n_s - 1/(J*n_g_i) - D_s' A^{-1} x_tilde_i.
  # The algebra below computes its squared-residual weighted norm without an
  # N by J influence matrix or a J by J fixed-effect covariance matrix.
  J <- length(n_group)
  p <- ncol(X)
  if (J < 2L || p < 1L) stop("Need at least two schools and one nuisance regressor.")
  if (nrow(X) != length(residual) || length(group) != nrow(X)) {
    stop("Inconsistent matrix, residual, or grouping lengths.")
  }
  xbar <- rowsum(X, group, reorder = FALSE) / n_group
  X_tilde <- X - xbar[group, , drop = FALSE]
  Ainv <- chol2inv(chol(crossprod(X_tilde)))
  residual2 <- residual^2
  weighted_X <- X_tilde * residual
  V_beta <- Ainv %*% crossprod(weighted_X) %*% Ainv
  rm(weighted_X)
  B <- rowsum(X_tilde * residual2, group, reorder = FALSE) / n_group
  h <- as.numeric(rowsum(residual2, group, reorder = FALSE)) / n_group^2
  D <- sweep(xbar, 2L, colMeans(xbar), "-")
  B_centered <- sweep(B, 2L, colMeans(B), "-")
  V <- (1 - 2 / J) * h + sum(h) / J^2 +
    rowSums((D %*% V_beta) * D) -
    2 * rowSums((D %*% Ainv) * B_centered)
  tolerance <- 1e-10 * max(1, max(abs(V)))
  if (any(!is.finite(V)) || any(V < -tolerance)) {
    stop("Centered fixed-effect HC0 variance is nonfinite or materially negative.")
  }
  list(variance = pmax(V, 0), nuisance_vcov_hc0 = V_beta,
       school_regressor_means = xbar)
}

fit_grade_stringency <- function(data, shrink = TRUE) {
  if (!requireNamespace("data.table", quietly = TRUE) ||
      !requireNamespace("fixest", quietly = TRUE)) {
    stop("The data.table and fixest packages are required.")
  }
  if (length(shrink) != 1L || is.na(shrink) || !is.logical(shrink)) {
    stop("shrink must be TRUE or FALSE.")
  }
  data.table::setDTthreads(4L)
  required <- c("MRUN", "AGNO", "RBD", "math", "reading", "female",
                "COD_ENSE", "PROM_GRAL", "SIT_FIN_R")
  if (!all(required %in% names(data))) {
    stop("Missing calibration columns: ", paste(setdiff(required, names(data)), collapse = ", "))
  }
  d <- data.table::as.data.table(data.table::copy(data))[, ..required]
  numeric_required <- setdiff(required, "SIT_FIN_R")
  if (!all(vapply(d[, ..numeric_required], is.numeric, logical(1)))) {
    stop("Identifier, score, sex, teaching-code and GPA columns must be numeric.")
  }
  if (anyNA(d) || any(!is.finite(as.matrix(d[, ..numeric_required])))) {
    stop("Calibration data must have complete finite values before fitting.")
  }
  if (any(d$MRUN <= 0 | d$RBD <= 0 | d$PROM_GRAL < 1 | d$PROM_GRAL > 7) ||
      any(!d$female %in% 0:1) || any(!d$SIT_FIN_R %in% c("P", "R"))) {
    stop("Invalid identifiers, GPA, sex or final-status values in calibration data.")
  }
  if (anyDuplicated(d[, c("MRUN", "AGNO"), with = FALSE])) {
    stop("Calibration data contain duplicate student-year records.")
  }
  years <- sort(unique(d$AGNO))
  school_ids <- sort(unique(d$RBD))
  J <- length(school_ids)
  if (J < 2L) stop("At least two schools are required.")

  # Sorting ensures rowsum(reorder=FALSE) aligns with school_ids, n_group and
  # the integer group vector used in the influence-function calculation.
  data.table::setorderv(d, c("RBD", "AGNO", "MRUN"))
  group <- match(d$RBD, school_ids)
  n_group <- tabulate(group, nbins = J)
  if (any(n_group < 2L)) {
    stop("Prefilter calibration schools to at least two matched records; the main pipeline may impose a stronger rule.")
  }
  basis_names <- character()
  transformation <- list()
  for (yr in years) {
    ii <- which(d$AGNO == yr)
    score_z <- list()
    transformation[[as.character(yr)]] <- list()
    for (subject in c("math", "reading")) {
      values <- d[[subject]][ii]
      mu <- mean(values)
      sig <- stats::sd(values)
      if (length(values) < 10L || !is.finite(sig) || sig <= 0 ||
          length(unique(values)) < 5L) {
        stop("Insufficient score variation for four-degree splines in year ", yr)
      }
      z <- (values - mu) / sig
      score_z[[subject]] <- z
      basis <- splines::ns(z, df = 4L, intercept = FALSE)
      transformation[[as.character(yr)]][[subject]] <- list(
        mean = mu, sd = sig, df = 4L,
        knots = unname(attr(basis, "knots")),
        boundary_knots = unname(attr(basis, "Boundary.knots")))
      for (k in seq_len(ncol(basis))) {
        nm <- paste0(subject, "_ns", k, "_y", yr)
        data.table::set(d, j = nm, value = 0)
        data.table::set(d, i = ii, j = nm, value = basis[, k])
        basis_names <- c(basis_names, nm)
      }
    }
    nm <- paste0("math_reading_y", yr)
    data.table::set(d, j = nm, value = 0)
    data.table::set(d, i = ii, j = nm,
                    value = score_z$math * score_z$reading)
    basis_names <- c(basis_names, nm)
  }
  # Explicit year indicators keep the school effects' normalization transparent.
  year_names <- character()
  for (yr in years[-1L]) {
    nm <- paste0("year_", yr)
    data.table::set(d, j = nm, value = as.numeric(d$AGNO == yr))
    year_names <- c(year_names, nm)
  }
  nuisance <- c("female", year_names, basis_names)
  fml <- stats::as.formula(paste("PROM_GRAL ~", paste(nuisance, collapse = " + "), "| RBD"))
  fit <- fixest::feols(fml, data = d, nthreads = 4L, fixef.rm = "none",
                       fixef.tol = 1e-10, collin.tol = 1e-10,
                       mem.clean = TRUE, notes = FALSE, warn = FALSE)
  if (stats::nobs(fit) != nrow(d)) stop("The regression silently dropped calibration records.")
  beta <- stats::coef(fit)
  if (length(beta) == 0L) stop("No identified nuisance regressors.")
  # Explicitly retain only the estimable RHS columns, after fixest's collinearity
  # removal. No dense school-indicator matrix is created in the empirical fit.
  X <- as.matrix(d[, names(beta), with = FALSE])
  residual <- stats::residuals(fit)
  theta_all <- fixest::fixef(fit, notes = FALSE)$RBD
  theta <- unname(theta_all[match(as.character(school_ids), names(theta_all))])
  if (anyNA(theta)) stop("A calibration school's fixed effect is missing.")
  centered_theta <- theta - mean(theta)
  variance <- .stringency_centered_fe_hc0(X, residual, group, n_group)
  V <- variance$variance
  noise_variance <- sum(V) / (J - 1L)
  tau2 <- max(stats::var(centered_theta) - noise_variance, 0)
  reliability <- if (tau2 == 0) rep(0, J) else tau2 / (tau2 + V)
  theta_eb <- reliability * centered_theta
  theta_eb <- theta_eb - mean(theta_eb)
  index <- if (shrink) -theta_eb else -centered_theta
  schools <- data.table::data.table(
    RBD = school_ids, n_calibration = n_group,
    theta = theta, theta_centered = centered_theta,
    theta_var_hc0 = V, theta_se_hc0 = sqrt(V),
    reliability = reliability, theta_eb = theta_eb,
    GRADE_STRINGENCY = index,
    GRADE_STRINGENCY_UNSHRUNK = -centered_theta)
  stopifnot(abs(mean(schools$GRADE_STRINGENCY)) < 1e-10,
            abs(mean(schools$GRADE_STRINGENCY_UNSHRUNK)) < 1e-10,
            all(is.finite(schools$GRADE_STRINGENCY)),
            all(schools$reliability >= 0 & schools$reliability <= 1))
  fit_metadata <- list(
    n_calibration = nrow(d), n_schools = J, years = years,
    n_by_year = d[, .(n = .N), by = AGNO][order(AGNO)],
    n_by_status = d[, .(n = .N), by = SIT_FIN_R][order(SIT_FIN_R)],
    specification = paste(deparse(fml), collapse = " "),
    standardization = "Subject scores standardized using mean and sample SD within calibration year.",
    spline = "Natural cubic spline, df=4, separately for subject and year; year-specific standardized math x reading product.",
    transformations = transformation,
    coefficients = beta,
    omitted_collinear_terms = setdiff(nuisance, names(beta)),
    nuisance_vcov_hc0 = variance$nuisance_vcov_hc0,
    centering = "Equal weight to each calibration school; recentered after shrinkage.",
    tau2 = tau2, observed_school_variance = stats::var(centered_theta),
    sampling_variance_correction = noise_variance,
    shrink = shrink,
    shrinkage = "Scalar empirical Bayes approximation: tau2=max(var(centered school FE)-sum(centered FE HC0 variances)/(J-1),0); reliability=tau2/(tau2+variance). Cross-school covariances are not used in the scalar weights.",
    historical_variance = "Centered school-FE HC0 sandwich includes common-slope uncertainty; conditional on observed covariates and spline knots.",
    uncertainty_caveat = "Empirical Bayes prior variance and weights are estimated; their uncertainty is not propagated. This helper supplies no lottery-stage standard errors.",
    residual_rmse = sqrt(mean(residual^2)),
    largest_absolute_school_mean_residual = max(abs(as.numeric(rowsum(residual, group, reorder = FALSE)) / n_group)),
    threads_requested = 4L,
    package_versions = c(fixest = as.character(utils::packageVersion("fixest")),
                         data.table = as.character(utils::packageVersion("data.table"))))
  list(schools = schools, metadata = fit_metadata)
}

verify_grade_stringency_covariance <- function(tolerance = 1e-9) {
  # Deterministic numerical verification of the algebra, separate from the
  # empirical estimation. Compare with full-dummy OLS HC0 on an unbalanced
  # example. No random draws, empirical estimates, or manuscript exports occur.
  n_group <- c(8L, 10L, 11L, 13L, 9L, 12L)
  J <- length(n_group)
  group <- rep(seq_len(J), n_group)
  i <- seq_along(group)
  X <- cbind(x1 = sin(i / 3) + group / 5,
             x2 = cos(i / 7) + group / 10,
             x3 = i %% 5)
  Z <- stats::model.matrix(~ factor(group) - 1)
  W <- cbind(Z, X)
  y <- group * 0.3 + X[, 1] * 0.2 - X[, 2] * 0.1 + X[, 3] * 0.05 +
    sin(i * 1.7) * (1 + group / 10)
  direct <- stats::lm.fit(W, y)
  Winv <- chol2inv(chol(crossprod(W)))
  V_full <- Winv %*% crossprod(W * direct$residuals) %*% Winv
  C <- diag(J) - matrix(1 / J, J, J)
  expected <- diag(C %*% V_full[seq_len(J), seq_len(J)] %*% t(C))
  computed <- .stringency_centered_fe_hc0(X, direct$residuals, group, n_group)$variance
  error <- max(abs(expected - computed))
  if (!is.finite(error) || error > tolerance * max(1, max(abs(expected)))) {
    stop("Centered FE covariance failed the full-dummy HC0 comparison: ", error)
  }
  list(passed = TRUE, maximum_absolute_difference = error,
       tolerance = tolerance, reference = "Full-dummy OLS HC0, deterministic unbalanced groups")
}
