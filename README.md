# Neighborhood Disparities in Land Surface Temperature and the Role of the Built Environment: Evidence from a Major Chinese City

This repository contains the analytical dataset and R code used for the research paper:

> **“Neighborhood Disparities in Land Surface Temperature and the Role of the Built Environment: Evidence from a Major Chinese City”**
>
> **Authored By:** Yang Ju (Nanjing University), Huiyan Shang (Nanjing University), Jiangang Xu (Nanjing University), Yu Huang (Nanjing University), Jinglu Song (Xi'an Jiaotong-Liverpool University), Yiwen Wang (Nanjing University), Ying Liang (Nanjing University), Maryia Bakhtsiyarava (Drexel University).

***

## Repository Structure

The project files are organized as follows:

*   **`code.R`**: The primary analytical script. This code utilizes the **`lavaan`** package to perform path analysis with Structural Equation Modeling (SEM) to examine how the built environment mediates LST disparities.
*   **`data0114/`**: Directory containing the core analytical dataset used for model estimation.
*   **`data_dictionary.txt`**: A reference file defining variable names in the analytical dataset.

---

## Getting Started

### Prerequisites
To ensure full compatibility with the saved models and results, this analysis should be run using:
*   **R version 4.5.2** or later.

The following R libraries are required:
```R
# Install essential packages
install.packages(c("lavaan"))
