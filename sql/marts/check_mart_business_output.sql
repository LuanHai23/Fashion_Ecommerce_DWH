USE FashionEcommerceDW;
GO

------------------------------------------------------------
-- Executive daily overview
------------------------------------------------------------

SELECT TOP 20
    full_date,
    total_orders,
    total_customers,
    total_quantity,
    net_revenue,
    gross_profit,
    profit_margin,
    average_order_value
FROM mart.vw_sales_overview_daily
ORDER BY full_date;

------------------------------------------------------------
-- Top products by revenue
------------------------------------------------------------

SELECT TOP 20
    product_id,
    product_name,
    category,
    segment,
    total_quantity_sold,
    net_revenue,
    gross_profit,
    profit_margin,
    return_quantity_rate,
    avg_rating
FROM mart.vw_product_performance
ORDER BY net_revenue DESC;

------------------------------------------------------------
-- Revenue by region
------------------------------------------------------------

SELECT TOP 20
    region,
    city,
    acquisition_channel,
    total_customers,
    total_orders,
    net_revenue,
    average_order_value
FROM mart.vw_customer_geography
ORDER BY net_revenue DESC;

------------------------------------------------------------
-- Return analysis
------------------------------------------------------------

SELECT TOP 20
    return_reason,
    category,
    segment,
    return_rows,
    total_return_quantity,
    total_refund_amount,
    avg_days_to_return
FROM mart.vw_return_analysis
ORDER BY return_rows DESC;

------------------------------------------------------------
-- Inventory health
------------------------------------------------------------

SELECT TOP 20
    product_id,
    product_name,
    category,
    stock_on_hand,
    units_sold,
    stockout_records,
    overstock_records,
    reorder_records,
    avg_sell_through_rate
FROM mart.vw_inventory_health
ORDER BY reorder_records DESC, stockout_records DESC;

------------------------------------------------------------
-- Traffic + sales
------------------------------------------------------------

SELECT TOP 20
    full_date,
    sessions,
    unique_visitors,
    page_views,
    avg_bounce_rate,
    revenue,
    revenue_per_session
FROM mart.vw_traffic_sales_daily
ORDER BY full_date;