#!/bin/bash

#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 10
#SBATCH --mem 150G
#SBATCH --time 20:00:00



file="HG002.hiseqx.pcr-free.40x.dedup.grch38"

samtools index -@ 10 ${file}.bam 

mosdepth -n -b1 -t 10  ${file} ${file}.bam 


