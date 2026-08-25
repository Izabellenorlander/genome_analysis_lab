#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH --mem=32G
#SBATCH -t 04:00:00
#SBATCH -J deseq2_all_replicates
#SBATCH --mail-type=ALL
#SBATCH --mail-user=izabelle.norlander.1017@student.uu.se
#SBATCH -o /home/izno1017/genome_analysis_lab/slurm/27_deseq2_all_replicates_%j.out
#SBATCH -e /home/izno1017/genome_analysis_lab/slurm/27_deseq2_all_replicates_%j.err

set -euo pipefail

cd /home/izno1017/genome_analysis_lab

module purge
module load R-bundle-Bioconductor/3.20-foss-2024a-R-4.4.2

mkdir -p results/27_deseq2_all_replicates

echo "Starting DESeq2 analysis with 3 control and 3 heat replicates"
echo "Started: $(date)"
echo "R version:"
Rscript --version

Rscript code/27_deseq2_all_replicates.R

echo "DESeq2 analysis finished: $(date)"
echo "Output files:"
ls -lh results/27_deseq2_all_replicates

echo "Summary:"
cat results/27_deseq2_all_replicates/DESeq2_summary.txt

echo "Done."
