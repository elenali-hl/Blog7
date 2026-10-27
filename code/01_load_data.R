
# ============================================================
# Blog Post 7: GDP per Capita and Life Expectancy
# 01 - Download and Inspect World Bank WDI Data
#
# Data source: World Bank, World Development Indicators
# Research period: 2000-2024
#
# Purpose:
# 1. Set up project directories
# 2. Load required R packages
# 3. Download official World Bank data
# 4. Inspect variables and data structure
# 5. Check geographic and temporal coverage
# 6. Check missing values and duplicates
# 7. Save original data for reproducibility
# ============================================================


# Step 1: Set up project directories

dir.create("code", showWarnings = FALSE)
dir.create("data-raw", showWarnings = FALSE)
dir.create("data", showWarnings = FALSE)
dir.create("results/figures",
           recursive = TRUE, showWarnings = FALSE)
dir.create("results/tables",
           recursive = TRUE, showWarnings = FALSE)

cat("=== STEP 1: PROJECT SETUP ===\n")
cat("Working directory:", getwd(), "\n")


# Step 2: Install and load packages

packages <- c(
  "WDI",
  "tidyverse",
  "plotly",
  "htmlwidgets"
)

missing_packages <- packages[
  !vapply(packages, requireNamespace,
          logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  install.packages(missing_packages)
}

invisible(lapply(packages, library,
                 character.only = TRUE))

cat("\n=== STEP 2: PACKAGES LOADED ===\n")
print(packages)


# Step 3: Download World Bank WDI data

cat("\n=== STEP 3: DOWNLOAD WDI DATA ===\n")

indicators <- c(
  gdp_per_capita = "NY.GDP.PCAP.PP.KD",
  life_expectancy = "SP.DYN.LE00.IN",
  population = "SP.POP.TOTL"
)

wdi_raw <- WDI::WDI(
  country = "all",
  indicator = indicators,
  start = 2000,
  end = 2024,
  extra = TRUE
)

cat("Download completed.\n")
print(head(wdi_raw, 10))


# Step 4: Inspect data structure

cat("\n=== STEP 4: DATA STRUCTURE ===\n")

glimpse(wdi_raw)

cat("\nVariable names:\n")
print(names(wdi_raw))

cat("\nDimensions:\n")
print(dim(wdi_raw))



# ============================================================
# Step 5: Check Data Coverage
# ============================================================

cat("\n=== STEP 5: DATA COVERAGE ===\n")

# 5.1 Number of geographic entities

cat("Number of geographic entities:",
    dplyr::n_distinct(wdi_raw$country), "\n")


# 5.2 Year range

cat("Year range:",
    min(wdi_raw$year, na.rm = TRUE), "-",
    max(wdi_raw$year, na.rm = TRUE), "\n")


# 5.3 Observations by year

cat("\n=== OBSERVATIONS BY YEAR ===\n")

year_summary <- wdi_raw %>%
  dplyr::count(year) %>%
  dplyr::arrange(year)

print(as.data.frame(year_summary))


# 5.4 Observations by region

cat("\n=== OBSERVATIONS BY REGION ===\n")

region_summary <- wdi_raw %>%
  dplyr::count(region, sort = TRUE)

print(as.data.frame(region_summary))


# 5.5 Number of unique regions

cat("\nNumber of regions:",
    dplyr::n_distinct(wdi_raw$region), "\n")

cat("\n=== STEP 5 COMPLETED ===\n")



# Step 6: Check missing values and duplicates

cat("\n=== STEP 6: DATA QUALITY ===\n")

missing_summary <- wdi_raw %>%
  summarise(
    missing_gdp = sum(is.na(gdp_per_capita)),
    missing_life = sum(is.na(life_expectancy)),
    missing_population = sum(is.na(population))
  )

print(missing_summary)

duplicate_count <- wdi_raw %>%
  count(iso2c, year) %>%
  filter(n > 1) %>%
  nrow()

cat("Duplicate entity-year pairs:",
    duplicate_count, "\n")

cat("\nComplete observations:\n")

wdi_raw %>%
  summarise(
    complete_rows = sum(
      !is.na(gdp_per_capita) &
        !is.na(life_expectancy) &
        !is.na(population)
    )
  ) %>%
  print()


# Step 7: Save original data

cat("\n=== STEP 7: SAVE RAW DATA ===\n")

write_csv(
  wdi_raw,
  "data-raw/wdi_raw.csv"
)

cat("Saved: data-raw/wdi_raw.csv\n")

cat("\n=== STEP 1 COMPLETED ===\n")
