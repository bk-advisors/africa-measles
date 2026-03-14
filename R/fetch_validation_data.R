# ---- Fetch validation data from WHO and World Bank APIs ----
# Run this BEFORE rendering data-validation-report.qmd.
# Saves results to data/validation_cache.rds
#
# Usage: Rscript R/fetch_validation_data.R

library(jsonlite)
library(dplyr)

csv <- read.csv("data/africa_measles.csv")

# ---- 1. WHO measles indicators (for the "indicator issue" table) ----
cat("Fetching WHO indicator list...\n")
ind_url <- "https://ghoapi.azureedge.net/api/Indicator?$filter=contains(IndicatorName,%27easles%27)"
indicators <- fromJSON(ind_url)$value %>%
  select(IndicatorCode, IndicatorName)
cat("  Found", nrow(indicators), "measles indicators\n")

# ---- 2. WHS3_41 for Kenya 1983 (to demonstrate the wrong indicator) ----
cat("Fetching WHS3_41 sample (Kenya 1983)...\n")
wrong_url <- paste0(
  "https://ghoapi.azureedge.net/api/WHS3_41",
  "?$filter=SpatialDim%20eq%20%27KEN%27%20and%20TimeDim%20eq%201983"
)
wrong_sample <- fromJSON(wrong_url)$value %>%
  transmute(SpatialDim, TimeDim, NumericValue = as.numeric(NumericValue))

# ---- 3. WHS3_62 for Kenya 1983 (correct indicator) ----
cat("Fetching WHS3_62 sample (Kenya 1983)...\n")
right_url <- paste0(
  "https://ghoapi.azureedge.net/api/WHS3_62",
  "?$filter=SpatialDim%20eq%20%27KEN%27%20and%20TimeDim%20eq%201983"
)
right_sample <- fromJSON(right_url)$value %>%
  transmute(SpatialDim, TimeDim, NumericValue = as.numeric(NumericValue))

# ---- 4. Full WHS3_62 data for Africa ----
cat("Fetching full WHO WHS3_62 data (Africa, 1980-2023)...\n")
who_url <- paste0(
  "https://ghoapi.azureedge.net/api/WHS3_62",
  "?$filter=ParentLocationCode%20eq%20%27AFR%27",
  "%20and%20TimeDim%20ge%201980%20and%20TimeDim%20le%202023"
)

who_raw <- fromJSON(who_url)
who <- who_raw$value
while (!is.null(who_raw[["@odata.nextLink"]])) {
  who_raw <- fromJSON(who_raw[["@odata.nextLink"]])
  who <- rbind(who, who_raw$value)
}

who_clean <- who %>%
  filter(SpatialDimType == "COUNTRY") %>%
  transmute(
    country_code = SpatialDim,
    year         = as.integer(TimeDim),
    who_cases    = as.numeric(NumericValue)
  )
cat("  WHO records:", nrow(who_clean), "\n")

# ---- 5. World Bank population ----
cat("Fetching World Bank population data...\n")
codes_str <- paste(unique(csv$country_code), collapse = ";")
wb_url <- paste0(
  "https://api.worldbank.org/v2/country/", codes_str,
  "/indicator/SP.POP.TOTL?date=1980:2023&format=json&per_page=20000"
)

wb_raw  <- fromJSON(wb_url)
wb_meta <- wb_raw[[1]]
wb      <- wb_raw[[2]]

if (wb_meta$pages > 1) {
  for (pg in 2:wb_meta$pages) {
    page_raw <- fromJSON(paste0(wb_url, "&page=", pg))
    wb <- rbind(wb, page_raw[[2]])
  }
}

wb_clean <- wb %>%
  transmute(
    country_code = countryiso3code,
    year         = as.integer(date),
    wb_pop       = as.numeric(value)
  ) %>%
  filter(!is.na(wb_pop))
cat("  World Bank records:", nrow(wb_clean), "\n")

# ---- Save everything ----
cache <- list(
  indicators   = indicators,
  wrong_sample = wrong_sample,
  right_sample = right_sample,
  who          = who_clean,
  wb           = wb_clean,
  fetched_at   = Sys.time()
)

saveRDS(cache, "data/validation_cache.rds")
cat("\nSaved to data/validation_cache.rds\n")
cat("Timestamp:", format(cache$fetched_at), "\n")
