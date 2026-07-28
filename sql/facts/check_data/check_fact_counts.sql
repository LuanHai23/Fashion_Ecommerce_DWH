USE FashionEcommerceDW;
GO

SELECT 'fact_sales_order_item' AS table_name, COUNT(*) AS row_count 
FROM dwh.fact_sales_order_item
UNION ALL
SELECT 'fact_payment', COUNT(*) 
FROM dwh.fact_payment
UNION ALL
SELECT 'fact_shipment', COUNT(*) 
FROM dwh.fact_shipment
UNION ALL
SELECT 'fact_return', COUNT(*) 
FROM dwh.fact_return
UNION ALL
SELECT 'fact_review', COUNT(*) 
FROM dwh.fact_review
ORDER BY table_name;