#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 1
#SBATCH --mem=4G
#SBATCH -t 00:30:00
#SBATCH -J rnaseq_cov
#SBATCH -o /home/izno1017/genome_analysis_lab/slurm/rnaseq_coverage_%j.out

set -euo pipefail

cd /home/izno1017/genome_analysis_lab

module load SAMtools/1.22.1-GCC-13.3.0

mkdir -p results/20_rnaseq_coverage

samtools coverage results/10_hisat2_mapping/Control_1.sorted.bam \
  > results/20_rnaseq_coverage/Control_1.coverage.tsv

samtools coverage results/10_hisat2_mapping/Heat_treated_42_12h_1.sorted.bam \
  > results/20_rnaseq_coverage/Heat_treated_42_12h_1.coverage.tsv
