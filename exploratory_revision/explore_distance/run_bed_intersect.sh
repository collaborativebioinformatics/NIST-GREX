

wget https://hgdownload.soe.ucsc.edu/goldenPath/hg38//bigZips/hg38.fa.gz


cat dist_start10000* > dist_start10000_rest_raw.bed


bedtools sort  -i dist_start10000_rest_raw.bed > dist_start10000_rest.bed


#non-syntenic  but not used in this revision

for i in dist_start1000000  dist_start10000      dist_start1000 dist_start10 dist_start100000   dist_start10000_rest dist_start100   dist_start1; do 
ls ../${i}.bed 
bedtools intersect -a ../${i}.bed -b hgUnique.hg38.bed > ${i}_nons.bed
done


