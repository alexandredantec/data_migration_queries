CREATE TABLE int_bimpli_customers AS

SELECT
  company_siret,
  MIN(CASE WHEN order_item_status = 'succeeded' OR order_item_status IS NULL THEN order_item_fulfilled_date END) AS first_bimpli_order_date,
  MAX(CASE WHEN order_item_status = 'succeeded' OR order_item_status IS NULL THEN order_item_fulfilled_date END) AS latest_bimpli_order_date,
  SUM(CASE WHEN order_item_status = 'succeeded' OR order_item_status IS NULL THEN business_volume_amount ELSE 0 END) AS total_bimpli_business_volume,
  SUM(CASE WHEN (order_item_status = 'succeeded' OR order_item_status IS NULL) AND order_type = 'gift' THEN business_volume_amount ELSE 0 END) AS total_bimpli_gift_business_volume,
  SUM(CASE WHEN (order_item_status = 'succeeded' OR order_item_status IS NULL) AND order_type = 'meal_voucher' THEN business_volume_amount ELSE 0 END) AS total_bimpli_mealvoucher_business_volume,
  COUNT(CASE WHEN order_item_status = 'succeeded' OR order_item_status IS NULL THEN order_item_id END) AS total_bimpli_orders,
  COUNT(CASE WHEN (order_item_status = 'succeeded' OR order_item_status IS NULL) AND order_type = 'gift' THEN order_item_id END) AS total_bimpli_gift_orders,
  COUNT(CASE WHEN (order_item_status = 'succeeded' OR order_item_status IS NULL) AND order_type = 'meal_voucher' THEN order_item_id END) AS total_bimpli_mealvoucher_orders
FROM int_bimpli_orders
GROUP BY company_siret