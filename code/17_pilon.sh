#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 8
#SBATCH --mem=64G
#SBATCH -t 08:00:00
#SBATCH -J pilon_chr3
#SBATCH -o /home/izno1017/genome_analysis_lab/slurm/pilon_%j.out

set -euo pipefail

cd /home/izno1017/genome_analysis_lab

module load BWA/0.7.19-GCCcore-13.3.0
module load SAMtools/1.22.1-GCC-13.3.0
module load Pilon/1.24-Java-17

ORIGINAL_ASM=results/04_flye_run2/assembly.fasta
R1=results/02_trimmomatic/chr3_illumina_R1_paired.fastq.gz
R2=results/02_trimmomatic/chr3_illumina_R2_paired.fastq.gz
OUTDIR=results/17_pilon

mkdir -p ${OUTDIR}

ASM=${OUTDIR}/flye_assembly_for_pilon.fasta

echo "Copying Flye assembly to Pilon output directory..."
cp ${ORIGINAL_ASM} ${ASM}

echo "Indexing assembly with BWA..."
bwa index ${ASM}

echo "Mapping Illumina reads to Flye assembly..."
bwa mem -t 8 ${ASM} ${R1} ${R2} | \
  samtools sort -@ 8 -m 4G -o ${OUTDIR}/illumina_to_flye.sorted.bam

echo "Indexing BAM file..."
samtools index ${OUTDIR}/illumina_to_flye.sorted.bam

echo "Running Pilon polishing..."
pilon \
  --genome ${ASM} \
  --frags ${OUTDIR}/illumina_to_flye.sorted.bam \
  --output chr3_pilon \
  --outdir ${OUTDIR} \
  --threads 8 \
  --changes \
  --vcf

echo "Pilon polishing finished."
echo "Output files:"
ls -lh ${OUTDIR}
