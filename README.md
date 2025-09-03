Here's the markdown file content you can copy and save as README.md:
markdown# Data Migration Project

Here are the queries included in the data_migration project.

## Query Categories

| Category | Purpose |
|----------|---------|
| **Data Quality** | Initial data quality checks |
| **Data Modelling** | The Data Model itself |
| **Analysis** | Analytical queries used to produce the charts |

## Data Model Architecture

The Data Model follows a basic **medallion approach** with three layers:

Bronze Layer (staging) → Silver Layer (intermediate) → Gold Layer (mart)

## Implementation Notes

> **Note:** A slight recursion was introduced to allow for easier joins between customers and orders based on the unified company id.

> **Warning:** `fct_orders` is not entirely normalised, as including the customer segment made analysis easier. This would not be implemented in production.

> **SQL:** SQL code was run on DuckDB and subsequently annotated for clarity. 
