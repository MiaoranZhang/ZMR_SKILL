# Gotchas

## Purpose

Read this file before patching a legacy script or when an apparently simple analysis starts failing for no obvious reason.

## Seurat and Assay Pitfalls

- Many scripts mix `RNA` and `SCT` on purpose. Check which assay drives clustering, which drives plotting, and which drives scoring before changing code.
- Direct slot access like `obj@assays$RNA@data` is common. Do not blindly replace it if downstream code expects the current structure.
- Re-running `SCTransform` on a subset can change downstream variable features and marker rankings. Only do it when the script logic already assumes reclustering.

## Harmony Pitfalls

- Some workflows may patch Harmony internals to avoid one-hot encoding issues. If `RunHarmony` fails in an older environment, inspect a known-good project script before changing the full integration path.
- Harmony grouping variables must exist and be clean factors or strings. Missing `orig.ident`, `stim`, or `sample` columns are a common hidden failure.

## DEG Pitfalls

- `DESeq2` should use raw integer-like counts, not scaled matrices or transformed Seurat slots. This matters especially in GeoMx workflows.
- `FindMarkers` calls often rely on explicit filtering of mitochondrial or immunoglobulin genes. If a comparison suddenly looks noisy, inspect the feature filter.
- In this corpus, many single-cell DEG comparisons use `MAST`. Do not switch tests casually if the result is meant to match an existing figure.

## Metadata Pitfalls

- A large fraction of the code assumes columns such as `group`, `stim`, `celltype_t`, `sampletype`, or `finaltype` already exist.
- Factor order matters for final plots. If a figure looks wrong, check level order before changing the plotting code itself.
- Renaming cluster or cell-type columns can silently break downstream plotting and CSV export.

## CellChat Pitfalls

- Group labels with slashes can cause trouble in some branches. Clean them if network or plotting code behaves strangely.
- `CellChat` workflows in the corpus assume a fully prepared metadata frame. If interactions are empty, inspect grouping labels and minimum-cell thresholds first.

## Spatial Pitfalls

- In `RCTD`, coordinate row names and count matrix column names must match exactly.
- Xenium and image-based workflows often depend on specific `fov` names and object slots. Check them before refactoring.
- `BuildNicheAssay` output depends strongly on neighborhood parameters; do not change them if the goal is figure continuity.

## Compatibility Pitfalls

- Some scripts rely on Windows absolute paths. If you modularize a workflow, preserve path expectations or introduce a single clean path block at the top.
- `SeuratDisk` compatibility hacks exist in older scripts. If h5ad conversion breaks, inspect the prior workaround before replacing the whole export section.
- Package versions matter for `scDblFinder`, `decontX`, `CellChat`, `infercnv`, and `spacexr`.

## Practical Debug Order

1. confirm the object and assay are what the script thinks they are
2. confirm metadata columns exist and have expected values
3. confirm factor levels and identities are set correctly
4. confirm raw counts versus transformed data are not being mixed
5. only then debug plotting or downstream statistics
