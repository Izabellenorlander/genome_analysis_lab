#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH --mem=16G
#SBATCH -t 02:00:00
#SBATCH -J hisat2_index_pilon
#SBATCH --mail-type=ALL
#SBATCH --mail-user=izabelle.norlander.1017@student.uu.se
#SBATCH -o /home/izno1017/genome_analysis_lab/slurm/22_hisat2_index_pilon_%j.out
#SBATCH -e /home/izno1017/genome_analysis_lab/slurm/22_hisat2_index_pilon_%j.err

set -euo pipefail

cd /home/izno1017/genome_analysis_lab

module load HISAT2/2.2.1-gompi-2024a

MASKED_GENOME=/home/izno1017/genome_analysis_lab/results/21_repeatmasker_pilon/chr3_pilon.masked.fasta
INDEX_DIR=/home/izno1017/genome_analysis_lab/results/22_hisat2_index_pilon

mkdir -p $INDEX_DIR

echo "Building HISAT2 index from Pilon-polished repeat-masked assembly..."
echo "Masked genome: $MASKED_GENOME"
echo "Index directory: $INDEX_DIR"
echo "Started: $(date)"

hisat2-build -p 2 $MASKED_GENOME $INDEX_DIR/chr3_pilon_hisat2_index

echo "HISAT2 index build finished."
echo "Finished: $(date)"
echo "Output files:"
ls -lh $INDEX_DIR
