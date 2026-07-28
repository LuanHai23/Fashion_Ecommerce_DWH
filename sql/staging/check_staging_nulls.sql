USE FashionEcommerceDW;
GO

SELECT 
    'stg.orders' AS table_name,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id
FROM stg.orders;

SELECT 
    'stg.order_items' AS table_name,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS null_quantity,
    SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS null_unit_price
FROM stg.order_items;

SELECT 
    'stg.products' AS table_name,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN cogs IS NULL THEN 1 ELSE 0 END) AS null_cogs
FROM stg.products;

SELECT 
    'stg.customers' AS table_name,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN signup_date IS NULL THEN 1 ELSE 0 END) AS null_signup_date
FROM stg.customers;

SELECT 
    'stg.returns' AS table_name,
    SUM(CASE WHEN return_id IS NULL THEN 1 ELSE 0 END) AS null_return_id,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN return_date IS NULL THEN 1 ELSE 0 END) AS null_return_date
FROM stg.returns;

SELECT 
    'stg.shipments' AS table_name,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN ship_date IS NULL THEN 1 ELSE 0 END) AS null_ship_date,
    SUM(CASE WHEN delivery_date IS NULL THEN 1 ELSE 0 END) AS null_delivery_date
FROM stg.shipments;