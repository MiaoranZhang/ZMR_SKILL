# Regional colocalization and SMR

## Colocalization

Define a region using stated bounds, a lead variant, or another justified locus definition. Preserve dense available variants throughout the region and inspect coverage in both traits. Do not run coloc only on significant or LD-clumped instruments. Match variants and allele representation before merging; explicit dataset names prevent beta, SE, and frequency columns from being assigned to the wrong trait.

For beta-based coloc inputs, set `varbeta = se^2`, assign `type = "quant"` or `"cc"` from the phenotype, and supply each dataset's own metadata. A quantitative trait needs a justified `sdY` or information for its estimation; do not assume `sdY = 1` unless standardization is documented. Record sample size and, for case-control data, the case fraction rather than copying them from an example.

The included helper uses a conservative input contract: one region, build-matched normalized biallelic SNPs, prealigned effect alleles, and trait-specific sample metadata. It rejects inconsistent position/allele pairs and duplicate variant IDs, reorders the two datasets by shared SNP ID, and writes PP.H0 through PP.H4 plus variant-level results. Input schema is `snp`, `chr`, `position`, `effect_allele`, `other_allele`, `beta`, `se`, and `eaf`.

```r
source("scripts/local-coloc.R")
result <- run_local_coloc(
  trait1, trait2,
  meta1 = list(type = "quant", N = study_n1, sdY = trait_sd, build = genome_build),
  meta2 = list(type = "cc", N = study_n2, s = case_fraction, build = genome_build),
  out_dir = "results/coloc_locus_01",
  p1 = prior_trait1, p2 = prior_trait2, p12 = prior_shared
)
```

`coloc.abf` assumes at most one causal variant per trait in the region. When multiple signals matter, use an appropriate conditional or fine-mapping approach, such as coloc with SuSiE, with correctly aligned signed LD. Report PP.H3, PP.H4, signal strength, overlap coverage, and sensitivity to priors. Low support for shared variation may reflect limited power or coverage; a shared signal does not establish mediation.

Official reference: [coloc input design](https://chr1swallace.github.io/coloc/articles/a02_data.html).

## SMR/HEIDI

Prepare the GWAS summary columns as `SNP A1 A2 freq b se p n`, with A1 as effect allele and freq its frequency. Use named source fields, a single header, consistent build, and explicit duplicate handling. Keep unknown sample size missing with a documented explanation if the chosen software permits it; do not fabricate it.

Use an appropriate LD reference and QTL summary files. For binary QTL summaries, the prefix denotes `.besd`, `.esi`, and `.epi` files; PLINK reference prefixes denote `.bed`, `.bim`, and `.fam`. Inspect the installed binary's help for supported flags. A generic command shape is:

```text
smr --bfile reference/ld_panel --gwas-summary input/gwas.ma --beqtl-summary input/qtl --out results/smr_run --thread-num 4
```

Choose tissue, cis window, QTL threshold, and HEIDI settings for the study. Export probe/gene, tissue, instrument, SMR estimate/SE/p-value, HEIDI p-value and SNP count, plus the multiple-testing correction. Separate unavailable HEIDI results from completed tests. Significant SMR with no detected HEIDI heterogeneity supports follow-up but cannot by itself distinguish mediation from horizontal pleiotropy. Preserve each run's table before stacking results.

Official reference: [SMR input and analysis documentation](https://yanglab.westlake.edu.cn/software/smr).
