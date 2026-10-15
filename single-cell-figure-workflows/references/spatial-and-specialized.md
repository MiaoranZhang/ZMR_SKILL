# Spatial and Specialized Workflows

## Purpose

Read this file when the task goes beyond standard Seurat clustering.

## Xenium and Spatial Mapping

Common operations:

- `ImageDimPlot`
- `ImageFeaturePlot`
- `GetTissueCoordinates`
- `RCTD` mapping through `spacexr`
- `BuildNicheAssay`
- niche frequency plots and ROIE heatmaps
- spatial `CellChat`

Typical pattern:

1. load Xenium Seurat object
2. visualize molecules or grouped annotations
3. map scRNA reference labels with `RCTD`
4. construct niche assay
5. compare niche composition
6. run spatial communication analysis

## GeoMx and NanoString

Common operations:

- build Seurat object from count matrix plus metadata
- use PCA or UMAP for sample-level structure
- run region-specific DEG with `DESeq2`
- remove patient batch effects with `limma::removeBatchEffect`
- generate heatmaps with `ComplexHeatmap` or `pheatmap`

Important analysis rule:

- for DESeq2, use raw integer-like counts, not scaled Seurat matrices

## Communication Analysis

Preferred tool:

- `CellChat`

Common sequence:

1. build metadata with a clear grouping label
2. `createCellChat`
3. assign database
4. `subsetData`
5. identify overexpressed genes and interactions
6. compute probabilities and pathways
7. aggregate network
8. visualize with circle, bubble, or chord plots

## CNV and Malignant-State Support

Common tools:

- `infercnv`
- `copykat`

Use these analyses as support for malignant-state interpretation, not as a replacement for expression-based biology.

## Additional Specialized Branches

Other specialized tools include:

- `Signac`
- `nichenetr`
- `scMetabolism`
- `monocle3`
- `slingshot`
- `TCGAbiolinks`

Rule:

- do not introduce one of these branches unless the project already needs that exact analysis layer
- if a project script already solved the same task, reuse its structure rather than inventing a new one
