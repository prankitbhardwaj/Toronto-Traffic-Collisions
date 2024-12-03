#### Preamble ####
# Purpose: Perform statistical modeling on the aggregated Toronto traffic collisions data.
# Author: [Your Name]
# Date: [Current Date]
# Contact: [Your Email]
# License: MIT
# Pre-requisites:
# - The `tidyverse`, `MASS`, `ggplot2`, `plotly`, and `here` packages must be installed.
# - Aggregated data must be available in `data/analysis_data/`.
# - Ensure you are in the project root directory when running this script.
# Any other information needed:
# - Output directories (`results/models`, `results/plots`, `results/model_predictions`) should exist or will be created.

#### Workspace Setup ####

# Load necessary libraries
library(tidyverse)
library(MASS)
library(ggplot2)
library(plotly)
library(here)

# Create necessary directories if they do not exist
if (!dir.exists(here("results", "plots"))) {
  dir.create(here("results", "plots"), recursive = TRUE)
}

if (!dir.exists(here("results", "models"))) {
  dir.create(here("results", "models"), recursive = TRUE)
}

if (!dir.exists(here("results", "model_predictions"))) {
  dir.create(here("results", "model_predictions"), recursive = TRUE)
}

#### Load Data ####

# Load aggregated data
neighbourhood_yearly_collisions <- read_csv(here("data", "analysis_data", "neighbourhood_yearly_collisions.csv"))

# Ensure NEIGHBOURHOOD_NAME is a factor with consistent levels
neighbourhood_levels <- sort(unique(neighbourhood_yearly_collisions$NEIGHBOURHOOD_NAME))

neighbourhood_yearly_collisions <- neighbourhood_yearly_collisions %>%
  mutate(NEIGHBOURHOOD_NAME = factor(NEIGHBOURHOOD_NAME, levels = neighbourhood_levels))

#### Statistical Modeling ####

# Check for overdispersion
mean_collisions <- mean(neighbourhood_yearly_collisions$total_collisions)
var_collisions <- var(neighbourhood_yearly_collisions$total_collisions)

if (var_collisions > mean_collisions) {
  message("Data is overdispersed. Negative Binomial Regression is appropriate.")
} else {
  message("Data is not overdispersed. Poisson Regression may be appropriate.")
}

# Fit Negative Binomial Regression
nb_model <- glm.nb(
  total_collisions ~ OCC_YEAR + NEIGHBOURHOOD_NAME,
  data = neighbourhood_yearly_collisions
)

# View model summary
print(summary(nb_model))

# Save model object
saveRDS(nb_model, file = here("results", "models", "nb_model.rds"))

#### Model Diagnostics ####

# Plot residuals vs fitted values
residuals <- residuals(nb_model, type = "pearson")
fitted_values <- fitted(nb_model)

ggplot(data = data.frame(fitted_values, residuals), aes(x = fitted_values, y = residuals)) +
  geom_point(alpha = 0.5) +
  geom_hline(yintercept = 0, color = "red") +
  labs(
    title = "Residuals vs Fitted Values",
    x = "Fitted Values",
    y = "Pearson Residuals"
  ) +
  theme_minimal()

# The plot will display in the RStudio Plots pane

# Save the diagnostic plot
ggsave(
  filename = here("results", "plots", "residuals_vs_fitted.png"),
  width = 8,
  height = 6
)

#### Predictions ####

# Generate predictions for all neighbourhoods over the range of years
prediction_grid <- expand.grid(
  OCC_YEAR = seq(
    from = min(neighbourhood_yearly_collisions$OCC_YEAR),
    to = max(neighbourhood_yearly_collisions$OCC_YEAR),
    by = 1
  ),
  NEIGHBOURHOOD_NAME = neighbourhood_levels
)

# Ensure NEIGHBOURHOOD_NAME is a factor with correct levels
prediction_grid$NEIGHBOURHOOD_NAME <- factor(
  prediction_grid$NEIGHBOURHOOD_NAME,
  levels = neighbourhood_levels
)

# Predict total collisions
prediction_grid$predicted_collisions <- predict(
  nb_model,
  newdata = prediction_grid,
  type = "response"
)

# Save the prediction grid
write_csv(
  prediction_grid,
  here("results", "model_predictions", "all_neighbourhoods_predictions.csv")
)

#### Visualization of Predictions ####

# Option 1: Faceted Plot by Neighbourhood

# Faceted plot by neighbourhood
ggplot(prediction_grid, aes(x = OCC_YEAR, y = predicted_collisions)) +
  geom_line(color = "blue") +
  labs(
    title = "Predicted Collisions Over Time by Neighbourhood",
    x = "Year",
    y = "Predicted Number of Collisions"
  ) +
  facet_wrap(~ NEIGHBOURHOOD_NAME, scales = "free_y") +
  theme_minimal()

# The plot will display in the RStudio Plots pane

# Save the faceted plot
ggsave(
  filename = here("results", "plots", "predicted_collisions_faceted.png"),
  width = 20,
  height = 15
)

# Option 2: Interactive Plot with plotly

# Create interactive plot
p <- ggplot(prediction_grid, aes(x = OCC_YEAR, y = predicted_collisions, color = NEIGHBOURHOOD_NAME)) +
  geom_line(show.legend = FALSE) +
  labs(
    title = "Predicted Collisions Over Time by Neighbourhood",
    x = "Year",
    y = "Predicted Number of Collisions"
  ) +
  theme_minimal()

# Convert to interactive plotly object
p_interactive <- ggplotly(p)

# Display interactive plot (in RStudio Viewer pane)
p_interactive

# Save interactive plot as HTML
htmlwidgets::saveWidget(p_interactive, file = here("results", "plots", "predicted_collisions_interactive.html"))

#### Actual vs Predicted Collisions ####

# Merge actual data with predictions
actual_vs_predicted <- neighbourhood_yearly_collisions %>%
  select(NEIGHBOURHOOD_NAME, OCC_YEAR, total_collisions) %>%
  rename(actual_collisions = total_collisions) %>%
  left_join(prediction_grid, by = c("NEIGHBOURHOOD_NAME", "OCC_YEAR"))

# Select a neighbourhood to plot
selected_neighbourhood <- "Annex"  # Replace with a valid neighbourhood

# Check if the selected neighbourhood exists
if (!(selected_neighbourhood %in% neighbourhood_levels)) {
  stop(paste("Neighbourhood", selected_neighbourhood, "does not exist in the data."))
}

# Filter data for the selected neighbourhood
data_to_plot <- actual_vs_predicted %>%
  filter(NEIGHBOURHOOD_NAME == selected_neighbourhood)

# Plot actual vs predicted collisions
ggplot(data_to_plot, aes(x = OCC_YEAR)) +
  geom_line(aes(y = actual_collisions, color = "Actual Collisions"), size = 1) +
  geom_line(aes(y = predicted_collisions, color = "Predicted Collisions"), linetype = "dashed", size = 1) +
  labs(
    title = paste("Actual vs Predicted Collisions in", selected_neighbourhood),
    x = "Year",
    y = "Number of Collisions",
    color = "Legend"
  ) +
  theme_minimal() +
  scale_color_manual(values = c("Actual Collisions" = "blue", "Predicted Collisions" = "red"))

# The plot will display in the RStudio Plots pane

# Save the plot
ggsave(
  filename = here("results", "plots", paste0("actual_vs_predicted_", selected_neighbourhood, ".png")),
  width = 8,
  height = 6
)

#### Notes ####

# You can loop over multiple neighbourhoods to create actual vs predicted plots for each one.

# Example:
# for (neighbourhood in c("Neighbourhood A", "Neighbourhood B", "Neighbourhood C")) {
#   # Repeat the plotting code inside the loop with neighbourhood replacing selected_neighbourhood
# }

#### End of Script ####