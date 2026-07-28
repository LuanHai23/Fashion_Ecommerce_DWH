USE FashionEcommerceDW;
GO

SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS total_order_items,
    SUM(quantity) AS total_quantity,
    SUM(gross_revenue) AS total_gross_revenue,
    SUM(net_revenue) AS total_net_revenue,
    SUM(estimated_cogs) AS total_estimated_cogs,
    SUM(gross_profit) AS total_gross_profit
FROM dwh.fact_sales_order_item;

SELECT TOP 10
    dp.category,
    SUM(f.net_revenue) AS net_revenue,
    SUM(f.gross_profit) AS gross_profit,
    SUM(f.quantity) AS total_quantity
FROM dwh.fact_sales_order_item f
JOIN dwh.dim_product dp
    ON f.product_key = dp.product_key
GROUP BY dp.category
ORDER BY net_revenue DESC;

SELECT TOP 10
    dg.region,
    SUM(f.net_revenue) AS net_revenue,
    COUNT(DISTINCT f.order_id) AS total_orders
FROM dwh.fact_sales_order_item f
JOIN dwh.dim_geography dg
    ON f.geography_key = dg.geography_key
GROUP BY dg.region
ORDER BY net_revenue DESC;

SELECT TOP 10
    drr.return_reason,
    COUNT(*) AS return_rows,
    SUM(fr.refund_amount) AS refund_amount
FROM dwh.fact_return fr
JOIN dwh.dim_return_reason drr
    ON fr.return_reason_key = drr.return_reason_key
GROUP BY drr.return_reason
ORDER BY return_rows DESC;