#### Preamble ####
# Purpose: Perform exploratory data analysis on the cleaned Toronto traffic collisions data.
# Author: [Your Name]
# Date: [Current Date]
# Contact: [Your Email]
# License: MIT
# Pre-requisites:
# - The `tidyverse`, `lubridate`, `sf`, `ggplot2`, and `here` packages must be installed.
# - Cleaned data must be available in `data/analysis_data/`.
# - Ensure you are in the project root directory when running this script.
# Any other information needed:
# - Output directories (`results/plots`) should exist or will be created.

#### Workspace Setup ####

# Load necessary libraries
library(tidyverse)
library(lubridate)
library(sf)
library(ggplot2)
library(here)

# Create necessary directories if they do not exist
if (!dir.exists(here("results", "plots"))) {
  dir.create(here("results", "plots"), recursive = TRUE)
}

#### Load Data ####

# Load the cleaned collisions data
collisions <- read_csv(here("data", "analysis_data", "collisions_clean.csv"))

# Load the neighbourhoods data
neighbourhoods <- st_read(here("data", "analysis_data", "neighbourhoods_clean.geojson"), quiet = TRUE)

# Ensure OCC_DATE is in Date format
collisions <- collisions %>%
  mutate(OCC_DATE = as.Date(OCC_DATE))

#### Data Aggregation ####

# Aggregate collisions by year
yearly_collisions <- collisions %>%
  group_by(OCC_YEAR) %>%
  summarize(total_collisions = n(), .groups = 'drop')

# Save aggregated yearly collisions data
write_csv(yearly_collisions, here("data", "analysis_data", "yearly_collisions.csv"))

# Aggregate collisions by neighbourhood and year
neighbourhood_yearly_collisions <- collisions %>%
  group_by(NEIGHBOURHOOD_NAME, OCC_YEAR) %>%
  summarize(
    total_collisions = n(),
    fatalities = sum(FATALITIES, na.rm = TRUE),
    injuries = sum(INJURY_COLLISIONS == "YES", na.rm = TRUE),
    .groups = 'drop'
  )

# Save aggregated data
write_csv(neighbourhood_yearly_collisions, here("data", "analysis_data", "neighbourhood_yearly_collisions.csv"))

#### Exploratory Data Analysis ####

# Plot total collisions over time
ggplot(yearly_collisions, aes(x = OCC_YEAR, y = total_collisions)) +
  geom_line(color = "blue") +
  geom_point(color = "blue") +
  labs(
    title = "Total Collisions Over Time",
    x = "Year",
    y = "Number of Collisions"
  ) +
  theme_minimal()

# The plot will display in the RStudio Plots pane

# Save the plot
ggsave(
  filename = here("results", "plots", "total_collisions_over_time.png"),
  width = 8,
  height = 6
)

#### Additional Exploratory Plots ####

# Collisions by Day of the Week
collisions %>%
  mutate(DayOfWeek = wday(OCC_DATE, label = TRUE, abbr = FALSE)) %>%
  group_by(DayOfWeek) %>%
  summarize(total_collisions = n()) %>%
  ggplot(aes(x = DayOfWeek, y = total_collisions)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(
    title = "Total Collisions by Day of the Week",
    x = "Day of the Week",
    y = "Number of Collisions"
  ) +
  theme_minimal()

# Save the plot
ggsave(
  filename = here("results", "plots", "collisions_by_day_of_week.png"),
  width = 8,
  height = 6
)

# Collisions by Hour of the Day
collisions %>%
  mutate(HourOfDay = hour(OCC_DATE)) %>%
  group_by(HourOfDay) %>%
  summarize(total_collisions = n()) %>%
  ggplot(aes(x = HourOfDay, y = total_collisions)) +
  geom_bar(stat = "identity", fill = "darkgreen") +
  labs(
    title = "Total Collisions by Hour of the Day",
    x = "Hour of the Day",
    y = "Number of Collisions"
  ) +
  theme_minimal()

# Save the plot
ggsave(
  filename = here("results", "plots", "collisions_by_hour_of_day.png"),
  width = 8,
  height = 6
)

#### Spatial Visualization ####

# Convert collisions to spatial data
collisions_sf <- st_as_sf(
  collisions,
  coords = c("LONG_WGS84", "LAT_WGS84"),
  crs = 4326,
  remove = FALSE
)

# Plot collision points over neighbourhoods
ggplot() +
  geom_sf(data = neighbourhoods, fill = "white", color = "black") +
  geom_sf(data = collisions_sf, alpha = 0.5, color = "red", size = 0.5) +
  labs(
    title = "Collision Locations in Toronto",
    x = "Longitude",
    y = "Latitude"
  ) +
  theme_minimal()

# The map will display in the RStudio Plots pane

# Save the map
ggsave(
  filename = here("results", "plots", "collision_map.png"),
  width = 8,
  height = 6
)

#### End of Script ####