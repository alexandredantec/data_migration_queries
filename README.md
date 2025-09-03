Data Migration Project
Here are the queries included in the data_migration project:
Query Categories
For the initial data quality checks → Data Quality
For the Data Model itself → Data Modelling
For the Analytical Queries used to Produce the Charts → Analysis
Data Model Architecture
The Data Model follows a basic medallion approach with:

Bronze layer (staging)
Silver layer (intermediate)
Gold layer (mart)

Implementation Notes
A slight recursion was introduced to allow for easier joins between customers and orders based on the unified company id.
fct_orders is not entirely normalised, as including the customer segment made analysis easier. This would not be implemented in production.

All queries were run in Duckdb and subsequently annotated. 
