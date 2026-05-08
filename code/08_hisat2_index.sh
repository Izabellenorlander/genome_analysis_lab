#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 02:00:00
#SBATCH -J hisat2_index
#SBATCH --mail-type=ALL
#SBATCH --mail-user=izabelle.norlander.1017@student.uu.se
#SBATCH -o /home/izno1017/genome_analysis_lab/slurm/hisat2_index_%j.out

module load HISAT2

MASKED_GENOME=/home/izno1017/genome_analysis_lab/results/08_repeatmasker/assembly.fasta.masked
INDEX_DIR=/home/izno1017/genome_analysis_lab/results/09_hisat2_index

mkdir -p $INDEX_DIR

hisat2-build -p 2 $MASKED_GENOME $INDEX_DIR/chr3_hisat2_index
