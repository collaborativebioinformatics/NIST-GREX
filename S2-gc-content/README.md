This CHM13V2.0-GCcontent-README.md file was generated on 20221012 by Eddy Huang.

---
GENERAL INFORMATION
---
**Title of Dataset** \
CHM13v2.0 GC Content Stratification BED files

**Running Environment** \
seqtk version-1.3-r106, bedtools v2.27.1, tabix v1.9

**Dataset Contact(s)** \
Eddy Huang, Rice University, eh58@rice.edu

---
STRATIFICATION OVERVIEW
---
The goal of this task is to generate CHM 13 GC Content stratification files to be used as standard resource of bed files for use with GA4GH benchmarking tools to stratify true positive, false positive, and false negative variant calls into different ranges of GC contents.

---
DATA & FILE OVERVIEW
---
**File List:** \
CHM13_gc15_slop50.bed.gz  
CHM13_gc15to20_slop50.bed.gz  
CHM13_gc20to25_slop50.bed.gz  
CHM13_gc25to30_slop50.bed.gz  
CHM13_gc30to55_slop50.bed.gz  
CHM13_gc55to60_slop50.bed.gz  
CHM13_gc60to65_slop50.bed.gz  
CHM13_gc65to70_slop50.bed.gz  
CHM13_gc70to75_slop50.bed.gz  
CHM13_gc75to80_slop50.bed.gz  
CHM13_gc80to85_slop50.bed.gz  
CHM13_gc85_slop50.bed.gz  
CHM13_gclt25orgt65_slop50.bed.gz  
CHM13_gclt30orgt55_slop50.bed.gz 

**File Descriptions:** \
GC content stratifications were created to stratify variants into different ranges(%) of GC content. 

- `CHM13_gc15_slop50.bed.gz`  
are regions where GC content is less than 15%
- `CHM13_gc85_slop50.bed.gz`  
are regions where GC content is greater than 85%
- `CHM13_gcxxtoyy_slop50.bed.gz`  
are regions where GC content is between xx% and yy%
- `CHM13_gclt*orgt*_slop50.bed.gz`  
are regions where GC content is less than some percentage (`gclt`) or greater than some percentage (`orgt`).

---
METHODS
---
**Description of methods used to generate the stratifications:** \
These files were created by Eddy Huang at Rice University based on the GRCh38-GCcontent created by Justin Zook and the disccusions at the 4th round of Structural Variants in the Cloud Hackathon. Followed by the methodologies in Justin Zook's methods, Heng Li's seqtk algorithm (https://github.com/lh3/seqtk) was adopted. This algorithm helps to identify  >=x bp regions with  >y% or <y% GC. The general idea of this algorithm is to automatically find the boundaries of high-GC regions.
The first part of the script file generates regions with <15, 20, 25, and 30% GC and >55, 60, 65, 70, 75, 80, and 85 % GC contents. Then, bedtools is used to expand each side by 50bp to get "200 bp regions in which the middle 100bp contains <x% or >x% GC" and subtract more stringent bed from less stringent bed to get GC content ranges. The rest goes in 30 to 65 bed files for moderate GC.

---
OPERATIONS
---
This script file is created based on the GRCh38 GC Content Stratification BED files generated by Justin Zook. To run the script, Seqtk version-1.3-r106 tool created by Heng Li, bedtools v2.27.1, and tabix v1.9 need to be installed. Three essential data files are required to run the script file: chm13v2.0 FASTA, chm13 genome file, and chm13 genome bed files. In order to run clean code and avoid potential input errors, all the output bed files generated previously need to be removed before each script run.

---
RESULTS
---
| Stratifications  | # of Base Pairs |
| ------------- | ------------- |
| GC <15% | 11,095,587 |
| GC >55% | 131,988,823 |
| GC >85% | 818,337 |
| GC <25% & >65% | 159,727,674 |
| GC <30% & >55% | 718,326,443 |
