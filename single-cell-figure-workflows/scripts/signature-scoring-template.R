library(Seurat)
library(AUCell)
library(GSEABase)

obj <- readRDS('D:/path/to/object.rds')
assay_for_score <- 'RNA'
group_var <- 'seurat_clusters'
output_prefix <- 'score_yyyymmdd'

# ---- gene sets ----
gene_sets <- list(
  checkpoint = c('CD274', 'PDCD1LG2', 'LGALS9', 'PVR', 'NECTIN2'),
  cytotoxic = c('NKG7', 'PRF1', 'GZMB', 'IFNG')
)

# ---- AddModuleScore ----
for (nm in names(gene_sets)) {
  obj <- AddModuleScore(obj, features = list(gene_sets[[nm]]), name = paste0(nm, '_score'))
}

# ---- AUCell ----
expr_mat <- as.matrix(GetAssayData(obj, assay = assay_for_score, slot = 'data'))
for (nm in names(gene_sets)) {
  gs <- GeneSet(gene_sets[[nm]], setName = nm)
  auc <- AUCell_run(expr_mat, gs)
  auc_df <- as.data.frame(t(getAUC(auc)))
  obj <- AddMetaData(obj, auc_df)
}

pdf(paste0(output_prefix, '_vln.pdf'), width = 6, height = 5)
VlnPlot(obj, features = c('checkpoint_score1', 'cytotoxic_score1'), group.by = group_var, pt.size = 0)
dev.off()

write.csv(obj@meta.data, paste0(output_prefix, '_metadata_scores.csv'), quote = FALSE)
saveRDS(obj, paste0(output_prefix, '_scored.rds'))

