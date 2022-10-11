
#!/bin/bash

#Goal : Run Tandem Repeat Finder on TR annotation region from adotto_TRannotations_v0.2.bed.gz to genearte % of A,C,G,T, matches and indels which will be used as a features in EBM pipeline

###create fasta for trf (TR annotations have 0-based start and end coordinates) 
zgrep -v ^ #chrom data/adotto_TRannotations_v0.2_json_flat.bed.gz |cut -f1-3 |sort | uniq |bedtools sort -i - | awk '{print $1 ":" $2 "-" $3+1}'| samtools faidx -r - Homo_sapiens_assembly38.fasta > data/adotto_TRannotations_Regions.fasta

trf data/adotto_TRannotations_Regions.fasta 3 7 7 80 5 40 500 -h -ngs > data/adotto_TRannotations_Regions_tandemrepeatfinder.txt

### Parse trf output to make table with required features

python code/trf_reformatter.py adotto_TRannotations_Regions_tandemrepeatfinder.txt adotto_TRannotations_Features
