# Blog Post 7: Does Economic Growth Translate into Longer Lives?

**An Interactive Analysis of GDP per Capita and Life Expectancy, 2000–2024**

## 1. Project Overview

This project examines the association between economic development and population health across economies from 2000 to 2024. Using World Bank World Development Indicators (WDI), it combines an animated Plotly bubble chart with descriptive statistics, correlations, a pooled log-linear regression, regional comparisons, and changes between the first and last years of the study.

**Research question:** How is GDP per capita associated with life expectancy, and how has this relationship evolved across economies and regions between 2000 and 2024?

The analysis is **descriptive, not causal**. Higher income and longer life expectancy are associated, but the methods do not establish that changes in income cause changes in longevity.

## 2. Data Sources and Definitions

Source: [World Bank World Development Indicators](https://databank.worldbank.org/source/world-development-indicators).

| Variable | WDI indicator | Definition and role |
| --- | --- | --- |
| GDP per capita | `NY.GDP.PCAP.PP.KD` | GDP per capita, purchasing power parity (PPP), constant international dollars; horizontal axis and income measure |
| Life expectancy | `SP.DYN.LE00.IN` | Life expectancy at birth, total population, in years; vertical axis and outcome |
| Population | `SP.POP.TOTL` | Total population; determines bubble size |

- **Period:** 2000–2024 (25 years).
- **Initial extraction:** 6,650 entity-year rows from 266 World Bank entities, including aggregates.
- **Cleaned analytic sample:** 4,916 economy-year observations, 199 economies, and seven regions.
- **Panel structure:** Unbalanced; some economy-year observations are unavailable or excluded because of missing/invalid values.
- **Regional and yearly means:** Unweighted averages over the available economy-year observations, not population-weighted estimates.

The raw and cleaned CSV files are kept separately so that the data preparation can be inspected.

## 3. Repository Structure

The analysis project is organized as follows:

```text
Blog7/
├── code/
│   ├── 01_load_data.R
│   ├── 02_clean_data.R
│   ├── 03_plotly_visualization.R
│   └── 04_economic_analysis.R
├── data-raw/
│   └── wdi_raw.csv
├── data/
│   └── wdi_clean.csv
├── results/
│   ├── figures/
│   │   └── gdp_life_interactive.html
│   └── tables/
│       ├── data_quality.csv
│       ├── year_coverage.csv
│       ├── overall_summary.csv
│       ├── regional_summary.csv
│       ├── regression_results.csv
│       ├── overall_correlation.csv
│       ├── regional_comparison.csv
│       ├── yearly_analysis.csv
│       ├── economy_changes.csv
│       └── balanced_comparison.csv
├── index.qmd
└── README.md
```

The published website uses a separate post directory:

```text
mywebsite/
└── blog/
    └── posts/
        └── post7/
            ├── index.qmd
            └── data/
                └── wdi_clean.csv
```

**Important:** The current `post7/index.qmd` generates the Plotly chart directly from `data/wdi_clean.csv` during Quarto rendering. The standalone `Blog7/results/figures/gdp_life_interactive.html` is an additional output of the visualization script; the blog does not need an iframe to load it. The CSV file must exist *inside* `mywebsite/blog/posts/post7/data/` when rendering that post.

## 4. Software Requirements

- R and RStudio (recommended for running and inspecting the scripts).
- [Quarto](https://quarto.org/) to render the `.qmd` blog post.
- R packages used in the documented workflow: `tidyverse`, `WDI`, `plotly`, `htmlwidgets`, `htmltools`, and `knitr`. The blog visualization explicitly loads `plotly`, `readr`, and `dplyr` (the latter two are included in `tidyverse`).

Install the listed packages in the R console:

```r
install.packages(c(
  "tidyverse",
  "WDI",
  "plotly",
  "htmlwidgets",
  "htmltools",
  "knitr"
))
```

If a script reports an additional missing package, install the package named in that error. Internet access may be required when the WDI API is queried in the data-loading step.

## 5. Reproduce the Data and Analysis

### Step 1 — Obtain the project

Download or clone the repository containing the complete `Blog7/` directory. Preserve the relative folder structure shown above. In particular, keep `code/`, `data-raw/`, `data/`, and `results/` together.

### Step 2 — Set the working directory

Open RStudio and set the working directory to the **`Blog7/` project root**, not to `Blog7/code/`:

```r
# Replace this example path if the project is stored elsewhere.
setwd("/path/to/your/Blog7")
getwd()
```

The scripts use project-relative file paths. Running them from the wrong directory can produce file-not-found errors.

### Step 3 — Run the scripts in order

```r
source("code/01_load_data.R")
source("code/02_clean_data.R")
source("code/03_plotly_visualization.R")
source("code/04_economic_analysis.R")
```

| Script | Purpose | Main expected outputs |
| --- | --- | --- |
| `01_load_data.R` | Retrieve and inspect WDI indicators for 2000–2024 | `data-raw/wdi_raw.csv` |
| `02_clean_data.R` | Exclude aggregates, handle missing/invalid observations, prepare analysis variables | `data/wdi_clean.csv` and data-quality/coverage tables |
| `03_plotly_visualization.R` | Create an animated, interactive bubble chart with year, income, longevity, population, and region | `results/figures/gdp_life_interactive.html` |
| `04_economic_analysis.R` | Calculate summary statistics, correlations, regression estimates, regional and temporal comparisons | CSV files in `results/tables/` |

The cleaned dataset includes the fields used in the Quarto visualization: `country`, `iso3c`, `year`, `region`, `gdp_per_capita`, `life_expectancy`, `population`, `population_millions`, and `log_gdp_per_capita`.

### Step 4 — Check the outputs

After running the scripts, verify that the cleaned CSV and the interactive HTML were created:

```r
file.exists("data/wdi_clean.csv")
file.exists("results/figures/gdp_life_interactive.html")

wdi <- readr::read_csv("data/wdi_clean.csv", show_col_types = FALSE)
nrow(wdi)
dplyr::n_distinct(wdi$iso3c)
range(wdi$year)
```

For the dataset used in the accompanying analysis, these checks should report **4,916 rows**, **199 distinct economies**, and years **2000 through 2024**. If the WDI source is updated, results from a fresh API download may differ from the archived CSV files.

### Step 5 — Render the blog post in `mywebsite`

The website version of the post is located at `mywebsite/blog/posts/post7/index.qmd`. Its embedded R code reads `data/wdi_clean.csv` relative to the **post directory**, so first copy the cleaned data into that directory.

From a terminal in the `AEDS_6400/` parent directory:

```bash
mkdir -p mywebsite/blog/posts/post7/data
cp Blog7/data/wdi_clean.csv mywebsite/blog/posts/post7/data/wdi_clean.csv
```

Then render from the website project root:

```bash
cd mywebsite
quarto render blog/posts/post7/index.qmd --to html
```

To preview locally:

```bash
quarto preview blog/posts/post7/index.qmd --to html
```

The Plotly widget is created by the R chunk inside `post7/index.qmd`. It supports hovering over bubbles, region legend interaction, and a year animation with a slider and Play button.

**Do not run the website post from an arbitrary directory and assume it can read `Blog7/data/wdi_clean.csv`.** The `post7/data/` copy is required by the current code.

## 6. Verify the Reported Results

The following checks independently reproduce the central numerical findings using the **archived cleaned dataset**. Run them from the `Blog7/` project root after completing the scripts in Section 5. Results may differ when the World Bank revises its historical data.

### Step 6A — Confirm the analysis sample

```r
library(readr)
library(dplyr)
wdi <- read_csv("data/wdi_clean.csv", show_col_types = FALSE)

stopifnot(nrow(wdi) == 4916)
stopifnot(n_distinct(wdi$iso3c) == 199)
stopifnot(n_distinct(wdi$region) == 7)
stopifnot(identical(range(as.integer(wdi$year), na.rm = TRUE), c(2000L, 2024L)))
```

These checks confirm 4,916 economy-year observations, 199 economies, seven regions, and the 2000–2024 observation range. The panel is unbalanced; it does not contain 199 observations in every year.

### Step 6B — Reproduce the correlations

```r
cor(wdi$gdp_per_capita, wdi$life_expectancy, use = "complete.obs")
cor(log(wdi$gdp_per_capita), wdi$life_expectancy, use = "complete.obs")
```

Expected correlations are approximately **0.673** and **0.825**, respectively. The log transformation is applied to strictly positive GDP per capita observations in the cleaned sample.

### Step 6C — Reproduce the pooled log-linear regression

```r
model <- lm(life_expectancy ~ log(gdp_per_capita), data = wdi)
summary(model)
coef(model)
summary(model)$r.squared
unname(coef(model)[2] * log(2))
```

Expected estimates are an intercept of approximately **12.867**, a slope of **6.093** on log GDP per capita, an R-squared of **0.681**, and an implied association of **4.22 years** for a doubling of GDP per capita. This is a pooled descriptive regression, **not** a causal estimate. Its conventional standard errors do not account for clustering within economies.

### Step 6D — Reproduce the matched 2000–2024 comparison

```r
endpoints <- wdi %>%
  filter(year %in% c(2000, 2024)) %>%
  select(iso3c, year, gdp_per_capita, life_expectancy) %>%
  filter(!is.na(gdp_per_capita), !is.na(life_expectancy))

matched_ids <- endpoints %>%
  group_by(iso3c) %>%
  filter(n_distinct(year) == 2) %>%
  ungroup()

matched_ids %>%
  group_by(year) %>%
  summarise(
    economies = n_distinct(iso3c),
    mean_gdp_pc = mean(gdp_per_capita),
    mean_life_expectancy = mean(life_expectancy),
    .groups = "drop"
  )
```

The archived analysis reports **189 matched economies**. Their mean GDP per capita is approximately **18,756.75** in 2000 and **27,003.36** in 2024; mean life expectancy is **66.94** and **73.55** years, respectively. The corresponding changes are approximately **+44.0%** in mean GDP per capita and **+6.61 years** in mean life expectancy. Matching endpoints does not require complete data for intervening years.

### Step 6E — Inspect regional, annual, and economy-level outputs

```r
read_csv("results/tables/regional_comparison.csv", show_col_types = FALSE)
read_csv("results/tables/yearly_analysis.csv", show_col_types = FALSE)
read_csv("results/tables/economy_changes.csv", show_col_types = FALSE)
read_csv("results/tables/balanced_comparison.csv", show_col_types = FALSE)
read_csv("results/tables/regression_results.csv", show_col_types = FALSE)
```

Compare these exported tables with the regional means, pandemic-era life expectancy change, and economy examples reported in the blog. In particular, the blog reports average life expectancy of **72.72** years in 2019, **71.47** in 2021, and **73.66** in 2024, based on the available unweighted observations in each year. These annual samples may differ in composition.

### Step 6F — Check the interactive figure

```r
file.exists("results/figures/gdp_life_interactive.html")
```

Open `results/figures/gdp_life_interactive.html` in a browser and verify the logarithmic GDP-per-capita x-axis, life-expectancy y-axis, population-sized bubbles, region colors, hover labels, and year slider / Play button. To reproduce the version embedded in the website, complete Step 5 above and inspect the rendered `post7/index.html`.

**Reproduction standard:** Use the archived `data-raw/wdi_raw.csv` and `data/wdi_clean.csv` to check the original reported numbers; a new live WDI API download may differ due to source revisions. The project has not been independently executed in a fresh environment as part of preparing this README.

## 7. Key Results

The reported results are calculated from the cleaned 2000–2024 dataset:

| Measure | Result |
| --- | ---: |
| Pearson correlation: GDP per capita vs. life expectancy | 0.673 |
| Pearson correlation: log GDP per capita vs. life expectancy | 0.825 |
| Pooled regression slope on log GDP per capita | 6.093 |
| Pooled regression R-squared | 0.681 |
| Estimated association for a doubling of GDP per capita | Approximately 4.22 additional years of life expectancy |
| Economies with data in both 2000 and 2024 | 189 |
| Mean GDP per capita change for those 189 economies | Approximately +44.0% |
| Mean life expectancy change for those 189 economies | Approximately +6.61 years |

The regression is a pooled descriptive model:

```text
life_expectancy = alpha + beta * log(gdp_per_capita) + error
```

Its conventional uncertainty estimates do not account for possible serial dependence within economies. The analysis also does not adjust for all relevant confounders or establish causal effects.

## 8. Interpretation and Limitations

The positive global association coexists with large regional differences and economy-specific exceptions. For example, some economies recorded substantial life expectancy improvements without similarly large increases in measured GDP per capita. Average life expectancy also declined during the COVID-19 period before recovering.

The findings should be read with these limitations in mind:

1. **Association, not causation:** Reverse causality and omitted variables may affect the relationship.
2. **Unbalanced panel:** Data availability differs across economies and years.
3. **Unweighted summaries:** Regional and yearly averages are not population-weighted.
4. **Pooled regression:** Between-economy and within-economy variation are combined, and conventional standard errors may understate uncertainty.
5. **Endpoint comparison:** The 189-economy comparison requires observations in both 2000 and 2024; it does **not** imply complete data for every intervening year.
6. **Source revisions:** WDI series may be revised after the data were downloaded.

## 9. Troubleshooting

**`'data/wdi_clean.csv' does not exist` when rendering `post7/index.qmd`:**

The file is missing from `mywebsite/blog/posts/post7/data/`. Copy it from `Blog7/data/` as shown in Step 5, then rerun Quarto.

**`there is no package called ...`:**

Install the named R package and retry.

**Plotly chart does not appear after a successful render:**

Check the browser console for JavaScript errors, confirm the R chunk executed, and inspect the rendered HTML. The current post should render the Plotly widget directly, not via an iframe referencing the standalone HTML file.

**Unexpected changes in observation counts or estimates:**

Compare the downloaded data with the archived `data-raw/wdi_raw.csv` and `data/wdi_clean.csv`. World Bank indicator data may change with revisions or updates.

## 10. Publishing and Repository Completeness

Before publishing or submitting, confirm that the repository includes the actual files, not only empty folders or a directory listing:

- All four R scripts in `code/`.
- Raw and cleaned CSV data in `data-raw/` and `data/`.
- The standalone interactive visualization in `results/figures/`.
- All analysis tables in `results/tables/`.
- The website post's `index.qmd` and its required `post7/data/wdi_clean.csv`.
- This `README.md`.

If Git ignores CSV files, inspect the applicable `.gitignore` rules and explicitly add the intended data files before committing. Do not publish only the HTML page while omitting the data needed to regenerate it.

## 11. References

- World Bank. [World Development Indicators](https://databank.worldbank.org/source/world-development-indicators).
- World Bank. [GDP per capita, PPP (constant international dollars)](https://data.worldbank.org/indicator/NY.GDP.PCAP.PP.KD), indicator `NY.GDP.PCAP.PP.KD`.
- World Bank. [Life expectancy at birth, total (years)](https://data.worldbank.org/indicator/SP.DYN.LE00.IN), indicator `SP.DYN.LE00.IN`.
- World Bank. [Population, total](https://data.worldbank.org/indicator/SP.POP.TOTL), indicator `SP.POP.TOTL`.
- Plotly. [Plotly R documentation](https://plotly.com/r/).
- Quarto. [Quarto documentation](https://quarto.org/docs/).
