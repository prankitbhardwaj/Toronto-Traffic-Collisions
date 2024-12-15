#### Preamble ####
# Purpose: Downloads and saves the data from Opendata Toronto
# Author: Prankit Bhardwaj
# Date: 28 November 2024
# Contact: prankit.bhardwaj@mail.utoronto.ca
# License: MIT


#### Workspace setup ####
library(opendatatoronto)
library(tidyverse)
library(dplyr)

#### Download data ####

#Get neighbourhood package
neighbour_package <- show_package("neighbourhoods")

#List all neighbourhood package resources
neighbourhood_resources <- list_package_resources("neighbourhoods")

#Identify the neighbourhood resources into csv and GeoJSON
neighbourhood_data <- filter(neighbourhood_resources, tolower(format) %in% c('csv', 'geojson'))

#Download each file and save them into the raw data folder
for (i in seq_len(nrow(neighbourhood_data))) {
  resource <- neighbourhood_data[i, ]
  file_format <- tolower(resource$format)
  data <- get_resource(resource)
  
  if (file_format == "csv") {
    write.csv(data, "data/raw_data/neighbourhoods.csv", row.names = FALSE)
  } else if (file_format == "geojson") {
    writeLines(jsonlite::toJSON(data, pretty = TRUE), "data/raw_data/neighbourhoods.geojson")
  }
}

########### Downloading collisions data ###########

#Get trafic collisions package
collisions_package <- show_package("ec53f7b2-769b-4914-91fe-a37ee27a90b3")

#List all neighbourhood package resources
collisions_resources <- list_package_resources("ec53f7b2-769b-4914-91fe-a37ee27a90b3")

#Identify the neighbourhood resources into csv and GeoJSON
collisions_data <- filter(collisions_resources, tolower(format) %in% c('csv', 'geojson'))

#Download each file and save them into the raw data folder
#NOTE: Files are extreme
for (i in seq_len(nrow(collisions_data))) {
  resource <- collisions_data[i, ]
  file_format <- tolower(resource$format)
  data <- get_resource(resource)
  
  if (file_format == "csv") {
    write.csv(data, "data/raw_data/collisions.csv", row.names = FALSE)
  } else if (file_format == "geojson") {
    writeLines(jsonlite::toJSON(data, pretty = TRUE), "data/raw_data/collisions.geojson")
  }
}

         
