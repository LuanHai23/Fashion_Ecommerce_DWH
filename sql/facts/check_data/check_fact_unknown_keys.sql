USE FashionEcommerceDW;
GO

SELECT
    'fact_sales_order_item' AS table_name,
    SUM(CASE WHEN customer_key = -1 THEN 1 ELSE 0 END) AS unknown_customer_key,
    SUM(CASE WHEN product_key = -1 THEN 1 ELSE 0 END) AS unknown_product_key,
    SUM(CASE WHEN geography_key = -1 THEN 1 ELSE 0 END) AS unknown_geography_key,
    SUM(CASE WHEN payment_method_key = -1 THEN 1 ELSE 0 END) AS unknown_payment_method_key,
    SUM(CASE WHEN device_key = -1 THEN 1 ELSE 0 END) AS unknown_device_key,
    SUM(CASE WHEN order_source_key = -1 THEN 1 ELSE 0 END) AS unknown_order_source_key,
    SUM(CASE WHEN promotion_key_1 = -1 THEN 1 ELSE 0 END) AS no_or_unknown_promotion_1,
    SUM(CASE WHEN promotion_key_2 = -1 THEN 1 ELSE 0 END) AS no_or_unknown_promotion_2
FROM dwh.fact_sales_order_item;

SELECT
    'fact_payment' AS table_name,
    SUM(CASE WHEN customer_key = -1 THEN 1 ELSE 0 END) AS unknown_customer_key,
    SUM(CASE WHEN payment_method_key = -1 THEN 1 ELSE 0 END) AS unknown_payment_method_key
FROM dwh.fact_payment;

SELECT
    'fact_shipment' AS table_name,
    SUM(CASE WHEN customer_key = -1 THEN 1 ELSE 0 END) AS unknown_customer_key,
    SUM(CASE WHEN geography_key = -1 THEN 1 ELSE 0 END) AS unknown_geography_key
FROM dwh.fact_shipment;

SELECT
    'fact_return' AS table_name,
    SUM(CASE WHEN customer_key = -1 THEN 1 ELSE 0 END) AS unknown_customer_key,
    SUM(CASE WHEN product_key = -1 THEN 1 ELSE 0 END) AS unknown_product_key,
    SUM(CASE WHEN geography_key = -1 THEN 1 ELSE 0 END) AS unknown_geography_key,
    SUM(CASE WHEN return_reason_key = -1 THEN 1 ELSE 0 END) AS unknown_return_reason_key
FROM dwh.fact_return;

SELECT
    'fact_review' AS table_name,
    SUM(CASE WHEN customer_key = -1 THEN 1 ELSE 0 END) AS unknown_customer_key,
    SUM(CASE WHEN product_key = -1 THEN 1 ELSE 0 END) AS unknown_product_key
FROM dwh.fact_review;