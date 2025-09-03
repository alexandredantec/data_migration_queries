--compare Swile customers by company size 
SELECT 
  DATE_TRUNC('month', orders.order_item_fulfilled_date) as month,
  salesforce_account_team_dynamic,
  SUM(orders.business_volume_amount) as monthly_bv
FROM fct_orders AS orders 
LEFT JOIN dim_customers customers ON orders.company_id = customers.company_id 
WHERE orders.customer_segment = 'swile_native'
GROUP BY DATE_TRUNC('month', order_item_fulfilled_date), salesforce_account_team_dynamic
ORDER BY salesforce_account_team_dynamic, month