library(tidyverse)

read_bed <- function(path) {
    readr::read_tsv(path,
                    col_names = c("chrom", "start", "end", "vcf_chrom",
                                  "vcf_start", "vcf_end", "vcf_len"),
                    na = ".",
                    col_types = cols("chrom" = "c",
                                     "vcf_chrom" = "c",
                                     .default = "d")) %>%
        filter(!chrom %in% c("chrX", "chrY")) %>%
        mutate(chrom = as.integer(str_replace(chrom, "chr", ""))) %>%
               ## start = start / 1e6,
               ## end = end / 1e6) %>%
        mutate(class = case_when(is.na(vcf_chrom) ~ NA_character_,
                                 vcf_end - vcf_start == 1 & vcf_len == 0 ~ "SNPs",
                                 vcf_len == 0 ~ "Other",
                                 abs(vcf_len) < 3 ~ "INDEL2s",
                                 abs(vcf_len) < 50 ~ "INDEL49s",
                                 TRUE ~ "SVs") %>%
                   factor()) %>%
        select(-vcf_chrom)
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

## group_hits <- function(df) {
##     df %>%
##         group_by(chrom, start, end, class) %>%
##         summarize(hits = n())
## }

## mk_chr_distr_plot <- function(df) {
##     df %>%
##         ggplot(aes(start, fill = class)) +
##         geom_histogram() +
##         facet_wrap(~chrom, scales = "free") +
##         scale_y_log10() +
##         labs(x = "pos (Mb)") +
##         theme(legend.position = "bottom")
## }

## mk_chr_sum_plot <- function(stat, df) {
##     df %>%
##         ggplot(aes_string("start", stat)) +
##         geom_point(size = 0.1) +
##         facet_wrap(~chrom, scales = "free") +
##         labs(x = "pos (Mb)")
## }

## mk_chr_hist_plot <- function(df) {
##     df %>%
##         ggplot(aes(factor(class))) +
##         geom_bar() +
##         facet_wrap(~chrom, scales = "free") +
##         scale_y_log10() +
##         theme(axis.text.x = element_text(hjust = 1, angle = 90)) +
##         labs(x = "pos (Mb)")
## }

## mk_grouped_hist_plot <- function(df) {
##     df %>%
##         ggplot(aes(hits)) +
##         geom_histogram() +
##         facet_wrap(~class, scales = "free") +
##         scale_y_log10()
## }

## mk_plot <- function(df, fun, path, ...) {
##     p <- fun(df)
##     ## print(p)
##     ggsave(path, ...)
## }

df <- read_bed(snakemake@input[[1]])

df_pos <- df %>%
    ## remove regions with no hits
    filter(!is.na(class)) %>%
    ## remove regions with hits that are partially outside
    filter(!(vcf_start < start | vcf_end > end))

rep0 <- df %>%
    filter(is.na(class))

## sumlen <- summarize_len(df_pos)

## grouped <- group_hits(df_pos)

sout <- snakemake@output

## mk_plot(df, mk_chr_distr_plot, sout$chr_dist)

## mk_plot(sumlen, partial(mk_chr_sum_plot, "med"), sout$med)
## mk_plot(sumlen, partial(mk_chr_sum_plot, "sd"), sout$sd)
## mk_plot(sumlen, partial(mk_chr_sum_plot, "max"), sout$max)

## mk_plot(df, mk_chr_hist_plot, sout$chr_hist)

## mk_plot(grouped, mk_grouped_hist_plot, sout$grouped)

## hacky scratch pad

## grouped %>%
##     mutate(hasone = hits == 1) %>%

## grouped %>%
##     filter(hits == 1) %>%
##     ggplot(aes(factor(class))) +
##     geom_bar() +
##     facet_wrap(~chrom)

## vcf_lens <- df %>%
##     group_by(chrom, start, end) %>%
##     summarize(totlen = sum(vcf_end - vcf_start)) %>%
##     ungroup() %>%
##     mutate(totfrac = totlen / ((end - start) * 1e6))

## vcf_lens %>%
##     mutate(totfrac = -log10(totfrac)) %>%
##     ggplot(aes(totfrac)) +
##     geom_histogram()

## reps with only one variant in them

rep1 <- df_pos %>%
    group_by(chrom, start, end) %>%
    summarize(n = n()) %>%
    ungroup() %>%
    filter(n == 1) %>%
    select(-n) %>%
    left_join(df, by = c("chrom", "start", "end"))

rep1_N <- rep1 %>%
    group_by(chrom) %>%
    summarize(N = n())

rep1_n <- rep1 %>%
    group_by(chrom, class) %>%
    summarize(n = n()) %>%
    left_join(rep1_N, by = "chrom") %>%
    mutate(frac = n / N)

## plot showing distribution of "simple" TRs is consistent across each chr

rep1_n %>%
    ggplot(aes(chrom, frac, fill = class)) +
    geom_col() +
    theme(legend.position = "bottom")
ggsave(sout$simple, width = 4, height = 3)

## rep1_n %>%
##     mutate(frac = sprintf("%.02f", 100 * frac)) %>%
##     pivot_wider(id_cols = chrom, names_from = class, values_from = frac) %>%
##     View()

rep1 %>%
    mutate(replen = (end - start) * 1e6) %>%
    ggplot(aes(replen, fill = class)) +
    geom_histogram() +
    scale_x_log10() +
    theme(legend.position = "bottom")
ggsave(sout$complex, width = 4, height = 3)

## reps with more than one variant in them

## repX <- df_pos %>%
##     anti_join(rep1, by = c("chrom", "start", "end")) %>%
##     filter(!is.na(class)) %>%
##     group_by(chrom, start, end, class) %>%
##     summarize(hits = n()) %>%
##     ungroup() %>%
##     pivot_wider(id_cols = c(chrom, start, end),
##                 names_from = class,
##                 values_from = hits)

## repX_cls <- repX %>%
##     mutate(Xclass = case_when(
##                !is.na(SVs) ~ "any",
##                !is.na(INDEL49s) ~ "<50",
##                is.na(INDEL2s) ~ "<3",
##                TRUE ~ "<1")) %>%
##     replace_na(list(INDEL49s = 0, INDEL2s = 0, SNPs = 0, SVs = 0)) %>%
##     mutate(hits = INDEL49s + INDEL2s + SNPs + SVs)

## plot showing distribution of binned "complex" tandem repeats

## repX_cls %>%
##     ggplot(aes(hits, fill = Xclass)) +
##     geom_histogram() +
##     ## facet_wrap(~chrom) +
##     scale_y_log10()

## repX %>%
##     mutate(hasSV = !is.na(SVs)) %>%
##     select(-SVs) %>%
##     replace_na(list(INDEL49s = 0, INDEL2s = 0, SNPs = 0)) %>%
##     pivot_longer(cols = c(INDEL49s, INDEL2s, SNPs), names_to = "class", values_to = "hits") %>%
##     ggplot(aes(hits)) +
##     geom_histogram() +
##     facet_wrap(hasSV~class, scales = "free")

## df_gt <- df_pos %>%
##     mutate(vcf_len = abs(vcf_len)) %>%
##     group_by(chrom, start, end) %>%
##     summarize(all = n(),
##               gt1 = sum(vcf_len >= 1),
##               gt3 = sum(vcf_len >= 3),
##               gt50 = sum(vcf_len >= 50))

## df_gt %>%
##     pivot_longer(cols = c(all, gt1, gt3, gt50), values_to = "hits", names_to = "cutoff") %>%
##     ggplot(aes(hits)) +
##     geom_histogram() +
##     scale_y_log10() +
##     facet_wrap(~cutoff, scales = "free")

## plot showing number of "simple" vs "not simple" TRs

rep_complex <- df_pos %>%
    group_by(chrom, start, end) %>%
    summarize(hits = if_else(n() > 1, "1+", "1")) %>%
    ungroup()

## rep0 %>%
##     select(chrom, start, end) %>%
##     mutate(hits = "0") %>%
##     bind_rows(rep_complex) %>%
##     ggplot(aes(hits)) +
##     geom_bar()

rep0 %>%
    select(chrom, start, end) %>%
    mutate(hits = "0") %>%
    bind_rows(rep_complex) %>%
    ggplot(aes(hits)) +
    geom_bar()
ggsave(sout$summary, width = 3, height = 3)
