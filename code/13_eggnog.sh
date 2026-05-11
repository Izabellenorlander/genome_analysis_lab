#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 4
#SBATCH --mem=32G
#SBATCH -t 12:00:00
#SBATCH -J eggnog
#SBATCH --mail-type=ALL
#SBATCH --mail-user=izabelle.norlander.1017@student.uu.se
#SBATCH -o /home/izno1017/genome_analysis_lab/slurm/eggnog_%j.out

module load eggnog-mapper/2.1.13

INPUT=/home/izno1017/genome_analysis_lab/results/11_braker/braker.aa
OUTDIR=/home/izno1017/genome_analysis_lab/results/13_eggnog
DATA_DIR=/data/eggNOG_data/5.0.0/rackham

mkdir -p $OUTDIR

emapper.py \
-i $INPUT \
--itype proteins \
-m diamond \
--cpu 4 \
--data_dir $DATA_DIR \
--output moss_annotation \
--output_dir $OUTDIR
