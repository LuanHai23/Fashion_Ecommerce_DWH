USE FashionEcommerceDW;
GO

SELECT 'dim_date' AS table_name, COUNT(*) AS row_count FROM dwh.dim_date
UNION ALL
SELECT 'dim_geography', COUNT(*) FROM dwh.dim_geography
UNION ALL
SELECT 'dim_customer', COUNT(*) FROM dwh.dim_customer
UNION ALL
SELECT 'dim_product', COUNT(*) FROM dwh.dim_product
UNION ALL
SELECT 'dim_promotion', COUNT(*) FROM dwh.dim_promotion
UNION ALL
SELECT 'dim_payment_method', COUNT(*) FROM dwh.dim_payment_method
UNION ALL
SELECT 'dim_device', COUNT(*) FROM dwh.dim_device
UNION ALL
SELECT 'dim_order_source', COUNT(*) FROM dwh.dim_order_source
UNION ALL
SELECT 'dim_return_reason', COUNT(*) FROM dwh.dim_return_reason
ORDER BY table_name;

