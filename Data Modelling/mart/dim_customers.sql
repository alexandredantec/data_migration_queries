CREATE TABLE dim_customers AS
WITH salesforce_customers AS (
  SELECT
    salesforce_accounts.salesforce_account_id,
    salesforce_accounts.salesforce_account_siret,
    salesforce_accounts.salesforce_activity_code,
    salesforce_accounts.salesforce_postal_code_id,
    salesforce_accounts.salesforce_account_team_dynamic,
    COALESCE(swile_customers.company_id, CONCAT('bimpli_only', bimpli_customers.company_siret)) AS company_id, 
    swile_customers.first_swile_order_date,
    swile_customers.latest_swile_order_date,
    swile_customers.total_swile_business_volume,
    swile_customers.total_swile_gift_business_volume,
    swile_customers.total_swile_mealvoucher_business_volume,
    swile_customers.total_swile_orders,
    swile_customers.total_swile_gift_orders,
    swile_customers.total_swile_mealvoucher_orders,
    bimpli_customers.first_bimpli_order_date,
    bimpli_customers.latest_bimpli_order_date,
    bimpli_customers.total_bimpli_business_volume,
    bimpli_customers.total_bimpli_gift_business_volume,
    bimpli_customers.total_bimpli_mealvoucher_business_volume,
    bimpli_customers.total_bimpli_orders,
    bimpli_customers.total_bimpli_gift_orders,
    bimpli_customers.total_bimpli_mealvoucher_orders
  FROM stg_salesforce_accounts AS salesforce_accounts
  LEFT JOIN int_swile_customers AS swile_customers 
    ON salesforce_accounts.salesforce_account_id = swile_customers.company_salesforce_account_id 
  LEFT JOIN int_bimpli_customers AS bimpli_customers
    ON salesforce_accounts.salesforce_account_siret = bimpli_customers.company_siret
)

SELECT
  company_id,
  salesforce_account_id,
  salesforce_account_siret AS company_siret,
  salesforce_activity_code,
  salesforce_postal_code_id,
  salesforce_account_team_dynamic,
  first_swile_order_date,
  latest_swile_order_date,
  total_swile_business_volume,
  total_swile_gift_business_volume,
  total_swile_mealvoucher_business_volume,
  total_swile_orders,
  total_swile_gift_orders,
  total_swile_mealvoucher_orders,
  first_bimpli_order_date,
  latest_bimpli_order_date,
  total_bimpli_business_volume,
  total_bimpli_gift_business_volume,
  total_bimpli_mealvoucher_business_volume,
  total_bimpli_orders,
  total_bimpli_gift_orders,
  total_bimpli_mealvoucher_orders,
  CASE 
    WHEN total_swile_orders > 0 AND total_bimpli_orders > 0
      THEN 'bimpli_migrated'
    WHEN total_swile_orders > 0 AND total_bimpli_orders IS NULL
      THEN 'swile_native'
    WHEN total_swile_orders IS NULL AND total_bimpli_orders > 0
      THEN 'bimpli_not_migrated'
    ELSE NULL
  END AS customer_segment
FROM salesforce_customers
WHERE total_swile_orders > 0 OR total_bimpli_orders > 0
UNION ALL 
SELECT
  company_id,
  company_salesforce_account_id as salesforce_account_id,
  company_siret,
  NULL AS salesforce_activity_code,
  NULL AS salesforce_postal_code_id,
  NULL AS salesforce_account_team_dynamic,
  first_swile_order_date,
  latest_swile_order_date,
  total_swile_business_volume,
  total_swile_gift_business_volume,
  total_swile_mealvoucher_business_volume,
  total_swile_orders,
  total_swile_gift_orders,
  total_swile_mealvoucher_orders,
  NULL AS first_bimpli_order_date,
  NULL AS latest_bimpli_order_date,
  NULL AS total_bimpli_business_volume,
  NULL AS total_bimpli_gift_business_volume,
  NULL AS total_bimpli_mealvoucher_business_volume,
  NULL AS total_bimpli_orders,
  NULL AS total_bimpli_gift_orders,
  NULL AS total_bimpli_mealvoucher_orders,
  'swile_native' AS customer_segment
FROM int_swile_customers 
WHERE company_salesforce_account_id NOT IN (SELECT salesforce_account_id FROM stg_salesforce_accounts)
UNION ALL 
SELECT
  CONCAT('bimpli_only', company_siret) AS company_id,
  NULL AS salesforce_account_id,
  company_siret,
  NULL AS salesforce_activity_code,
  NULL AS salesforce_postal_code_id,
  NULL AS salesforce_account_team_dynamic,
  NULL AS first_swile_order_date,
  NULL AS latest_swile_order_date,
  NULL AS total_swile_business_volume,
  NULL AS total_swile_gift_business_volume,
  NULL AS total_swile_mealvoucher_business_volume,
  NULL AS total_swile_orders,
  NULL AS total_swile_gift_orders,
  NULL AS total_swile_mealvoucher_orders,
  first_bimpli_order_date,
  latest_bimpli_order_date,
  total_bimpli_business_volume,
  total_bimpli_gift_business_volume,
  total_bimpli_mealvoucher_business_volume,
  total_bimpli_orders,
  total_bimpli_gift_orders,
  total_bimpli_mealvoucher_orders,
  'bimpli_not_migrated' AS customer_segment
FROM int_bimpli_customers 
WHERE company_siret NOT IN (SELECT salesforce_account_siret FROM stg_salesforce_accounts)
