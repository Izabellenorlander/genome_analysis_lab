#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH --mem=32G
#SBATCH -t 14:00:00
#SBATCH -J busco_chr3
#SBATCH --mail-type=ALL
#SBATCH --mail-user=izabelle.norlander.1017@student.uu.se
#SBATCH -o /home/izno1017/genome_analysis_lab/slurm/busco_chr3_%j.out

module load BUSCO

busco \
-i /home/izno1017/genome_analysis_lab/results/04_flye_run2/assembly.fasta \
-o busco_chr3 \
-m genome \
-l viridiplantae_odb10 \
--out_path /home/izno1017/genome_analysis_lab/results/06_busco \
-c 2
