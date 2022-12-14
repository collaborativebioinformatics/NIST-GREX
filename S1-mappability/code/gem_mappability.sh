#!/usr/bin/bash
#SBATCH -n 8 # number of cores
#SBATCH --mem 200g # memory pool for all cores
#SBATCH --job-name=GEM
#SBATCH --time=15:00:00
#SBATCH --mail-type=ALL
 
echo "Running job $JOB_NAME, $JOB_ID on $HOSTNAME"

## Variables defined with job submission
# l - length
# m - mismatches
# e - edit distance

START_STIME=`date +%Y%m%dT%H%M%S`
START_TIME=`date +%s`

## Dependencies
export PATH=$PATH:/path/to/GEM-binaries-Linux-x86_64-core_i3-20130406-045632/bin
export PATH=$PATH:/path/to/bedops/bin

## Variables
REF=/path/tosv_hackathon/chm13.fa
REFID=chm13
WKDIR=/path/tosv_hackathon/


## Indexing reference if index is not present
IDXFILE=${WKDIR}/${REFID}_gemidx
if [ -f "${IDXFILE}.gem" ]; then
    echo "${IDXFILE}.gem exists"
else 
	echo "Reference index does not exist, indexing."
	gem-indexer -i ${REF} -o ${IDXFILE} --complement emulate -T 8 
fi

MAPBASE=${WKDIR}/${REFID}_gemmap_l100_m2_e1
if [ -f "${MAPBASE}.mappability" ]; then
	echo "${MAPBASE}.mappability exists"
else
	echo "Mappability file does not exist, generating"
	gem-mappability -m 2 -e 1 -T 8 -I ${IDXFILE}.gem -l 100 -o ${MAPBASE}
fi


gem-2-wig -I ${WKDIR}/${REFID}_gemidx.gem \
	-i ${MAPBASE}.mappability \
	-o ${MAPBASE}

## Removing additional chromosome name information from fasta - to prevent errors when generating bed file
sed 's/ AC//' ${MAPBASE}.wig > ${MAPBASE}_name_clean.wig
sed 's/ AC//' ${MAPBASE}.sizes > ${MAPBASE}_name_clean.sizes

wig2bed -m 16G < ${MAPBASE}_name_clean.wig > ${MAPBASE}.bed

awk '$5>0.9' ${MAPBASE}.bed > ${MAPBASE}_uniq.bed


## Not sure this is necessary
#/home/justin.zook/GEM_mappability/wigToBigWig ${MAPBASE}_nodna.wig \
#	${MAPBASE}_nodna.sizes \
#	${MAPBASE}.bw

END_TIME=`date +%s`
ELAPSED_TIME=`expr $END_TIME - $START_TIME`

echo "$START_STIME  $ELAPSED_TIME" $JOB_ID $HOSTNAME 