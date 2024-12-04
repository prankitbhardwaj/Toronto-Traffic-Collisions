# Assessing the Impact of Vision Zero on Traffic Collisions in Toronto Neighborhoods

## Overview

This repository contains all the files, data, and scripts associated with the analysis of traffic collision data in Toronto neighborhoods from 2014 to 2021. The primary goal of this project is to evaluate the factors influencing collision frequencies and assess the impact of the Vision Zero Road Safety Plan implemented in 2017.

## File Structure

The repository is structured as follows:

- **`data/`**
  - **`raw_data/`**: Contains the raw data as obtained from the City of Toronto Open Data Portal.
    - `traffic_collisions_2014_2021.csv`: Raw traffic collision data.
    - `neighbourhoods.geojson`: Geospatial data defining Toronto neighborhoods.
  - **`analysis_data/`**: Contains the cleaned and processed datasets used for analysis.
    - `neighbourhood_yearly_collisions.parquet`: Aggregated collision data by neighborhood and year.
- **`scripts/`**: Contains the R scripts used to download, clean, and process data.
  - `data_download.R`: Script for downloading raw data.
  - `data_cleaning.R`: Script for cleaning and preparing the raw data.
  - `data_analysis.R`: Script for data analysis and visualization.
- **`model/`**: Contains fitted models and related outputs.
  - `model_fitting.R`: Script for fitting the Negative Binomial regression model.
  - `nb_model.rds`: Saved Negative Binomial regression model object.
  - `cv_model.rds`: Saved cross-validation model results.
- **`paper/`**: Contains the files used to generate the research paper.
  - `paper.qmd`: The Quarto document of the paper.
  - `references.bib`: Bibliography file with all references.
  - `paper.pdf`: The final rendered PDF of the paper.
- **`other/`**: Contains additional resources and documentation.
  - **`literature/`**: Relevant literature and articles.
  - `appendix.qmd`: Appendix with supplementary analyses.
  - `llm_usage.txt`: Documentation of interactions with language models.

## Statement on LLM Usage

Aspects of this project were developed with the assistance of language models, including ChatGPT. Specifically:

- **Writing Assistance**: The abstract, introduction, discussion, and conclusion sections of the paper were drafted with the help of ChatGPT.
- **Code Troubleshooting**: Assistance was provided in debugging R code and resolving errors during data analysis.
- **Appendix Development**: Guidance was obtained for structuring and writing the appendix, focusing on data collection methodologies and limitations.

All interactions with language models are documented in `other/llm_usage.txt`.

## Acknowledgments

- **Data Sources**: The data used in this project were obtained from the [City of Toronto's Open Data Portal](https://open.toronto.ca/):
  - [Police Annual Statistical Report - Traffic Collisions](https://open.toronto.ca/dataset/police-annual-statistical-report-traffic-collisions/)
  - [Neighbourhoods](https://open.toronto.ca/dataset/neighbourhoods/)
- **Software**: The analysis was conducted using R version 4.0.5 [@R-base], along with the following R packages:
  - **MASS** [@MASS]
  - **tidyverse** [@tidyverse]
  - **caret** [@caret]
  - **ggplot2** [@ggplot2]
  - **broom** [@broom]
  - **kableExtra** [@kableExtra]
  - **here** [@here]
  - **sf** [@sf]

## License

This project is licensed under the [MIT License](LICENSE).


---

**Note**: This README provides an overview of the project's purpose, structure, and resources. It replaces the placeholder content from the starter folder and includes all relevant information specific to this project.
