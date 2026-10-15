# Task Playbooks

## Purpose

Read this file when the task is clear and you need an execution checklist instead of broad guidance.

## Playbook 1: Take Over a Legacy Script

1. Read the top 100 to 200 lines first.
2. Identify the main object names and current assay.
3. Find the biological contrast driving the script.
4. Check required metadata columns before changing logic.
5. Locate export files to understand downstream expectations.
6. Patch the smallest possible section.
7. Re-run only the affected branch if the workflow is long.

## Playbook 2: Start a New Seurat-Style Project

1. Start from `scripts/seurat-backbone-template.R`.
2. Define the input path block and output prefix first.
3. Decide whether the project should use `NormalizeData` or `SCTransform`.
4. Lock the integration variable for Harmony.
5. Build the first clustering and marker pass.
6. Save an `rds` checkpoint before subclustering.
7. Only add scoring or communication layers after the main cell states are stable.

## Playbook 3: Support a Manuscript Figure

1. Identify the exact biological sentence the figure must support.
2. Use the nearest existing project script as the base.
3. Keep factor order and color mapping explicit.
4. Export direct PDF output with fixed dimensions.
5. Save the source table or matrix that generated the plot.
6. Avoid adding extra branches that do not change the figure-level conclusion.

## Playbook 4: Add Signature Scoring

1. Start from `scripts/signature-scoring-template.R`.
2. Decide whether the score should be `AUCell`, `AddModuleScore`, or a corpus-matched alternative.
3. Check which assay should feed the score.
4. Add the score back into metadata with a stable column name.
5. Plot the score across the exact grouping variable needed for the figure.
6. Export the score table if the result may be reused.

## Playbook 5: Add CellChat

1. Start from `scripts/cellchat-template.R`.
2. Confirm the grouping label is biologically clean and not too sparse.
3. Build the metadata frame explicitly.
4. Use the correct CellChat database.
5. Run the standard subset, overexpression, probability, and pathway steps.
6. Filter weak results before final visualization.
7. Save the CellChat object if later figures depend on it.

## Playbook 6: Add Xenium Plus RCTD

1. Start from `scripts/xenium-rctd-template.R`.
2. Confirm counts, coordinates, and cell IDs align.
3. Prepare the scRNA reference before building the `Reference` object.
4. Run `RCTD` and write predicted labels back into the Seurat object.
5. Only then add niche or spatial communication layers.
6. Export both mapped metadata and final plots.

## Playbook 7: Debug a Failed Pipeline

1. Reproduce the failure on the smallest object branch possible.
2. Print `colnames(meta.data)`, identities, and assay names first.
3. Check whether the failure is data-shape, metadata, or package-version related.
4. Compare the failing block to the nearest working script in `corpus-map.md`.
5. Fix the narrowest upstream cause instead of rewriting the whole block.

## Playbook 8: Add Subtype State Pipeline

1. Start from `scripts/subtype-state-pipeline-template.R`.
2. Confirm the subtype label column already exists and is biologically curated.
3. Run one-vs-rest `FindMarkers` for each subtype.
4. Run Hallmark and GO `fgsea` on the full DEG rank vector for each subtype.
5. For top-pathway heatmaps, first choose top pathways per subtype, then rebuild the full NES matrix from the complete `fgsea` table across all subtypes.
6. If one subtype is the figure focus, add pathway-score violins and top-gene violins for that subtype.
7. Run `CytoTRACE2` before `monocle3`, and use the highest-score cells as the root set.
8. Summarize pseudotime by subtype and run late-vs-early pathway enrichment.
9. For source tracing, inject subtype labels back into the full annotated object and run `CellChat` on the full ecosystem.
10. Save direct PDF, TSV, and RDS outputs at every major branch.
