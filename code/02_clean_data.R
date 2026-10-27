
# ============================================================
# Blog Post 7: GDP per Capita and Life Expectancy
# 02 - Data Cleaning and Feature Engineering
#
# Data source: World Bank WDI
# Period: 2000-2024
#
# Purpose:
# 1. Load raw data
# 2. Remove aggregate entities
# 3. Check missing and invalid values
# 4. Create variables for Plotly
# 5. Calculate descriptive statistics
# 6. Save cleaned data and summary tables
# ============================================================


# Step 1: Load packages and raw data

library(tidyverse)

cat("\n=== STEP 1: LOAD RAW DATA ===\n")

wdi_raw <- readr::read_csv(
  "data-raw/wdi_raw.csv",
  show_col_types = FALSE
)

cat("Raw observations:", nrow(wdi_raw), "\n")
cat("Raw geographic entities:",
    n_distinct(wdi_raw$iso3c), "\n")


# Step 2: Remove aggregate entities

cat("\n=== STEP 2: REMOVE AGGREGATES ===\n")

wdi_countries <- wdi_raw %>%
  filter(
    !is.na(region),
    region != "Aggregates",
    !is.na(iso3c),
    iso3c != ""
  )

cat("Observations after filtering:",
    nrow(wdi_countries), "\n")

cat("Remaining economies:",
    n_distinct(wdi_countries$iso3c), "\n")

cat("\nObservations by region:\n")

region_summary <- wdi_countries %>%
  distinct(iso3c, region) %>%
  count(region, name = "economies")

print(as.data.frame(region_summary))


# Step 3: Check missing and invalid values

cat("\n=== STEP 3: DATA QUALITY ===\n")

quality_summary <- wdi_countries %>%
  summarise(
    total_rows = n(),
    missing_gdp = sum(is.na(gdp_per_capita)),
    missing_life = sum(is.na(life_expectancy)),
    missing_population = sum(is.na(population)),
    invalid_gdp = sum(
      !is.na(gdp_per_capita) &
        gdp_per_capita <= 0
    ),
    invalid_life = sum(
      !is.na(life_expectancy) &
        life_expectancy <= 0
    ),
    invalid_population = sum(
      !is.na(population) &
        population <= 0
    )
  )

print(as.data.frame(quality_summary))


# Step 4: Clean data and create new variables

cat("\n=== STEP 4: FEATURE ENGINEERING ===\n")

wdi_clean <- wdi_countries %>%
  filter(
    !is.na(gdp_per_capita),
    !is.na(life_expectancy),
    !is.na(population),
    gdp_per_capita > 0,
    life_expectancy > 0,
    population > 0
  ) %>%
  mutate(
    log_gdp_per_capita = log(gdp_per_capita),
    population_millions = population / 1000000,
    year = as.integer(year)
  ) %>%
  select(
    country,
    iso2c,
    iso3c,
    year,
    region,
    income,
    gdp_per_capita,
    log_gdp_per_capita,
    life_expectancy,
    population,
    population_millions
  ) %>%
  arrange(year, region, country)

cat("Clean observations:", nrow(wdi_clean), "\n")

cat("Countries/economies:",
    n_distinct(wdi_clean$iso3c), "\n")

cat("Years:",
    n_distinct(wdi_clean$year), "\n")


# Step 5: Check duplicates and year coverage

cat("\n=== STEP 5: VALIDATION ===\n")

duplicate_count <- wdi_clean %>%
  count(iso3c, year) %>%
  filter(n > 1) %>%
  nrow()

cat("Duplicate economy-year pairs:",
    duplicate_count, "\n")

if (duplicate_count > 0) {
  stop("Duplicate economy-year observations found.")
}

year_coverage <- wdi_clean %>%
  group_by(year) %>%
  summarise(
    economies = n_distinct(iso3c),
    .groups = "drop"
  )

print(as.data.frame(year_coverage))


# Step 6: Calculate descriptive statistics

cat("\n=== STEP 6: DESCRIPTIVE STATISTICS ===\n")

overall_summary <- wdi_clean %>%
  summarise(
    observations = n(),
    economies = n_distinct(iso3c),
    mean_gdp = mean(gdp_per_capita),
    median_gdp = median(gdp_per_capita),
    mean_life = mean(life_expectancy),
    median_life = median(life_expectancy),
    min_life = min(life_expectancy),
    max_life = max(life_expectancy)
  )

print(as.data.frame(overall_summary))


# Step 7: Regional statistics by year

cat("\n=== STEP 7: REGIONAL STATISTICS ===\n")

regional_summary <- wdi_clean %>%
  group_by(year, region) %>%
  summarise(
    economies = n_distinct(iso3c),
    mean_gdp = mean(gdp_per_capita),
    median_gdp = median(gdp_per_capita),
    mean_life = mean(life_expectancy),
    total_population = sum(population),
    .groups = "drop"
  ) %>%
  arrange(year, region)

print(as.data.frame(head(regional_summary, 10)))


# Step 8: Save cleaned data and summary tables

cat("\n=== STEP 8: SAVE OUTPUTS ===\n")

readr::write_csv(
  wdi_clean,
  "data/wdi_clean.csv"
)

readr::write_csv(
  quality_summary,
  "results/tables/data_quality.csv"
)

readr::write_csv(
  year_coverage,
  "results/tables/year_coverage.csv"
)

readr::write_csv(
  overall_summary,
  "results/tables/overall_summary.csv"
)

readr::write_csv(
  regional_summary,
  "results/tables/regional_summary.csv"
)

cat("All cleaned data and tables saved.\n")

cat("\n=== STEP 2 COMPLETED ===\n")
