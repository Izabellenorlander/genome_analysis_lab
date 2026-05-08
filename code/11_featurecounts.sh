#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH --mem=16G
#SBATCH -t 04:00:00
#SBATCH -J featurecounts
#SBATCH --mail-type=ALL
#SBATCH --mail-user=izabelle.norlander.1017@student.uu.se
#SBATCH -o /home/izno1017/genome_analysis_lab/slurm/featurecounts_%j.out

module load Subread

featureCounts \
-T 2 \
-p \
-t exon \
-g gene_id \
-a /home/izno1017/genome_analysis_lab/results/11_braker/braker.gtf \
-o /home/izno1017/genome_analysis_lab/results/12_featurecounts/gene_counts.txt \
/home/izno1017/genome_analysis_lab/results/10_hisat2_mapping/Control_1.sorted.bam \
/home/izno1017/genome_analysis_lab/results/10_hisat2_mapping/Heat_treated_42_12h_1.sorted.bam
