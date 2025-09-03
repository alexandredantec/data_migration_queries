-- check monthly BV by customer segment (main analysis)
SELECT 
  DATE_TRUNC('month', order_item_fulfilled_date) as month,
  customer_segment,
  SUM(CASE WHEN order_item_status = 'succeeded' OR order_item_status IS NULL THEN business_volume_amount ELSE 0 END) as monthly_bv
FROM fct_orders
GROUP BY DATE_TRUNC('month', order_item_fulfilled_date), customer_segment
ORDER BY month, customer_segment