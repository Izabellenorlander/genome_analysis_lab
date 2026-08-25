#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 4
#SBATCH --mem=64G
#SBATCH -t 48:00:00
#SBATCH -J hisat2_mapping_all
#SBATCH --mail-type=ALL
#SBATCH --mail-user=izabelle.norlander.1017@student.uu.se
#SBATCH -o /home/izno1017/genome_analysis_lab/slurm/23_hisat2_mapping_all_%j.out
#SBATCH -e /home/izno1017/genome_analysis_lab/slurm/23_hisat2_mapping_all_%j.err

set -euo pipefail

cd /home/izno1017/genome_analysis_lab

module load HISAT2/2.2.1-gompi-2024a
module load SAMtools/1.22.1-GCC-13.3.0

INDEX=/home/izno1017/genome_analysis_lab/results/22_hisat2_index_pilon/chr3_pilon_hisat2_index
DATA_DIR=/proj/uppmax2026-1-61/uppmax2026-1-61/Genome_Analysis/2_Zhou_2023/reads/transcriptomic_data
OUT_DIR=/home/izno1017/genome_analysis_lab/results/23_hisat2_mapping_all

mkdir -p $OUT_DIR

echo "Starting HISAT2 mapping for all RNA-seq replicates"
echo "Index: $INDEX"
echo "Data directory: $DATA_DIR"
echo "Output directory: $OUT_DIR"
echo "Started: $(date)"

SAMPLES=(
  "Control_1"
  "Control_2"
  "Control_3"
  "Heat_treated_42_12h_1"
  "Heat_treated_42_12h_2"
  "Heat_treated_42_12h_3"
)

for SAMPLE in "${SAMPLES[@]}"
do
  echo "----------------------------------------"
  echo "Mapping $SAMPLE"
  echo "Started sample: $(date)"

  R1=$DATA_DIR/${SAMPLE}_f1.fq.gz
  R2=$DATA_DIR/${SAMPLE}_r2.fq.gz

  echo "R1: $R1"
  echo "R2: $R2"

  if [ ! -f "$R1" ]; then
    echo "ERROR: Missing R1 file: $R1"
    exit 1
  fi

  if [ ! -f "$R2" ]; then
    echo "ERROR: Missing R2 file: $R2"
    exit 1
  fi

  hisat2 -p 4 -x $INDEX --dta \
    -1 $R1 \
    -2 $R2 \
    2> $OUT_DIR/${SAMPLE}_hisat2.log | \
    samtools view -@ 4 -bS - | \
    samtools sort -@ 4 -o $OUT_DIR/${SAMPLE}.sorted.bam

  samtools index $OUT_DIR/${SAMPLE}.sorted.bam

  echo "Finished mapping $SAMPLE"
  echo "Finished sample: $(date)"
done

echo "----------------------------------------"
echo "Merging all RNA-seq BAM files for BRAKER RNA evidence"

samtools merge -@ 4 -f \
  $OUT_DIR/merged_all_rnaseq.bam \
  $OUT_DIR/Control_1.sorted.bam \
  $OUT_DIR/Control_2.sorted.bam \
  $OUT_DIR/Control_3.sorted.bam \
  $OUT_DIR/Heat_treated_42_12h_1.sorted.bam \
  $OUT_DIR/Heat_treated_42_12h_2.sorted.bam \
  $OUT_DIR/Heat_treated_42_12h_3.sorted.bam

samtools index $OUT_DIR/merged_all_rnaseq.bam

echo "Checking BAM files with samtools quickcheck"
samtools quickcheck \
  $OUT_DIR/Control_1.sorted.bam \
  $OUT_DIR/Control_2.sorted.bam \
  $OUT_DIR/Control_3.sorted.bam \
  $OUT_DIR/Heat_treated_42_12h_1.sorted.bam \
  $OUT_DIR/Heat_treated_42_12h_2.sorted.bam \
  $OUT_DIR/Heat_treated_42_12h_3.sorted.bam \
  $OUT_DIR/merged_all_rnaseq.bam

echo "HISAT2 mapping for all replicates done."
echo "Finished: $(date)"

echo "Alignment rate summary:"
grep "overall alignment rate" $OUT_DIR/*_hisat2.log || true

echo "Output files:"
ls -lh $OUT_DIR
