-- identify how each segment performs
SELECT 
  customer_segment,
  COUNT(*) as customers,
  ROUND(SUM(COALESCE(total_swile_business_volume,0) + COALESCE(total_bimpli_business_volume,0))) as total_bv,
  ROUND(AVG(COALESCE(total_swile_business_volume,0) + COALESCE(total_bimpli_business_volume,0))) as avg_bv_per_customer
FROM fct_customers 
GROUP BY customer_segment
ORDER BY total_bv DESC