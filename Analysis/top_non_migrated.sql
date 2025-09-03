-- identify top Bimpli churners 
SELECT 
  company_siret,
  total_bimpli_business_volume,
  total_bimpli_orders,
  first_bimpli_order_date,
  latest_bimpli_order_date,
  -- Calculate recency/engagement metrics
  DATEDIFF('day', latest_bimpli_order_date, CURRENT_DATE) as days_since_last_order
FROM fct_customers 
WHERE customer_segment = 'bimpli_not_migrated'
ORDER BY total_bimpli_business_volume DESC
LIMIT 50  -- Top 50 targets