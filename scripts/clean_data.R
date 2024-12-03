#### Preamble ####
# Purpose: Cleans the raw plane data recorded by two observers..... [...UPDATE THIS...]
# Author: Rohan Alexander [...UPDATE THIS...]
# Date: 6 April 2023 [...UPDATE THIS...]
# Contact: rohan.alexander@utoronto.ca [...UPDATE THIS...]
# License: MIT
# Pre-requisites: [...UPDATE THIS...]
# Any other information needed? [...UPDATE THIS...]

# clean_data.R

# Load necessary libraries
library(tidyverse)
library(lubridate)
library(sf)
library(here)

# Set file paths
collisions_csv <- here("data", "raw_data", "collisions.csv")
neighbourhoods_csv <- here("data", "raw_data", "neighbourhoods.csv")
neighbourhoods_geojson <- here("data", "raw_data", "neighbourhoods.geojson")

# Load the collisions data
collisions <- read_csv(collisions_csv)

# Load the neighbourhoods data
# Use GeoJSON if spatial analysis is required
if (file.exists(neighbourhoods_geojson)) {
  neighbourhoods <- st_read(neighbourhoods_geojson)
} else {
  neighbourhoods <- read_csv(neighbourhoods_csv)
}

# Data Cleaning for Collisions Dataset
# ------------------------------------

# Convert OCC_DATE from milliseconds to POSIXct
collisions <- collisions %>%
  mutate(
    OCC_DATE = as.POSIXct(OCC_DATE / 1000, origin = "1970-01-01", tz = "UTC"),
    OCC_YEAR = year(OCC_DATE),
    OCC_MONTH = month(OCC_DATE, label = TRUE, abbr = FALSE),
    OCC_DOW = wday(OCC_DATE, label = TRUE, abbr = FALSE),
    OCC_HOUR = hour(OCC_DATE)
  )

# Handle missing values in FATALITIES
collisions <- collisions %>%
  mutate(
    FATALITIES = replace_na(FATALITIES, 0)
  )

# Extract NEIGHBOURHOOD_NAME from NEIGHBOURHOOD_158 (if it exists)
if ("NEIGHBOURHOOD_158" %in% names(collisions)) {
  collisions <- collisions %>%
    mutate(
      NEIGHBOURHOOD_NAME = str_extract(NEIGHBOURHOOD_158, "^[^(]+") %>% str_trim()
    )
} else {
  # If NEIGHBOURHOOD_NAME already exists, ensure it's clean
  collisions <- collisions %>%
    mutate(
      NEIGHBOURHOOD_NAME = str_trim(NEIGHBOURHOOD_NAME)
    )
}

# Remove rows with missing or zero coordinates
collisions <- collisions %>%
  filter(!is.na(LONG_WGS84) & !is.na(LAT_WGS84)) %>%
  filter(LONG_WGS84 != 0 & LAT_WGS84 != 0)

# Standardize and convert indicator variables
indicator_cols <- c("INJURY_COLLISIONS", "FTR_COLLISIONS", "PD_COLLISIONS",
                    "AUTOMOBILE", "MOTORCYCLE", "PASSENGER", "BICYCLE", "PEDESTRIAN")

# Standardize values to "NO" and "YES"
collisions <- collisions %>%
  mutate(across(all_of(indicator_cols), ~ case_when(
    toupper(.x) == "YES" ~ "YES",
    toupper(.x) == "NO" ~ "NO",
    TRUE ~ "NO"  # Handle NA and any other unexpected values
  )))

# Convert indicator variables to factors with levels "NO" and "YES"
collisions <- collisions %>%
  mutate(across(all_of(indicator_cols), ~ factor(.x, levels = c("NO", "YES"))))

# Data Cleaning for Neighbourhoods Dataset
# ----------------------------------------

if (exists("neighbourhoods")) {
  if (inherits(neighbourhoods, "sf")) {
    # Neighbourhoods data is spatial
    # Ensure coordinate reference system is consistent
    neighbourhoods <- st_transform(neighbourhoods, crs = 4326)
    # Standardize AREA_NAME
    neighbourhoods <- neighbourhoods %>%
      mutate(
        AREA_NAME = str_trim(AREA_NAME)
      )
  } else {
    # Neighbourhoods data is not spatial
    # Clean as per non-spatial data
    neighbourhoods <- neighbourhoods %>%
      mutate(
        AREA_NAME = str_trim(AREA_NAME),
        AREA_DESC = str_trim(AREA_DESC)
      )
  }
}

# Save Cleaned Data
# -----------------

# Ensure the 'analysis_data' directory exists
if (!dir.exists(here("data", "analysis_data"))) {
  dir.create(here("data", "analysis_data"), recursive = TRUE)
}

# Save cleaned collisions data
write_csv(collisions, here("data", "analysis_data", "collisions_clean.csv"))

# Save cleaned neighbourhoods data
if (inherits(neighbourhoods, "sf")) {
  st_write(neighbourhoods, here("data", "analysis_data", "neighbourhoods_clean.geojson"), delete_dsn = TRUE)
} else {
  write_csv(neighbourhoods, here("data", "analysis_data", "neighbourhoods_clean.csv"))
}

# Print message
message("Data cleaning completed successfully.")
