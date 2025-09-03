-- analysis of top 10 naf by sector 
-- requires a seed file with naf codes (downloaded from INSEE website)
WITH base AS (
SELECT 
  DATE_TRUNC('month', orders.order_item_fulfilled_date) as month,
  description,
  customers.salesforce_activity_code,
  SUM(orders.business_volume_amount) /1000 as monthly_bv
FROM fct_orders AS orders 
LEFT JOIN dim_customers customers ON orders.company_id = customers.company_id 
LEFT JOIN stg_naf_codes AS naf_codes ON customers.salesforce_activity_code = naf_codes.code
WHERE orders.customer_segment = 'swile_native'
GROUP BY DATE_TRUNC('month', order_item_fulfilled_date), description, customers.salesforce_activity_code

), 
top_naf AS (
SELECT 
  customers.salesforce_activity_code,
  SUM(orders.business_volume_amount) as monthly_bv
FROM fct_orders AS orders 
LEFT JOIN dim_customers customers ON orders.company_id = customers.company_id 
WHERE orders.customer_segment = 'swile_native'
GROUP BY customers.salesforce_activity_code
ORDER BY SUM(orders.business_volume_amount) DESC
LIMIT 10
)
SELECT 
  base.month,
  base.description,
  base.monthly_bv 
FROM base
INNER JOIN top_naf ON base.salesforce_activity_code = top_naf.salesforce_activity_code
ORDER BY description, month