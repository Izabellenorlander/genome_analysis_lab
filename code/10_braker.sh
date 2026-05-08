#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH --mem=64G
#SBATCH -t 24:00:00
#SBATCH -J braker_annotation
#SBATCH --mail-type=ALL
#SBATCH --mail-user=izabelle.norlander.1017@student.uu.se
#SBATCH -o /home/izno1017/genome_analysis_lab/slurm/braker_%j.out

BRAKER_SIF=/proj/uppmax2026-1-61/Genome_Analysis/2_Zhou_2023/braker3.sif

GENOME=/home/izno1017/genome_analysis_lab/results/08_repeatmasker/assembly.fasta.masked
BAM=/home/izno1017/genome_analysis_lab/results/10_hisat2_mapping/merged_rnaseq.bam
OUT_DIR=/home/izno1017/genome_analysis_lab/results/11_braker
AUGUSTUS_CONFIG=/home/izno1017/bin/augustus_config

mkdir -p $OUT_DIR
mkdir -p $OUT_DIR/tmp

export TMPDIR=$OUT_DIR/tmp
export AUGUSTUS_CONFIG_PATH=/opt/Augustus/config

singularity exec --cleanenv \
-B /home/izno1017:/home/izno1017 \
-B /proj:/proj \
-B $AUGUSTUS_CONFIG:/opt/Augustus/config \
$BRAKER_SIF \
braker.pl \
--genome=$GENOME \
--bam=$BAM \
--species=Niphotrichum_japonicum_izno1017 \
--threads=2 \
--min_contig=5000 \
--workingdir=$OUT_DIR \
--softmasking \
--skipOptimize
