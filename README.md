# Assessing the Impact of Vision Zero on Traffic Collisions in Toronto Neighborhoods

## Overview

This repository contains all the files, data, and scripts associated with the analysis of traffic collision data in Toronto neighborhoods from 2014 to 2021. The primary goal of this project is to evaluate the factors influencing collision frequencies and assess the impact of the Vision Zero Road Safety Plan implemented in 2017.

## File Structure

### **`data/`**
- **`raw/`**
  - `collisions.csv`: Raw traffic collision data (2014–2021).
  - `neighbourhoods.geojson`: Toronto neighborhood boundaries.

- **`processed/`**
  - `collisions_clean.csv`: Cleaned and processed traffic collision data.
  - `neighbourhood_yearly_collisions.csv`: Aggregated yearly collision data by neighborhood.

### **`scripts/`**
- `data_cleaning.R`: Cleans and preprocesses raw traffic collision data.
- `model_fitting.R`: Fits the Negative Binomial regression model and saves outputs.
- `visualizations.R`: Creates maps and visualizations for temporal and spatial analyses.
- `eda.R`: Performs exploratory data analysis (EDA) of collision data.
- `simulation.R`: Simulates datasets for testing and validation.

### **`paper/`**
- `paper.qmd`: Quarto file containing the final analysis, results, and discussion.
- `references.bib`: Bibliography file with references for data, software, and methodologies.
- `paper.pdf`: Rendered PDF of the final paper.

### **`models/`**
- `nb_model.RDS`: Saved Negative Binomial model object for reproducibility.
- `cv_results.RDS`: Cross-validation results from the model.

### **`docs/`**
- `README.md`: Documentation for repository usage and structure.

### **`other/`**
- **`llm_usage/`**
  - `llm_usage.txt`: Logs of interactions with large language models (LLMs).

### **`results/`**
- Contains all the output of models

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
