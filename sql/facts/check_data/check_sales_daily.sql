USE FashionEcommerceDW;
GO

SELECT
    COUNT(*) AS invalid_sales_daily_rows
FROM dwh.fact_sales_daily
WHERE revenue < 0
   OR cogs < 0;

SELECT
    COUNT(*) AS total_days,
    SUM(revenue) AS total_revenue,
    SUM(cogs) AS total_cogs,
    SUM(gross_profit) AS total_gross_profit,
    AVG(revenue) AS avg_daily_revenue
FROM dwh.fact_sales_daily;

SELECT TOP 20
    sales_date,
    revenue,
    cogs,
    gross_profit
FROM dwh.fact_sales_daily
ORDER BY sales_date;