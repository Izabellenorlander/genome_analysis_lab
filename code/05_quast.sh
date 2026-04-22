#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH --mem=8G
#SBATCH -t 01:00:00
#SBATCH -J quast_chr3
#SBATCH -o /home/izno1017/genome_analysis_lab/slurm/quast_%j.out

module load QUAST/5.3.0

quast.py \
/home/izno1017/genome_analysis_lab/results/04_flye*/assembly.fasta \
-o /home/izno1017/genome_analysis_lab/results/05_quast
