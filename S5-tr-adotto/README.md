# Tandem Repeat Feature Engineering using regions from an in-progress GIAB TR benchmark

1. Extracted Tandem Repeat aanotaions from adotto_TRannotations_v0.2.bed.gz
2. Parsing TR annotations to genearte list of feratures for EBM pipeline
   - percentage of A, C, G, Ts, and PerMatch were genearted programatically using TR region.
     
     This may not provide accurate measurement of these feature. Therfore decided to run Adam's pipeline to genearte these feature
