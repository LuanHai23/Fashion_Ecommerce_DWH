USE FashionEcommerceDW;
GO

SELECT
    COUNT(*) AS invalid_revenue_rows
FROM dwh.fact_sales_order_item
WHERE gross_revenue < 0
   OR net_revenue < 0
   OR discount_amount < 0
   OR discount_amount > gross_revenue;

SELECT TOP 20
    order_id,
    product_id,
    quantity,
    unit_price,
    discount_amount,
    gross_revenue,
    net_revenue,
    estimated_cogs,
    gross_profit
FROM dwh.fact_sales_order_item
ORDER BY sales_order_item_key;