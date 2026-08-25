#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 4
#SBATCH --mem=96G
#SBATCH -t 48:00:00
#SBATCH -J braker_pilon_allrna
#SBATCH --mail-type=ALL
#SBATCH --mail-user=izabelle.norlander.1017@student.uu.se
#SBATCH -o /home/izno1017/genome_analysis_lab/slurm/24_braker_pilon_allrna_%j.out
#SBATCH -e /home/izno1017/genome_analysis_lab/slurm/24_braker_pilon_allrna_%j.err

set -euo pipefail

cd /home/izno1017/genome_analysis_lab

BRAKER_SIF=/proj/uppmax2026-1-61/uppmax2026-1-61/Genome_Analysis/2_Zhou_2023/braker3.sif

GENOME=/home/izno1017/genome_analysis_lab/results/21_repeatmasker_pilon/chr3_pilon.masked.fasta
OUT_DIR=/home/izno1017/genome_analysis_lab/results/24_braker_pilon_allrna
AUGUSTUS_CONFIG=/home/izno1017/bin/augustus_config

BAM1=/home/izno1017/genome_analysis_lab/results/23_hisat2_mapping_all/Control_1.sorted.bam
BAM2=/home/izno1017/genome_analysis_lab/results/23_hisat2_mapping_all/Control_2.sorted.bam
BAM3=/home/izno1017/genome_analysis_lab/results/23_hisat2_mapping_all/Control_3.sorted.bam
BAM4=/home/izno1017/genome_analysis_lab/results/23_hisat2_mapping_all/Heat_treated_42_12h_1.sorted.bam
BAM5=/home/izno1017/genome_analysis_lab/results/23_hisat2_mapping_all/Heat_treated_42_12h_2.sorted.bam
BAM6=/home/izno1017/genome_analysis_lab/results/23_hisat2_mapping_all/Heat_treated_42_12h_3.sorted.bam

BAM_LIST=${BAM1},${BAM2},${BAM3},${BAM4},${BAM5},${BAM6}

mkdir -p $OUT_DIR

TMP_BASE=/scratch/$USER/braker_pilon_allrna_${SLURM_JOB_ID}
mkdir -p $TMP_BASE

export TMPDIR=$TMP_BASE
export AUGUSTUS_CONFIG_PATH=/opt/Augustus/config

echo "Starting BRAKER annotation on Pilon-polished repeat-masked assembly"
echo "Started: $(date)"
echo "BRAKER container: $BRAKER_SIF"
echo "Genome: $GENOME"
echo "Output directory: $OUT_DIR"
echo "AUGUSTUS config: $AUGUSTUS_CONFIG"
echo "TMPDIR: $TMPDIR"
echo "BAM list:"
echo "$BAM_LIST"

echo "Checking input files..."
ls -lh "$BRAKER_SIF"
ls -lh "$GENOME"
ls -ld "$AUGUSTUS_CONFIG"
ls -lh "$BAM1" "$BAM2" "$BAM3" "$BAM4" "$BAM5" "$BAM6"

singularity exec --cleanenv \
  -B /home/izno1017:/home/izno1017 \
  -B /proj:/proj \
  -B /scratch:/scratch \
  -B $AUGUSTUS_CONFIG:/opt/Augustus/config \
  $BRAKER_SIF \
  braker.pl \
  --genome=$GENOME \
  --bam=$BAM_LIST \
  --species=Niphotrichum_japonicum_pilon_allrna_izno1017 \
  --threads=4 \
  --min_contig=5000 \
  --workingdir=$OUT_DIR \
  --softmasking \
  --skipOptimize

echo "BRAKER finished: $(date)"
echo "Output directory content:"
ls -lh $OUT_DIR

echo "Checking important output files:"
find $OUT_DIR -maxdepth 2 -type f \( -name "*.gtf" -o -name "*.gff3" -o -name "*.aa" -o -name "*.codingseq" \) -print -exec ls -lh {} \;

echo "Cleaning temporary directory:"
rm -rf "$TMP_BASE"

echo "Done."
