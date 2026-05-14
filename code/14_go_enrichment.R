# GO enrichment analysis based on DESeq2 results and EggNOG annotations

# Install required packages if missing

if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

if (!requireNamespace("clusterProfiler", quietly = TRUE)) {
  BiocManager::install("clusterProfiler")
}

if (!requireNamespace("GO.db", quietly = TRUE)) {
  BiocManager::install("GO.db")
}

if (!requireNamespace("AnnotationDbi", quietly = TRUE)) {
  BiocManager::install("AnnotationDbi")
}

if (!requireNamespace("dplyr", quietly = TRUE)) {
  install.packages("dplyr")
}

if (!requireNamespace("tidyr", quietly = TRUE)) {
  install.packages("tidyr")
}

if (!requireNamespace("ggplot2", quietly = TRUE)) {
  install.packages("ggplot2")
}

# Load packages

library(clusterProfiler)
library(GO.db)
library(AnnotationDbi)
library(dplyr)
library(tidyr)
library(ggplot2)

# Read DESeq2 results

deseq <- read.csv(
  "DESeq2_results.csv",
  row.names = 1,
  check.names = FALSE
)

deseq$gene_id <- rownames(deseq)

# Read EggNOG-mapper annotations

eggnog <- read.delim(
  "moss_annotation.emapper.annotations",
  comment.char = "#",
  header = FALSE,
  sep = "\t",
  quote = ""
)

colnames(eggnog) <- c(
  "query", "seed_ortholog", "evalue", "score", "eggNOG_OGs",
  "max_annot_lvl", "COG_category", "Description", "Preferred_name",
  "GOs", "EC", "KEGG_ko", "KEGG_Pathway", "KEGG_Module",
  "KEGG_Reaction", "KEGG_rclass", "BRITE", "KEGG_TC",
  "CAZy", "BiGG_Reaction", "PFAMs"
)

# Convert transcript IDs, e.g. g1744.t1, to gene IDs, e.g. g1744

eggnog$gene_id <- sub("\\.t[0-9]+$", "", eggnog$query)

# Select significantly differentially expressed genes

sig_genes <- deseq %>%
  filter(!is.na(padj)) %>%
  filter(padj < 0.1) %>%
  pull(gene_id)

# Create GO term-to-gene mapping from EggNOG annotations

term2gene <- eggnog %>%
  filter(GOs != "-") %>%
  dplyr::select(gene_id, GOs) %>%
  separate_rows(GOs, sep = ",") %>%
  filter(GOs != "") %>%
  distinct(GOs, gene_id)

# Add GO term names using GO.db

go_ids <- unique(term2gene$GOs)

go_names <- AnnotationDbi::select(
  GO.db,
  keys = go_ids,
  columns = c("TERM", "ONTOLOGY"),
  keytype = "GOID"
)

term2name <- go_names %>%
  dplyr::select(GOID, TERM) %>%
  filter(!is.na(TERM)) %>%
  distinct()

# Run GO enrichment analysis

ego <- enricher(
  gene = sig_genes,
  TERM2GENE = term2gene,
  TERM2NAME = term2name,
  pAdjustMethod = "BH",
  pvalueCutoff = 0.05,
  qvalueCutoff = 0.2
)

go_results <- as.data.frame(ego)

# Save GO enrichment results

write.csv(
  go_results,
  "GO_enrichment_results_with_names.csv",
  row.names = FALSE
)

# Save GO enrichment plots if enriched terms were found

if (nrow(go_results) > 0) {
  png("GO_enrichment_dotplot_with_names.png", width = 1200, height = 900)
  print(dotplot(ego, showCategory = 15))
  dev.off()
  
  png("GO_enrichment_barplot_with_names.png", width = 1200, height = 900)
  print(barplot(ego, showCategory = 15))
  dev.off()
}

# Collapse EggNOG transcript-level annotations to gene-level annotations

eggnog_gene_level <- eggnog %>%
  dplyr::select(gene_id, Description, Preferred_name, GOs, KEGG_ko, KEGG_Pathway, PFAMs) %>%
  group_by(gene_id) %>%
  summarise(
    Description = paste(unique(na.omit(Description)), collapse = "; "),
    Preferred_name = paste(unique(na.omit(Preferred_name)), collapse = "; "),
    GOs = paste(unique(na.omit(GOs)), collapse = "; "),
    KEGG_ko = paste(unique(na.omit(KEGG_ko)), collapse = "; "),
    KEGG_Pathway = paste(unique(na.omit(KEGG_Pathway)), collapse = "; "),
    PFAMs = paste(unique(na.omit(PFAMs)), collapse = "; "),
    .groups = "drop"
  )

# Merge DESeq2 results with EggNOG functional annotations

deseq_annotated <- deseq %>%
  left_join(eggnog_gene_level, by = "gene_id")

write.csv(
  deseq_annotated,
  "DESeq2_results_with_EggNOG_annotations_clean.csv",
  row.names = FALSE
)

# Save top 20 differentially expressed genes with functional annotations

top20_annotated <- deseq_annotated %>%
  filter(!is.na(padj)) %>%
  arrange(padj) %>%
  dplyr::select(
    gene_id, baseMean, log2FoldChange, padj,
    Description, Preferred_name, GOs, KEGG_ko, KEGG_Pathway, PFAMs
  ) %>%
  head(20)

write.csv(
  top20_annotated,
  "Top20_DE_genes_with_EggNOG_annotations.csv",
  row.names = FALSE
)

# Print short summary

cat("GO enrichment analysis completed.\n")
cat("Number of significant DE genes:", length(sig_genes), "\n")
cat("Number of genes with GO annotations:", length(unique(term2gene$gene_id)), "\n")
cat("Number of enriched GO terms:", nrow(go_results), "\n")