suppressPackageStartupMessages({
  library(DESeq2)
  library(ggplot2)
  library(pheatmap)
  library(RColorBrewer)
})

count_file <- "results/26_featurecounts_all/gene_counts_all_replicates.txt"
out_dir <- "results/27_deseq2_all_replicates"

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

cat("Reading featureCounts table...\n")

count_data <- read.table(
  count_file,
  header = TRUE,
  row.names = 1,
  check.names = FALSE,
  comment.char = "#",
  sep = "\t"
)

cat("Dimensions of full featureCounts table:",
    nrow(count_data), "rows x", ncol(count_data), "columns\n")

# featureCounts metadata columns:
# Chr, Start, End, Strand, Length
# Count columns therefore begin at column 6 of count_data,
# because Geneid was used as row names.
counts <- count_data[, 6:ncol(count_data)]

# Clean sample names
sample_names <- basename(colnames(counts))
sample_names <- sub("\\.sorted\\.bam$", "", sample_names)
colnames(counts) <- sample_names

expected_samples <- c(
  "Control_1",
  "Control_2",
  "Control_3",
  "Heat_treated_42_12h_1",
  "Heat_treated_42_12h_2",
  "Heat_treated_42_12h_3"
)

if (!all(expected_samples %in% colnames(counts))) {
  stop(
    "Not all expected samples were found. Found: ",
    paste(colnames(counts), collapse = ", ")
  )
}

# Ensure fixed sample order
counts <- counts[, expected_samples]

# Convert to integer matrix
counts <- as.matrix(counts)
storage.mode(counts) <- "integer"

cat("Count matrix dimensions:",
    nrow(counts), "genes x", ncol(counts), "samples\n")

cat("Library sizes before normalization:\n")
print(colSums(counts))

# Sample metadata
sample_info <- data.frame(
  condition = factor(
    c("control", "control", "control", "heat", "heat", "heat"),
    levels = c("control", "heat")
  ),
  row.names = colnames(counts)
)

cat("Sample metadata:\n")
print(sample_info)

# Filter very low-count genes:
# retain genes with at least 10 counts in at least 3 samples
keep <- rowSums(counts >= 10) >= 3

cat("Genes before filtering:", nrow(counts), "\n")
cat("Genes retained after filtering:", sum(keep), "\n")
cat("Genes removed by filtering:", sum(!keep), "\n")

counts_filtered <- counts[keep, ]

# Create DESeq2 dataset
dds <- DESeqDataSetFromMatrix(
  countData = counts_filtered,
  colData = sample_info,
  design = ~ condition
)

# Run complete DESeq2 workflow:
# size-factor estimation, dispersion estimation and Wald test
dds <- DESeq(dds)

# Heat versus control
res <- results(
  dds,
  contrast = c("condition", "heat", "control"),
  alpha = 0.1
)

res_df <- as.data.frame(res)
res_df$gene_id <- rownames(res_df)

# Order by adjusted p-value, placing NAs last
res_df <- res_df[
  order(is.na(res_df$padj), res_df$padj),
]

# Add regulation category
res_df$regulation <- "Not significant"
res_df$regulation[
  !is.na(res_df$padj) &
  res_df$padj < 0.1 &
  res_df$log2FoldChange > 0
] <- "Upregulated in heat"

res_df$regulation[
  !is.na(res_df$padj) &
  res_df$padj < 0.1 &
  res_df$log2FoldChange < 0
] <- "Downregulated in heat"

sig_df <- subset(
  res_df,
  !is.na(padj) & padj < 0.1
)

up_df <- subset(
  sig_df,
  log2FoldChange > 0
)

down_df <- subset(
  sig_df,
  log2FoldChange < 0
)

cat("Significant genes, padj < 0.1:", nrow(sig_df), "\n")
cat("Upregulated in heat:", nrow(up_df), "\n")
cat("Downregulated in heat:", nrow(down_df), "\n")

# Save result tables
write.csv(
  res_df,
  file.path(out_dir, "DESeq2_results_all_replicates.csv"),
  row.names = FALSE
)

write.csv(
  sig_df,
  file.path(out_dir, "DESeq2_significant_genes_padj_0.1.csv"),
  row.names = FALSE
)

write.csv(
  up_df,
  file.path(out_dir, "DESeq2_upregulated_in_heat.csv"),
  row.names = FALSE
)

write.csv(
  down_df,
  file.path(out_dir, "DESeq2_downregulated_in_heat.csv"),
  row.names = FALSE
)

# Normalized counts
normalized_counts <- counts(dds, normalized = TRUE)

write.csv(
  data.frame(
    gene_id = rownames(normalized_counts),
    normalized_counts,
    check.names = FALSE
  ),
  file.path(out_dir, "normalized_counts.csv"),
  row.names = FALSE
)

# Size factors and dispersion information
write.csv(
  data.frame(
    sample = names(sizeFactors(dds)),
    condition = sample_info[names(sizeFactors(dds)), "condition"],
    size_factor = sizeFactors(dds)
  ),
  file.path(out_dir, "sample_size_factors.csv"),
  row.names = FALSE
)

# Variance-stabilizing transformation for QC plots
vsd <- vst(dds, blind = FALSE)

# PCA plot
pca_data <- plotPCA(
  vsd,
  intgroup = "condition",
  returnData = TRUE
)

percent_var <- round(
  100 * attr(pca_data, "percentVar")
)

pca_data$sample <- rownames(pca_data)

pca_plot <- ggplot(
  pca_data,
  aes(
    x = PC1,
    y = PC2,
    shape = condition,
    label = sample
  )
) +
  geom_point(size = 4) +
  geom_text(
    vjust = -1,
    check_overlap = TRUE
  ) +
  xlab(paste0("PC1: ", percent_var[1], "% variance")) +
  ylab(paste0("PC2: ", percent_var[2], "% variance")) +
  ggtitle("PCA of RNA-seq samples") +
  theme_classic(base_size = 13)

ggsave(
  file.path(out_dir, "PCA_all_replicates.png"),
  pca_plot,
  width = 8,
  height = 6,
  dpi = 300
)

write.csv(
  pca_data,
  file.path(out_dir, "PCA_coordinates.csv"),
  row.names = FALSE
)

# Sample-distance heatmap
sample_dist <- dist(t(assay(vsd)))
sample_dist_matrix <- as.matrix(sample_dist)

rownames(sample_dist_matrix) <- colnames(vsd)
colnames(sample_dist_matrix) <- colnames(vsd)

annotation_col <- data.frame(
  condition = sample_info$condition
)
rownames(annotation_col) <- rownames(sample_info)

pdf(
  file.path(out_dir, "sample_distance_heatmap.pdf"),
  width = 8,
  height = 7
)

pheatmap(
  sample_dist_matrix,
  annotation_col = annotation_col,
  annotation_row = annotation_col,
  main = "Sample-to-sample distances",
  border_color = NA
)

dev.off()

write.csv(
  sample_dist_matrix,
  file.path(out_dir, "sample_distance_matrix.csv")
)

# MA plot
pdf(
  file.path(out_dir, "MA_plot_all_replicates.pdf"),
  width = 8,
  height = 7
)

plotMA(
  res,
  alpha = 0.1,
  ylim = c(-10, 10),
  main = "DESeq2 MA plot: heat vs control"
)

dev.off()

# Volcano plot
volcano_df <- res_df[
  !is.na(res_df$padj) &
  !is.na(res_df$log2FoldChange),
]

# Prevent infinite values where padj is exactly zero
minimum_nonzero_padj <- min(
  volcano_df$padj[volcano_df$padj > 0],
  na.rm = TRUE
)

volcano_df$padj_plot <- volcano_df$padj
volcano_df$padj_plot[volcano_df$padj_plot == 0] <-
  minimum_nonzero_padj

volcano_df$minus_log10_padj <- -log10(volcano_df$padj_plot)

volcano_plot <- ggplot(
  volcano_df,
  aes(
    x = log2FoldChange,
    y = minus_log10_padj,
    shape = regulation
  )
) +
  geom_point(alpha = 0.65, size = 1.6) +
  geom_vline(
    xintercept = 0,
    linetype = "dashed"
  ) +
  geom_hline(
    yintercept = -log10(0.1),
    linetype = "dashed"
  ) +
  labs(
    title = "Differential expression: heat vs control",
    x = "log2 fold change",
    y = "-log10 adjusted p-value",
    shape = "Regulation"
  ) +
  theme_classic(base_size = 13)

ggsave(
  file.path(out_dir, "volcano_plot_all_replicates.png"),
  volcano_plot,
  width = 8,
  height = 6,
  dpi = 300
)

# Top 20 most significant genes for later annotation/heatmap
top20 <- head(sig_df, 20)

write.csv(
  top20,
  file.path(out_dir, "top20_significant_genes.csv"),
  row.names = FALSE
)

# Save session information for reproducibility
capture.output(
  sessionInfo(),
  file = file.path(out_dir, "R_session_info.txt")
)

# Text summary
summary_lines <- c(
  "DESeq2 analysis with biological replicates",
  "===========================================",
  "",
  paste("Input genes:", nrow(counts)),
  paste("Genes retained after filtering:", nrow(counts_filtered)),
  paste("Control replicates:", 3),
  paste("Heat-treated replicates:", 3),
  paste("Significance cutoff: adjusted p-value < 0.1"),
  "",
  paste("Significant genes:", nrow(sig_df)),
  paste("Upregulated in heat:", nrow(up_df)),
  paste("Downregulated in heat:", nrow(down_df)),
  "",
  "Contrast: heat versus control",
  "Positive log2FoldChange = higher expression in heat",
  "Negative log2FoldChange = lower expression in heat",
  "",
  paste(
    "PC1 variance explained:",
    paste0(percent_var[1], "%")
  ),
  paste(
    "PC2 variance explained:",
    paste0(percent_var[2], "%")
  )
)

writeLines(
  summary_lines,
  file.path(out_dir, "DESeq2_summary.txt")
)

cat("\nAnalysis completed successfully.\n")
cat(paste(summary_lines, collapse = "\n"))
cat("\n")
