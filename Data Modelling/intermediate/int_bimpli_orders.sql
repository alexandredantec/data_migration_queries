CREATE TABLE int_bimpli_orders AS 
SELECT
  order_item_id,
  NULL AS order_id,
  company_id,
  company_siret,
  'gift' as order_type,
  source_system,
  NULL AS order_item_status,
  business_volume_amount,
  order_item_fulfilled_date,
FROM stg_bimpli_gift_orders
UNION ALL 
SELECT
  order_item_id,
  order_id,
  company_id,
  company_siret,
  'meal_voucher' as order_type,
  source_system,
  CASE
    WHEN order_item_status = 'success'
      THEN 'succeeded'
    ELSE order_item_status
  END AS order_item_status,
  business_volume_amount,
  order_item_fulfilled_date,
FROM stg_bimpli_mealvoucher_orders