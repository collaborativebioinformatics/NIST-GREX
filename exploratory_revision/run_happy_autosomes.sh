#!/bin/bash

#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 5
#SBATCH --mem 99G
#SBATCH --time 00:50:00



MOUNTIN="giab/exploratory/"
MOUNTOUT=$MOUNTIN
hap_py_sif="software/installers/hap.py/sing/hap.py_latest.sif"
REF=${MOUNTOUT}"GRCh38_HG2-T2TQ100-V1.0.vcf"
TEST=${MOUNTOUT}"HG002.hiseqx.pcr-free.40x.deepvariant-v1.0.grch38.vcf"
STRAT=${MOUNTOUT}"stratification.tsv"
FA=${MOUNTOUT}"hg38.fa"
f=${MOUNTOUT}"GRCh38_HG2-T2TQ100-V1.0_smvar.benchmark.autosomes.bed"
ls $REF $TEST $STRAT $FA $f

OUT=${MOUNTOUT}"explore_dist/happy_out_"
ls ${OUT}*

module load singularity

singularity  exec --bind $MOUNTIN:$MOUNTOUT ${hap_py_sif} /opt/hap.py/bin/hap.py  $REF $TEST  --stratification $STRAT -o $OUT -r $FA  --threads 5  -f ${f}


