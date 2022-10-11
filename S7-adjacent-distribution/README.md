# NIST Genomic features 
## Giab Benchmarks
### S7 

(Exploratory analysis to understand how variants are distributed in a VCF) calculating number of variants of different sizes in a larger region around any variant  (Distribution of adjacent variants) (S7)

Take in a [VCF](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data/AshkenazimTrio/analysis/HPRC-HG002.cur.20211005/HPRC-cur.20211005-align2-GRCh38.dip.vcf.gz), make the following exploratory plots - probably start with just one chromosome then have 22 plots for the autosomes and plot distance between adjacent variants, number of variants in different window sizes, a metric to identify clusters of variants
Input: VCF file
Outputs: Plots that show number of variants density and good cutoffs; code along with dependencies to install (defining a conda environment or snakemake commands) to generate this for given VCF/BED, could be genome specific BED file stratification  


## Histogram

![Histogram of genomic position of variants](./S7-adjacent-distribution/data/hist_chrs_variant_position.pdf)

![Histogram of genomic distance between variants](./S7-adjacent-distribution/data/hist_chrs_variant_distance.pdf)

