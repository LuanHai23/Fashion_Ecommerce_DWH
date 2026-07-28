USE FashionEcommerceDW;
GO

SELECT
    'fact_inventory_snapshot' AS table_name,
    SUM(CASE WHEN product_key = -1 THEN 1 ELSE 0 END) AS unknown_product_key,
    SUM(CASE WHEN snapshot_date_key IS NULL THEN 1 ELSE 0 END) AS null_snapshot_date_key
FROM dwh.fact_inventory_snapshot;

SELECT
    'fact_web_traffic_daily' AS table_name,
    SUM(CASE WHEN traffic_date_key IS NULL THEN 1 ELSE 0 END) AS null_traffic_date_key,
    SUM(CASE WHEN traffic_source IS NULL THEN 1 ELSE 0 END) AS null_traffic_source
FROM dwh.fact_web_traffic_daily;

SELECT
    'fact_sales_daily' AS table_name,
    SUM(CASE WHEN sales_date_key IS NULL THEN 1 ELSE 0 END) AS null_sales_date_key,
    SUM(CASE WHEN sales_date IS NULL THEN 1 ELSE 0 END) AS null_sales_date
FROM dwh.fact_sales_daily;