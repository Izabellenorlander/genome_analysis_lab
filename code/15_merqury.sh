#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 4
#SBATCH --mem=32G
#SBATCH -t 06:00:00
#SBATCH -J merqury_chr3
#SBATCH --mail-type=ALL
#SBATCH --mail-user=izabelle.norlander.1017@student.uu.se
#SBATCH -o /home/izno1017/genome_analysis_lab/slurm/merqury_%j.out

module load merqury/20240628-1ad7c32-gfbf-2024a
module load meryl/1.4.1-GCCcore-13.3.0

READ1=/home/izno1017/genome_analysis_lab/results/02_trimmomatic/chr3_illumina_R1_paired.fastq.gz
READ2=/home/izno1017/genome_analysis_lab/results/02_trimmomatic/chr3_illumina_R2_paired.fastq.gz
ASSEMBLY=/home/izno1017/genome_analysis_lab/results/04_flye_run2/assembly.fasta
OUTDIR=/home/izno1017/genome_analysis_lab/results/15_merqury

K=21

mkdir -p $OUTDIR
cd $OUTDIR

# Build meryl k-mer database from Illumina reads
meryl k=$K count output chr3_illumina.meryl $READ1 $READ2

# Run Merqury assembly evaluation
merqury.sh chr3_illumina.meryl $ASSEMBLY chr3_merqury
