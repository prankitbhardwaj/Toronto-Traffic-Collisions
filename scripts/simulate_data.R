#### Preamble ####
# Purpose: Simulates a dataset of Australian electoral divisions, including the 
  #state and party that won each division.
# Author: Rohan Alexander
# Date: 26 September 2024
# Contact: rohan.alexander@utoronto.ca
# License: MIT
# Pre-requisites: The `tidyverse` package must be installed
# Any other information needed? Make sure you are in the `starter_folder` rproj


#### Workspace setup ####
# simulate_data.R

# Load necessary libraries
library(tidyverse)
library(lubridate)
library(dplyr)
library(MASS)

# Set seed for reproducibility
set.seed(123)

# Define number of observations
n <- 100000  # Adjust as needed

# Simulate date and time
start_date <- as.Date("2014-01-01")
end_date <- as.Date("2024-11-26")  # Up to the latest data refresh date

date_sequence <- seq.Date(start_date, end_date, by = "day")
OCC_DATE <- sample(date_sequence, n, replace = TRUE)

OCC_YEAR <- year(OCC_DATE)
OCC_MONTH <- month(OCC_DATE, label = TRUE, abbr = FALSE)
OCC_DOW <- wday(OCC_DATE, label = TRUE, abbr = FALSE)

# Simulate hour with a realistic distribution (e.g., more collisions during rush hours)
OCC_HOUR <- sample(0:23, n, replace = TRUE, prob = c(
  rep(0.02, 5),  # Early morning
  rep(0.05, 2),  # Morning
  rep(0.08, 2),  # Late morning
  rep(0.1, 3),   # Afternoon
  rep(0.15, 2),  # Rush hour
  rep(0.1, 2),   # Evening
  rep(0.05, 4),  # Night
  rep(0.02, 4)   # Late night
))

# Simulate divisions
DIVISION <- sample(paste0("D", sprintf("%02d", 11:55)), n, replace = TRUE)

# Simulate fatalities with low probability
FATALITIES <- rbinom(n, 1, 0.001)

# Simulate injury collisions with interaction with hour (more injuries during rush hours)
INJURY_COLLISIONS <- ifelse(OCC_HOUR %in% c(7:9, 16:18), 
                            rbinom(n, 1, 0.15),  # Higher probability during rush hours
                            rbinom(n, 1, 0.05))  # Lower probability otherwise

INJURY_COLLISIONS <- factor(ifelse(INJURY_COLLISIONS == 1, "YES", "NO"), levels = c("NO", "YES"))

# Simulate Fail to Remain collisions
FTR_COLLISIONS <- factor(ifelse(rbinom(n, 1, 0.05) == 1, "YES", "NO"), levels = c("NO", "YES"))

# Simulate Property Damage collisions
PD_COLLISIONS <- factor(ifelse(rbinom(n, 1, 0.6) == 1, "YES", "NO"), levels = c("NO", "YES"))

# Simulate Neighbourhoods
neighbourhoods_list <- c("Neighbourhood A", "Neighbourhood B", "Neighbourhood C", "Neighbourhood D")
NEIGHBOURHOOD_NAME <- sample(neighbourhoods_list, n, replace = TRUE)

# Simulate coordinates within Toronto bounding box
LONG_WGS84 <- runif(n, -79.6393, -79.1152)
LAT_WGS84 <- runif(n, 43.5810, 43.8555)

# Simulate involvement indicators with interactions
AUTOMOBILE <- factor(rep("YES", n), levels = c("NO", "YES"))  # All involve an automobile

MOTORCYCLE <- factor(ifelse(rbinom(n, 1, 0.02) == 1, "YES", "NO"), levels = c("NO", "YES"))
BICYCLE <- factor(ifelse(rbinom(n, 1, 0.05) == 1, "YES", "NO"), levels = c("NO", "YES"))
PEDESTRIAN <- factor(ifelse(rbinom(n, 1, 0.05) == 1, "YES", "NO"), levels = c("NO", "YES"))

# Ensure that at least one of MOTORCYCLE, BICYCLE, or PEDESTRIAN is "NO" if AUTOMOBILE is "YES"
# (This is just for illustrative purposes; adjust logic as needed)

# Create the data frame
simulate_data <- data.frame(
  OCC_DATE,
  OCC_YEAR,
  OCC_MONTH,
  OCC_DOW,
  OCC_HOUR,
  DIVISION,
  FATALITIES,
  INJURY_COLLISIONS,
  FTR_COLLISIONS,
  PD_COLLISIONS,
  NEIGHBOURHOOD_NAME,
  LONG_WGS84,
  LAT_WGS84,
  AUTOMOBILE,
  MOTORCYCLE,
  BICYCLE,
  PEDESTRIAN
)


# Add interactions (e.g., higher chance of injuries when pedestrians are involved)
simulate_data <- simulate_data %>%
  mutate(
    INJURY_COLLISIONS = ifelse(
      MOTORCYCLE == "YES" | BICYCLE == "YES" | PEDESTRIAN == "YES",
      "YES",
      as.character(INJURY_COLLISIONS)  # Convert to character for ifelse
    ),
    INJURY_COLLISIONS = factor(INJURY_COLLISIONS, levels = c("NO", "YES"))
  )
# Convert indicator variables to factors
indicator_cols <- c("INJURY_COLLISIONS", "FTR_COLLISIONS", "PD_COLLISIONS",
                    "AUTOMOBILE", "MOTORCYCLE", "BICYCLE", "PEDESTRIAN")

simulate_data <- simulate_data %>%
  mutate(across(all_of(indicator_cols), ~ factor(.x, levels = c("NO", "YES"))))
# Save the simulated data
write_csv(simulate_data, "data/simulated_data/simulated_collisions.csv")

# Print message
message("Simulated data generated successfully.")
