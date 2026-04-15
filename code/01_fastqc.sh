#!/bin/bash
module load FastQC

fastqc ~/Genome_Analysis_Paper2/data/chr3_illumina_R1.fastq.gz \
       ~/Genome_Analysis_Paper2/data/chr3_illumina_R2.fastq.gz \
       -o ~/Genome_Analysis_Paper2/results/01_fastqc_raw
