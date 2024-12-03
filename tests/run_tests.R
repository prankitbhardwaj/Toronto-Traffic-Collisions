# run_tests.R

# Load necessary library
library(testthat)
library(here)

# Load the cleaned data
collisions <- read_csv(here("data", "analysis_data", "collisions_clean.csv"))

# Run tests for simulated data
test_file(here("tests", "test_simulated_data.R"))

# Run tests for actual data
test_file(here("tests", "test_analysis_data.R"))

# Alternatively, run all tests in the 'tests' directory
# test_dir(here("tests"))