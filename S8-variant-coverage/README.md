# S8 Pipeline - Coverage of variants from a bam file

Author: Philippe Sanio

The S8 pipeline maps the mean coverage of a sequence.bam file to a given variants.vcf file.
For the extraction of the coverage Mosdepth is bing used.

## Pipeline
- Inputs
  - sequence.bam
  - variants.vcf
- Output:
  - plots with the coverage mapped to the variant call.

![S8 Pipeline](./img/Hackerthon22_S8.drawio.png)


### Mosdepth
For the coverage extraction mosdepth is being used. In this example the coverage is being calculated for each basepair (bp), the binsize of 10bp and a quality of above 20. The output will be used for S8 pipeline.

```BASH
mosdepth -b 10 -x -t 12 -Q 20 ./coverage ./sequence.bam
```

### S8
The S8 pipeline maps the mean coverage for each variant in the .vcf file and outputs a plot for each varient type

```BASH
python s8 coverage.per-base.bed.gz variants.vcf
```

### Results 

Bam: HG002.hiseqx.pcr-free.40x.dedup.grch38.bam
VCF: HG002.hiseqx.pcr-free.40x.deepvariant-v1.0.grch38.vcf.gz
Results for chr22:
> **Note:** For this run, the coverage with binsize of 10 was used! (Update will follow)

![coverage for variant](./img/mean_coverage_grch38_covbin_10.png)

