library(Seurat)
library(spacexr)

xenium_obj <- readRDS('D:/path/to/xenium_object.rds')
ref_obj <- readRDS('D:/path/to/reference_object.rds')
ref_group_var <- 'celltype_t'
output_prefix <- 'xenium_rctd_yyyymmdd'

query_counts <- GetAssayData(xenium_obj, assay = 'Xenium', slot = 'counts')
coords <- GetTissueCoordinates(xenium_obj, which = 'centroids')
rownames(coords) <- coords$cell
coords$cell <- NULL
query <- SpatialRNA(coords, query_counts, colSums(query_counts))

ref_counts <- GetAssayData(ref_obj, assay = 'RNA', slot = 'counts')
ref_cluster <- as.factor(ref_obj@meta.data[[ref_group_var]])
names(ref_cluster) <- colnames(ref_obj)
ref_nUMI <- colSums(ref_counts)
reference <- Reference(ref_counts, ref_cluster, ref_nUMI)

rctd <- create.RCTD(query, reference, max_cores = 1)
rctd <- run.RCTD(rctd, doublet_mode = 'doublet')

annotations_df <- rctd@results$results_df
annotations <- annotations_df$first_type
names(annotations) <- rownames(annotations_df)
xenium_obj$predicted.celltype <- annotations

pdf(paste0(output_prefix, '_celltype.pdf'), width = 8, height = 7)
ImageDimPlot(xenium_obj, group.by = 'predicted.celltype', dark.background = FALSE)
dev.off()

write.csv(xenium_obj@meta.data, paste0(output_prefix, '_metadata.csv'), quote = FALSE)
saveRDS(xenium_obj, paste0(output_prefix, '.rds'))
