#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(Seurat)
  library(dplyr)
  library(tidyr)
  library(readr)
  library(stringr)
  library(ggplot2)
  library(forcats)
  library(msigdbr)
  library(fgsea)
  library(CytoTRACE2)
  library(monocle3)
  library(SingleCellExperiment)
  library(Matrix)
  library(CellChat)
  library(pheatmap)
})

set.seed(100)
options(stringsAsFactors = FALSE)

root_dir <- normalizePath(".", winslash = "/", mustWork = TRUE)
sub_obj_file <- "D:/path/to/subcluster_object.rds"
full_obj_file <- "D:/path/to/full_annotated_object.rds"
out_dir <- file.path(root_dir, "subtype_state_pipeline")
fig_dir <- file.path(out_dir, "figures")
tab_dir <- file.path(out_dir, "tables")
obj_dir <- file.path(out_dir, "objects")
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(tab_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(obj_dir, recursive = TRUE, showWarnings = FALSE)

group_var <- "celltype"
highlight_subtype <- "Subtype_A"
condition_levels <- c("Day3_high", "Day7_high", "Day10_high", "Day7_market", "Day10_market")

clean_term <- function(x) {
  x %>%
    str_remove("^HALLMARK_") %>%
    str_remove("^GOBP_") %>%
    str_replace_all("_", " ") %>%
    str_to_title()
}

get_data_layer <- function(obj, assay = "RNA", layer = "data") {
  x <- tryCatch(LayerData(obj, assay = assay, layer = layer), error = function(e) NULL)
  if (is.null(x)) x <- GetAssayData(obj, assay = assay, slot = layer)
  x
}

get_count_layer <- function(obj, assay = "RNA") {
  x <- tryCatch(LayerData(obj, assay = assay, layer = "counts"), error = function(e) NULL)
  if (is.null(x)) x <- GetAssayData(obj, assay = assay, slot = "counts")
  x
}

safe_fgsea <- function(stats_vec, pathways, comparison_label, collection_label) {
  if (length(stats_vec) < 50 || length(pathways) == 0) return(tibble())
  fgseaMultilevel(pathways = pathways, stats = stats_vec, minSize = 10, maxSize = 500, eps = 0) %>%
    as_tibble() %>%
    mutate(comparison = comparison_label, collection = collection_label)
}

star_label <- function(p) {
  ifelse(is.na(p), "", ifelse(p < 0.001, "***", ifelse(p < 0.01, "**", ifelse(p < 0.05, "*", ""))))
}

compute_module_scores <- function(data_mat, module_list) {
  out <- lapply(names(module_list), function(nm) {
    genes <- intersect(module_list[[nm]], rownames(data_mat))
    if (length(genes) == 0) rep(NA_real_, ncol(data_mat)) else Matrix::colMeans(data_mat[genes, , drop = FALSE])
  })
  out <- as.data.frame(do.call(cbind, out))
  colnames(out) <- names(module_list)
  rownames(out) <- colnames(data_mat)
  out
}

build_top_fgsea_heatmap <- function(fgsea_tbl, subtype_order, top_n = 2) {
  selected <- fgsea_tbl %>%
    filter(!is.na(NES)) %>%
    mutate(comparison = factor(comparison, levels = subtype_order)) %>%
    arrange(comparison, desc(NES), padj) %>%
    group_by(comparison) %>%
    slice_head(n = top_n) %>%
    ungroup()

  row_order <- selected %>%
    arrange(comparison, desc(NES)) %>%
    pull(pathway_clean) %>%
    unique()

  full_tbl <- fgsea_tbl %>%
    filter(pathway_clean %in% row_order) %>%
    mutate(comparison = factor(comparison, levels = subtype_order)) %>%
    select(comparison, pathway_clean, NES, padj) %>%
    distinct()

  nes_df <- full_tbl %>%
    select(pathway_clean, comparison, NES) %>%
    pivot_wider(names_from = comparison, values_from = NES) %>%
    as.data.frame()
  rownames(nes_df) <- nes_df$pathway_clean
  nes_df$pathway_clean <- NULL
  nes_df <- nes_df[, subtype_order, drop = FALSE]
  nes_mat <- as.matrix(nes_df[row_order, , drop = FALSE])

  star_df <- full_tbl %>%
    mutate(star = star_label(padj)) %>%
    select(pathway_clean, comparison, star) %>%
    pivot_wider(names_from = comparison, values_from = star, values_fill = "") %>%
    as.data.frame()
  rownames(star_df) <- star_df$pathway_clean
  star_df$pathway_clean <- NULL
  star_df <- star_df[, subtype_order, drop = FALSE]
  star_mat <- as.matrix(star_df[row_order, , drop = FALSE])

  list(selected = selected, nes_mat = nes_mat, star_mat = star_mat)
}

Sub <- readRDS(sub_obj_file)
DefaultAssay(Sub) <- "RNA"
Sub <- NormalizeData(Sub, verbose = FALSE)
Sub$condition <- factor(as.character(Sub$orig.ident), levels = condition_levels)
Sub$subtype <- factor(as.character(Sub[[group_var]][, 1]))
subtype_order <- levels(Sub$subtype)
Idents(Sub) <- "subtype"

hallmark_sets <- msigdbr(species = "Mus musculus", category = "H") %>%
  distinct(gs_name, gene_symbol) %>%
  split(x = .$gene_symbol, f = .$gs_name)

gobp_sets <- msigdbr(species = "Mus musculus", category = "C5", subcategory = "GO:BP") %>%
  distinct(gs_name, gene_symbol) %>%
  split(x = .$gene_symbol, f = .$gs_name)

sub_deg_list <- list()
hallmark_list <- list()
gobp_list <- list()
for (stype in subtype_order) {
  deg_tbl <- FindMarkers(Sub, ident.1 = stype, assay = "RNA", logfc.threshold = 0, min.pct = 0.05, test.use = "wilcox") %>%
    tibble::rownames_to_column("gene")
  fc_col <- if ("avg_log2FC" %in% colnames(deg_tbl)) "avg_log2FC" else "avg_logFC"
  deg_tbl <- deg_tbl %>%
    mutate(log2FC = .data[[fc_col]], comparison = stype) %>%
    select(-all_of(fc_col))
  sub_deg_list[[stype]] <- deg_tbl

  stats_vec <- deg_tbl$log2FC
  names(stats_vec) <- deg_tbl$gene
  stats_vec <- stats_vec[!is.na(stats_vec)]
  stats_vec <- stats_vec[!duplicated(names(stats_vec))]
  stats_vec <- sort(stats_vec, decreasing = TRUE)

  hallmark_list[[stype]] <- safe_fgsea(stats_vec, hallmark_sets, stype, "Hallmark")
  gobp_list[[stype]] <- safe_fgsea(stats_vec, gobp_sets, stype, "GOBP")
}

subtype_deg <- bind_rows(sub_deg_list)
hallmark_fgsea <- bind_rows(hallmark_list) %>% mutate(pathway_clean = clean_term(pathway))
gobp_fgsea <- bind_rows(gobp_list) %>% mutate(pathway_clean = clean_term(pathway))

write_tsv(subtype_deg, file.path(tab_dir, "subtype_markers.tsv"))
write_tsv(hallmark_fgsea, file.path(tab_dir, "subtype_hallmark_fgsea.tsv"))
write_tsv(gobp_fgsea, file.path(tab_dir, "subtype_gobp_fgsea.tsv"))

top_heat <- build_top_fgsea_heatmap(hallmark_fgsea, subtype_order, top_n = 2)
write_tsv(tibble::rownames_to_column(as.data.frame(top_heat$nes_mat), "pathway"), file.path(tab_dir, "subtype_hallmark_top2_nes_matrix.tsv"))
write_tsv(tibble::rownames_to_column(as.data.frame(top_heat$star_mat), "pathway"), file.path(tab_dir, "subtype_hallmark_top2_star_matrix.tsv"))

lim <- max(abs(top_heat$nes_mat), na.rm = TRUE)
bk <- seq(-lim, lim, length.out = 101)
cols <- colorRampPalette(c("#2166AC", "#F7F7F7", "#B2182B"))(100)
pdf(file.path(fig_dir, "subtype_hallmark_top2_heatmap.pdf"), width = 5, height = 4)
pheatmap(
  top_heat$nes_mat,
  color = cols,
  breaks = bk,
  cluster_rows = FALSE,
  cluster_cols = FALSE,
  display_numbers = top_heat$star_mat,
  number_color = "black",
  border_color = "white"
)
dev.off()

highlight_top <- hallmark_fgsea %>%
  filter(comparison == highlight_subtype, padj < 0.05, NES > 0) %>%
  arrange(desc(NES)) %>%
  slice_head(n = 3)
score_sets <- hallmark_sets[highlight_top$pathway]
score_mat <- compute_module_scores(get_data_layer(Sub), score_sets)
score_mat$cell <- rownames(score_mat)
write_tsv(score_mat, file.path(tab_dir, paste0(highlight_subtype, "_pathway_scores.tsv")))

Sub <- cytotrace2(Sub, species = "mouse", is_seurat = TRUE, slot_type = "counts", seed = 14)
saveRDS(Sub, file.path(obj_dir, "subtype_object_cytotrace2.rds"))

counts <- get_count_layer(Sub)
cell_meta <- Sub@meta.data
rownames(cell_meta) <- colnames(Sub)
gene_meta <- data.frame(gene_short_name = rownames(counts), row.names = rownames(counts))
cds <- new_cell_data_set(counts, cell_metadata = cell_meta, gene_metadata = gene_meta)
SingleCellExperiment::reducedDims(cds)$UMAP <- Embeddings(Sub, "umap")
cds <- cluster_cells(cds, reduction_method = "UMAP")
cds <- learn_graph(cds, use_partition = FALSE)
root_cells <- Sub@meta.data %>%
  tibble::rownames_to_column("cell") %>%
  filter(!is.na(CytoTRACE2_Score)) %>%
  arrange(desc(CytoTRACE2_Score)) %>%
  slice_head(n = 300) %>%
  pull(cell)
cds <- order_cells(cds, root_cells = root_cells)
saveRDS(cds, file.path(obj_dir, "subtype_monocle3_cds.rds"))

Full <- readRDS(full_obj_file)
DefaultAssay(Full) <- "RNA"
Full$chat_label <- as.character(Full$celltype)
match_idx <- match(colnames(Full), colnames(Sub))
is_sub <- !is.na(match_idx)
Full$chat_label[is_sub] <- as.character(Sub$subtype[match_idx[is_sub]])
Full$chat_group <- make.names(Full$chat_label)
Full$condition <- factor(as.character(Full$orig.ident), levels = condition_levels)

data(CellChatDB.mouse)
# Reuse the standard CellChat template logic here and target highlight_subtype directly.
