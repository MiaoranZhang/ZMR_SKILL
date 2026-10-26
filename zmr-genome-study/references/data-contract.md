# Study and variant contract

## Before selecting variants

Record exposure/outcome definitions, tissue or cell context for QTLs, data release, ancestry, genome build, effect units, total and per-variant sample sizes where available, case/control counts, participant overlap, and ascertainment. Define cis/trans scope, instrument threshold, LD rules, region boundaries, and the multiple-testing family for this analysis. Keep project-specific source locations in private run configuration.

Map columns by name. A useful normalized table has `SNP`, `chr`, `pos`, `effect_allele`, `other_allele`, `eaf`, `beta`, `se`, `pval`, and `samplesize`. Add study, trait, and tissue identifiers to prevent accidental cross-study deduplication. MR helpers accept the standard TwoSampleMR exposure/outcome tables; coloc uses the separate schema below.

## Checks that change inference

- Confirm build and allele representation before joining. An rsID match alone does not resolve multiallelic variants, genome-build changes, or indel normalization.
- Align beta and effect-allele frequency to the stated effect allele. Do not substitute MAF for EAF. For a known EAF, MAF can be calculated as `min(eaf, 1-eaf)` for coloc input.
- Require finite beta, positive finite SE, valid probability/frequency ranges, and distinct nonmissing allele labels. Investigate underflowed p-values rather than silently inventing precision.
- Within a study and trait, remove exact duplicate records transparently; conflicting duplicate variants need a documented resolution. Retain a removal count and reason.
- For case-control GWAS, verify whether effects are log odds ratios. Transform an odds ratio to log scale only with consistent uncertainty; do not transform SE as if it were an odds ratio.
- Match LD reference ancestry and build. Record clumping parameters and missing reference variants. A lead-SNP selection list may define loci, but regional coloc requires dense summary data rather than the clumped MR instrument table.

## Optional OpenGWAS access

Operators provision their own `OPENGWAS_JWT` privately. A script can check availability without displaying the value:

```r
if (!nzchar(Sys.getenv("OPENGWAS_JWT", unset = ""))) {
  stop("Configure OPENGWAS_JWT privately before using OpenGWAS.")
}
# Supported ieugwasr/TwoSampleMR calls read the runtime credential.
# Pass only approved study IDs and query parameters; never print the credential.
```

Check the installed function signature before calling an API. Keep authenticated objects and headers out of saved analysis objects. Use bounded retries for transient failures, honor service allowance/reset information, and stop on authentication errors. Prefer reusable authorized local data when already available. No access token, personal API configuration, private data cache, or `.Renviron` file belongs in a shared skill.

Official reference: [ieugwasr authentication and allowance](https://mrcieu.github.io/ieugwasr/articles/guide.html).
