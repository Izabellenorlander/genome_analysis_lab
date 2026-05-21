#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 4
#SBATCH --mem=32G
#SBATCH -t 04:00:00
#SBATCH -J merqury_pilon
#SBATCH -o /home/izno1017/genome_analysis_lab/slurm/merqury_pilon_%j.out
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=izabelle.norlanderr@gmail.com

set -euo pipefail

cd /home/izno1017/genome_analysis_lab

module load merqury/20240628-1ad7c32-gfbf-2024a

OUTDIR=results/19_merqury_pilon
READ_DB=results/15_merqury/chr3_illumina.meryl
POLISHED_ASM=results/17_pilon/chr3_pilon.fasta

mkdir -p ${OUTDIR}
cd ${OUTDIR}

ln -sf /home/izno1017/genome_analysis_lab/${POLISHED_ASM} chr3_pilon.fasta

echo "Running Merqury on Pilon-polished assembly..."
merqury.sh \
  /home/izno1017/genome_analysis_lab/${READ_DB} \
  chr3_pilon.fasta \
  chr3_pilon_merqury

echo "Merqury on Pilon-polished assembly finished."
ls -lh
