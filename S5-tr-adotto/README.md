# Tandem Repeat Feature Engineering using regions from an in-progress GIAB TR benchmark

1. Extracted Tandem Repeat aanotaions from adotto_TRannotations_v0.2.bed.gz
2. Parsing TR annotations to genearte list of feratures for EBM pipeline
   - percentage of A, C, G, Ts, and PerMatch were genearted programatically using TR region.
     
     This may not provide accurate measurement of these feature. Therfore decided to run Adam's pipeline to genearte these feature
## Input TR aanotation file
```
% head -n3 adotto_TRannotations_v0.2.bed
chr1    16682   16774   [{"chrom": "chr1", "start": 16712, "end": 16743, "period": 3.0, "copies": 10.7, "score": 56, "entropy": 0.95, "repeat": "TGG"}, {"chrom": "chr1", "start": 16712, "end": 16743, "period": 9.0, "copies": 3.6, "score": 69, "entropy": 0.95, "repeat": "TGGTGGGGG"}, {"chrom": "chr1", "start": 16713, "end": 16738, "period": 1.0, "copies": 26.0, "score": 28, "entropy": 0.85, "repeat": "G"}]
chr1    19275   19473   [{"chrom": "chr1", "start": 19278, "end": 19286, "period": 4.0, "copies": 2.2, "score": 27, "entropy": 1.53, "repeat": "CGAG"}, {"chrom": "chr1", "start": 19305, "end": 19442, "period": 70.0, "copies": 2.0, "score": 377, "entropy": 1.65, "repeat": "TGAGAAGGCAGAGGCGCGACTGGGGTTCATGAGGAAAGGGAGGAGGAGGATGTGGGATGGTGGAGGGGTT"}, {"chrom": "chr1", "start": 19326, "end": 19388, "period": 18.0, "copies": 3.1, "score": 69, "entropy": 1.57, "repeat": "GGGGTTTGAGAAGGCAGA"}, {"chrom": "chr1", "start": 19335, "end": 19353, "period": 3.0, "copies": 6.3, "score": 30, "entropy": 1.17, "repeat": "GAG"}, {"chrom": "chr1", "start": 19412, "end": 19423, "period": 6.0, "copies": 2.0, "score": 36, "entropy": 0.65, "repeat": "GGGAGG"}]
chr1    20798   20893   [{"chrom": "chr1", "start": 20797, "end": 20862, "period": 18.0, "copies": 3.2, "score": 108, "entropy": 1.67, "repeat": "GAGCCACCACAGAAAACA"}, {"chrom": "chr1", "start": 20832, "end": 20861, "period": 7.0, "copies": 3.7, "score": 40, "entropy": 1.4, "repeat": "ACAGAAA"}]

```

## Output bed file

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
