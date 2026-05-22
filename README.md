# Genome Analysis Lab

This repository contains the code and documentation for my Genome Analysis course project based on Paper II, Zhou et al. (2023), focusing on chromosome 3 of the moss *Niphotrichum japonicum*.

The main project report is written in the GitHub Wiki. The wiki contains the project plan, daily log, methods, results, interpretations, limitations, questions for higher grades, and final conclusions.


## Repository structure

```text
genome_analysis_lab/
├── code/          # Scripts used for the analysis
├── results/       # Selected small result summaries and reports
├── README.md      # Repository overview
└── .gitignore     # Files and folders excluded from GitHub
```

Large files such as FASTQ, BAM, FASTA assemblies, Meryl databases and most intermediate result files are not stored in this repository. These files were stored and analysed on UPPMAX.

## Code

The `code/` directory contains the scripts used in the project.

```text
01_fastqc.sh
02_trimmomatic.sh
03_fastqc_trimmed.sh
04_flye.sh
05_quast.sh
06_busco.sh
07_repeatmasker.sh
08_hisat2_index.sh
09_hisat2_mapping.sh
10_braker.sh
11_featurecounts.sh
12_deseq2_analysis.R
13_eggnog.sh
14_go_enrichment.R
15_merqury.sh
16_mummer.sh
17_pilon.sh
18_quast_pilon_comparison.sh
19_merqury_pilon.sh
20_rnaseq_coverage.sh
```

The scripts are numbered according to the approximate order of the workflow.


## Wiki

The full report is available in the GitHub Wiki for this repository.

Suggested reading order:

1. Home
2. Project plan
3. Daily log
4. Quality control and preprocessing
5. Genome assembly
6. Assembly evaluation
7. Repeat masking
8. Structural and functional annotation
9. RNA-seq mapping and read counting
10. Differential expression and GO enrichment
11. Extra analyses: Merqury and MUMmer
12. Summary and conclusions
13. Questions for grade 4 and 5
