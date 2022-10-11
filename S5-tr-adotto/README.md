# Tandem Repeat Feature Engineering using regions from an in-progress GIAB TR benchmark

1. Extracted Tandem Repeat aanotaions from adotto_TRannotations_v0.2.bed.gz
2. Parsing TR annotations to genearte list of feratures for EBM pipeline
   - percentage of A, C, G, Ts, and PerMatch were genearted programatically using TR region.
     
     This may not provide accurate measurement of these feature. Therfore decided to run Adam's pipeline to genearte these feature

## output bed file

```
% head adotto_TRannotations_v0.2_json_flat.bed
chrom	start	end	period	copies	score	entropy	repeat
chr1	16712	16743	3.0	10.7	56	0.95	TGG
chr1	16712	16743	9.0	3.6	69	0.95	TGGTGGGGG
chr1	16713	16738	1.0	26.0	28	0.85	G
chr1	19278	19286	4.0	2.2	27	1.53	CGAG
chr1	19326	19388	18.0	3.1	69	1.57	GGGGTTTGAGAAGGCAGA
chr1	19335	19353	3.0	6.3	30	1.17	GAG
chr1	19412	19423	6.0	2.0	36	0.65	GGGAGG
chr1	20797	20862	18.0	3.2	108	1.67	GAGCCACCACAGAAAACA

```
