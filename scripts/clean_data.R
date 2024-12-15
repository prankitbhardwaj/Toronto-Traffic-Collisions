#### Preamble ####
# Purpose: Cleans the raw traffic collision data recorded by the Toronto Police Service.
# Author: Rohan Alexander
# Date: 6 April 2023
# Contact: rohan.alexander@utoronto.ca
# License: MIT
# Pre-requisites: The `tidyverse`, `lubridate`, `sf`, `here`, and `arrow` packages must be installed.
# Any other information needed? Ensure you are in the project root directory.

#### Workspace setup ####

# Load necessary libraries
library(tidyverse)
library(lubridate)
library(sf)
library(here)
library(arrow)

# Set file paths using 'here' for consistency
collisions_csv <- here("data", "raw_data", "collisions.csv")
neighbourhoods_csv <- here("data", "raw_data", "neighbourhoods.csv")
neighbourhoods_geojson <- here("data", "raw_data", "neighbourhoods.geojson")

# Load the collisions data
collisions <- read_csv(collisions_csv)

# Print the structure of the raw data
cat("Structure of raw collisions data:\n")
str(collisions)
cat("\n")

# Load the neighbourhoods data
# Use GeoJSON if spatial analysis is required
if (file.exists(neighbourhoods_geojson)) {
  neighbourhoods <- st_read(neighbourhoods_geojson, quiet = TRUE)
} else {
  neighbourhoods <- read_csv(neighbourhoods_csv)
}

# Print the structure of the neighbourhoods data
cat("Structure of neighbourhoods data:\n")
str(neighbourhoods)
cat("\n")

#### Data Cleaning for Collisions Dataset ####

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
  if ("NEIGHBOURHOOD_NAME" %in% names(collisions)) {
    collisions <- collisions %>%
      mutate(
        NEIGHBOURHOOD_NAME = str_trim(NEIGHBOURHOOD_NAME)
      )
  } else {
    stop("NEIGHBOURHOOD_NAME column does not exist and NEIGHBOURHOOD_158 is also missing.")
  }
}

# Remove rows with missing or zero coordinates
collisions <- collisions %>%
  filter(!is.na(LONG_WGS84) & !is.na(LAT_WGS84)) %>%
  filter(LONG_WGS84 != 0 & LAT_WGS84 != 0)

# Verify data after filtering
cat("Data after filtering missing and zero coordinates:\n")
str(collisions)
cat("\n")

# Define indicator columns
indicator_cols <- c("INJURY_COLLISIONS", "FTR_COLLISIONS", "PD_COLLISIONS",
                    "AUTOMOBILE", "MOTORCYCLE", "PASSENGER", "BICYCLE", "PEDESTRIAN")

# Check if all indicator columns exist
missing_cols <- setdiff(indicator_cols, names(collisions))
if (length(missing_cols) > 0) {
  stop(paste("The following indicator columns are missing in collisions data:", paste(missing_cols, collapse = ", ")))
}

# Standardize values to "NO" and "YES"
collisions <- collisions %>%
  mutate(across(all_of(indicator_cols), ~ case_when(
    toupper(.x) == "YES" ~ "YES",
    toupper(.x) == "NO" ~ "NO",
    TRUE ~ "NO"  # Handle NA and any other unexpected values
  )))

# Verify standardization
for (col in indicator_cols) {
  cat("After standardization, unique values in", col, ":\n")
  print(unique(collisions[[col]]))
  cat("\n")
}

# Convert indicator variables to factors with levels "NO" and "YES"
collisions <- collisions %>%
  mutate(across(all_of(indicator_cols), ~ factor(.x, levels = c("NO", "YES"))))

# Verify conversion to factors
for (col in indicator_cols) {
  cat("After conversion to factor, class of", col, ":", class(collisions[[col]]), "\n")
  print(levels(collisions[[col]]))
  cat("\n")
}

#### Data Cleaning for Neighbourhoods Dataset ####

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

#### Save Cleaned Data ####

# Ensure the 'analysis_data' directory exists
if (!dir.exists(here("data", "analysis_data"))) {
  dir.create(here("data", "analysis_data"), recursive = TRUE)
}

# Save cleaned collisions data as CSV and Parquet
write_csv(collisions, here("data", "analysis_data", "collisions_clean.csv"))
write_parquet(collisions, here("data", "analysis_data", "collisions_clean.parquet"))

# Save cleaned neighbourhoods data
if (exists("neighbourhoods")) {
  if (inherits(neighbourhoods, "sf")) {
    st_write(neighbourhoods, here("data", "analysis_data", "neighbourhoods_clean.geojson"), delete_dsn = TRUE, quiet = TRUE)
  } else {
    write_csv(neighbourhoods, here("data", "analysis_data", "neighbourhoods_clean.csv"))
  }
}

# Print message
message("Data cleaning completed successfully, and cleaned data saved as CSV and Parquet.")
