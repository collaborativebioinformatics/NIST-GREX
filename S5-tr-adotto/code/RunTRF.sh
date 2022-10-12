
#!/bin/bash

#Goal : Run Tandem Repeat Finder on TR annotation region from adotto_TRannotations_v0.2.bed.gz to genearte % of A,C,G,T, matches and indels which will be used as a features in EBM pipeline

###create fasta for trf 
zcat data/adotto_TRannotations_v0.2.bed.gz |cut -f1-3 |awk '{print $1 ":" $2 "-" $3}'| samtools faidx -r - Homo_sapiens_assembly38.fasta > data/adotto_TRRegions.fasta

trf data/adotto_TRRegions.fasta 3 7 7 80 5 40 500 -h -ngs > data/adotto_TRRegions_tandemrepeatfinder.txt

### Parse trf output to make table with required features

python code/trf_reformatter.py data/adotto_TRRegions_tandemrepeatfinder.txt data/adotto_TRRegions_Annos
