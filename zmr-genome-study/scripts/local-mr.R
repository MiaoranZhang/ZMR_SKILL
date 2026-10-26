# Local, single-pair MR helper. Input instruments must already be LD-independent.
# Sourcing this file defines a function; it does not run an analysis or call an API.
run_local_mr <- function(exposure, outcome, out_dir, ivw,
                         outcome_scale, harmonise_action = 2L, seed = 1L) {
  if (!requireNamespace("TwoSampleMR", quietly = TRUE)) {
    stop("Install TwoSampleMR in the analysis environment.")
  }
  ivw <- match.arg(ivw, c("mr_ivw_mre", "mr_ivw_fe"))
  outcome_scale <- match.arg(outcome_scale, c("beta", "log_odds"))
  if (length(harmonise_action) != 1L || !harmonise_action %in% 1:3) {
    stop("harmonise_action must be 1, 2, or 3.")
  }
  check_input <- function(x, side) {
    required <- c("SNP", paste0(c("beta", "se", "effect_allele", "other_allele",
                                  "eaf", "id"), ".", side), side)
    if (!is.data.frame(x) || !all(required %in% names(x)) || !nrow(x)) {
      stop("Provide a nonempty standard TwoSampleMR table for each side.")
    }
    id <- x[[paste0("id.", side)]]
    if (anyNA(id) || length(unique(id)) != 1L) stop("Use one study per side.")
    if (anyNA(x$SNP) || any(!nzchar(x$SNP)) || anyDuplicated(x$SNP)) {
      stop("Resolve missing or duplicate variants within each study first.")
    }
    b <- x[[paste0("beta.", side)]]
    se <- x[[paste0("se.", side)]]
    eaf <- x[[paste0("eaf.", side)]]
    if (!is.numeric(b) || !is.numeric(se) || !is.numeric(eaf) ||
        any(!is.finite(b)) || any(!is.finite(se) | se <= 0) ||
        any(!is.na(eaf) & (!is.finite(eaf) | eaf <= 0 | eaf >= 1))) {
      stop("Invalid effect, SE, or effect-allele frequency.")
    }
    a1 <- x[[paste0("effect_allele.", side)]]
    a2 <- x[[paste0("other_allele.", side)]]
    if (anyNA(a1) || anyNA(a2) || any(!nzchar(a1) | !nzchar(a2)) ||
        any(toupper(a1) == toupper(a2))) stop("Invalid allele labels.")
  }
  check_input(exposure, "exposure")
  check_input(outcome, "outcome")
  if (file.exists(out_dir)) stop("Choose a new output directory.")
  set.seed(seed)
  all_rows <- TwoSampleMR::harmonise_data(exposure, outcome, action = harmonise_action)
  dat <- all_rows[!is.na(all_rows$mr_keep) & all_rows$mr_keep, , drop = FALSE]
  if (!nrow(dat)) stop("No usable harmonized instruments; no estimate produced.")
  methods <- if (nrow(dat) == 1L) "mr_wald_ratio" else ivw
  if (nrow(dat) >= 3L) methods <- c(methods, "mr_egger_regression", "mr_weighted_median")
  res <- TwoSampleMR::mr(dat, method_list = methods)
  if (!nrow(res)) stop("No MR estimates returned.")
  res$estimate_status <- ifelse(is.finite(res$b) & is.finite(res$se) &
                                 is.finite(res$pval), "estimated", "not_estimable")
  res$lower_beta <- res$b - 1.96 * res$se
  res$upper_beta <- res$b + 1.96 * res$se
  if (outcome_scale == "log_odds") {
    res$OR <- exp(res$b)
    res$lower_OR <- exp(res$lower_beta)
    res$upper_OR <- exp(res$upper_beta)
  }
  diagnostic_status <- data.frame(
    diagnostic = c("heterogeneity", "egger_intercept", "steiger", "mr_presso"),
    status = c("insufficient_instruments", "insufficient_instruments",
               "not_run_requires_trait_metadata", "not_run_optional_extension")
  )
  het <- ple <- NULL
  if (nrow(dat) >= 3L) {
    het <- tryCatch(TwoSampleMR::mr_heterogeneity(
      dat, method_list = c("mr_ivw", "mr_egger_regression")), error = function(e) NULL)
    ple <- tryCatch(TwoSampleMR::mr_pleiotropy_test(dat), error = function(e) NULL)
    assess <- function(x, columns) {
      if (is.null(x) || !nrow(x) || !all(columns %in% names(x))) return("failed")
      if (all(is.finite(as.matrix(x[, columns, drop = FALSE])))) "computed" else "incomplete"
    }
    diagnostic_status$status[1] <- assess(het, c("Q", "Q_df", "Q_pval"))
    diagnostic_status$status[2] <- assess(ple, c("egger_intercept", "se", "pval"))
  }
  if (!dir.create(out_dir, recursive = TRUE)) stop("Could not create output directory.")
  write_table <- function(x, file) {
    if (!is.null(x)) write.table(x, file.path(out_dir, file), sep = "\t",
                                quote = FALSE, row.names = FALSE, na = "NA")
  }
  write_table(all_rows, "harmonized_all.tsv")
  write_table(dat, "harmonized_kept.tsv")
  write_table(res, "mr_estimates.tsv")
  write_table(het, "heterogeneity.tsv")
  write_table(ple, "egger_intercept.tsv")
  write_table(data.frame(SNP = dat$SNP,
                         approximate_F = (dat$beta.exposure / dat$se.exposure)^2),
              "instrument_strength.tsv")
  write_table(diagnostic_status, "diagnostic_status.tsv")
  write_table(data.frame(stage = c("exposure_input", "outcome_input", "harmonized", "kept"),
                         n = c(nrow(exposure), nrow(outcome), nrow(all_rows), nrow(dat))),
              "stage_counts.tsv")
  write_table(data.frame(ivw = ivw, outcome_scale = outcome_scale,
                         harmonise_action = harmonise_action, seed = seed,
                         TwoSampleMR = as.character(utils::packageVersion("TwoSampleMR"))),
              "parameters.tsv")
  invisible(list(estimates = res, harmonized = dat, diagnostics = diagnostic_status))
}
