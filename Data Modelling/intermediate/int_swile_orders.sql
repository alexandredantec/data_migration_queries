CREATE TABLE int_swile_orders AS 
SELECT
  order_item_id,
  order_id,
  company_id,
  company_salesforce_account_id,
  company_siret,
  'gift' as order_type,
  source_system,
  lower(order_item_status) AS order_item_status,
  business_volume_amount,
  order_item_fulfilled_date,
FROM stg_swile_gift_orders
UNION ALL 
SELECT
  order_item_id,
  order_id,
  company_id,
  company_salesforce_account_id,
  company_siret,
  'meal_voucher' as order_type, 
  source_system,
  lower(order_item_status) AS order_item_status,
  business_volume_amount,
  order_item_fulfilled_date,
FROM stg_swile_mealvoucher_orders