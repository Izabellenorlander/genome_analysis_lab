#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 4
#SBATCH --mem=32G
#SBATCH -t 08:00:00
#SBATCH -J featurecounts_all
#SBATCH --mail-type=ALL
#SBATCH --mail-user=izabelle.norlander.1017@student.uu.se
#SBATCH -o /home/izno1017/genome_analysis_lab/slurm/26_featurecounts_all_%j.out
#SBATCH -e /home/izno1017/genome_analysis_lab/slurm/26_featurecounts_all_%j.err

set -euo pipefail

cd /home/izno1017/genome_analysis_lab

module load Subread/2.1.1-GCC-13.3.0
module load SAMtools/1.22.1-GCC-13.3.0

ANNOTATION=/home/izno1017/genome_analysis_lab/results/24_braker_pilon_allrna/braker.gtf
BAM_DIR=/home/izno1017/genome_analysis_lab/results/23_hisat2_mapping_all
OUT_DIR=/home/izno1017/genome_analysis_lab/results/26_featurecounts_all
OUTPUT=$OUT_DIR/gene_counts_all_replicates.txt

CONTROL1=$BAM_DIR/Control_1.sorted.bam
CONTROL2=$BAM_DIR/Control_2.sorted.bam
CONTROL3=$BAM_DIR/Control_3.sorted.bam
HEAT1=$BAM_DIR/Heat_treated_42_12h_1.sorted.bam
HEAT2=$BAM_DIR/Heat_treated_42_12h_2.sorted.bam
HEAT3=$BAM_DIR/Heat_treated_42_12h_3.sorted.bam

mkdir -p "$OUT_DIR"

echo "Starting featureCounts for all six RNA-seq replicates"
echo "Started: $(date)"
echo "Annotation: $ANNOTATION"
echo "Output: $OUTPUT"

echo
echo "Checking annotation:"
ls -lh "$ANNOTATION"

echo
echo "Checking BAM files:"
ls -lh \
  "$CONTROL1" \
  "$CONTROL2" \
  "$CONTROL3" \
  "$HEAT1" \
  "$HEAT2" \
  "$HEAT3"

echo
echo "Checking BAM integrity:"
samtools quickcheck \
  "$CONTROL1" \
  "$CONTROL2" \
  "$CONTROL3" \
  "$HEAT1" \
  "$HEAT2" \
  "$HEAT3"

echo "All BAM files passed samtools quickcheck."

featureCounts \
  -T 4 \
  -p \
  --countReadPairs \
  -t exon \
  -g gene_id \
  -a "$ANNOTATION" \
  -o "$OUTPUT" \
  "$CONTROL1" \
  "$CONTROL2" \
  "$CONTROL3" \
  "$HEAT1" \
  "$HEAT2" \
  "$HEAT3"

echo
echo "featureCounts finished: $(date)"

echo
echo "Output files:"
ls -lh "$OUT_DIR"

echo
echo "First lines of count matrix:"
head -n 5 "$OUTPUT"

echo
echo "Assignment summary:"
cat "${OUTPUT}.summary"

echo
echo "Number of gene rows:"
awk 'BEGIN{n=0} !/^#/ && NR>1 {n++} END{print n}' "$OUTPUT"

echo "Done."
