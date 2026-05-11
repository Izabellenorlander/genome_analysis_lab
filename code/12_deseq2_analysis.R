# Load required package

library(DESeq2)

# Read featureCounts output

count_data <- read.table(
  "gene_counts.txt",
  header = TRUE,
  row.names = 1,
  check.names = FALSE,
  comment.char = "#"
)

# Extract count columns

counts <- count_data[, 6:7]

# Rename samples

colnames(counts) <- c("Control", "Heat")

# Create sample metadata

sample_info <- data.frame(
  condition = factor(c("control", "heat")),
  row.names = colnames(counts)
)

# Create DESeq2 dataset

dds <- DESeqDataSetFromMatrix(
  countData = counts,
  colData = sample_info,
  design = ~ condition
)

# Estimate size factors

dds <- estimateSizeFactors(dds)

# Set manual dispersion due to lack of biological replicates

mcols(dds)$dispersion <- 0.1

# Run differential expression analysis

dds <- nbinomWaldTest(dds)

# Extract results

res <- results(dds)

# Order genes by adjusted p-value

res_ordered <- res[order(res$padj), ]

# Display top differentially expressed genes

head(res_ordered)

# Generate MA plot

plotMA(res)

# Save results

write.csv(
  as.data.frame(res_ordered),
  "DESeq2_results.csv"
)

