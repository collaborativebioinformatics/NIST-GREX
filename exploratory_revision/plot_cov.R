
library(tidyverse)
library(Hmisc)

library(dplyr)

library(tidyverse)

pretty_theme <-
  theme(
    text = element_text(size = 10),
    line = element_line(linewidth = 0.2),
    axis.ticks.length = unit(0.25, "mm"),
    axis.line = element_line(linewidth = 0.15),
    legend.box.spacing = unit(0.2, "cm"),
    legend.margin = margin(0, 0, 0.75, 0, "mm"),
    plot.margin = margin(1, 1, 1, 1, "mm"),
    legend.key.size = unit(0.55, "lines"),
    legend.spacing = unit(1.5, "mm"),
    strip.text = element_text(size = rel(1), margin = margin(1, 1, 1, 1, "mm")),
    strip.background = element_rect(
      linetype = "blank",
      fill = "gray"
    )
  )

geom_line_size <- 0.25
geom_point_size <- 0.4
annot_size <- 6
errorbar_size <- 0.2

phred <- function(x) {
  if_else(x <= 0, NA, - 10 * log10(x))
}

binCI <- function(x, n, name) {
  .mean <- sprintf("%s_mean", name)
  .lower <- sprintf("%s_lower", name)
  .upper <- sprintf("%s_upper", name)
  if_else(
    n == 0, 
    tibble(PointEst = NA, Lower = NA, Upper = NA),
    Hmisc::binconf(x, n, alpha = 0.05, method = "wilson") %>%
      as_tibble()
  ) %>%
    rename(
      {{ .mean }} := PointEst,
      {{ .lower }} := Lower,
      {{ .upper }} := Upper
    )
}






read_summary <- function(path, which1){  #function(f, path) {
  #which1 <- "cov" #f(path)
  read_csv(
    path,
    col_types = cols(
      Type = "c",
      Subtype = "c",
      Subset = "c",
      Filter = "c",
      Genotype = "c",
      QQ.Field = "c",
      QQ = "c",
      .default = "d"
    ),
    na = c(".", "")
  ) %>%
    filter(
      Filter == "PASS" &
        Subtype %in% c("*", "I16_PLUS", "D16_PLUS")
    ) %>%
    mutate(
      .recall = map2(TRUTH.TP, TRUTH.TP + TRUTH.FN, ~ binCI(.x, .y, "Recall")),
      .precision = map2(QUERY.TP, QUERY.TP + QUERY.FP, ~ binCI(.x, .y, "Precision"))
    ) %>% 
    unnest(c(.recall, .precision)) %>%
    select(Type, Subtype, Subset, matches("^(Recall|Precision)_")) %>%
    mutate(build = which1) %>%
    pivot_longer(
      cols = c(-Type, -Subtype, -Subset, -build),
      names_to = c("metric", "bound"),
      names_pattern = "(.+)_(.+)",
      values_to = "value"
    ) %>%
    mutate(
      metric = sprintf("1 - %s", metric),
      value = phred(1 - value)
    ) %>%
    pivot_wider(
      id_cols = c(Type, Subtype, Subset, build, metric),
      names_from = bound,
      values_from = value
    )
}


make_plot <- function(df) {
  df %>%
    mutate(
      Subset = case_when(
        Subset == "cov0-20" ~  "0-20",
        Subset == "cov20-40" ~ "20-40",
        Subset == "cov40-60" ~ "40-60",
        Subset == "cov60-80" ~ "60-80",
        Subset == "cov80-" ~   ">80",
        TRUE ~ "other"
      )
    )  %>% mutate(Subset = factor(.$Subset, levels = comparison_subsets1)) %>% 
    ggplot(aes(mean, fct_rev(Subset), fill = build) ) + #
    geom_col(position = position_dodge()) +
    geom_errorbar(
      aes(xmin = lower, xmax = upper),
      position = "dodge",
      linewidth = 0.1
    ) +
    theme(legend.position = "top") +
    pretty_theme
}




setwd("giab_revision_coverage/")

path_to_comp="hap_out/happy_out_.extended_cov_may5.csv"
comparison_subsets= c("cov0-20", "cov20-40", "cov40-60", "cov60-80", "cov80-")
comparison_subsets1= c("0-20", "20-40", "40-60", "60-80", ">80")
which1 = "all"
a= read_summary(path_to_comp,which1)

a  %>%
  filter(Subset %in% comparison_subsets) %>%
  filter(Subtype == "*") %>% mutate(build = factor(build, levels = c("all", "non-syntenic"))) %>%
  make_plot() +
  facet_wrap(c("Type", "metric"), ncol = 2) +
  labs(x = "Phred(Metric)",y = "Coverage bins", fill = "Target Regions")



# replace SNP with SNV, in csv file 