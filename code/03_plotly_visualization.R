
# ============================================================
# Blog Post 7: GDP per Capita and Life Expectancy
# 03 - Interactive Data Visualization with Plotly
#
# Data Source: World Bank WDI
# Period: 2000-2024
#
# Research Question:
# Does higher GDP per capita correspond to longer
# life expectancy across economies and over time?
#
# Purpose:
# 1. Load cleaned WDI data
# 2. Prepare variables for visualization
# 3. Create an animated bubble chart
# 4. Add regional colors and country hover information
# 5. Add interactive year animation
# 6. Improve layout and readability
# 7. Export an interactive HTML file
# 8. Validate output
# ============================================================


# ============================================================
# Step 1: Load Packages and Data
# ============================================================

cat("\n=== STEP 1: LOAD DATA ===\n")

packages <- c(
  "tidyverse",
  "plotly",
  "htmlwidgets",
  "scales"
)

missing_packages <- packages[
  !vapply(
    packages,
    requireNamespace,
    logical(1),
    quietly = TRUE
  )
]

if (length(missing_packages) > 0) {
  install.packages(missing_packages)
}

invisible(lapply(
  packages,
  library,
  character.only = TRUE
))

wdi_clean <- readr::read_csv(
  "data/wdi_clean.csv",
  show_col_types = FALSE
)

cat("Observations:", nrow(wdi_clean), "\n")

cat(
  "Economies:",
  dplyr::n_distinct(wdi_clean$iso3c),
  "\n"
)

cat(
  "Years:",
  dplyr::n_distinct(wdi_clean$year),
  "\n"
)


# ============================================================
# Step 2: Validate and Prepare Data
# ============================================================

cat("\n=== STEP 2: PREPARE DATA ===\n")

required_columns <- c(
  "country",
  "iso3c",
  "year",
  "region",
  "gdp_per_capita",
  "life_expectancy",
  "population"
)

stopifnot(
  all(required_columns %in% names(wdi_clean))
)

plot_data <- wdi_clean %>%
  filter(
    !is.na(country),
    !is.na(iso3c),
    !is.na(region),
    !is.na(gdp_per_capita),
    !is.na(life_expectancy),
    !is.na(population),
    gdp_per_capita > 0,
    life_expectancy > 0,
    population > 0
  ) %>%
  mutate(
    year = as.integer(year),
    country = as.character(country),
    region = as.character(region),
    population_millions = population / 1000000
  ) %>%
  arrange(year, region, country)

duplicate_count <- plot_data %>%
  count(iso3c, year) %>%
  filter(n > 1) %>%
  nrow()

if (duplicate_count > 0) {
  stop("Duplicate economy-year records found.")
}

cat("Plot observations:", nrow(plot_data), "\n")


# ============================================================
# Step 3: Create Hover Information
# ============================================================

cat("\n=== STEP 3: CREATE HOVER TEXT ===\n")

plot_data <- plot_data %>%
  mutate(
    hover_text = paste0(
      "<b>", country, "</b>",
      "<br>Year: ", year,
      "<br>Region: ", region,
      "<br>GDP per capita (PPP): $",
      scales::comma(round(gdp_per_capita)),
      "<br>Life expectancy: ",
      round(life_expectancy, 1),
      " years",
      "<br>Population: ",
      scales::comma(population)
    )
  )


# ============================================================
# Step 4: Create Population Bubble Sizes
# ============================================================

cat("\n=== STEP 4: SCALE POPULATION ===\n")

# Plotly marker.size represents bubble diameter.
# Using sqrt(population) makes bubble area approximately
# proportional to population before the visual cap.
#
# The transformation compresses extreme population sizes
# so that smaller economies remain visible.

max_population <- max(plot_data$population)

plot_data <- plot_data %>%
  mutate(
    bubble_size = 5 +
      45 * sqrt(population / max_population)
  )

cat(
  "Bubble diameter range:",
  round(min(plot_data$bubble_size), 2),
  "-",
  round(max(plot_data$bubble_size), 2),
  "\n"
)


# ============================================================
# Step 5: Define Regional Colors
# ============================================================

cat("\n=== STEP 5: REGION COLORS ===\n")

region_colors <- c(
  "East Asia & Pacific" = "#1f77b4",
  "Europe & Central Asia" = "#ff7f0e",
  "Latin America & Caribbean" = "#2ca02c",
  "Middle East, North Africa, Afghanistan & Pakistan" =
    "#d62728",
  "North America" = "#9467bd",
  "South Asia" = "#8c564b",
  "Sub-Saharan Africa" = "#e377c2"
)

region_names <- names(region_colors)

unknown_regions <- setdiff(
  unique(plot_data$region),
  region_names
)

if (length(unknown_regions) > 0) {
  stop(
    "Unknown regions: ",
    paste(unknown_regions, collapse = ", ")
  )
}


# ============================================================
# Step 6: Create Animated Bubble Chart
# ============================================================

cat("\n=== STEP 6: CREATE PLOTLY CHART ===\n")

# Use plotly directly rather than ggplotly.
# Build separate regional traces for stable legend colors.
#
# We use add_markers() with marker.size explicitly
# instead of the high-level size mapping.
#
# No line.width parameter is supplied.

interactive_plot <- plot_ly(
  width = 1200,
  height = 850
)

for (region_name in region_names) {
  
  region_data <- plot_data %>%
    filter(region == region_name)
  
  interactive_plot <- interactive_plot %>%
    add_markers(
      data = region_data,
      x = ~gdp_per_capita,
      y = ~life_expectancy,
      frame = ~year,
      ids = ~iso3c,
      text = ~hover_text,
      hoverinfo = "text",
      name = region_name,
      legendgroup = region_name,
      showlegend = TRUE,
      marker = list(
        color = unname(region_colors[region_name]),
        size = region_data$bubble_size,
        opacity = 0.70,
        sizemode = "diameter"
      )
    )
}


# ============================================================
# Step 7: Customize Layout
# ============================================================

cat("\n=== STEP 7: CUSTOMIZE LAYOUT ===\n")

# Keep both axes fixed throughout the animation.
# Plotly log-axis ranges use log10 coordinates.

gdp_limits <- range(
  plot_data$gdp_per_capita,
  na.rm = TRUE
)

x_limits <- log10(gdp_limits)

interactive_plot <- interactive_plot %>%
  layout(
    
    title = list(
      text = paste0(
        "Does Economic Growth Translate ",
        "into Longer Lives?",
        "<br><sup>",
        "World Bank WDI | 2000-2024",
        "</sup>"
      ),
      x = 0.5,
      xanchor = "center",
      font = list(size = 22)
    ),
    
    xaxis = list(
      title = list(
        text = "GDP per capita, PPP (log scale)",
        standoff = 15
      ),
      type = "log",
      range = x_limits,
      tickvals = c(
        500, 1000, 2000, 5000,
        10000, 20000, 50000,
        100000, 200000
      ),
      ticktext = c(
        "$500", "$1k", "$2k", "$5k",
        "$10k", "$20k", "$50k",
        "$100k", "$200k"
      ),
      gridcolor = "#E5E5E5",
      zeroline = FALSE,
      automargin = TRUE
    ),
    
    yaxis = list(
      title = list(
        text = "Life expectancy at birth (years)",
        standoff = 15
      ),
      range = c(10, 90),
      dtick = 10,
      gridcolor = "#E5E5E5",
      zeroline = FALSE,
      automargin = TRUE
    ),
    
    legend = list(
      title = list(
        text = "World Bank Region"
      ),
      orientation = "h",
      x = 0.5,
      xanchor = "center",
      y = -0.43,
      yanchor = "top",
      font = list(size = 11)
    ),
    
    hovermode = "closest",
    
    paper_bgcolor = "white",
    plot_bgcolor = "white",
    
    font = list(
      family = "Arial",
      size = 13,
      color = "#333333"
    ),
    
    margin = list(
      l = 100,
      r = 50,
      b = 280,
      t = 110
    )
  )


# ============================================================
# Step 8: Configure Animation
# ============================================================

cat("\n=== STEP 8: CONFIGURE ANIMATION ===\n")

interactive_plot <- interactive_plot %>%
  animation_opts(
    frame = 900,
    transition = 350,
    easing = "linear",
    redraw = FALSE
  ) %>%
  animation_slider(
    currentvalue = list(
      prefix = "Year: ",
      font = list(size = 16)
    ),
    x = 0.12,
    len = 0.83,
    y = -0.20,
    pad = list(t = 30, b = 10)
  ) %>%
  animation_button(
    x = 0,
    xanchor = "left",
    y = -0.20,
    yanchor = "top"
  )


# ============================================================
# Step 9: Display Interactive Plot
# ============================================================

cat("\n=== STEP 9: DISPLAY PLOT ===\n")

interactive_plot


# ============================================================
# Step 10: Export Interactive HTML
# ============================================================

cat("\n=== STEP 10: EXPORT HTML ===\n")

output_file <- paste0(
  "results/figures/",
  "gdp_life_interactive.html"
)

htmlwidgets::saveWidget(
  widget = interactive_plot,
  file = output_file,
  selfcontained = TRUE
)

cat("Saved:", output_file, "\n")


# ============================================================
# Step 11: Validate Export
# ============================================================

cat("\n=== STEP 11: VALIDATION ===\n")

if (!file.exists(output_file)) {
  stop("HTML export failed.")
}

file_size <- file.info(output_file)$size

cat(
  "HTML file size (MB):",
  round(file_size / 1024^2, 2),
  "\n"
)

cat(
  "Number of animation years:",
  n_distinct(plot_data$year),
  "\n"
)

cat(
  "Number of regions:",
  n_distinct(plot_data$region),
  "\n"
)

cat(
  "Number of economies:",
  n_distinct(plot_data$iso3c),
  "\n"
)

cat("\n=== STEP 3 COMPLETED ===\n")

browseURL(
  normalizePath(
    "results/figures/gdp_life_interactive.html"
  )
)
