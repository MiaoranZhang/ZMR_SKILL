# Local beta-based coloc for one region and two traits; no downloads or credentials.
run_local_coloc <- function(trait1, trait2, meta1, meta2, out_dir, p1, p2, p12) {
  if (!requireNamespace("coloc", quietly = TRUE)) stop("Install coloc first.")
  check_input <- function(x, meta) {
    required <- c("snp", "chr", "position", "effect_allele", "other_allele",
                  "beta", "se", "eaf")
    if (!is.data.frame(x) || !all(required %in% names(x)) || !nrow(x)) {
      stop("Provide a nonempty normalized region table for each trait.")
    }
    if (anyNA(x$snp) || any(!nzchar(x$snp)) || anyDuplicated(x$snp)) {
      stop("Resolve missing or duplicate variant identifiers first.")
    }
    if (anyNA(x$chr) || any(!nzchar(as.character(x$chr))) || length(unique(x$chr)) != 1L) {
      stop("Each input must describe one chromosome within a defined locus.")
    }
    if (!all(vapply(x[c("position", "beta", "se", "eaf")], is.numeric, logical(1))) ||
        any(!is.finite(x$position) | x$position <= 0 | x$position != floor(x$position)) ||
        any(!is.finite(x$beta)) || any(!is.finite(x$se) | x$se <= 0) ||
        any(!is.finite(x$eaf) | x$eaf <= 0 | x$eaf >= 1)) stop("Invalid numeric input.")
    if (anyNA(x$effect_allele) || anyNA(x$other_allele) ||
        any(!x$effect_allele %in% c("A", "C", "G", "T")) ||
        any(!x$other_allele %in% c("A", "C", "G", "T")) ||
        any(x$effect_allele == x$other_allele)) {
      stop("This helper requires normalized biallelic SNPs with uppercase alleles.")
    }
    positive_scalar <- function(x) is.numeric(x) && length(x) == 1L && is.finite(x) && x > 0
    if (!is.list(meta) || length(meta$type) != 1L || !meta$type %in% c("quant", "cc") ||
        !positive_scalar(meta$N) || meta$N <= 1 ||
        length(meta$build) != 1L || is.na(meta$build) || !nzchar(meta$build)) {
      stop("Specify type, N, and build separately for each trait.")
    }
    if (meta$type == "quant" && !positive_scalar(meta$sdY)) {
      stop("Provide a justified trait SD (sdY) for a quantitative trait.")
    }
    if (meta$type == "cc" && (!positive_scalar(meta$s) || meta$s >= 1)) {
      stop("Provide the case fraction (0 < s < 1) for a case-control trait.")
    }
  }
  check_input(trait1, meta1)
  check_input(trait2, meta2)
  if (!identical(meta1$build, meta2$build)) stop("Genome builds differ.")
  priors <- list(p1, p2, p12)
  if (!all(vapply(priors, function(x) is.numeric(x) && length(x) == 1L &&
                    is.finite(x) && x > 0 && x < 1, logical(1)))) stop("Invalid priors.")
  shared <- sort(intersect(as.character(trait1$snp), as.character(trait2$snp)))
  if (length(shared) < 2L) stop("Insufficient shared variants for regional inference.")
  a <- trait1[match(shared, trait1$snp), , drop = FALSE]
  b <- trait2[match(shared, trait2$snp), , drop = FALSE]
  if (any(a$chr != b$chr | a$position != b$position)) stop("Variant coordinates differ.")
  if (any(a$effect_allele != b$effect_allele | a$other_allele != b$other_allele)) {
    stop("Align allele representation and beta/EAF before running this helper.")
  }
  if (file.exists(out_dir)) stop("Choose a new output directory.")
  dataset <- function(x, meta) {
    d <- list(snp = as.character(x$snp), position = x$position, beta = x$beta,
              varbeta = x$se^2, MAF = pmin(x$eaf, 1 - x$eaf),
              type = meta$type, N = meta$N)
    if (meta$type == "quant") d$sdY <- meta$sdY else d$s <- meta$s
    coloc::check_dataset(d)
    d
  }
  d1 <- dataset(a, meta1)
  d2 <- dataset(b, meta2)
  res <- coloc::coloc.abf(dataset1 = d1, dataset2 = d2, p1 = p1, p2 = p2, p12 = p12)
  if (!dir.create(out_dir, recursive = TRUE)) stop("Could not create output directory.")
  write_table <- function(x, file) write.table(x, file.path(out_dir, file), sep = "\t",
                                               quote = FALSE, row.names = FALSE, na = "NA")
  write_table(a, "trait1_shared.tsv")
  write_table(b, "trait2_shared.tsv")
  write_table(as.data.frame(t(res$summary)), "coloc_summary.tsv")
  write_table(res$results, "coloc_variants.tsv")
  write_table(data.frame(trait1_variants = nrow(trait1), trait2_variants = nrow(trait2),
                         shared_variants = length(shared)), "coverage.tsv")
  write_table(data.frame(p1 = p1, p2 = p2, p12 = p12, build = meta1$build,
                         trait1_type = meta1$type, trait2_type = meta2$type,
                         trait1_N = meta1$N, trait2_N = meta2$N,
                         trait1_sdY = if (is.null(meta1$sdY)) NA_real_ else meta1$sdY,
                         trait2_sdY = if (is.null(meta2$sdY)) NA_real_ else meta2$sdY,
                         trait1_case_fraction = if (is.null(meta1$s)) NA_real_ else meta1$s,
                         trait2_case_fraction = if (is.null(meta2$s)) NA_real_ else meta2$s,
                         coloc = as.character(utils::packageVersion("coloc"))), "parameters.tsv")
  invisible(res)
}
