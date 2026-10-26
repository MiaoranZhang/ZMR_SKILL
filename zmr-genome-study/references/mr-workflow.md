# Mendelian randomization

## Extract the scientific workflow

1. Select instruments using exposure evidence and the declared LD design. Keep the unfiltered selection table and each exclusion reason. Do not select instruments by favorable outcome p-values.
2. Obtain outcome effects for those variants; document missing SNPs and any proxies with allele mapping and LD information.
3. Harmonize exposure/outcome alleles with an explicit palindromic-SNP policy. Keep the full harmonization output and then select `mr_keep == TRUE` for inference.
4. Estimate the association and export results in long form, one row per study pair and method. Retrieve methods by identifier/name, never by a presumed row index.
5. Add supported sensitivity analyses and instrument diagnostics; save each result before joining summaries.

## Estimators and diagnostics

- One valid instrument supports a Wald ratio; multiple independent instruments permit IVW. Egger, weighted median/mode, and other sensitivity estimators require enough usable instruments and suitable assumptions. Do not pad unavailable methods with fabricated rows of estimates.
- Fix the primary IVW model in the analysis plan. A heterogeneity-based choice may reproduce a specified historical analysis, but document that rule and report both models if scientifically appropriate; do not select the model that gives a preferable p-value. The supplied helper requires an explicit IVW argument for this reason.
- Report Cochran's Q with its degrees of freedom and p-value where supported. A nonsignificant Q or Egger-intercept test does not establish valid instruments.
- Approximate per-SNP strength with `F = (beta_exposure / se_exposure)^2`. This is not statistical power and is not the conditional F statistic for multivariable MR. Compute R-squared only with a formula appropriate to trait scale and sample design; do not switch formulas based on an arbitrary instrument count or sum correlated instruments as independent.
- Steiger directionality requires comparable variance-explained estimates. Confirm sample size, trait scale, and binary-trait assumptions before using it; record when it cannot be assessed.
- MR-PRESSO requires sufficient instruments and simulation precision. Record the seed, number of draws, global test, outlier findings, and distortion test where available. Keep original and corrected estimates; missing corrected output is not a zero effect. Do not repeatedly drop variants merely to obtain a desired result.
- Consider sample overlap, winner's curse, weak instruments, correlated pleiotropy, and multiple comparisons when interpreting an apparent effect. Escalate the method only when the study design calls for it.

## Local helper

```r
source("scripts/local-mr.R")
# Tables have standard TwoSampleMR columns and represent one trait each.
# Instruments have already been selected and checked for LD independence.
result <- run_local_mr(
  exposure, outcome, out_dir = "results/mr_pair_01",
  ivw = "mr_ivw_mre", outcome_scale = "beta"
)
```

Use `outcome_scale = "log_odds"` only for an outcome reported on that scale. The helper creates a new directory, saves all harmonized rows, reports usable instruments and per-SNP F, runs supported estimators, and records the scope of diagnostics. It does not download data, select/clump instruments, or prove their independence. Extend the workflow explicitly for Steiger, PRESSO, power, or additional methods.

For bidirectional MR, build a separate instrument set for the reverse direction. For multivariable MR, combine instruments across exposures, resolve LD, obtain every retained SNP's effect on every exposure, harmonize jointly, and assess conditional strength. A collection of univariable estimates is not multivariable MR.

Official references: [allele harmonization](https://mrcieu.github.io/TwoSampleMR/articles/harmonise.html), [MR and multivariable workflows](https://mrcieu.github.io/TwoSampleMR/articles/perform_mr.html), [multiplicative random-effects IVW](https://mrcieu.github.io/TwoSampleMR/reference/mr_ivw_mre.html).
