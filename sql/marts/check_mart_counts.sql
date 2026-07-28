USE FashionEcommerceDW;
GO

SELECT 'vw_sales_overview_daily' AS mart_name, COUNT(*) AS row_count
FROM mart.vw_sales_overview_daily
UNION ALL
SELECT 'vw_product_performance', COUNT(*)
FROM mart.vw_product_performance
UNION ALL
SELECT 'vw_customer_geography', COUNT(*)
FROM mart.vw_customer_geography
UNION ALL
SELECT 'vw_return_analysis', COUNT(*)
FROM mart.vw_return_analysis
UNION ALL
SELECT 'vw_inventory_health', COUNT(*)
FROM mart.vw_inventory_health
UNION ALL
SELECT 'vw_traffic_sales_daily', COUNT(*)
FROM mart.vw_traffic_sales_daily
UNION ALL
SELECT 'vw_web_traffic_by_source', COUNT(*)
FROM mart.vw_web_traffic_by_source
UNION ALL
SELECT 'vw_revenue_reconciliation', COUNT(*)
FROM mart.vw_revenue_reconciliation
ORDER BY mart_name;