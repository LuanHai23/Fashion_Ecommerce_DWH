USE FashionEcommerceDW;
GO

------------------------------------------------------------
-- Inventory by category
------------------------------------------------------------

SELECT TOP 10
    dp.category,
    SUM(fi.stock_on_hand) AS total_stock_on_hand,
    SUM(fi.units_sold) AS total_units_sold,
    SUM(CASE WHEN fi.stockout_flag = 1 THEN 1 ELSE 0 END) AS stockout_records,
    SUM(CASE WHEN fi.reorder_flag = 1 THEN 1 ELSE 0 END) AS reorder_records,
    AVG(CAST(fi.sell_through_rate AS FLOAT)) AS avg_sell_through_rate
FROM dwh.fact_inventory_snapshot fi
JOIN dwh.dim_product dp
    ON fi.product_key = dp.product_key
GROUP BY dp.category
ORDER BY total_units_sold DESC;

------------------------------------------------------------
-- Web traffic by source
------------------------------------------------------------

SELECT
    traffic_source,
    SUM(sessions) AS total_sessions,
    SUM(unique_visitors) AS total_unique_visitors,
    SUM(page_views) AS total_page_views,
    AVG(CAST(bounce_rate AS FLOAT)) AS avg_bounce_rate
FROM dwh.fact_web_traffic_daily
GROUP BY traffic_source
ORDER BY total_sessions DESC;

------------------------------------------------------------
-- Revenue trend by year/month from sales daily
------------------------------------------------------------

SELECT
    dd.[year],
    dd.[month],
    SUM(fs.revenue) AS revenue,
    SUM(fs.cogs) AS cogs,
    SUM(fs.gross_profit) AS gross_profit
FROM dwh.fact_sales_daily fs
JOIN dwh.dim_date dd
    ON fs.sales_date_key = dd.date_key
GROUP BY dd.[year], dd.[month]
ORDER BY dd.[year], dd.[month];

------------------------------------------------------------
-- Compare traffic and sales by date
------------------------------------------------------------

SELECT TOP 30
    dd.full_date,
    fs.revenue,
    SUM(wt.sessions) AS sessions,
    SUM(wt.page_views) AS page_views
FROM dwh.dim_date dd
LEFT JOIN dwh.fact_sales_daily fs
    ON dd.date_key = fs.sales_date_key
LEFT JOIN dwh.fact_web_traffic_daily wt
    ON dd.date_key = wt.traffic_date_key
WHERE fs.revenue IS NOT NULL
GROUP BY dd.full_date, fs.revenue
ORDER BY dd.full_date;