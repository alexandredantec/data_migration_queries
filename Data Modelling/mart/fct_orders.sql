CREATE TABLE fct_orders AS 
WITH 
bimpli_orders AS (
  SELECT
    bimpli_orders.order_item_id,
    bimpli_orders.order_id,
    customers.company_id,
    customers.customer_segment,
    bimpli_orders.order_type,
    bimpli_orders.source_system,
    bimpli_orders.order_item_status,
    bimpli_orders.business_volume_amount,
    bimpli_orders.order_item_fulfilled_date
  FROM int_bimpli_orders AS bimpli_orders
  LEFT JOIN dim_customers AS customers 
    ON bimpli_orders.company_siret = customers.company_siret
),
swile_orders AS (
  SELECT
    swile_orders.order_item_id,
    swile_orders.order_id,
    customers.company_id,
    customers.customer_segment,
    swile_orders.order_type,
    swile_orders.source_system,
    swile_orders.order_item_status,
    swile_orders.business_volume_amount,
    swile_orders.order_item_fulfilled_date
  FROM int_swile_orders AS swile_orders
  LEFT JOIN dim_customers AS customers 
    ON swile_orders.company_salesforce_account_id = customers.salesforce_account_id
)
SELECT
    order_item_id,
    order_id,
    company_id,
    customer_segment,
    order_type,
    source_system,
    order_item_status,
    business_volume_amount,
    order_item_fulfilled_date
FROM swile_orders
UNION ALL
SELECT
    order_item_id,
    order_id,
    company_id,
    customer_segment,
    order_type,
    source_system,
    order_item_status,
    business_volume_amount,
    order_item_fulfilled_date
FROM bimpli_orders