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
        select(-vcf_chrom) %>%
        mutate(chrom = as.integer(str_replace(chrom, "chr", "")),
               start = start / 1e6,
               end = end / 1e6) %>%
        mutate(class = case_when(vcf_end - vcf_start == 1 & vcf_len == 0 ~ "SNPs",
                                 vcf_len == 0 ~ "Other",
                                 abs(vcf_len) < 3 ~ "INDELs (1-2)",
                                 abs(vcf_len) < 50 ~ "INDELs (3-49)",
                                 TRUE ~ "SVs") %>%
                   factor())
}

summarize_len <- function(df) {
    df %>%
        group_by(chrom, start, end) %>%
        summarize(med = median(abs(vcf_len)),
                  mean = mean(abs(vcf_len)),
                  sd = sd(abs(vcf_len)),
                  max = max(abs(vcf_len)),
                  min = min(abs(vcf_len)))
}

group_hits <- function(df) {
    df %>%
        group_by(chrom, start, end, class) %>%
        summarize(hits = n())
}

mk_chr_distr_plot <- function(df) {
    df %>%
        ggplot(aes(start, fill = class)) +
        geom_histogram() +
        facet_wrap(~chrom, scales = "free") +
        scale_y_log10() +
        labs(x = "pos (Mb)") +
        theme(legend.position = "bottom")
}

mk_chr_sum_plot <- function(stat, df) {
    df %>%
        ggplot(aes_string("start", stat)) +
        geom_point(size = 0.1) +
        facet_wrap(~chrom, scales = "free") +
        labs(x = "pos (Mb)")
}

mk_chr_hist_plot <- function(df) {
    df %>%
        ggplot(aes(factor(class))) +
        geom_bar() +
        facet_wrap(~chrom, scales = "free") +
        scale_y_log10() +
        theme(axis.text.x = element_text(hjust = 1, angle = 90)) +
        labs(x = "pos (Mb)")
}

mk_grouped_hist_plot <- function(df) {
    df %>%
        ggplot(aes(hits)) +
        geom_histogram() +
        facet_wrap(~class, scales = "free") +
        scale_y_log10()
}

mk_plot <- function(df, fun, path, ...) {
    p <- fun(df)
    ## print(p)
    ggsave(path, ...)
}

df <- read_bed(snakemake@input[[1]])
sumlen <- summarize_len(df)
grouped <- group_hits(df)

sout <- snakemake@output

mk_plot(df, mk_chr_distr_plot, sout$chr_dist)

mk_plot(sumlen, partial(mk_chr_sum_plot, "med"), sout$med)
mk_plot(sumlen, partial(mk_chr_sum_plot, "sd"), sout$sd)
mk_plot(sumlen, partial(mk_chr_sum_plot, "max"), sout$max)

mk_plot(df, mk_chr_hist_plot, sout$chr_hist)

mk_plot(grouped, mk_grouped_hist_plot, sout$grouped)
