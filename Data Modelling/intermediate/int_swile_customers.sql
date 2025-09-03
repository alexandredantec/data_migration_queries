CREATE TABLE int_swile_customers AS
WITH 

latest_company AS (
  SELECT
    company_salesforce_account_id,
    company_id,
    company_siret,
    ROW_NUMBER() OVER (PARTITION BY company_salesforce_account_id ORDER BY order_item_fulfilled_date DESC) AS company_rank 
  FROM int_swile_orders
  QUALIFY company_rank = 1
)

SELECT
  latest_company.company_salesforce_account_id,
  latest_company.company_id,
  latest_company.company_siret,
  MIN(CASE WHEN swile_orders.order_item_status = 'succeeded' THEN swile_orders.order_item_fulfilled_date END) AS first_swile_order_date,
  MAX(CASE WHEN swile_orders.order_item_status = 'succeeded' THEN swile_orders.order_item_fulfilled_date END) AS latest_swile_order_date,
  SUM(CASE WHEN swile_orders.order_item_status = 'succeeded' THEN swile_orders.business_volume_amount ELSE 0 END) AS total_swile_business_volume,
  SUM(CASE WHEN swile_orders.order_type = 'gift' AND swile_orders.order_item_status = 'succeeded' THEN swile_orders.business_volume_amount ELSE 0 END) AS total_swile_gift_business_volume,
  SUM(CASE WHEN swile_orders.order_type = 'meal_voucher' AND swile_orders.order_item_status = 'succeeded' THEN swile_orders.business_volume_amount ELSE 0 END) AS total_swile_mealvoucher_business_volume,
  COUNT(CASE WHEN swile_orders.order_item_status = 'succeeded' THEN swile_orders.order_item_id END) AS total_swile_orders,
  COUNT(CASE WHEN swile_orders.order_type = 'gift' AND swile_orders.order_item_status = 'succeeded' THEN order_item_id END) AS total_swile_gift_orders,
  COUNT(CASE WHEN swile_orders.order_type = 'meal_voucher' AND swile_orders.order_item_status = 'succeeded' THEN order_item_id END) AS total_swile_mealvoucher_orders
FROM latest_company
LEFT JOIN int_swile_orders AS swile_orders ON latest_company.company_salesforce_account_id = swile_orders.company_salesforce_account_id
GROUP BY latest_company.company_salesforce_account_id, latest_company.company_id, latest_company.company_siret