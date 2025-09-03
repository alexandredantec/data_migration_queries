-- compare migrated and non migrated Bimpli customers (across Bimpli products only)
SELECT 
  DATE_TRUNC('month', order_item_fulfilled_date) as month,
  SUM(CASE WHEN customer_segment = 'bimpli_migrated' THEN business_volume_amount ELSE 0 END) as migrated_monthly_bv,
  SUM(CASE WHEN customer_segment = 'bimpli_not_migrated' THEN business_volume_amount ELSE 0 END) as churned_monthly_bv,
FROM fct_orders
WHERE source_system IN ('bimpli_gift', 'bimpli_mv') -- change this to compare across a specific product
AND (order_item_status = 'succeeded' OR order_item_status IS NULL)
GROUP BY DATE_TRUNC('month', order_item_fulfilled_date)
ORDER BY month