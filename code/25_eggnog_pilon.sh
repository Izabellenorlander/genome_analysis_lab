#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 4
#SBATCH --mem=32G
#SBATCH -t 12:00:00
#SBATCH -J eggnog_pilon
#SBATCH --mail-type=ALL
#SBATCH --mail-user=izabelle.norlander.1017@student.uu.se
#SBATCH -o /home/izno1017/genome_analysis_lab/slurm/25_eggnog_pilon_%j.out
#SBATCH -e /home/izno1017/genome_analysis_lab/slurm/25_eggnog_pilon_%j.err

set -euo pipefail

cd /home/izno1017/genome_analysis_lab

module load eggnog-mapper/2.1.13-gfbf-2024a

INPUT=/home/izno1017/genome_analysis_lab/results/24_braker_pilon_allrna/braker.aa
OUTDIR=/home/izno1017/genome_analysis_lab/results/25_eggnog_pilon
DATA_DIR=/data/eggNOG_data/5.0.0/rackham

mkdir -p $OUTDIR

echo "Starting EggNOG-mapper annotation"
echo "Started: $(date)"
echo "Input proteins: $INPUT"
echo "Output directory: $OUTDIR"
echo "EggNOG data directory: $DATA_DIR"

echo "Checking input files:"
ls -lh "$INPUT"
ls -ld "$DATA_DIR"

emapper.py \
  -i $INPUT \
  --itype proteins \
  -m diamond \
  --cpu 4 \
  --data_dir $DATA_DIR \
  --output moss_annotation_pilon \
  --output_dir $OUTDIR

echo "EggNOG-mapper finished: $(date)"
echo "Output files:"
ls -lh $OUTDIR

echo "Annotation summary:"
if [ -f "$OUTDIR/moss_annotation_pilon.emapper.annotations" ]; then
  echo "Number of annotation rows excluding comments:"
  grep -v "^#" "$OUTDIR/moss_annotation_pilon.emapper.annotations" | wc -l

  echo "First non-comment annotation rows:"
  grep -v "^#" "$OUTDIR/moss_annotation_pilon.emapper.annotations" | head
else
  echo "WARNING: Expected annotation file not found."
fi

echo "Done."
