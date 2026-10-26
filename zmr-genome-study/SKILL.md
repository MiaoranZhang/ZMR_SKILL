---
name: zmr-genome-study
description: Build reproducible R workflows for GWAS and molecular-QTL summary-data research, including two-sample Mendelian randomization, SMR/HEIDI, colocalization, and genetic evidence figures. Use for 孟德尔随机化, GWAS/QTL integration, genetic causal inference, and zmr GenomeStudy requests.
---

# zmr GenomeStudy SKILL

Turn GWAS and molecular-QTL summary statistics into inspectable genetic evidence. Preserve the explicit R workflow: standardize columns, check variants, select instruments or regions, harmonize, estimate, assess sensitivity, export tables, then plot. Treat MR, SMR, and colocalization as complementary evidence with distinct assumptions.

## Choose the workflow

- For all analyses, read [data-contract.md](references/data-contract.md) for study metadata, variant matching, LD, and optional OpenGWAS access.
- For two-sample MR, bidirectional MR, or a request to extend to multivariable MR, read [mr-workflow.md](references/mr-workflow.md). The runnable [local MR helper](scripts/local-mr.R) covers a single exposure-outcome pair with preselected independent instruments.
- For regional colocalization or SMR/HEIDI, read [coloc-smr-workflow.md](references/coloc-smr-workflow.md). The [local coloc helper](scripts/local-coloc.R) covers one region and two traits under a single-causal-variant model.
- For consolidated evidence tables, forest plots, or locus figures, read [reporting.md](references/reporting.md).

This skill focuses on genetic association and causal-inference workflows. Single-cell expression, qPCR, and general transcriptomic differential analysis belong to their corresponding workflows; add them only when the request calls for integration.

## Working conventions

- Prefer transparent R scripts and named columns over positional indexing and elaborate frameworks. Inspect dimensions, missingness, variant counts, and group counts after key transformations.
- Preserve raw inputs. Save harmonized data, exclusions, method-level estimates, and per-locus results before building summaries. Keep exposure, outcome, tissue, locus, and method identifiers explicit.
- Choose analysis parameters from the question, ancestry, design, and available data. Record their timing; do not describe a choice made after inspecting outcomes as prespecified.
- Never substitute an arbitrary sample size, allele frequency, trait scale, or case fraction. Report a missing prerequisite or use a justified alternative.
- Distinguish insufficient instruments, invalid input, failed computation, and a completed analysis with a nonsignificant result.
- Interpret findings at the level supported by instrument validity, LD, sample overlap, sensitivity, and replication. A shared signal or nonsignificant pleiotropy test alone does not prove causality.

## Credentials and sharing

The supplied scripts use local inputs and need no API credential. Optional OpenGWAS access uses the operator's runtime `OPENGWAS_JWT` environment variable. Never embed a credential in scripts, prompts, reports, examples, or exported objects. Do not print environment contents, HTTP authorization headers, or authentication responses. Share only intended scripts, documentation, and approved outputs; exclude credential files, private paths, participant data, and project-specific source archives.

## Delivery

Provide the script, input schema and study metadata, chosen parameters, stage counts, result and sensitivity tables, interpretable plots when requested, and software versions. State which analyses actually ran. The included helpers are starting points with deliberately bounded scope; they do not execute clumping, SMR, MR-PRESSO, Steiger tests, or multivariable MR automatically.
