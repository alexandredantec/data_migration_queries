-- =============================================
-- DATA QUALITY TESTING QUERIES
-- Swile/Bimpli Customer Unification Analysis
-- =============================================

-- 1. CHECK SIRET COMPLETENESS ACROSS ALL TABLES
-- =============================================
SELECT COUNT(*), 'salesforce' AS source FROM stg_salesforce_accounts WHERE salesforce_account_siret IS NULL 
UNION ALL
SELECT COUNT(*), 'swile_mealvoucher' AS source FROM stg_swile_mealvoucher_orders WHERE company_siret IS NULL 
UNION ALL
SELECT COUNT(*), 'swile_gift' AS source FROM stg_swile_gift_orders WHERE company_siret IS NULL 
UNION ALL
SELECT COUNT(*), 'bimpli_mealvoucher' AS source FROM stg_bimpli_mealvoucher_orders WHERE company_siret IS NULL 
UNION ALL
SELECT COUNT(*), 'bimpli_gift' AS source FROM stg_bimpli_gift_orders WHERE company_siret IS NULL;

-- 2. CHECK SIRET UNIQUENESS BY TABLE
-- =============================================

-- Salesforce SIRET uniqueness
SELECT salesforce_account_siret, COUNT(*) AS total 
FROM stg_salesforce_accounts 
GROUP BY salesforce_account_siret 
ORDER BY COUNT(*) DESC;

-- Salesforce account_id uniqueness
SELECT salesforce_account_id, COUNT(*) AS total 
FROM stg_salesforce_accounts 
GROUP BY salesforce_account_id 
ORDER BY COUNT(*) DESC;

-- Swile Gift: SIRET to company_id relationships
SELECT company_siret, COUNT(DISTINCT company_id) AS total 
FROM stg_swile_gift_orders 
GROUP BY company_siret 
ORDER BY COUNT(DISTINCT company_id) DESC;

-- Swile Meal Voucher: SIRET to company_id relationships  
SELECT company_siret, COUNT(DISTINCT company_id) AS total 
FROM stg_swile_mealvoucher_orders 
GROUP BY company_siret 
ORDER BY COUNT(DISTINCT company_id) DESC;

-- Bimpli Gift: SIRET to company_id relationships
SELECT company_siret, COUNT(DISTINCT company_id) AS total 
FROM stg_bimpli_gift_orders 
GROUP BY company_siret 
ORDER BY COUNT(DISTINCT company_id) DESC;

-- Bimpli Meal Voucher: SIRET to company_id relationships
SELECT company_siret, COUNT(DISTINCT company_id) AS total 
FROM stg_bimpli_mealvoucher_orders 
GROUP BY company_siret 
ORDER BY COUNT(DISTINCT company_id) DESC;

-- 3. INVESTIGATE SIRET-TO-COMPANY_ID RELATIONSHIP ISSUES
-- =============================================

-- Swile Gift: Show problematic SIRET cases with temporal analysis
WITH company_count AS (
  SELECT company_siret, COUNT(DISTINCT company_id) AS total 
  FROM stg_swile_gift_orders 
  GROUP BY company_siret
  HAVING COUNT(DISTINCT company_id) > 1
)
SELECT 
  orders.company_siret,
  orders.company_id,
  COUNT(*) AS order_count,
  COUNT(DISTINCT orders.company_salesforce_account_id) AS total_salesforce_accounts,
  MIN(orders.order_item_fulfilled_date) AS first_order_date,
  MAX(orders.order_item_fulfilled_date) AS latest_order_date
FROM stg_swile_gift_orders AS orders 
INNER JOIN company_count AS companies 
  ON orders.company_siret = companies.company_siret 
GROUP BY orders.company_siret, orders.company_id 
ORDER BY orders.company_siret, order_count DESC;

-- Bimpli Meal Voucher: Show problematic SIRET cases
WITH company_count AS (
  SELECT company_siret, COUNT(DISTINCT company_id) AS total 
  FROM stg_bimpli_mealvoucher_orders 
  GROUP BY company_siret
  HAVING COUNT(DISTINCT company_id) > 1
)
SELECT 
  orders.company_siret,
  orders.company_id,
  COUNT(*) AS order_count,
  MIN(orders.order_item_fulfilled_date) AS first_order_date,
  MAX(orders.order_item_fulfilled_date) AS latest_order_date
FROM stg_bimpli_mealvoucher_orders AS orders 
INNER JOIN company_count AS companies 
  ON orders.company_siret = companies.company_siret 
GROUP BY orders.company_siret, orders.company_id 
ORDER BY orders.company_siret, orders.order_item_fulfilled_date;

-- 4. CHECK SALESFORCE-SWILE RELATIONSHIP INTEGRITY
-- =============================================

-- Count Swile customers missing from Salesforce
SELECT COUNT(*), 'swile_gift_invalid_sf_ids' AS check_name
FROM stg_swile_gift_orders
WHERE company_salesforce_account_id IS NOT NULL 
  AND company_salesforce_account_id NOT IN (
    SELECT salesforce_account_id FROM stg_salesforce_accounts
  )
UNION ALL
SELECT COUNT(*), 'swile_mv_invalid_sf_ids' AS check_name  
FROM stg_swile_mealvoucher_orders
WHERE company_salesforce_account_id IS NOT NULL
  AND company_salesforce_account_id NOT IN (
    SELECT salesforce_account_id FROM stg_salesforce_accounts
  );

-- Investigate missing Salesforce customers by SIRET
SELECT COUNT(*), 'swile_gift_missing_siret' AS source
FROM stg_swile_gift_orders 
WHERE company_siret NOT IN (
  SELECT salesforce_account_siret FROM stg_salesforce_accounts
)
UNION ALL 
SELECT COUNT(*), 'swile_mv_missing_siret' AS source
FROM stg_swile_mealvoucher_orders 
WHERE company_siret NOT IN (
  SELECT salesforce_account_siret FROM stg_salesforce_accounts
);

-- 5. ANALYZE MISSING SALESFORCE CUSTOMERS IN DETAIL
-- =============================================

-- Show the 2 missing customers with their BV impact
SELECT 
  company_siret,
  company_id, 
  company_salesforce_account_id,
  COUNT(*) AS total_orders,
  MIN(order_item_fulfilled_date) AS first_order,
  MAX(order_item_fulfilled_date) AS last_order,
  SUM(business_volume_amount) AS total_bv
FROM stg_swile_mealvoucher_orders 
WHERE company_salesforce_account_id NOT IN (
  SELECT salesforce_account_id FROM stg_salesforce_accounts
)
GROUP BY company_siret, company_id, company_salesforce_account_id
ORDER BY total_bv DESC;

-- Check if missing customers have Bimpli history
WITH missing_salesforce_swile_records AS (
  SELECT DISTINCT
    company_siret,
    company_id,
    company_salesforce_account_id
  FROM stg_swile_mealvoucher_orders 
  WHERE company_salesforce_account_id NOT IN (
    SELECT salesforce_account_id FROM stg_salesforce_accounts
  )
)
SELECT 
  swile.company_siret,
  bimpli_gift.company_id AS bimpli_gift_company_id,
  bimpli_mealvoucher.company_id AS bimpli_mv_company_id
FROM missing_salesforce_swile_records AS swile 
LEFT JOIN stg_bimpli_gift_orders AS bimpli_gift 
  ON swile.company_siret = bimpli_gift.company_siret 
LEFT JOIN stg_bimpli_mealvoucher_orders AS bimpli_mealvoucher 
  ON swile.company_siret = bimpli_mealvoucher.company_siret;

-- 6. CHECK SIRET CONSISTENCY BETWEEN SALESFORCE AND SWILE
-- =============================================

-- Find SIRET mismatches between Salesforce and Swile operational data
WITH swile_customer_sirets AS (
  SELECT DISTINCT 
    company_salesforce_account_id,
    company_siret AS swile_siret
  FROM stg_swile_gift_orders
  WHERE company_salesforce_account_id IS NOT NULL
  UNION 
  SELECT DISTINCT
    company_salesforce_account_id, 
    company_siret AS swile_siret
  FROM stg_swile_mealvoucher_orders  
  WHERE company_salesforce_account_id IS NOT NULL
)
SELECT 
  sf.salesforce_account_id,
  sf.salesforce_account_siret AS sf_siret,
  swile.swile_siret,
  CASE WHEN sf.salesforce_account_siret = swile.swile_siret 
       THEN 'match' 
       ELSE 'mismatch' 
  END AS siret_status
FROM stg_salesforce_accounts sf
JOIN swile_customer_sirets swile 
  ON sf.salesforce_account_id = swile.company_salesforce_account_id
WHERE sf.salesforce_account_siret != swile.swile_siret;

-- 7. CHECK ORDER_ITEM_ID UNIQUENESS (PRIMARY KEY VALIDATION)
-- =============================================

-- Check uniqueness across all order tables
SELECT COUNT(*), 'bimpli_gift_duplicates' AS source
FROM (
  SELECT order_item_id, COUNT(*)
  FROM stg_bimpli_gift_orders
  GROUP BY order_item_id
  HAVING COUNT(*) > 1
)
UNION ALL
SELECT COUNT(*), 'bimpli_mv_duplicates' AS source
FROM (
  SELECT order_item_id, COUNT(*)
  FROM stg_bimpli_mealvoucher_orders
  GROUP BY order_item_id
  HAVING COUNT(*) > 1
)
UNION ALL
SELECT COUNT(*), 'swile_gift_duplicates' AS source
FROM (
  SELECT order_item_id, COUNT(*)
  FROM stg_swile_gift_orders
  GROUP BY order_item_id
  HAVING COUNT(*) > 1
)
UNION ALL
SELECT COUNT(*), 'swile_mv_duplicates' AS source
FROM (
  SELECT order_item_id, COUNT(*)
  FROM stg_swile_mealvoucher_orders
  GROUP BY order_item_id
  HAVING COUNT(*) > 1
);

-- 8. CHECK ORDER STATUS CONSISTENCY
-- =============================================

-- Check status values across all tables
SELECT DISTINCT order_item_status, 'swile_gift' AS source
FROM stg_swile_gift_orders
UNION ALL
SELECT DISTINCT order_item_status, 'swile_mv' AS source  
FROM stg_swile_mealvoucher_orders
UNION ALL
SELECT DISTINCT order_item_status, 'bimpli_gift' AS source
FROM stg_bimpli_gift_orders
UNION ALL
SELECT DISTINCT order_item_status, 'bimpli_mv' AS source
FROM stg_bimpli_mealvoucher_orders;

-- 9. CUSTOMER COUNT COMPARISON ACROSS SYSTEMS
-- =============================================

-- Compare customer counts across all systems
SELECT COUNT(*), 'salesforce_total' AS source FROM stg_salesforce_accounts
UNION ALL
SELECT COUNT(DISTINCT company_salesforce_account_id), 'swile_customers_in_sf' AS source 
FROM (
  SELECT company_salesforce_account_id FROM stg_swile_gift_orders WHERE company_salesforce_account_id IS NOT NULL
  UNION
  SELECT company_salesforce_account_id FROM stg_swile_mealvoucher_orders WHERE company_salesforce_account_id IS NOT NULL
)
UNION ALL
SELECT COUNT(DISTINCT company_siret), 'bimpli_customers' AS source
FROM (
  SELECT company_siret FROM stg_bimpli_gift_orders
  UNION
  SELECT company_siret FROM stg_bimpli_mealvoucher_orders
);