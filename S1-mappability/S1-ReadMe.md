# Mappability for CHM13v2.0 reference genome
Pilar Alvarez Jerez \
Last update: October 11, 2022 \
Based on [GIAB CRCh38 Stratifications](https://github.com/genome-in-a-bottle/genome-stratifications/blob/master/GRCh38/mappability/GRCh38-mappability-README.md)
## Goal: 
Generate T2T-CHM13v2.0 stratification BED file similar to what exists for GRCh38. Goal is to end with BED file with regions of low mappability per chromosome based on two stringency levels.


## Example on how to run on one chromosome

Set up working directory

	export MAIN=/home/
	mkdir $MAIN/sv_hackathon/
	cd $MAIN/sv_hackathon
	

First extract chromosome from CHM13v2.0 fasta file

	
	module load samtools
	samtools faidx chm13v2.0.fa.gz chr21 > 	chm13_chr21.fa.gz
	samtools faidx chm13_chr21.fa.gz

Download and install bedops and GEM binaries in your directory

[Links](https://github.com/genome-in-a-bottle/genome-stratifications/blob/master/GRCh38/mappability/GRCh38-mappability-README.md) to both binaries


	# On $MAIN directory
	tar jxvf bedops_linux_x86_64-v2.4.41.tar.bz2
	tar jxvf GEM-binaries-Linux-x86_64-core_i3-20130406-045632.tbz2

### Upload first GEM script to directory
[Original script](https://github.com/genome-in-a-bottle/genome-stratifications/blob/master/GRCh38/mappability/run_GEM_mappability_GRCh38.sh) \
Renamed as [gem_mappability.sh](https://github.com/collaborativebioinformatics/NIST-genomic-features/blob/main/S1-mappability/code/gem_mappability.sh) for this project \
What to alter in script:
- Main variable paths/names
- l, m, e parameters

### Running script for chr21
	sbatch gem_mappability.sh
Note, running twice. 
-   low stringency: l-100, m-2, e-1 (2 mismatches and 1 indels)
-   high stringency: l-250, m-0, e-0 (0 mismatches and 0 indels)

Running the script generates raw mappability files.
Example output from script

- `chm13_chr21_gemmap_l100_m2_e1_name_clean.sizes`
- `chm13_chr21_gemmap_l100_m2_e1_name_clean.wig`
- `**chm13_chr21_gemmap_l100_m2_e1_name_uniq.bed**`
- `**chm13_chr21_gemmap_l100_m2_e1.bed**`
- `chm13_chr21_gemmap_l100_m2_e1.mappability`
- `chm13_chr21_gemmap_l100_m2_e1.sizes`
- `chm13_chr21_gemmap_l100_m2_e1.wig`

Interested in bed files for now
`chm13_chr21_gemmap_l100_m2_e1.bed`
 Has all the region calls with their different mappability score

	head chm13_chr21_gemmap_l100_m2_e1.bed
	chr21	0	33	id-1	1.000000
	chr21	33	38	id-2	0.117851
	chr21	38	42	id-3	0.142857
	chr21	42	43	id-4	0.250000
	chr21	43	49	id-5	0.166667
	chr21	49	50	id-6	0.142857
	chr21	50	64	id-7	0.166667
	chr21	64	65	id-8	0.333333

`chm13_chr21_gemmap_l100_m2_e1_uniq.bed`
Only contains regions with unique mappability

	head chm13_chr21_gemmap_l100_m2_e1_uniq.bed
	chr21	0	33	id-1	1.000000
	chr21	884	925	id-42	1.000000
	chr21	2369	2467	id-48	1.000000
	chr21	2621	2708	id-50	1.000000
	chr21	2710	2726	id-52	1.000000
	chr21	2728	3495	id-54	1.000000
	chr21	3546	3579	id-56	1.000000

Using the two uniq BED files to run second script

### Upload sorting script

[Original script](https://github.com/genome-in-a-bottle/genome-stratifications/blob/master/GRCh38/mappability/run_GEM_mappability_sort_GRCh38.sh)

Need to change initial variable paths
Renamed [union_chr21_test.sh](https://github.com/collaborativebioinformatics/NIST-genomic-features/blob/main/S1-mappability/code/union_chr21_test.sh)

Create files needed for script

	awk 'BEGIN {FS="\t"}; {print $1 FS "0" FS $2}' \
	$MAIN/sv_hackathon/chm13_chr21.fa.gz.fai > $MAIN/sv_hackathon/chm13_chr21.bed
	head $MAIN/sv_hackathon/chm13_chr21.bed
	
	awk '{FS="\t"};{print $1 FS $3}' \
	$MAIN/sv_hackathon/chm13_chr21.bed > $MAIN/sv_hackathon/chm13_chr21_onlychr.genome
	head $MAIN/sv_hackathon/chm13_chr21_onlychr.genome

Ran script like this

	sbatch --mem=100g --cpus-per-task=4 \
	--mail-type=ALL --time=12:00:00 union_chr21_test.sh  \
	chm13_chr21_gemmap_l100_m2_e1_uniq.bed \
	chm13_chr21_gemmap_l250_m0_e0_uniq.bed

**Outputs we care about**
-   `chm13_21_nonunique_l*_m*_e*.bed.gz`  contains only regions that are “low mappability”, meaning they have other homologous regions in the reference genome for the given read length, number of mismatches, and number of indels.
    -   low mappability regions for low stringency parameters: l100_m2_e1
    -   low mappability for high stringency parameters: l250_m0_e0
-   `chm13_chr21_lowmappabilityall.bed.gz`  and  `chm13_chr21_notinlowmappabilityall.bed.gz`  is a union (and non-overlapping complement, "notin") of low and high stringency short read mappability.
*Explanations taken from original linked github*

Quick look into `chm13_chr21_lowmappabilityall.bed.gz`

	gunzip chm13_chr21_lowmappabilityall.bed.gz
	head chm13_chr21_lowmappabilityall.bed
	chr21	33	2728
	chr21	3495	3617
	chr21	4889	5036
	chr21	5215	5314
	chr21	5468	5879
	chr21	6620	6643
	chr21	7170	7198
	chr21	8073	8103
	chr21	9194	9449
	chr21	15466	15721

All example chr21 files can be found in [code folder]
(https://github.com/collaborativebioinformatics/NIST-genomic-features/tree/main/S1-mappability/code)
## Next steps
Having trouble running scripts for whole genome
Debugging if error is coming from first script or second

Once whole genome is done, we can create plots to visualize  low mappability regions
