USE FashionEcommerceDW;
GO

SELECT
    'vw_sales_overview_daily' AS mart_name,
    SUM(CASE WHEN date_key IS NULL THEN 1 ELSE 0 END) AS null_date_key,
    SUM(CASE WHEN full_date IS NULL THEN 1 ELSE 0 END) AS null_full_date,
    SUM(CASE WHEN net_revenue IS NULL THEN 1 ELSE 0 END) AS null_net_revenue
FROM mart.vw_sales_overview_daily;

SELECT
    'vw_product_performance' AS mart_name,
    SUM(CASE WHEN product_key IS NULL THEN 1 ELSE 0 END) AS null_product_key,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) AS null_product_name
FROM mart.vw_product_performance;

SELECT
    'vw_traffic_sales_daily' AS mart_name,
    SUM(CASE WHEN date_key IS NULL THEN 1 ELSE 0 END) AS null_date_key,
    SUM(CASE WHEN full_date IS NULL THEN 1 ELSE 0 END) AS null_full_date
FROM mart.vw_traffic_sales_daily;

SELECT
    'vw_revenue_reconciliation' AS mart_name,
    SUM(CASE WHEN sales_date_key IS NULL THEN 1 ELSE 0 END) AS null_sales_date_key,
    SUM(CASE WHEN sales_date IS NULL THEN 1 ELSE 0 END) AS null_sales_date,
    SUM(CASE WHEN reconciliation_status IS NULL THEN 1 ELSE 0 END) AS null_reconciliation_status
FROM mart.vw_revenue_reconciliation;