
# ============================================================
# Blog Post 7: GDP per Capita and Life Expectancy
# 04 - Economic Analysis and Statistical Findings
#
# Data: World Bank WDI, 2000-2024
#
# Purpose:
# 1. Estimate GDP-life expectancy correlations
# 2. Estimate log-linear relationships
# 3. Compare geographic regions
# 4. Examine changes over time
# 5. Compare within-economy changes
# 6. Export reproducible results
# ============================================================


# ============================================================
# Step 1: Load Data
# ============================================================

library(tidyverse)

cat("\n=== STEP 1: LOAD DATA ===\n")

wdi <- readr::read_csv(
  "data/wdi_clean.csv",
  show_col_types = FALSE
)

cat("Observations:", nrow(wdi), "\n")
cat("Economies:", n_distinct(wdi$iso3c), "\n")


# ============================================================
# Step 2: Overall Correlation
# ============================================================

cat("\n=== STEP 2: CORRELATION ===\n")

overall_correlation <- wdi %>%
  summarise(
    correlation_gdp_life = cor(
      gdp_per_capita,
      life_expectancy
    ),
    correlation_log_gdp_life = cor(
      log_gdp_per_capita,
      life_expectancy
    )
  )

print(as.data.frame(overall_correlation))


# ============================================================
# Step 3: Log-Linear Regression
# ============================================================

cat("\n=== STEP 3: LOG-LINEAR REGRESSION ===\n")

model <- lm(
  life_expectancy ~ log_gdp_per_capita,
  data = wdi
)

print(summary(model))

model_results <- tibble(
  term = names(coef(model)),
  estimate = as.numeric(coef(model))
)

readr::write_csv(
  model_results,
  "results/tables/regression_results.csv"
)


# ============================================================
# Step 4: Regional Comparison
# ============================================================

cat("\n=== STEP 4: REGIONAL COMPARISON ===\n")

regional_comparison <- wdi %>%
  group_by(region) %>%
  summarise(
    economies = n_distinct(iso3c),
    observations = n(),
    mean_gdp = mean(gdp_per_capita),
    median_gdp = median(gdp_per_capita),
    mean_life = mean(life_expectancy),
    correlation = cor(
      log_gdp_per_capita,
      life_expectancy
    ),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_life))

print(as.data.frame(regional_comparison))


# ============================================================
# Step 5: Changes Over Time
# ============================================================

cat("\n=== STEP 5: YEARLY ANALYSIS ===\n")

yearly_analysis <- wdi %>%
  group_by(year) %>%
  summarise(
    economies = n_distinct(iso3c),
    mean_gdp = mean(gdp_per_capita),
    mean_life = mean(life_expectancy),
    correlation = cor(
      log_gdp_per_capita,
      life_expectancy
    ),
    .groups = "drop"
  ) %>%
  arrange(year)

print(as.data.frame(yearly_analysis))


# ============================================================
# Step 6: Within-Economy Changes
# ============================================================

cat("\n=== STEP 6: ECONOMY-LEVEL CHANGES ===\n")

start_data <- wdi %>%
  filter(year == 2000) %>%
  select(
    iso3c,
    country,
    gdp_2000 = gdp_per_capita,
    life_2000 = life_expectancy
  )

end_data <- wdi %>%
  filter(year == 2024) %>%
  select(
    iso3c,
    gdp_2024 = gdp_per_capita,
    life_2024 = life_expectancy
  )

economy_changes <- start_data %>%
  inner_join(
    end_data,
    by = "iso3c"
  ) %>%
  mutate(
    gdp_growth_pct =
      100 * (gdp_2024 / gdp_2000 - 1),
    life_change =
      life_2024 - life_2000
  ) %>%
  arrange(desc(life_change))

cat("Matched economies:",
    nrow(economy_changes), "\n")

print(
  as.data.frame(
    head(economy_changes, 15)
  )
)

# Balanced endpoint comparison: same economies in 2000 and 2024

balanced_comparison <- economy_changes %>%
  summarise(
    economies = n(),
    mean_gdp_2000 = mean(gdp_2000),
    mean_gdp_2024 = mean(gdp_2024),
    mean_life_2000 = mean(life_2000),
    mean_life_2024 = mean(life_2024),
    average_life_gain = mean(life_change)
  )

print(as.data.frame(balanced_comparison))

readr::write_csv(
  balanced_comparison,
  "results/tables/balanced_comparison.csv"
)


# ============================================================
# Step 7: Save Analysis Tables
# ============================================================

cat("\n=== STEP 7: SAVE RESULTS ===\n")

readr::write_csv(
  overall_correlation,
  "results/tables/overall_correlation.csv"
)

readr::write_csv(
  regional_comparison,
  "results/tables/regional_comparison.csv"
)

readr::write_csv(
  yearly_analysis,
  "results/tables/yearly_analysis.csv"
)

readr::write_csv(
  economy_changes,
  "results/tables/economy_changes.csv"
)

cat("All analysis tables saved.\n")

cat("\n=== STEP 4 COMPLETED ===\n")
