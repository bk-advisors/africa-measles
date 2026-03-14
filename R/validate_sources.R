# ---- Validate CSV against original sources ----
# Fetches measles cases from WHO GHO API and population from World Bank API,
# then compares both against data/africa_measles.csv.
#
# Requires: jsonlite, dplyr
# Usage:    Rscript R/validate_sources.R

library(jsonlite)
library(dplyr)

csv <- read.csv("data/africa_measles.csv")
csv_codes <- unique(csv$country_code)

cat("=== CSV SUMMARY ===\n")
cat("Countries:", length(csv_codes), "\n")
cat("Rows:", nrow(csv), "\n")
cat("Year range:", min(csv$year), "-", max(csv$year), "\n\n")


# =========================================================================
# 1. WHO GHO — Measles reported cases (WHS3_62)
#    NOTE: WHS3_62 is the correct indicator for reported case counts.
#    WHS3_41 is a different indicator and returns different values.
# =========================================================================
cat("=== FETCHING WHO MEASLES DATA ===\n")

who_url <- paste0(
 "https://ghoapi.azureedge.net/api/WHS3_62",
 "?$filter=ParentLocationCode%20eq%20%27AFR%27",
 "%20and%20TimeDim%20ge%201980%20and%20TimeDim%20le%202023"
)

who_raw <- fromJSON(who_url)
who <- who_raw$value

# Handle pagination
while (!is.null(who_raw[["@odata.nextLink"]])) {
  who_raw <- fromJSON(who_raw[["@odata.nextLink"]])
  who <- rbind(who, who_raw$value)
}

who <- who %>%
  filter(SpatialDimType == "COUNTRY") %>%
  transmute(
    country_code = SpatialDim,
    year         = as.integer(TimeDim),
    who_cases    = as.numeric(NumericValue)
  )

cat("WHO records fetched:", nrow(who), "\n\n")


# =========================================================================
# 2. World Bank — Total population (SP.POP.TOTL)
# =========================================================================
cat("=== FETCHING WORLD BANK POPULATION DATA ===\n")

# Query only the ISO3 codes present in the CSV
codes_str <- paste(csv_codes, collapse = ";")
wb_url <- paste0(
  "https://api.worldbank.org/v2/country/", codes_str,
  "/indicator/SP.POP.TOTL?date=1980:2023&format=json&per_page=20000"
)

wb_raw  <- fromJSON(wb_url)
wb_meta <- wb_raw[[1]]
wb      <- wb_raw[[2]]

# Handle pagination
if (wb_meta$pages > 1) {
  for (pg in 2:wb_meta$pages) {
    page_raw <- fromJSON(paste0(wb_url, "&page=", pg))
    wb <- rbind(wb, page_raw[[2]])
  }
}

wb <- wb %>%
  transmute(
    country_code = countryiso3code,
    year         = as.integer(date),
    wb_pop       = as.numeric(value)
  ) %>%
  filter(!is.na(wb_pop))

cat("World Bank records fetched:", nrow(wb), "\n\n")


# =========================================================================
# 3. Compare: CSV cases vs WHO cases
# =========================================================================
cat("=== CASES COMPARISON: CSV vs WHO ===\n")

cases_check <- csv %>%
  select(country_code, year, csv_cases = cases) %>%
  inner_join(who, by = c("country_code", "year"))

cases_check <- cases_check %>%
  mutate(
    diff       = csv_cases - who_cases,
    pct_diff   = ifelse(who_cases > 0,
                        round((diff / who_cases) * 100, 2), NA)
  )

exact   <- sum(cases_check$diff == 0, na.rm = TRUE)
total   <- nrow(cases_check)
matched <- sum(abs(cases_check$pct_diff) < 1, na.rm = TRUE)

cat("Rows matched (inner join):", total, "of", nrow(csv), "CSV rows\n")
cat("Exact matches:", exact, "/", total, "\n")
cat("Within 1% tolerance:", matched, "/", total, "\n")

mismatches <- cases_check %>%
  filter(diff != 0) %>%
  arrange(desc(abs(pct_diff)))

if (nrow(mismatches) > 0) {
  cat("\nTop discrepancies (cases):\n")
  print(head(mismatches, 15))
} else {
  cat("All case counts match exactly.\n")
}


# =========================================================================
# 4. Compare: CSV population vs World Bank population
# =========================================================================
cat("\n=== POPULATION COMPARISON: CSV vs WORLD BANK ===\n")

pop_check <- csv %>%
  select(country_code, year, csv_pop = population) %>%
  inner_join(wb, by = c("country_code", "year"))

pop_check <- pop_check %>%
  mutate(
    diff       = csv_pop - wb_pop,
    pct_diff   = ifelse(wb_pop > 0,
                        round((diff / wb_pop) * 100, 2), NA)
  )

exact_p   <- sum(pop_check$diff == 0, na.rm = TRUE)
total_p   <- nrow(pop_check)
matched_p <- sum(abs(pop_check$pct_diff) < 1, na.rm = TRUE)

cat("Rows matched (inner join):", total_p, "of", nrow(csv), "CSV rows\n")
cat("Exact matches:", exact_p, "/", total_p, "\n")
cat("Within 1% tolerance:", matched_p, "/", total_p, "\n")

pop_mismatches <- pop_check %>%
  filter(diff != 0) %>%
  arrange(desc(abs(pct_diff)))

if (nrow(pop_mismatches) > 0) {
  cat("\nTop discrepancies (population):\n")
  print(head(pop_mismatches, 15))
} else {
  cat("All population figures match exactly.\n")
}


# =========================================================================
# 5. Verify derived column: cases_per_million
# =========================================================================
cat("\n=== DERIVED COLUMN CHECK: cases_per_million ===\n")

csv <- csv %>%
  mutate(
    calc_rate = round(cases / population * 1e6, 1),
    rate_diff = abs(cases_per_million - calc_rate)
  )

rate_ok <- sum(csv$rate_diff < 0.2, na.rm = TRUE)
cat("cases_per_million matches (cases/pop * 1M, within 0.2):",
    rate_ok, "/", nrow(csv), "\n")

rate_issues <- csv %>% filter(rate_diff >= 0.2)
if (nrow(rate_issues) > 0) {
  cat("\nRate discrepancies:\n")
  print(head(rate_issues %>%
    select(country, year, cases, population,
           cases_per_million, calc_rate, rate_diff), 10))
} else {
  cat("All rates are internally consistent.\n")
}


# =========================================================================
# 6. Coverage: countries in CSV but not in WHO (and vice versa)
# =========================================================================
cat("\n=== COVERAGE GAPS ===\n")

who_codes <- unique(who$country_code)

in_csv_not_who <- setdiff(csv_codes, who_codes)
in_who_not_csv <- setdiff(who_codes, csv_codes)

if (length(in_csv_not_who) > 0) {
  cat("In CSV but not in WHO:", paste(in_csv_not_who, collapse = ", "), "\n")
} else {
  cat("All CSV countries found in WHO data.\n")
}

if (length(in_who_not_csv) > 0) {
  cat("In WHO but not in CSV:", paste(in_who_not_csv, collapse = ", "), "\n")
  cat("(These may have been excluded for <15 years of reporting.)\n")
} else {
  cat("All WHO African countries are in the CSV.\n")
}

cat("\n=== VALIDATION COMPLETE ===\n")

