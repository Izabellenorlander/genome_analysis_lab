#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH --mem=16G
#SBATCH -t 01:00:00
#SBATCH -J quast_pilon
#SBATCH -o /home/izno1017/genome_analysis_lab/slurm/quast_pilon_%j.out
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=izabelle.norlanderr@gmail.com

set -euo pipefail

cd /home/izno1017/genome_analysis_lab

module load QUAST/5.3.0-gfbf-2024a

OUTDIR=results/18_quast_pilon_comparison

mkdir -p ${OUTDIR}

quast.py \
  results/04_flye_run2/assembly.fasta \
  results/17_pilon/chr3_pilon.fasta \
  -o ${OUTDIR} \
  -t 2 \
  --labels Flye,Pilon

echo "QUAST comparison finished."
echo "Output folder:"
ls -lh ${OUTDIR}
