#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -n 4
#SBATCH -t 04:00:00
#SBATCH -J repeatmasker_pilon
#SBATCH --output=slurm/21_repeatmasker_pilon_%j.out
#SBATCH --error=slurm/21_repeatmasker_pilon_%j.err

set -euo pipefail

cd /home/izno1017/genome_analysis_lab

module load RepeatMasker/4.2.1-foss-2024a

ASSEMBLY="results/17_pilon/chr3_pilon.fasta"
OUTDIR="results/21_repeatmasker_pilon"

mkdir -p "$OUTDIR"

echo "Running RepeatMasker on Pilon-polished assembly..."
echo "Input assembly: $ASSEMBLY"
echo "Output directory: $OUTDIR"
echo "Started: $(date)"

RepeatMasker \
  -pa 4 \
  -species Viridiplantae \
  -dir "$OUTDIR" \
  "$ASSEMBLY"

echo "Finished RepeatMasker: $(date)"
echo "Output files:"
ls -lh "$OUTDIR"

if [ -f "$OUTDIR/chr3_pilon.fasta.masked" ]; then
  cp "$OUTDIR/chr3_pilon.fasta.masked" "$OUTDIR/chr3_pilon.masked.fasta"
  echo "Copied masked assembly to: $OUTDIR/chr3_pilon.masked.fasta"
else
  echo "WARNING: Expected masked file not found: $OUTDIR/chr3_pilon.fasta.masked"
fi

echo "Done."
