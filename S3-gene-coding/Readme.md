### Generate gene coding sequence beds for CHM13v2.0

- Script (modified for CHM13v2.0) - https://github.com/genome-in-a-bottle/genome-stratifications/blob/master/GRCh38/FunctionalRegions/create_GRCh38_cds_bed.Rmd
- Input: CHM13v2.0 fasta, feature table, gff available on NCBI ftp site.
- Output: BED file containing regions of CHM13v2.0 that are gene coding sequences

### How bed files were generated

- Used DNAnexus -> Tools -> ttyd -> opened the worker URL
- Installed dependencies on the Ubuntu machine
  - `apt-get install libxml2-dev libcurl4-openssl-dev libssl-dev libcurl4-gnutls-dev	libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev	libharfbuzz-dev libfribidi-dev libpng-dev libtiff5-dev libjpeg-dev`
- Set up PATH
  - `PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig`
  - `PATH=/usr/lib/x86_64-linux-gnu/pkgconfig:$PATH`
- Installed packages for R
  - `install.packages("rmarkdown", dep = TRUE)`
  - `install.packages("tinytex")`
  - `tinytex::install_tinytex()`
  - `install.packages('knitr', dependencies = TRUE)`
  - `install.packages("tidyverse")`
  - `install.packages("devtools")`
- Convert R markdown to R script
  - `knitr::purl("create_GRCh38_cds_bed.Rmd")`
- Make changes to the R script 
  - `cp create_GRCh38_cds_bed.R create_T2TCHM13_v2.0_cds_bed.R`
  - Update ftp paths to point to the new T2T CHM13v2.0 feature table and gff files
  - For T2TCHM13 the fna.fai file doesn't exist
    - ` wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/009/914/755/GCA_009914755.4_T2T-CHM13v2.0/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna.gz`
    - Install samtools - https://www.htslib.org/download/
    - ` gunzip GCA_009914755.4_T2T-CHM13v2.0_genomic.fna.gz`
    - ` samtools faidx - --fai-idx GCA_009914755.4_T2T-CHM13v2.0_genomic.fna.fai`
    - Modified the fai file to change accessions to chromosome numbers
  - Other minor changes

### Next steps
We have so far generated the bed files of CDS regions in T2T-CHM13v2.0 using the above input. This would enable us to:
  1. TODO: See the differences of coverage of CDS regions between GRCh38 and T2T-CHM13v2.0 by generating plots
  2. TODO: Compare variant calls for a control sample within these regions between GRCh38 and T2T-CHM13v2.0


