USE FashionEcommerceDW;
GO

TRUNCATE TABLE dq.revenue_reconciliation;
TRUNCATE TABLE dwh.fact_sales_daily;
TRUNCATE TABLE dwh.fact_web_traffic_daily;
TRUNCATE TABLE dwh.fact_inventory_snapshot;
GO

------------------------------------------------------------
-- 1. Load fact_inventory_snapshot
------------------------------------------------------------

INSERT INTO dwh.fact_inventory_snapshot (
    snapshot_date_key,
    product_key,
    product_id,

    stock_on_hand,
    units_received,
    units_sold,
    stockout_days,
    days_of_supply,
    fill_rate,

    stockout_flag,
    overstock_flag,
    reorder_flag,
    sell_through_rate,

    inventory_year,
    inventory_month
)
SELECT
    dd.date_key AS snapshot_date_key,
    COALESCE(dp.product_key, -1) AS product_key,
    i.product_id,

    i.stock_on_hand,
    i.units_received,
    i.units_sold,
    i.stockout_days,
    i.days_of_supply,
    i.fill_rate,

    i.stockout_flag,
    i.overstock_flag,
    i.reorder_flag,
    i.sell_through_rate,

    i.[year] AS inventory_year,
    i.[month] AS inventory_month
FROM stg.inventory i
LEFT JOIN dwh.dim_date dd
    ON i.snapshot_date = dd.full_date
LEFT JOIN dwh.dim_product dp
    ON i.product_id = dp.product_id;
GO

------------------------------------------------------------
-- 2. Load fact_web_traffic_daily
------------------------------------------------------------

INSERT INTO dwh.fact_web_traffic_daily (
    traffic_date_key,
    traffic_source,

    sessions,
    unique_visitors,
    page_views,
    bounce_rate,
    avg_session_duration_sec
)
SELECT
    dd.date_key AS traffic_date_key,
    wt.traffic_source,

    wt.sessions,
    wt.unique_visitors,
    wt.page_views,
    wt.bounce_rate,
    wt.avg_session_duration_sec
FROM stg.web_traffic wt
LEFT JOIN dwh.dim_date dd
    ON wt.traffic_date = dd.full_date;
GO

------------------------------------------------------------
-- 3. Load fact_sales_daily
------------------------------------------------------------

INSERT INTO dwh.fact_sales_daily (
    sales_date_key,
    sales_date,

    revenue,
    cogs,
    gross_profit
)
SELECT
    dd.date_key AS sales_date_key,
    s.sales_date,

    s.revenue,
    s.cogs,
    s.gross_profit
FROM stg.sales s
LEFT JOIN dwh.dim_date dd
    ON s.sales_date = dd.full_date;
GO

------------------------------------------------------------
-- 4. Load dq.revenue_reconciliation
------------------------------------------------------------

;WITH order_item_daily AS (
    SELECT
        f.order_date_key AS sales_date_key,
        SUM(f.gross_revenue) AS gross_revenue_from_order_items,
        SUM(f.net_revenue) AS net_revenue_from_order_items,
        SUM(f.estimated_cogs) AS estimated_cogs_from_order_items,
        SUM(f.gross_profit) AS gross_profit_from_order_items
    FROM dwh.fact_sales_order_item f
    GROUP BY f.order_date_key
),
sales_file_daily AS (
    SELECT
        fs.sales_date_key,
        fs.sales_date,
        fs.revenue AS revenue_from_sales_file,
        fs.cogs AS cogs_from_sales_file,
        fs.gross_profit AS gross_profit_from_sales_file
    FROM dwh.fact_sales_daily fs
)
INSERT INTO dq.revenue_reconciliation (
    sales_date_key,
    sales_date,

    revenue_from_sales_file,
    cogs_from_sales_file,
    gross_profit_from_sales_file,

    gross_revenue_from_order_items,
    net_revenue_from_order_items,
    estimated_cogs_from_order_items,
    gross_profit_from_order_items,

    revenue_diff_vs_gross,
    revenue_diff_vs_net,

    revenue_diff_pct_vs_gross,
    revenue_diff_pct_vs_net,

    reconciliation_status
)
SELECT
    s.sales_date_key,
    s.sales_date,

    s.revenue_from_sales_file,
    s.cogs_from_sales_file,
    s.gross_profit_from_sales_file,

    oi.gross_revenue_from_order_items,
    oi.net_revenue_from_order_items,
    oi.estimated_cogs_from_order_items,
    oi.gross_profit_from_order_items,

    s.revenue_from_sales_file - ISNULL(oi.gross_revenue_from_order_items, 0) AS revenue_diff_vs_gross,
    s.revenue_from_sales_file - ISNULL(oi.net_revenue_from_order_items, 0) AS revenue_diff_vs_net,

    CASE
        WHEN s.revenue_from_sales_file IS NULL OR s.revenue_from_sales_file = 0 THEN NULL
        ELSE 
            (s.revenue_from_sales_file - ISNULL(oi.gross_revenue_from_order_items, 0))
            / s.revenue_from_sales_file
    END AS revenue_diff_pct_vs_gross,

    CASE
        WHEN s.revenue_from_sales_file IS NULL OR s.revenue_from_sales_file = 0 THEN NULL
        ELSE 
            (s.revenue_from_sales_file - ISNULL(oi.net_revenue_from_order_items, 0))
            / s.revenue_from_sales_file
    END AS revenue_diff_pct_vs_net,

    CASE
        WHEN oi.sales_date_key IS NULL THEN 'missing_order_item_data'
        WHEN ABS(s.revenue_from_sales_file - ISNULL(oi.gross_revenue_from_order_items, 0)) <= 1 THEN 'matched_gross_revenue'
        WHEN ABS(s.revenue_from_sales_file - ISNULL(oi.net_revenue_from_order_items, 0)) <= 1 THEN 'matched_net_revenue'
        ELSE 'mismatch'
    END AS reconciliation_status
FROM sales_file_daily s
LEFT JOIN order_item_daily oi
    ON s.sales_date_key = oi.sales_date_key;
GO