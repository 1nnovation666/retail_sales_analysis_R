# Retail Sales and Profitability Analysis with R

An exploratory analysis of sales, discounts, and profitability using Tableau’s Superstore sample dataset.

[Read the full report](Retail_Profitability_Report.pdf)

## Project Objectives

- Compare profitability across product categories.
- Examine the relationship between discounts and profit margins.
- Build and compare linear and quadratic regression models.
- Identify areas for further business investigation.

## Dataset

The analysis covers 10,194 order lines across 5,111 distinct orders.

Data source: [Tableau Superstore sample dataset](https://public.tableau.com/app/sample-data/sample_-_superstore.xls).

This is an educational portfolio project using sample data.

## Tools and Methods

- R and RStudio
- readxl for importing Excel data
- Data-quality checks for missing values and duplicate records
- Aggregation by product category and discount level
- Data visualization using base R
- Linear and quadratic regression using lm()
- Residual diagnostics

## Key Findings

- Total sales were approximately 2.33 million, with total profit of 292,296.81.
- The overall profit margin was 12.56%.
- Furniture had a profit margin of 2.61%, compared with 17.22% for Office Supplies and 17.45% for Technology.
- Every observed discount group at 30% or higher recorded an aggregate loss.
- Adding a squared discount term to the category-adjusted regression increased adjusted R² from 0.7511 to 0.8470.

Monetary figures are reported in the dataset’s units.

## Interpretation and Limitations

Category and discount-group margins are calculated as total profit divided by total sales. Regression models use each order line’s profit-to-sales ratio.

The results describe associations, not causal effects. Differences in product mix and other factors may influence the relationship between discounts and profitability.

The quadratic model improved in-sample fit, but residual patterns remained. No holdout prediction evaluation was performed; adjusted R² should not be interpreted as prediction accuracy.

## Repository Contents

| File | Description |
|---|---|
| sales_analysis.R | R analysis script |
| Retail_Profitability_Report.pdf | Findings, methods, and recommendations |
| overall_summary.csv | Overall performance metrics |
| category_summary.csv | Results by product category |
| discount_summary.csv | Results by discount level |
| Rplot.pdf | Product category profit margins |
| Rplot01.pdf | Discount and profit-margin scatter plot |
| Rplot02.pdf | Regression residual diagnostic |

The source Excel workbook is also included.

## Running the Analysis

1. Download the repository files.
2. Open sales_analysis.R in RStudio.
3. Install the readxl package if needed.
4. Update any local file and output paths to match your computer.
5. Ensure the script imports the workbook’s Orders sheet as orders before running the analysis.
6. Run the script from the beginning.

## Potential Next Steps

- Investigate furniture profitability by sub-category and product.
- Examine product mix within high-discount groups.
- Evaluate model performance on held-out data.
