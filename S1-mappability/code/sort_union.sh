#!/usr/bin/bash
## sort mappability beds, remove extra chromosomes, and generate union and anti-union beds.

## Assumes dependencies are in path
## 	Dependencies
##	- bgzip (from htslib)
##	- complmentBed (from bedtools2)
##	- multiIntersectBed (from bedtools2)
##	- subtractBed (from bedtools2)
##	- mergeBed (from bedtools2)

module load samtools bedtools

## Global variables
BENCHROOT=/path/to/sv_hackathon/
BEDTOOLSGENOME=/path/to/sv_hackathon/chm13_chr21_onlychr.genome
GENOMEBED=/path/to/sv_hackathon/chm13_chr21.bed
ID=chr21


## Generating BAM
function sort_bed(){
	INBED=$1
	BEDBASE=${1%%.*}
	local OUTBED=${BEDBASE}.sort.bed.gz

	grep 	-e "$(printf '^chr[0-9XYM]\t')" -e "$(printf '^chr[12][0-9]\t')" ${INBED} |\
		sed 's/^chr//;s/^X	/23	/;s/^Y	/24	/;s/^M	/25	/'  |\
		awk '$1<26' |\
		sort -k1,1n -k2,2n |\
		sed 's/^23/X/;s/^24/Y/;s/^25/M/;s/^/chr/' |\
	 	bgzip -c > ${OUTBED}
	echo "${OUTBED}"
}


## Get bed compliments
function get_nonunique(){
	MAPBED=$1
	BEDBASE=${MAPBED%%_uniq.*}
	local OUTBED=${BEDBASE}_nonuniq.sort.bed.gz

	## getting low mappability regions and merging
	## regions within 100bp
	complementBed -i ${MAPBED} -g ${BEDTOOLSGENOME} | \
		mergeBed -d 100 -i stdin |
		bgzip -c > ${OUTBED}
	echo "${OUTBED}"
}


#################################################################
## Merging all mappability bed files and also find its complement

## List of input beds passed as an array

i=0
for INPUTBED in $@;
do
	SORTEDBED=$(sort_bed ${INPUTBED})
    SORTEDNONUNIQUEBEDS[$i]=$(get_nonunique ${SORTEDBED})
    i=$(($i+1))
done

echo "${SORTEDNONUNIQUEBEDS[@]}"

## Merged mappability
# multiIntersectBed -i ${SORTEDNONUNIQUEBEDS[@]} |\
multiIntersectBed -i *_nonuniq.sort.bed.gz |\
 	mergeBed -d 100 -i stdin |\
	bgzip -c > ${ID}_lowmappabilityall.bed.gz

## Merged compliment
subtractBed -a ${GENOMEBED} -b ${ID}_lowmappabilityall.bed.gz |\
	bgzip -c > ${ID}_notinlowmappabilityall.bed.gz
