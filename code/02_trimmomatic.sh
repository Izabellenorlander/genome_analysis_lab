#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -n 2
#SBATCH -t 02:00:00
#SBATCH -J trim_chr3
#SBATCH -o /home/izno1017/genome_analysis_lab/slurm/trim_chr3_%j.out

module load Trimmomatic

trimmomatic PE -threads 2 \
/proj/uppmax2026-1-61/Genome_Analysis/2_Zhou_2023/reads/genomics_chr3_data/chr3_illumina_R1.fastq.gz \
/proj/uppmax2026-1-61/Genome_Analysis/2_Zhou_2023/reads/genomics_chr3_data/chr3_illumina_R2.fastq.gz \
~/genome_analysis_lab/results/02_trimmomatic/chr3_illumina_R1_paired.fastq.gz \
~/genome_analysis_lab/results/02_trimmomatic/chr3_illumina_R1_unpaired.fastq.gz \
~/genome_analysis_lab/results/02_trimmomatic/chr3_illumina_R2_paired.fastq.gz \
~/genome_analysis_lab/results/02_trimmomatic/chr3_illumina_R2_unpaired.fastq.gz \
LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20 MINLEN:36
