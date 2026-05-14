#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 4
#SBATCH --mem=16G
#SBATCH -t 04:00:00
#SBATCH -J mummer_chr3
#SBATCH --mail-type=ALL
#SBATCH --mail-user=izabelle.norlander.1017@student.uu.se
#SBATCH -o /home/izno1017/genome_analysis_lab/slurm/mummer_%j.out

module load MUMmer/4.0.1-GCCcore-13.3.0

REF=/proj/uppmax2026-1-61/Genome_Analysis/2_Zhou_2023/Ceratodon_purpureus/C_purpureus.fna
QUERY=/home/izno1017/genome_analysis_lab/results/04_flye_run2/assembly.fasta
OUTDIR=/home/izno1017/genome_analysis_lab/results/16_mummer

mkdir -p $OUTDIR
cd $OUTDIR

nucmer \
  --prefix=chr3_vs_ceratodon \
  --threads=4 \
  $REF \
  $QUERY

show-coords \
  -rcl \
  chr3_vs_ceratodon.delta \
  > chr3_vs_ceratodon.coords

delta-filter \
  -1 \
  chr3_vs_ceratodon.delta \
  > chr3_vs_ceratodon.filtered.delta

show-coords \
  -rcl \
  chr3_vs_ceratodon.filtered.delta \
  > chr3_vs_ceratodon.filtered.coords

mummerplot \
  --png \
  --layout \
  --filter \
  -p chr3_vs_ceratodon \
  chr3_vs_ceratodon.delta
