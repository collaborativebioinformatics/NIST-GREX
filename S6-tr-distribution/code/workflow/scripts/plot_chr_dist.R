library(tidyverse)

read_bed <- function(path) {
    readr::read_tsv(path,
                    col_names = c("chrom", "start", "end", "vcf_chrom",
                                  "vcf_start", "vcf_end", "vcf_len"),
                    na = ".",
                    col_types = cols("chrom" = "c",
                                     "vcf_chrom" = "c",
                                     .default = "d")) %>%
        filter(!is.na(vcf_chrom)) %>%
        select(-vcf_chrom)
}

df <- read_bed("../../results/bed/intersected.bed")

labeled <- df %>%
    mutate(class = case_when(vcf_end - vcf_start == 1 & vcf_len == 0 ~ "SNPs",
                             vcf_len == 0 ~ "Other",
                             abs(vcf_len) < 3 ~ "INDELs (1-2)",
                             abs(vcf_len) < 50 ~ "INDELs (3-49)",
                             TRUE ~ "SVs") %>%
           factor()) %>%
    mutate(chrom = as.integer(str_replace(chrom, "chr", "")))

labeled %>%
    ggplot(aes(start, fill = class)) +
    geom_histogram() +
    facet_wrap(~chrom, scales = "free") +
    scale_y_log10()

grouped <- labeled %>%
    group_by(chrom, start, end, class) %>%
    summarize(hits = n())

grouped %>%
    ggplot(aes(hits)) +
    geom_histogram() +
    facet_wrap(~class, scales = "free") +
    scale_y_log10()




