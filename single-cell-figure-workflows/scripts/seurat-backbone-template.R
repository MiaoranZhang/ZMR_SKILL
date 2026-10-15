library(Seurat)
library(ggplot2)
library(harmony)
library(cowplot)
library(ggpubr)

# ---- paths and labels ----
input_path <- 'D:/path/to/filtered_feature_bc_matrix'
project_id <- 'project_name'
output_prefix <- 'project_name_yyyymmdd'
integration_var <- 'orig.ident'

# ---- read and build object ----
counts <- Read10X(input_path)
scRNA <- CreateSeuratObject(counts, project = project_id, min.cells = 3, min.features = 200)

# ---- metadata and QC ----
scRNA$group <- scRNA$orig.ident
scRNA[['percent.mt']] <- PercentageFeatureSet(scRNA, pattern = '^MT-')

# optional QC subset
# scRNA <- subset(scRNA, subset = nFeature_RNA > 200 & nFeature_RNA < 8000 & percent.mt < 20)

# ---- normalization and integration ----
scRNA <- SCTransform(scRNA, vars.to.regress = c('nCount_RNA', 'percent.mt'))
scRNA <- RunPCA(scRNA, npcs = 50, verbose = FALSE)
scRNA <- RunHarmony(scRNA, group.by.vars = integration_var, assay.use = 'SCT')

# ---- embedding and clustering ----
scRNA <- RunTSNE(scRNA, reduction = 'harmony', dims = 1:30) %>%
  RunUMAP(reduction = 'harmony', dims = 1:30, seed.use = 1000)
scRNA <- FindNeighbors(scRNA, reduction = 'harmony', dims = 1:30, k.param = 30) %>%
  FindClusters(resolution = 0.3, random.seed = 0)

# ---- markers ----
all_markers <- FindAllMarkers(
  scRNA,
  only.pos = TRUE,
  min.pct = 0.1,
  logfc.threshold = 0.25,
  min.diff.pct = 0.01,
  assay = 'SCT'
)
write.csv(all_markers, paste0(output_prefix, '_markers.csv'), quote = FALSE)

# ---- plots ----
pdf(paste0(output_prefix, '_umap_cluster.pdf'), width = 6, height = 5)
DimPlot(scRNA, label = TRUE, pt.size = 0.4) + theme_classic()
dev.off()

saveRDS(scRNA, paste0(output_prefix, '.rds'))
