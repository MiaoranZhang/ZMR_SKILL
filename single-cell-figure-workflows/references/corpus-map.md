# Workflow Map

## Purpose

Use this file to choose a suitable analysis scaffold by task type. Adapt the nearest existing project script or template when one is available.

## Workflow Families

- **Single-cell integration and annotation:** Seurat or Harmony preprocessing, clustering, marker discovery, cell annotation, and annotation figures.
- **Cell-state scoring:** AUCell, AddModuleScore, JASMINE, or rank-based enrichment, with the method selected to match the biological question.
- **Cell communication:** CellChat or another method already established in the project.
- **Spatial and imaging-based profiling:** Xenium, RCTD, GeoMx, or related spatial workflows.
- **Copy-number support:** infercnv or copykat for malignant-state or CNV analyses.
- **Subtype and trajectory analysis:** focused subclustering, pathway enrichment, CytoTRACE2, monocle3, and source-to-target communication tracing when relevant.
- **Differential expression and visualization:** DESeq2, limma, marker tables, heatmaps, and manuscript-ready plots.

## Scaffold Selection

- Start from the closest project script when the task extends an existing analysis.
- Use the corresponding template in `scripts/` for a new workflow.
- Reuse established metadata, assays, factor orders, color mappings, and export conventions.
- Introduce a new method only when the existing workflow cannot answer the scientific question.
