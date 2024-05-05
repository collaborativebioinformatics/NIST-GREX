#!/bin/bash

#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 23
#SBATCH --mem 80G
#SBATCH --time 30:00:00

export PYTHONUNBUFFERED=1


for chrom in {1..22}; do 
python write_bed_var_tandem.py  chr${chrom} & 
done 
wait



for i in "1" "2" "3-10" "10-30" "30-50" "50-100" "100-" ; do
cat numvr_${i}*.bed >numvr_${i}.bed
done