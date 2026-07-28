USE FashionEcommerceDW;
GO

SELECT 'dim_geography' AS table_name, * 
FROM dwh.dim_geography 
WHERE geography_key = -1;

SELECT 'dim_customer' AS table_name, * 
FROM dwh.dim_customer 
WHERE customer_key = -1;

SELECT 'dim_product' AS table_name, * 
FROM dwh.dim_product 
WHERE product_key = -1;

SELECT 'dim_promotion' AS table_name, * 
FROM dwh.dim_promotion 
WHERE promotion_key = -1;

SELECT 'dim_payment_method' AS table_name, * 
FROM dwh.dim_payment_method 
WHERE payment_method_key = -1;

SELECT 'dim_device' AS table_name, * 
FROM dwh.dim_device 
WHERE device_key = -1;

SELECT 'dim_order_source' AS table_name, * 
FROM dwh.dim_order_source 
WHERE order_source_key = -1;

SELECT 'dim_return_reason' AS table_name, * 
FROM dwh.dim_return_reason 
WHERE return_reason_key = -1;