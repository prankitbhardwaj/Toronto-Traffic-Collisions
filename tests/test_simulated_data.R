#### Preamble ####
# Purpose: Tests the structure and validity of the simulated Toronto traffic collisions dataset.
# Author: Rohan Alexander
# Date: 26 November 2024
# Contact: rohan.alexander@utoronto.ca
# License: MIT
# Pre-requisites: 
# - The `tidyverse`, `lubridate`, `sf`, and `testthat` packages must be installed and loaded
# - `simulate_data.R` and `clean_data.R` must have been run
# - Ensure you are in the project root directory (`Toronto-Traffic-Collisions`) when running tests

#### Workspace setup ####

library(testthat)
library(tidyverse)
library(lubridate)
library(sf)
library(here)

#### Testing Simulated Data ####

# Load the simulated data
simulate_data <- read_csv(here("data", "simulated_data", "simulated_collisions.csv"))

# Convert indicator variables to factors
indicator_cols <- c("INJURY_COLLISIONS", "FTR_COLLISIONS", "PD_COLLISIONS",
                    "AUTOMOBILE", "MOTORCYCLE", "BICYCLE", "PEDESTRIAN")

simulate_data <- simulate_data %>%
  mutate(across(all_of(indicator_cols), ~ factor(.x, levels = c("NO", "YES"))))

# Continue with your tests
context("Testing Simulated Data")

test_that("All required columns are present", {
  expected_cols <- c("OCC_DATE", "OCC_YEAR", "OCC_MONTH", "OCC_DOW", "OCC_HOUR",
                     "DIVISION", "FATALITIES", "INJURY_COLLISIONS", "FTR_COLLISIONS",
                     "PD_COLLISIONS", "NEIGHBOURHOOD_NAME", "LONG_WGS84", "LAT_WGS84",
                     "AUTOMOBILE", "MOTORCYCLE", "BICYCLE", "PEDESTRIAN")
  expect_true(all(expected_cols %in% names(simulate_data)))
})

# ... other tests ...

test_that("Indicator variables are factors with levels NO and YES", {
  for (col in indicator_cols) {
    expect_true(is.factor(simulate_data[[col]]), info = paste(col, "is not a factor"))
    expect_equal(levels(simulate_data[[col]]), c("NO", "YES"), info = paste(col, "does not have levels NO and YES"))
  }
})

test_that("No missing values in key columns", {
  key_cols <- c("OCC_DATE", "OCC_YEAR", "OCC_MONTH", "OCC_DOW", "OCC_HOUR",
                "LONG_WGS84", "LAT_WGS84")
  for (col in key_cols) {
    expect_false(any(is.na(simulate_data[[col]])), info = paste("Missing values in", col))
  }
})

test_that("Dates are within expected range", {
  expect_true(all(simulate_data$OCC_DATE >= as.Date("2014-01-01") & simulate_data$OCC_DATE <= as.Date("2024-11-26")))
})

test_that("Coordinates are within Toronto bounding box", {
  expect_true(all(simulate_data$LONG_WGS84 >= -79.6393 & simulate_data$LONG_WGS84 <= -79.1152))
  expect_true(all(simulate_data$LAT_WGS84 >= 43.5810 & simulate_data$LAT_WGS84 <= 43.8555))
})

test_that("Injury collisions are YES when vulnerable road users are involved", {
  vulnerable_involved <- simulate_data %>%
    filter(MOTORCYCLE == "YES" | BICYCLE == "YES" | PEDESTRIAN == "YES")
  
  expect_true(all(vulnerable_involved$INJURY_COLLISIONS == "YES"))
})

test_that("FATALITIES are 0 or 1", {
  expect_true(all(simulate_data$FATALITIES %in% c(0, 1)))
})

test_that("Indicator variables are factors with levels NO and YES", {
  indicator_cols <- c("INJURY_COLLISIONS", "FTR_COLLISIONS", "PD_COLLISIONS",
                      "AUTOMOBILE", "MOTORCYCLE", "BICYCLE", "PEDESTRIAN")
  for (col in indicator_cols) {
    expect_true(is.factor(simulate_data[[col]]))
    expect_true(all(levels(simulate_data[[col]]) == c("NO", "YES")))
  }
})