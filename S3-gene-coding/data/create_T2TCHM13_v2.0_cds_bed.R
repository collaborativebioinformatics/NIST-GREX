## ----message = FALSE----------------------------------------------------------
library(tidyverse)

ftbl_path <- paste0("ftp://ftp.ncbi.nlm.nih.gov//genomes/refseq/",
	            "vertebrate_mammalian/Homo_sapiens/all_assembly_versions/",
		    "GCF_009914755.1_T2T-CHM13v2.0/",
		    "GCF_009914755.1_T2T-CHM13v2.0_feature_table.txt.gz")
gff_path <- paste0("ftp://ftp.ncbi.nlm.nih.gov//genomes/refseq/",
	           "vertebrate_mammalian/Homo_sapiens/all_assembly_versions/",
	           "GCF_009914755.1_T2T-CHM13v2.0/",
		   "GCF_009914755.1_T2T-CHM13v2.0_genomic.gff.gz")
faidx_path <- paste0("/home/dnanexus/GCA_009914755.4_T2T-CHM13v2.0_genomic.modified.fna.fai")

## -----------------------------------------------------------------------------
ftbl_md5 <- "2664fae90e5fbd522ffbfa10657ebef1"

ftbl_file <- "GCF_009914755.1_T2T-CHM13v2.0_feature_table.txt.gz"
if (!file.exists(ftbl_file)) {
  download.file(url = ftbl_path, destfile = ftbl_file)

  ## MD5 check
  dwn_md5 <- tools::md5sum(ftbl_file)

  if(ftbl_md5 != dwn_md5){
    warning("MD5 for downloaded feature table does not match expected MD5")
  }
}

## defining column types and names
ftbl_col_names <- read_lines(ftbl_file, n_max = 1) %>%
  str_split(pattern = "\t") %>% unlist()
ftbl_col_types <- "cccccccddcclcccdlddc"

feature_table <- read_tsv(ftbl_file, comment = "#",
                          col_names = ftbl_col_names,
                          col_types = ftbl_col_types)

chrom_accn_df <- feature_table %>%
  dplyr::select(chromosome, genomic_accession, assembly_unit, seq_type) %>%
  distinct()


## -----------------------------------------------------------------------------
gff_md5 <- "a9e6f6493d89d2cbaa92474031e831e3"

gff_file <- "GCF_009914755.1_T2T-CHM13v2.0_genomic.gff.gz"
if (!file.exists(gff_file)) {
  download.file(url = gff_path, destfile = gff_file)

  ## MD5 check
  dwn_md5 <- tools::md5sum(gff_file)

  if(gff_md5 != dwn_md5){
    warning("MD5 for downloaded feature table does not match expected MD5")
  }
}

## defining column types and names
gff_table <- read_tsv(gff_file, col_names = c("seqid", "source", "type", "start", "end",
                              "score", "strand", "phase", "attributes"),
                comment = "#")

## Exon table with only RefSeq entries
exon_table <- gff_table %>%
  filter(type == "CDS",
         grepl("RefSeq", source)) %>%
  rename(genomic_accession = seqid) %>%
  left_join(chrom_accn_df)

## Extracting CDS for chromosomes and converting to 3 column table.
exon_table_3col <- exon_table %>%
    filter(chromosome %in% c(1:22, "X", "Y", "MT"),
           seq_type %in% c("chromosome","mitochondrion"),
           assembly_unit %in% c("Primary Assembly", "non-nuclear"))%>%
    select(chromosome, start, end) %>%
    ## Sorting table by chromosome and feature start position
    arrange(chromosome, start) %>%
    # mutate(chrom = paste0("chr", chromosome)) %>%
    # select(chrom, start, end) %>%
    select(chromosome, start, end) %>%
  distinct()

## Write to table as a bed file
tmp_bed <- tempfile(fileext = ".bed")
write_tsv(exon_table_3col, tmp_bed, col_names = FALSE)


## -----------------------------------------------------------------------------
merged_bed_file <- "T2T-CHM13v2.0_refseq_cds_merged.bed"
system2("bedtools", args = c("merge", "-i", tmp_bed),
        stdout = merged_bed_file)

## Generating not-in bed
## Generating genome bed for subtractBed
faidx_file <- "GCA_009914755.4_T2T-CHM13v2.0_genomic.modified.fna.fai"
faidx_md5 <- "d4cfae9a49981e6303616b7f19a1c121"
genome_bed_file <- "human.T2T-CHM13v2.0.chroms.only.genome.bed"

if (!file.exists(faidx_file)) {
  download.file(url = faidx_path, destfile = faidx_file)

  ## MD5 check
  dwn_md5 <- tools::md5sum(faidx_file)

  if(faidx_md5 != dwn_md5){
   warning("MD5 for downloaded reference index does not match expected MD5")
  }
}


faidx_df <- read_tsv(faidx_file, col_names = c("CHROM","SIZE","X1","X2","X3")) %>%
  # filter(CHROM %in% paste0("chr", c(1:22,"X","Y"))) %>%
  filter(CHROM %in% c(1:22,"X","Y")) %>%
  mutate(START = 1) %>%
  select(CHROM, START, SIZE)

write_tsv(faidx_df, path = genome_bed_file, col_names = FALSE)

notin_merged_bed_file <- "notin_T2T-CHM13v2.0_refseq_cds_merged.bed"
system2("subtractBed", args = c("-a", genome_bed_file, "-b", merged_bed_file),
        stdout = notin_merged_bed_file)

## Compressing stratificaiton beds
system2("bgzip", args = c("-f", merged_bed_file))
system2("bgzip", args = c("-f", notin_merged_bed_file))


## -----------------------------------------------------------------------------
merged_bed <- read_tsv(paste0(merged_bed_file, ".gz"),
                       col_names = c("chrom","start","end"))

total_cds <- sum(merged_bed$end - merged_bed$start)

notin_merged_bed <- read_tsv(paste0(notin_merged_bed_file, ".gz"),
                       col_names = c("chrom","start","end"))

notin_total_cds <- sum(notin_merged_bed$end - notin_merged_bed$start)


## -----------------------------------------------------------------------------
s_info <- devtools::session_info()
print(s_info$platform)
s_info$packages %>%
  filter(attached) %>%
  dplyr::select(package, loadedversion, source) %>%
      knitr::kable()


## -----------------------------------------------------------------------------
system("bedtools --version",intern = TRUE)


## -----------------------------------------------------------------------------
system("bgzip --version",intern = TRUE)

