#### Preamble ####
# Purpose: Tests the structure and validity of the actual Toronto traffic collisions dataset.
# Author: Rohan Alexander
# Date: 26 November 2024
# Contact: rohan.alexander@utoronto.ca
# License: MIT
# Pre-requisites: 
# - The `tidyverse`, `lubridate`, `sf`, and `testthat` packages must be installed and loaded
# - `clean_data.R` must have been run
# - Ensure you are in the project root directory (`Toronto-Traffic-Collisions`) when running tests

#### Workspace setup ####

library(testthat)
library(tidyverse)
library(lubridate)
library(sf)
library(here)

#### Testing Actual Data ####

# Load the actual data
collisions <- read_csv(here("data", "analysis_data", "collisions_clean.csv"))

# Define indicator columns
indicator_cols <- c("INJURY_COLLISIONS", "FTR_COLLISIONS", "PD_COLLISIONS",
                    "AUTOMOBILE", "MOTORCYCLE", "PASSENGER", "BICYCLE", "PEDESTRIAN")

# Convert indicator variables to factors with levels "NO" and "YES"
collisions <- collisions %>%
  mutate(across(all_of(indicator_cols), ~ factor(.x, levels = c("NO", "YES"))))

# Continue with your tests
context("Testing Actual Data")

test_that("All required columns are present", {
  expected_cols <- c("OCC_DATE", "OCC_YEAR", "OCC_MONTH", "OCC_DOW", "OCC_HOUR",
                     "DIVISION", "FATALITIES", "INJURY_COLLISIONS", "FTR_COLLISIONS",
                     "PD_COLLISIONS", "NEIGHBOURHOOD_NAME", "LONG_WGS84", "LAT_WGS84",
                     "AUTOMOBILE", "MOTORCYCLE", "PASSENGER", "BICYCLE", "PEDESTRIAN")
  expect_true(all(expected_cols %in% names(collisions)))
})

test_that("No missing values in key columns", {
  key_cols <- c("OCC_DATE", "OCC_YEAR", "OCC_MONTH", "OCC_DOW", "OCC_HOUR",
                "LONG_WGS84", "LAT_WGS84")
  for (col in key_cols) {
    expect_false(any(is.na(collisions[[col]])), info = paste("Missing values in", col))
  }
})

test_that("Dates are within expected range", {
  expect_true(all(collisions$OCC_DATE >= as.Date("2014-01-01") & collisions$OCC_DATE <= as.Date("2024-11-26")))
})

test_that("Coordinates are within Toronto bounding box", {
  expect_true(all(collisions$LONG_WGS84 >= -79.6393 & collisions$LONG_WGS84 <= -79.1152))
  expect_true(all(collisions$LAT_WGS84 >= 43.5810 & collisions$LAT_WGS84 <= 43.8555))
})

test_that("Indicator variables are factors with levels NO and YES", {
  for (col in indicator_cols) {
    expect_true(is.factor(collisions[[col]]), info = paste(col, "is not a factor"))
    expect_equal(levels(collisions[[col]]), c("NO", "YES"), info = paste(col, "does not have levels NO and YES"))
  }
})

test_that("FATALITIES are non-negative integers", {
  expect_true(all(collisions$FATALITIES >= 0))
  expect_true(all(collisions$FATALITIES == floor(collisions$FATALITIES)))
})