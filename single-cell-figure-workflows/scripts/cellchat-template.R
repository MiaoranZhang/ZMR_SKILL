library(Seurat)
library(CellChat)

obj <- readRDS('D:/path/to/object.rds')
group_var <- 'celltype_t'
assay_name <- 'RNA'
output_prefix <- 'cellchat_yyyymmdd'

meta_use <- obj@meta.data
cellchat_obj <- createCellChat(object = obj, assay = assay_name, meta = meta_use, group.by = group_var)
cellchat_obj@DB <- CellChatDB.human

cellchat_obj <- subsetData(cellchat_obj)
cellchat_obj <- identifyOverExpressedGenes(cellchat_obj)
cellchat_obj <- identifyOverExpressedInteractions(cellchat_obj)
cellchat_obj <- computeCommunProb(cellchat_obj)
cellchat_obj <- filterCommunication(cellchat_obj, min.cells = 3)
cellchat_obj <- computeCommunProbPathway(cellchat_obj)
cellchat_obj <- aggregateNet(cellchat_obj)
cellchat_obj <- netAnalysis_computeCentrality(cellchat_obj, slot.name = 'netP')

pdf(paste0(output_prefix, '_circle.pdf'), width = 8, height = 8)
netVisual_circle(cellchat_obj@net$weight, vertex.weight = as.numeric(table(cellchat_obj@idents)), weight.scale = TRUE)
dev.off()

saveRDS(cellchat_obj, paste0(output_prefix, '.rds'))
