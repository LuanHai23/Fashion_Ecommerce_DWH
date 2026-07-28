USE FashionEcommerceDW;
GO

------------------------------------------------------------
-- 1. Sales Overview Daily
------------------------------------------------------------

CREATE OR ALTER VIEW mart.vw_sales_overview_daily AS
SELECT
    dd.date_key,
    dd.full_date,
    dd.[year],
    dd.[quarter],
    dd.[month],
    dd.month_name,
    dd.[day],
    dd.day_name,
    dd.is_weekend,

    COUNT(DISTINCT f.order_id) AS total_orders,
    COUNT(*) AS total_order_items,
    COUNT(DISTINCT f.customer_id) AS total_customers,

    SUM(f.quantity) AS total_quantity,
    SUM(f.gross_revenue) AS gross_revenue,
    SUM(f.discount_amount) AS discount_amount,
    SUM(f.net_revenue) AS net_revenue,
    SUM(f.estimated_cogs) AS estimated_cogs,
    SUM(f.gross_profit) AS gross_profit,

    CASE 
        WHEN SUM(f.net_revenue) = 0 THEN NULL
        ELSE SUM(f.gross_profit) / SUM(f.net_revenue)
    END AS profit_margin,

    CASE 
        WHEN COUNT(DISTINCT f.order_id) = 0 THEN NULL
        ELSE SUM(f.net_revenue) / COUNT(DISTINCT f.order_id)
    END AS average_order_value,

    COUNT(DISTINCT CASE WHEN f.order_status = 'delivered' THEN f.order_id END) AS delivered_orders,
    COUNT(DISTINCT CASE WHEN f.order_status = 'cancelled' THEN f.order_id END) AS cancelled_orders,
    COUNT(DISTINCT CASE WHEN f.order_status = 'returned' THEN f.order_id END) AS returned_orders,

    SUM(CASE WHEN f.order_status = 'delivered' THEN f.net_revenue ELSE 0 END) AS delivered_net_revenue,
    SUM(CASE WHEN f.order_status = 'cancelled' THEN f.net_revenue ELSE 0 END) AS cancelled_net_revenue,
    SUM(CASE WHEN f.order_status = 'returned' THEN f.net_revenue ELSE 0 END) AS returned_net_revenue
FROM dwh.fact_sales_order_item f
LEFT JOIN dwh.dim_date dd
    ON f.order_date_key = dd.date_key
GROUP BY
    dd.date_key,
    dd.full_date,
    dd.[year],
    dd.[quarter],
    dd.[month],
    dd.month_name,
    dd.[day],
    dd.day_name,
    dd.is_weekend;
GO

------------------------------------------------------------
-- 2. Product Performance
------------------------------------------------------------

CREATE OR ALTER VIEW mart.vw_product_performance AS
WITH sales_by_product AS (
    SELECT
        product_key,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(*) AS total_order_items,
        SUM(quantity) AS total_quantity_sold,
        SUM(gross_revenue) AS gross_revenue,
        SUM(discount_amount) AS discount_amount,
        SUM(net_revenue) AS net_revenue,
        SUM(estimated_cogs) AS estimated_cogs,
        SUM(gross_profit) AS gross_profit
    FROM dwh.fact_sales_order_item
    GROUP BY product_key
),
returns_by_product AS (
    SELECT
        product_key,
        COUNT(*) AS return_rows,
        SUM(return_quantity) AS total_return_quantity,
        SUM(refund_amount) AS total_refund_amount
    FROM dwh.fact_return
    GROUP BY product_key
),
reviews_by_product AS (
    SELECT
        product_key,
        COUNT(*) AS total_reviews,
        AVG(CAST(rating AS FLOAT)) AS avg_rating
    FROM dwh.fact_review
    GROUP BY product_key
)
SELECT
    dp.product_key,
    dp.product_id,
    dp.product_name,
    dp.category,
    dp.segment,
    dp.size,
    dp.color,
    dp.standard_price,
    dp.standard_cogs,

    ISNULL(s.total_orders, 0) AS total_orders,
    ISNULL(s.total_order_items, 0) AS total_order_items,
    ISNULL(s.total_quantity_sold, 0) AS total_quantity_sold,
    ISNULL(s.gross_revenue, 0) AS gross_revenue,
    ISNULL(s.discount_amount, 0) AS discount_amount,
    ISNULL(s.net_revenue, 0) AS net_revenue,
    ISNULL(s.estimated_cogs, 0) AS estimated_cogs,
    ISNULL(s.gross_profit, 0) AS gross_profit,

    CASE 
        WHEN ISNULL(s.net_revenue, 0) = 0 THEN NULL
        ELSE s.gross_profit / s.net_revenue
    END AS profit_margin,

    ISNULL(r.return_rows, 0) AS return_rows,
    ISNULL(r.total_return_quantity, 0) AS total_return_quantity,
    ISNULL(r.total_refund_amount, 0) AS total_refund_amount,

    CASE 
        WHEN ISNULL(s.total_quantity_sold, 0) = 0 THEN NULL
        ELSE CAST(ISNULL(r.total_return_quantity, 0) AS FLOAT) / s.total_quantity_sold
    END AS return_quantity_rate,

    ISNULL(rv.total_reviews, 0) AS total_reviews,
    rv.avg_rating
FROM dwh.dim_product dp
LEFT JOIN sales_by_product s
    ON dp.product_key = s.product_key
LEFT JOIN returns_by_product r
    ON dp.product_key = r.product_key
LEFT JOIN reviews_by_product rv
    ON dp.product_key = rv.product_key
WHERE dp.product_key <> -1;
GO

------------------------------------------------------------
-- 3. Customer & Geography Analysis
------------------------------------------------------------

CREATE OR ALTER VIEW mart.vw_customer_geography AS
SELECT
    dg.geography_key,
    dg.zip,
    dg.city,
    dg.region,
    dg.district,

    dc.gender,
    dc.age_group,
    dc.acquisition_channel,

    COUNT(DISTINCT f.customer_id) AS total_customers,
    COUNT(DISTINCT f.order_id) AS total_orders,
    COUNT(*) AS total_order_items,

    SUM(f.quantity) AS total_quantity,
    SUM(f.net_revenue) AS net_revenue,
    SUM(f.gross_profit) AS gross_profit,

    CASE 
        WHEN SUM(f.net_revenue) = 0 THEN NULL
        ELSE SUM(f.gross_profit) / SUM(f.net_revenue)
    END AS profit_margin,

    CASE 
        WHEN COUNT(DISTINCT f.order_id) = 0 THEN NULL
        ELSE SUM(f.net_revenue) / COUNT(DISTINCT f.order_id)
    END AS average_order_value
FROM dwh.fact_sales_order_item f
LEFT JOIN dwh.dim_geography dg
    ON f.geography_key = dg.geography_key
LEFT JOIN dwh.dim_customer dc
    ON f.customer_key = dc.customer_key
GROUP BY
    dg.geography_key,
    dg.zip,
    dg.city,
    dg.region,
    dg.district,
    dc.gender,
    dc.age_group,
    dc.acquisition_channel;
GO

------------------------------------------------------------
-- 4. Return Analysis
------------------------------------------------------------

CREATE OR ALTER VIEW mart.vw_return_analysis AS
SELECT
    return_date.date_key AS return_date_key,
    return_date.full_date AS return_date,
    return_date.[year],
    return_date.[quarter],
    return_date.[month],
    return_date.month_name,

    dp.product_key,
    dp.product_id,
    dp.product_name,
    dp.category,
    dp.segment,
    dp.size,
    dp.color,

    dg.region,
    dg.city,

    drr.return_reason,

    COUNT(*) AS return_rows,
    COUNT(DISTINCT fr.order_id) AS returned_orders,
    SUM(fr.return_quantity) AS total_return_quantity,
    SUM(fr.refund_amount) AS total_refund_amount,
    AVG(CAST(fr.days_to_return AS FLOAT)) AS avg_days_to_return
FROM dwh.fact_return fr
LEFT JOIN dwh.dim_date return_date
    ON fr.return_date_key = return_date.date_key
LEFT JOIN dwh.dim_product dp
    ON fr.product_key = dp.product_key
LEFT JOIN dwh.dim_geography dg
    ON fr.geography_key = dg.geography_key
LEFT JOIN dwh.dim_return_reason drr
    ON fr.return_reason_key = drr.return_reason_key
GROUP BY
    return_date.date_key,
    return_date.full_date,
    return_date.[year],
    return_date.[quarter],
    return_date.[month],
    return_date.month_name,
    dp.product_key,
    dp.product_id,
    dp.product_name,
    dp.category,
    dp.segment,
    dp.size,
    dp.color,
    dg.region,
    dg.city,
    drr.return_reason;
GO

------------------------------------------------------------
-- 5. Inventory Health
------------------------------------------------------------

CREATE OR ALTER VIEW mart.vw_inventory_health AS
SELECT
    dd.date_key AS snapshot_date_key,
    dd.full_date AS snapshot_date,
    dd.[year],
    dd.[quarter],
    dd.[month],
    dd.month_name,

    dp.product_key,
    dp.product_id,
    dp.product_name,
    dp.category,
    dp.segment,
    dp.size,
    dp.color,

    SUM(fi.stock_on_hand) AS stock_on_hand,
    SUM(fi.units_received) AS units_received,
    SUM(fi.units_sold) AS units_sold,
    SUM(fi.stockout_days) AS stockout_days,

    AVG(CAST(fi.days_of_supply AS FLOAT)) AS avg_days_of_supply,
    AVG(CAST(fi.fill_rate AS FLOAT)) AS avg_fill_rate,
    AVG(CAST(fi.sell_through_rate AS FLOAT)) AS avg_sell_through_rate,

    SUM(CASE WHEN fi.stockout_flag = 1 THEN 1 ELSE 0 END) AS stockout_records,
    SUM(CASE WHEN fi.overstock_flag = 1 THEN 1 ELSE 0 END) AS overstock_records,
    SUM(CASE WHEN fi.reorder_flag = 1 THEN 1 ELSE 0 END) AS reorder_records
FROM dwh.fact_inventory_snapshot fi
LEFT JOIN dwh.dim_date dd
    ON fi.snapshot_date_key = dd.date_key
LEFT JOIN dwh.dim_product dp
    ON fi.product_key = dp.product_key
GROUP BY
    dd.date_key,
    dd.full_date,
    dd.[year],
    dd.[quarter],
    dd.[month],
    dd.month_name,
    dp.product_key,
    dp.product_id,
    dp.product_name,
    dp.category,
    dp.segment,
    dp.size,
    dp.color;
GO

------------------------------------------------------------
-- 6. Traffic + Sales Daily
------------------------------------------------------------

CREATE OR ALTER VIEW mart.vw_traffic_sales_daily AS
WITH traffic_daily AS (
    SELECT
        traffic_date_key,
        SUM(sessions) AS sessions,
        SUM(unique_visitors) AS unique_visitors,
        SUM(page_views) AS page_views,
        AVG(CAST(bounce_rate AS FLOAT)) AS avg_bounce_rate,
        AVG(CAST(avg_session_duration_sec AS FLOAT)) AS avg_session_duration_sec
    FROM dwh.fact_web_traffic_daily
    GROUP BY traffic_date_key
)
SELECT
    dd.date_key,
    dd.full_date,
    dd.[year],
    dd.[quarter],
    dd.[month],
    dd.month_name,
    dd.day_name,
    dd.is_weekend,

    ISNULL(t.sessions, 0) AS sessions,
    ISNULL(t.unique_visitors, 0) AS unique_visitors,
    ISNULL(t.page_views, 0) AS page_views,
    t.avg_bounce_rate,
    t.avg_session_duration_sec,

    fs.revenue,
    fs.cogs,
    fs.gross_profit,

    CASE
        WHEN ISNULL(t.sessions, 0) = 0 THEN NULL
        ELSE fs.revenue / t.sessions
    END AS revenue_per_session
FROM dwh.dim_date dd
LEFT JOIN traffic_daily t
    ON dd.date_key = t.traffic_date_key
LEFT JOIN dwh.fact_sales_daily fs
    ON dd.date_key = fs.sales_date_key
WHERE t.traffic_date_key IS NOT NULL
   OR fs.sales_date_key IS NOT NULL;
GO

------------------------------------------------------------
-- 7. Web Traffic by Source
------------------------------------------------------------

CREATE OR ALTER VIEW mart.vw_web_traffic_by_source AS
SELECT
    dd.date_key,
    dd.full_date,
    dd.[year],
    dd.[quarter],
    dd.[month],
    dd.month_name,

    wt.traffic_source,

    SUM(wt.sessions) AS sessions,
    SUM(wt.unique_visitors) AS unique_visitors,
    SUM(wt.page_views) AS page_views,
    AVG(CAST(wt.bounce_rate AS FLOAT)) AS avg_bounce_rate,
    AVG(CAST(wt.avg_session_duration_sec AS FLOAT)) AS avg_session_duration_sec
FROM dwh.fact_web_traffic_daily wt
LEFT JOIN dwh.dim_date dd
    ON wt.traffic_date_key = dd.date_key
GROUP BY
    dd.date_key,
    dd.full_date,
    dd.[year],
    dd.[quarter],
    dd.[month],
    dd.month_name,
    wt.traffic_source;
GO

------------------------------------------------------------
-- 8. Revenue Reconciliation
------------------------------------------------------------

CREATE OR ALTER VIEW mart.vw_revenue_reconciliation AS
SELECT
    rr.sales_date_key,
    rr.sales_date,

    dd.[year],
    dd.[quarter],
    dd.[month],
    dd.month_name,

    rr.revenue_from_sales_file,
    rr.cogs_from_sales_file,
    rr.gross_profit_from_sales_file,

    rr.gross_revenue_from_order_items,
    rr.net_revenue_from_order_items,
    rr.estimated_cogs_from_order_items,
    rr.gross_profit_from_order_items,

    rr.revenue_diff_vs_gross,
    rr.revenue_diff_vs_net,
    rr.revenue_diff_pct_vs_gross,
    rr.revenue_diff_pct_vs_net,

    rr.reconciliation_status
FROM dq.revenue_reconciliation rr
LEFT JOIN dwh.dim_date dd
    ON rr.sales_date_key = dd.date_key;
GO