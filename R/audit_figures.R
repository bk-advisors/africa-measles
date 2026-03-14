# ---- Audit key figures used in LinkedIn post and chart ----
# Run this script to verify claims before publishing.

library(dplyr)
library(scales)

df <- read.csv("data/africa_measles.csv")

cat("=== DATA OVERVIEW ===\n")
cat("Countries:", n_distinct(df$country), "\n")
cat("Year range:", min(df$year), "-", max(df$year),
    paste0("(", max(df$year) - min(df$year) + 1, " years)\n"))

# ---- 1. Continental totals by year ----
yearly <- df %>%
  group_by(year) %>%
  summarise(total_cases = sum(cases, na.rm = TRUE), .groups = "drop")

peak <- yearly %>% slice_max(total_cases, n = 1)
low  <- yearly %>% slice_min(total_cases, n = 1)

cat("\n=== LINKEDIN CLAIM: '1.4 million cases in 1981' ===\n")
cat("1981 total:", comma(yearly$total_cases[yearly$year == 1981]), "\n")

cat("\n=== LINKEDIN CLAIM: '35,000 in 2016' ===\n")
cat("2016 total:", comma(yearly$total_cases[yearly$year == 2016]), "\n")

cat("\n=== LINKEDIN CLAIM: '97% drop' ===\n")
pct_drop <- (1 - low$total_cases / peak$total_cases) * 100
cat("Peak year:", peak$year, "—", comma(peak$total_cases), "cases\n")
cat("Low year: ", low$year, "—", comma(low$total_cases), "cases\n")
cat("Reduction:", round(pct_drop, 1), "%\n")

# ---- 2. Chart title claim: 'over 90%' reduction ----
cat("\n=== CHART TITLE: 'cut cases by over 90%' ===\n")
pre  <- df %>% filter(year < 2001) %>%
  summarise(avg = mean(cases_per_million, na.rm = TRUE))
post <- df %>% filter(year >= 2001) %>%
  summarise(avg = mean(cases_per_million, na.rm = TRUE))
cat("Avg cases/million pre-2001: ", round(pre$avg, 1), "\n")
cat("Avg cases/million post-2001:", round(post$avg, 1), "\n")
cat("Reduction:", round((1 - post$avg / pre$avg) * 100, 1), "%\n")

# ---- 3. Countries named as high pre-2001 ----
cat("\n=== LINKEDIN CLAIM: Malawi, Zambia, Niger, Kenya 'thousands per million' ===\n")
named <- c("Malawi", "Zambia", "Niger", "Kenya")
df %>%
  filter(year < 2001, country %in% named) %>%
  group_by(country) %>%
  summarise(avg_rate = round(mean(cases_per_million, na.rm = TRUE), 0),
            .groups = "drop") %>%
  arrange(desc(avg_rate)) %>%
  mutate(label = paste0(country, ": ", comma(avg_rate), " per million")) %>%
  pull(label) %>%
  cat(sep = "\n")

# ---- 4. Recent years for context ----
cat("\n\n=== RECENT YEARS (2017-2023) ===\n")
yearly %>%
  filter(year >= 2017) %>%
  mutate(label = paste0(year, ": ", comma(total_cases))) %>%
  pull(label) %>%
  cat(sep = "\n")

cat("\n\n=== AUDIT COMPLETE ===\n")
