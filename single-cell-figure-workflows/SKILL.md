---
name: single-cell-figure-workflows
description: R coding and figure guidance for bioinformatics projects. Use for Seurat and Harmony single-cell workflows, cell annotation figures, tumor microenvironment projects, AUCell or AddModuleScore or JASMINE scoring, CellChat, infercnv or copykat, Xenium or RCTD, NanoString GeoMx, DESeq2 or limma, and manuscript-ready plotting.
---

# Single-Cell Figure Workflows

## Overview

Use this skill for Seurat-first, biology-driven, manuscript-oriented R analysis: load data, build or subset biologically named objects, run clustering or DEG or scoring or communication analysis, then export direct PDF and CSV outputs.

This skill focuses on extending, cleaning, or rewriting bioinformatics analysis and manuscript-figure workflows.

## When To Use This Skill

Use it when the task involves any of these:

- editing or extending existing R analysis scripts
- building a new R workflow that follows a project's established conventions
- continuing Seurat or Harmony single-cell analyses
- subclustering immune, stromal, epithelial, or lineage-specific populations
- scoring signatures with `AUCell`, `AddModuleScore`, `JASMINE`, or rank-based enrichment
- running `CellChat`, `infercnv`, `copykat`, `SingleR`, `scDblFinder`, or `decontX`
- handling `Xenium`, `RCTD`, `BuildNicheAssay`, or `NanoString GeoMx`
- making manuscript-ready UMAP, DotPlot, FeaturePlot, violin, heatmap, or stacked-bar figures

## Workflow Decision Tree

1. Identify the modality first.
   - Standard single-cell or subclustering: read [references/single-cell-workflows.md](references/single-cell-workflows.md)
   - Spatial or specialized profiling: read [references/spatial-and-specialized.md](references/spatial-and-specialized.md)
   - Legacy style, naming, exports, or refactor discipline: read [references/style-rules.md](references/style-rules.md)
   - Looking for a workflow scaffold by analysis type: read [references/corpus-map.md](references/corpus-map.md)
   - Looking for common failure modes: read [references/gotchas.md](references/gotchas.md)
   - Trying to execute a standard task fast: read [references/task-playbooks.md](references/task-playbooks.md)
   - Doing subtype function plus FGSEA plus CytoTRACE2 plus monocle3 plus CellChat source tracing: read [references/subtype-state-pipeline.md](references/subtype-state-pipeline.md)

2. If you need a direct scaffold, start from the nearest template in `scripts/`.
   - `scripts/seurat-backbone-template.R`
   - `scripts/signature-scoring-template.R`
   - `scripts/cellchat-template.R`
   - `scripts/xenium-rctd-template.R`
   - `scripts/subtype-state-pipeline-template.R`

3. Preserve the project's biological frame.
   - Prefer object names like `Epi`, `CD4T`, `LNCD4T`, `Macro`, `Fib`, `Tcells`, `Tumor`
   - Preserve metadata columns such as `orig.ident`, `group`, `stim`, `sampletype`, `celltype`, `celltype_t`, `finaltype`, `seurat_clusters`

4. Choose the smallest safe change.
   - Legacy monolithic script: patch surgically unless the user asks for cleanup
   - New workflow or repeated logic: extract helper functions when it removes obvious duplication
   - If a template solves most of the task, copy it and adapt it instead of rebuilding from zero

5. Keep outputs manuscript-ready.
   - Export direct `pdf`, `csv`, or `rds` artifacts
   - Use explicit filenames tied to project, date, or comparison

## Core Rules

- Stay in `R` unless there is a clear reason not to.
- Match the project's existing package stack before introducing new tools.
- Do not force abstract software-engineering patterns onto a script whose real job is fast biological iteration.
- If an existing script already encodes the right biological contrast, reuse that structure instead of rebuilding from scratch.
- When changing a legacy script, protect object names and downstream file expectations unless the user asks for a broader refactor.
- If the code is feeding a manuscript figure, optimize for the exact biological sentence the output needs to support.

## Default Analysis Backbone

For Seurat-heavy workflows, the recurring backbone is:

1. Read counts or RDS
2. `CreateSeuratObject`
3. QC or cleanup
4. `NormalizeData` or `SCTransform`
5. `RunPCA`
6. `RunHarmony` when integrating across `orig.ident`, `stim`, or `sample`
7. `RunTSNE` and `RunUMAP`
8. `FindNeighbors` and `FindClusters`
9. `FindAllMarkers` or `FindMarkers`
10. signature scoring, communication, or subset-specific follow-up
11. export PDFs, CSVs, and RDS files

Typical corpus defaults:

- dimensions: often `1:20`, `1:30`, or `1:50`
- `k.param`: often `30` or `50`
- resolution: often `0.2` to `0.5`
- seeds: commonly `0`, `100`, or `1000`

## Preferred Extensions

- For state scoring: prefer `AUCell`, `AddModuleScore`, `JASMINE`, or rank-based enrichment already used in the corpus
- For communication: prefer `CellChat`
- For lineage or temporal direction: prefer `slingshot` or the existing manuscript-specific logic
- For annotation: prefer `SingleR` if a reference already exists
- For contamination or doublets: prefer `decontX` and `scDblFinder`
- For CNV or malignant-state support: prefer `infercnv` or `copykat`

## Output Style

- Prefer direct plots over wrapper abstractions
- Use manual color palettes when they are already established in the script
- Use `theme_classic`, `guides`, factor releveling, and explicit dimensions for submission-ready figures
- Minimize unused whitespace, use heavier axis, border, and key data-line weights, and set non-gene figure text in Arial Bold. For composite figures, use A4 page width by default (210 mm / 8.27 in) and determine height from the figure content rather than forcing a fixed page height. Make text as large as possible while preventing overlap, clipping, or obstruction of data and labels.
- Render English gene symbols in Arial Italic wherever they appear as plot text, including axis labels, marker labels, and in-panel annotations. Do not italicize cell types, pathways, statistical terms, or other non-gene labels.
- Save intermediate objects when downstream scripts depend on them
- For final single-cell UMAP figures, use all cells by default. Do not cap or balance the number of plotted cells per cluster or cell type, because that distorts apparent population proportions and mixing. Rasterization is encouraged for large objects because it preserves all cells while keeping output manageable. Follow the full-cell UMAP rules in [references/single-cell-workflows.md](references/single-cell-workflows.md).
- For cell-annotation DotPlots, preserve marker-panel grouping and gene order, and produce matched views by unsupervised cluster and by curated cell label. Follow the grouped annotation DotPlot rules in [references/single-cell-workflows.md](references/single-cell-workflows.md).
- For single-cell DotPlots, format x-axis gene labels in italic type and rotate them 60 degrees for consistent readability.
- For single-gene differential-expression barplots, use donor/sample-level biological replicates, display effect size (`log2FC`) and the stated P/q value, and separate expression level from the fraction of expressing cells. Follow the detailed rules in [references/single-cell-workflows.md](references/single-cell-workflows.md).
- For single-cell QC summaries, show paired before-versus-after distributions of `nCount`, `nFeature`, and mitochondrial percentage for every sample, split by biological group, using the compact faceted violin layout defined in [references/single-cell-workflows.md](references/single-cell-workflows.md). Omit QC threshold lines by default because filtering rules may be sample-specific.

## Reference Map

- [references/corpus-map.md](references/corpus-map.md): workflow families and scaffold selection
- [references/single-cell-workflows.md](references/single-cell-workflows.md): Seurat, Harmony, subclustering, DEG, and signature routines
- [references/spatial-and-specialized.md](references/spatial-and-specialized.md): Xenium, RCTD, GeoMx, NanoString, CellChat, infercnv, and related branches
- [references/style-rules.md](references/style-rules.md): naming, refactor discipline, output conventions, and recurring coding habits
- [references/gotchas.md](references/gotchas.md): high-frequency breakpoints and compatibility traps seen in the corpus
- [references/task-playbooks.md](references/task-playbooks.md): fast checklists for common task types
- [references/subtype-state-pipeline.md](references/subtype-state-pipeline.md): subtype one-vs-rest FGSEA, corrected top-pathway heatmaps, CytoTRACE2, monocle3, and CellChat incoming-source workflow
