CREATE TABLE stg_swile_gift_orders AS (
SELECT
  SOURCE_SYSTEM AS source_system,
  CAST(ORDER_ITEMS__FULFILLED_AT AS DATE) AS order_item_fulfilled_date,
  ORDER_ITEMS__ID AS order_item_id,
  ORDER_ITEMS__STATUS AS order_item_status,
  ORDERS__ID AS order_id,
  COMPANIES__ID AS company_id,
  COMPANIES__SALESFORCE_ACCOUNT_ID AS company_salesforce_account_id,
  COMPANIES__SIRET AS company_siret,
  BUSINESS_VOLUME_AMOUNT AS business_volume_amount
FROM migration_data.gift_swile_orders
)