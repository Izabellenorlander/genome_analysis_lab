#!/bin/bash
module load FastQC

fastqc ~/genome_analysis_lab/results/02_trimmomatic/chr3_illumina_R1_paired.fastq.gz \
       ~/genome_analysis_lab/results/02_trimmomatic/chr3_illumina_R2_paired.fastq.gz \
       -o ~/genome_analysis_lab/results/03_fastqc_trimmed
