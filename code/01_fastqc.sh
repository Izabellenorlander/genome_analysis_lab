#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH --mem=8G
#SBATCH -t 01:00:00
#SBATCH -J fastqc_raw
#SBATCH -o /home/izno1017/genome_analysis_lab/slurm/fastqc_raw_%j.out

module load FastQC

RAW_DIR=/proj/uppmax2026-1-61/Genome_Analysis/2_Zhou_2023/reads/genomics_chr3_data
OUT_DIR=/home/izno1017/genome_analysis_lab/results/01_fastqc_raw

mkdir -p $OUT_DIR

fastqc \
  -t 2 \
  -o $OUT_DIR \
  $RAW_DIR/chr3_illumina_R1.fastq.gz \
  $RAW_DIR/chr3_illumina_R2.fastq.gz
