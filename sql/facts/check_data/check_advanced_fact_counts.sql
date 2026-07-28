USE FashionEcommerceDW;
GO

SELECT 'fact_inventory_snapshot' AS table_name, COUNT(*) AS row_count
FROM dwh.fact_inventory_snapshot
UNION ALL
SELECT 'fact_web_traffic_daily', COUNT(*)
FROM dwh.fact_web_traffic_daily
UNION ALL
SELECT 'fact_sales_daily', COUNT(*)
FROM dwh.fact_sales_daily
UNION ALL
SELECT 'revenue_reconciliation', COUNT(*)
FROM dq.revenue_reconciliation
ORDER BY table_name;