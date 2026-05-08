#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 4
#SBATCH -t 05:00:00
#SBATCH -J repeat_masker
#SBATCH --mail-type=ALL
#SBATCH --mail-user=izabelle.norlander.1017@student.uu.se
#SBATCH -o /home/izno1017/genome_analysis_lab/slurm/repeat_masker_%j.out

module load RepeatMasker

GENOME=/home/izno1017/genome_analysis_lab/results/04_flye_run2/assembly.fasta
OUT_DIR=/home/izno1017/genome_analysis_lab/results/08_repeatmasker

mkdir -p $OUT_DIR

RepeatMasker \
-pa 4 \
-xsmall \
-species "land plants" \
-dir $OUT_DIR \
$GENOME
