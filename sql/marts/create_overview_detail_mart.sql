USE FashionEcommerceDW;
GO

CREATE OR ALTER VIEW mart.vw_overview_order_item AS
SELECT
    f.sales_order_item_key,
    f.order_id,
    f.customer_id,

    dd.full_date AS order_date,
    DATEFROMPARTS(dd.[year], dd.[month], 1) AS month_start,
    dd.[year],
    dd.[quarter],
    dd.[month],
    dd.month_name,

    dg.region,
    dp.segment,

    f.order_status,
    f.quantity,
    f.net_revenue,
    f.gross_profit
FROM dwh.fact_sales_order_item f
LEFT JOIN dwh.dim_date dd
    ON f.order_date_key = dd.date_key
LEFT JOIN dwh.dim_geography dg
    ON f.geography_key = dg.geography_key
LEFT JOIN dwh.dim_product dp
    ON f.product_key = dp.product_key;
GO