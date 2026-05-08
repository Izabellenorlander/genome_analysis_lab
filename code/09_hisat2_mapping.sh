#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH --mem=32G
#SBATCH -t 24:00:00
#SBATCH -J hisat2_mapping
#SBATCH --mail-type=ALL
#SBATCH --mail-user=izabelle.norlander.1017@student.uu.se
#SBATCH -o /home/izno1017/genome_analysis_lab/slurm/hisat2_mapping_%j.out

module load HISAT2
module load SAMtools

INDEX=/home/izno1017/genome_analysis_lab/results/09_hisat2_index/chr3_hisat2_index
DATA_DIR=/proj/uppmax2026-1-61/Genome_Analysis/2_Zhou_2023/reads/transcriptomic_data
OUT_DIR=/home/izno1017/genome_analysis_lab/results/10_hisat2_mapping

mkdir -p $OUT_DIR

echo "Mapping Control_1..."

hisat2 -p 2 -x $INDEX --dta \
-1 $DATA_DIR/Control_1_f1.fq.gz \
-2 $DATA_DIR/Control_1_r2.fq.gz \
2> $OUT_DIR/Control_1_hisat2.log | \
samtools view -bS - | \
samtools sort -@ 2 -o $OUT_DIR/Control_1.sorted.bam

samtools index $OUT_DIR/Control_1.sorted.bam


echo "Mapping Heat_treated_42_12h_1..."

hisat2 -p 2 -x $INDEX --dta \
-1 $DATA_DIR/Heat_treated_42_12h_1_f1.fq.gz \
-2 $DATA_DIR/Heat_treated_42_12h_1_r2.fq.gz \
2> $OUT_DIR/Heat_treated_42_12h_1_hisat2.log | \
samtools view -bS - | \
samtools sort -@ 2 -o $OUT_DIR/Heat_treated_42_12h_1.sorted.bam

samtools index $OUT_DIR/Heat_treated_42_12h_1.sorted.bam


echo "Merging BAM files..."

samtools merge -@ 2 \
$OUT_DIR/merged_rnaseq.bam \
$OUT_DIR/Control_1.sorted.bam \
$OUT_DIR/Heat_treated_42_12h_1.sorted.bam

samtools index $OUT_DIR/merged_rnaseq.bam

echo "HISAT2 mapping done."
