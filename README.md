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
- `clean_data.R`: Cleans and preprocesses raw traffic collision data.
- `model_data.R`: Fits the Negative Binomial regression model and saves outputs.
- `download_data.R`: Downloads raw data into `data/raw/`.
- `exploratory_data_analysis.R`: Performs exploratory data analysis (EDA) of collision data.
- `simulate_data.R`: Simulates datasets for testing and validation.

### **`paper/`**
- `paper.qmd`: Quarto file containing the final analysis, results, and discussion.
- `references.bib`: Bibliography file with references for data, software, and methodologies.
- `paper.pdf`: Rendered PDF of the final paper.

### **`results/`**
- `model_predictions/`: Model prediction outputs (CSV files).
- `model/`: Saved model objects (e.g., `nb_model.rds`).
- `plots/`: Figures and other visual outputs.

### **`tests/`**:
- `test_analysis_data.R` and `test_simulated_data.R`: Validate data integrity and consistency.

### **`other/`**
- **`llm_usage/`**
  - `llm_usage.txt`: Logs of interactions with large language models (LLMs).
  
## How to Reproduce the Analysis
- **Install Dependencies**:  
   Ensure you have R (≥4.0.5). Then install necessary packages:
   ```r
   install.packages(c("tidyverse","MASS","ggplot2","caret","broom","kableExtra","here","sf","lubridate"))
   ```
- **Run Scripts in Order**:
	- **scripts/download_data.R**: Downloads raw data into data/raw/.
  	- **scripts/clean_data.R**: Cleans raw data, producing data/processed/collisions_clean.csv.
	- **scripts/exploratory_data_analysis.R**: Performs EDA and saves plots in results/plots/.
	- **scripts/model_data.R**: Fits the Negative Binomial model, saves it as nb_model.rds, and generates predictions in results/model_predictions/.

- **Render the Paper**:
After running the above scripts, render the paper:   

   ```r
   quarto render paper/paper.qmd
   ```

The final paper.pdf will contain the complete analysis, results, and discussion.
   
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
**Note**: The dataset contain an aggregate of over 800,000 entries so the rendering time might be a bit longer than expected.
