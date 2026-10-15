# Single-Cell Workflows

## Purpose

Read this file when the task is standard single-cell or subclustering work in an established R project.

## Default Backbone

The most common pattern is:

1. load matrix or `rds`
2. `CreateSeuratObject`
3. QC and metadata cleanup
4. `NormalizeData` or `SCTransform`
5. `RunPCA`
6. `RunHarmony` when integrating
7. `RunTSNE` and `RunUMAP`
8. `FindNeighbors` and `FindClusters`
9. `FindAllMarkers` or `FindMarkers`
10. subset, rescore, or export

## Typical Parameter Range

- PCs: `20`, `30`, or `50`
- Harmony groups: usually `orig.ident`, `stim`, `sample`, or `group`
- clustering resolution: usually `0.2` to `0.5`
- `k.param`: often `30` or `50`
- seeds: often `0`, `100`, or `1000`

Use existing values from the nearest script when possible. Do not normalize all projects to one universal setting.

## Assay Habits

- `SCT` is commonly used for integrated clustering and marker work
- `RNA` is still used often for scoring, exports, and reference-based tasks
- Direct slot access like `obj@assays$RNA@data` or `obj@meta.data` is common in the corpus

Do not rewrite every slot access to accessor functions unless the task is a deliberate cleanup.

## Metadata Habits

The corpus often depends on these columns:

- `orig.ident`
- `group`
- `stim`
- `sampletype`
- `celltype`
- `celltype_t`
- `finaltype`
- `seurat_clusters`

Before adding new code, inspect which of these already drives the contrast.

## Marker and DEG Patterns

Common uses:

- `FindAllMarkers` for cluster definition
- `FindMarkers` for explicit pairwise contrasts
- `MAST` for many single-cell DEG comparisons
- `DESeq2` in profiling datasets such as GeoMx

Common filtering habits:

- remove mitochondrial genes before specific marker runs
- exclude immunoglobulin-heavy artifacts in some compartments
- use `min.pct`, `logfc.threshold`, and `min.diff.pct` explicitly

## Signature and Program Scoring

The corpus repeatedly uses:

- `AUCell`
- `AddModuleScore`
- `JASMINE`
- `fgsea`
- `singleseqgset`
- `dorothea` plus `viper`

Preferred rule:

- use the scoring method already established in the nearest script
- only switch methods when the current one cannot support the biological claim

## Common Subclustering Pattern

1. subset one lineage
2. rerun normalization or `SCTransform`
3. rerun PCA and integration if needed
4. recluster at lower resolution
5. relabel clusters biologically
6. rerun markers and focused scoring

Typical objects:

- `Epi`
- `Fib`
- `Macro`
- `Myeloid`
- `CD4T`
- `CD8T`
- `Bcell`
- `Tcells`

## Annotation Pattern

- `SingleR` appears in newer scripts
- manual reassignment based on marker interpretation is also common

When extending annotation code:

- keep the automatic label layer separate from the final biologically curated label

## Plotting Pattern

Most common plot families:

- `DimPlot`
- `FeaturePlot`
- `DotPlot`
- `VlnPlot`
- `RidgePlot`
- stacked bars with `ggplot2`
- `pheatmap`

The figures are usually written directly to PDF with explicit width and height.

## Final UMAP Figure Rules

Use these rules for final cluster and cell-annotation UMAP figures unless the user explicitly requests a diagnostic downsampled view:

- Plot every cell. Never impose a separate per-cluster or per-cell-type maximum for the final figure; balanced category sampling changes visible proportions and can falsely suggest contamination or mixing.
- For large objects, rasterize the point layer rather than sampling cells. In Seurat, prefer `DimPlot(..., raster = TRUE)` with an appropriate `raster.dpi`; rasterization must not change the number of plotted cells.
- Randomize the full point order with a fixed seed (`shuffle = TRUE`, explicit `seed`) so no biological group is systematically drawn on top. This is reordering, not subsampling.
- Keep the UMAP coordinate panel square: use a fixed 1:1 aspect ratio and calculate equal x/y spans from the full embedding. Do not crop away small or distant clusters.
- Show labels in the plot for both unsupervised clusters and curated cell types, and retain a complete manual-color legend. Place labels at the median coordinates of all cells in each group. Avoid automatic repulsion that moves labels away from their group; wrap long display labels when needed while preserving the full label in metadata and the legend.
- Use the established manual palette when no project-specific palette already exists. Keep colors identical between related cluster, cell-type, DotPlot, and slide figures whenever biologically appropriate.
- Make legend text and color keys large enough for presentation use. Use explicit plot dimensions and a point size that remains visible after export without saturating dense regions.
- Export both high-resolution PNG and PDF. When reproducibility matters, also export the complete UMAP coordinate table with cell ID, cluster, and cell-type label, and verify its row count equals the number of cells in the object.
- State `all cells` or `no cell subsampling` in the subtitle when a previous or comparison figure used downsampling.

For the validated large-object pattern, use `DimPlot` with all cells, `raster = TRUE`, `shuffle = TRUE`, a fixed seed, manual colors, explicit median-position labels, `coord_fixed(ratio = 1)`, and direct PNG/PDF export.

## Grouped Cell-Annotation DotPlot Rules

Use these rules for marker-based cell annotation DotPlots:

- Treat marker panels as named biological groups, such as `Tcells`, `VC`, `Neurons`, `OPC`, `Micro`, `Astro`, and `Oligo`. Preserve both the panel order and the gene order supplied by the analysis or user.
- Put marker genes on the x-axis and identities on the y-axis. Use column facets to group genes by their biological marker panel, with free x-scale and proportional facet width (`facet_grid(..., scales = "free_x", space = "free_x")`). Show the marker-group headings above the corresponding genes.
- Produce two matched DotPlots for broad annotation: one grouped by unsupervised cluster and one grouped by curated cell label. The cluster view must retain potential heterogeneity or conflicts; the cell-label view summarizes the final annotation. Do not substitute one for the other.
- Use dot size for percent expressed and color for scaled average expression. Prefer radius-based dot scaling and the established light-to-dark purple gradient unless a project-specific scale already exists.
- Keep factor levels explicit. Order clusters consistently across annotation figures, and use the same biologically meaningful cell-label order in the final-label view. Preserve `Unknown/Ambiguous` rather than silently dropping or redistributing it.
- Check every requested and validation marker against the object before plotting. Export a marker inventory that records present and missing genes; never silently omit missing markers.
- Keep the requested marker panel separate from an independent validation panel when both exist. Use the requested panel to reproduce the proposed annotation and the validation panel to support or challenge it.
- Format x-axis gene labels in Arial Italic and rotate them 60 degrees. Keep marker-group headings and all other non-gene text in Arial Bold. Use readable axis text, panel spacing, and enlarged legends suitable for presentation.
- Make the legend explicit: `Percent Expressed` for dot size and `Average Expression` for color. Keep the size legend above the color legend when both are on the right.
- Export high-resolution PNG and PDF with explicit dimensions, plus the complete `DotPlot` data table used to draw each figure. Do not use cell subsampling for annotation DotPlots.

The validated implementation pattern is `DotPlot(..., scale = TRUE, scale.by = "radius")`, followed by explicit feature and identity factor levels, a marker-group facet, manual gradient and legend formatting, and direct PNG/PDF/data export.

## Single-Gene Differential-Expression Barplot Rules

Use this layout when comparing one gene such as `IGF1` between conditions across cell subclusters:

- Treat the donor or independent biological sample as the replicate. Summarize all eligible cells within each donor-by-condition-by-subcluster, and do not use individual cells as independent observations in a significance test.
- Make expression level and expression prevalence distinct outcomes. A matched two-panel figure is preferred: panel A shows donor-level expression (box/violin or a mean bar with donor points and uncertainty); panel B shows the fraction of gene-positive cells for each condition within each subcluster.
- For panel A, state the expression scale, such as donor mean `log1p(CP10K)`. Show individual donor observations. If bars are used, show the donor points and an uncertainty interval (SEM or confidence interval) rather than a bar alone.
- For panel B, define positivity explicitly (normally raw count > 0). Report positive-cell numerator and total-cell denominator for each condition and subcluster. A cell-pooled fraction may be shown as a descriptive bar; use donor-specific fractions as the independent observations for inferential testing, and make the aggregation and weighting clear. Prefer donor-mean fraction bars with donor points/error bars when the intended quantity is the average donor prevalence.
- Report `log2FC` for every tested subcluster, with the direction explicitly defined (for example, PD versus Control). State which expression or proportion scale and pseudocount were used to compute it. For expression, calculate the fold change on the linear normalized expression scale, not by taking a ratio of log-transformed values. For positive-cell prevalence, calculate it from the group fractions and state whether these are pooled-cell or donor-mean fractions.
- Show the test's P value and, when testing multiple subclusters, the multiple-testing-adjusted value such as BH `q`. Define the statistical unit and test in the legend or caption; keep raw P and adjusted q distinguishable. If both panels have tests, adjust within each prespecified family of subcluster comparisons and report the family in the caption/table.
- Low or zero expression can make fold changes sensitive to pseudocounts. State the pseudocount and use it consistently across subclusters; retain unrounded values in the result table. If all observations are zero or a group lacks donor coverage, mark the comparison as not estimable instead of reporting an artificial fold change or P value.
- Check donor and cell counts per condition/subcluster before plotting. Flag very small subclusters and missing donor coverage in the table or caption; do not interpret a pooled-cell P value as donor-level evidence.
- For several subclusters, put panels A and B on one row when labels and statistics remain legible. Use a shared Control/PD palette, explicit cluster order, concise per-cluster annotations, and avoid annotation overlap. If a wide two-panel figure is needed, use the established A4-width layout and size the height to content.
- Render the gene symbol in Arial italic. Use Arial bold for other plot text, heavier axes/box outlines, minimal unused space, and readable legend keys.
- Export PDF and high-resolution PNG plus a donor-level summary table, a cluster-level statistics table (group sizes, effect sizes, raw P and adjusted q), and the exact numerator/denominator table used for prevalence bars.

The validated implementation pattern for small single-gene comparisons is a donor-level expression distribution with donor dots in panel A and a positive-cell fraction comparison in panel B. Keep the plotted summary aligned with the inferential unit, and describe any cell-pooled prevalence as descriptive.

## Before-and-After QC Violin Figure Rules

Use the following layout for per-sample comparisons of QC distributions before and after filtering:

- Build one vertically stacked row for each core metric: `nCount_RNA` (or the object's equivalent nCount field), `nFeature_RNA` (or equivalent nFeature field), and mitochondrial percentage (`percent.mt`, `percent_mt`, or the verified project column). Keep the three metrics separate because their scales differ.
- Within every metric row, split samples into side-by-side biological-group panels, such as disease and control. Give each panel a clear group heading and retain the same sample order across all three metric rows.
- For every sample, draw paired side-by-side violins for `Before QC` and `After QC`. Use light gray for before QC and saturated blue for after QC, with a clearly visible black outline. Do not overlay the two distributions in a way that hides either one.
- Plot a black central-summary point on each violin, using the median by default because QC distributions are typically skewed. If a mean is used instead, state it explicitly in the caption or legend.
- Use one shared legend per metric row or one shared legend for the complete composite when space permits. Legend labels must read `Before QC` and `After QC`, and the fill colors must remain identical across all rows.
- Do not draw QC threshold lines by default. QC rules may differ among samples, so a single horizontal cutoff can be misleading. Add threshold annotations only when the user explicitly requests them and the actual per-sample thresholds can be represented accurately; never replace sample-specific rules with an invented global cutoff.
- Use the same y-axis limits for biological-group panels within a metric so their distributions are directly comparable. Allow different y-axis limits between nCount, nFeature, and mitochondrial percentage.
- Put sample ID on the x-axis, rotate labels only as much as required for readability, and use bold text. Keep panel titles, axis labels, and sample names large while preventing overlap.
- Add large panel letters (`A`, `B`, `C`) to the left of the three metric rows when the output is a supplementary or composite figure.
- Use all available cells from the corresponding before- and after-QC states; do not use unequal category sampling. Verify sample IDs and biological-group assignments before joining the two states, and preserve samples even when their before/after cell counts differ.
- Follow the global figure style: Arial Bold text, heavier outlines and axes, minimal unused whitespace, A4 composite width (210 mm / 8.27 in), and content-driven height.
- Export the assembled figure as high-resolution PNG and PDF, and save the long-form source table containing cell ID, sample ID, biological group, QC state, metric name, and metric value.

A validated implementation pattern is to reshape the three QC metrics into long format, set explicit factors for biological group, sample, QC state, and metric, draw `geom_violin(position = position_dodge(...), trim = TRUE)`, add median points with matching dodge, facet by biological group, and assemble the three metric rows with a shared A4-width layout. Threshold layers are optional and must not be added unless explicitly requested and supported by the true sample-specific QC rules.
