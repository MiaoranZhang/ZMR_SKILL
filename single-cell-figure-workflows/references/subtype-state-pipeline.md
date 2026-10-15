# Subtype State Pipeline

## Purpose

Use this reference when a user already has a curated subcluster object and wants a reusable workflow for:

- subtype one-vs-rest marker discovery
- Hallmark or GO `fgsea`
- top-pathway dotplots or heatmaps
- highlighted-subtype pathway-score and top-gene violin plots
- `CytoTRACE2`
- `monocle3` pseudotime rooted at the highest `CytoTRACE2` cells
- pseudotime pathway activation
- `CellChat` source tracing back to the whole annotated object

## Inputs To Confirm First

- a lineage-specific Seurat object such as `Fib`, `Macro`, `Epi`, or `Tcells`
- a stable subtype column, usually `celltype`, `subtype`, or `finaltype`
- metadata columns such as `orig.ident`, `group`, and `day`
- a full annotated ecosystem object if CellChat source tracing is needed

## Recommended Workflow

1. Normalize the lineage object on `RNA`.
2. Set `Idents(obj)` to the curated subtype column.
3. Run one-vs-rest `FindMarkers` for every subtype.
4. Build a ranked vector from full `log2FC` values and run Hallmark and GO `fgsea`.
5. Summarize top pathways per subtype for manuscript plots.
6. If one subtype is the focus, compute pathway scores on the same object and add focused violin plots.
7. Run `CytoTRACE2` on the subtype object.
8. Build `monocle3` from the same object and use top `CytoTRACE2` cells as root cells.
9. Compare late versus early pseudotime states with `FindMarkers` and rerun `fgsea`.
10. Inject subtype labels into the full annotated object and run `CellChat` to trace incoming signals.

## Critical Rule For Top-Pathway Heatmaps

Do not make the heatmap matrix from the sparse selected table alone.

Wrong:
- select top 2 pathways per subtype
- pivot that sparse table directly
- fill missing values with `0`

This creates fake zeros for other subtypes.

Correct:
1. choose top pathways per subtype from the full `fgsea` table
2. collect the union of these pathways
3. go back to the complete `fgsea` table
4. extract NES for those pathways across all subtypes
5. build the final `pathway x subtype` NES matrix from that complete table
6. build the star matrix from the complete `padj` table as well

## Plotting Rules

- Dotplot: use the selected top pathways only, grouped by subtype.
- Heatmap: use the corrected full NES matrix across all subtypes.
- Significance stars should be built from full `padj` values, not just from the selected sparse table.
- If subtype names contain underscores, check `AverageExpression()` output because Seurat may convert them to dashes.

## CytoTRACE2 And Monocle3 Rules

- Run `CytoTRACE2` before `monocle3`.
- Use the highest `CytoTRACE2` cells as the root set, often top 100 to 300 cells.
- Save both the updated Seurat object and the `monocle3` cds.
- Summarize pseudotime by subtype before writing conclusions.

## CellChat Rules

- Run CellChat on the full annotated ecosystem object, not on the subtype object alone, if the goal is to ask where the subtype comes from.
- Replace the lineage-level label with subtype labels only for the lineage of interest.
- Keep all non-lineage cell types unchanged.
- For incoming-signal plots, target the subtype of interest directly.
- Prefer pathway and source summaries before showing native bubble plots.

## Compatibility Checks

- `CellChat` may bring in functions that conflict with `dplyr`; use explicit `dplyr::` if a pipeline suddenly breaks.
- `subsetCommunication()` may already return character `source` and `target`; do not overwrite them with numeric helper columns.
- On Windows, keep script files BOM-free if `Rscript` reports an unexpected input at the first character.

## Output Set To Keep

- subtype marker table
- subtype Hallmark and GO `fgsea` tables
- corrected top-pathway heatmap matrix and star-label matrix
- highlighted-subtype pathway-score and top-gene violin plots
- `CytoTRACE2` score table and subtype summary
- `monocle3` pseudotime table and plots
- pseudotime Hallmark and GO summaries
- CellChat incoming interaction table, source summary, pathway summary, and native plots
