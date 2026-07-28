USE FashionEcommerceDW;
GO

SELECT
    reconciliation_status,
    COUNT(*) AS day_count,
    SUM(revenue_from_sales_file) AS total_sales_file_revenue,
    SUM(gross_revenue_from_order_items) AS total_order_items_gross_revenue,
    SUM(net_revenue_from_order_items) AS total_order_items_net_revenue,
    SUM(revenue_diff_vs_gross) AS total_diff_vs_gross,
    SUM(revenue_diff_vs_net) AS total_diff_vs_net
FROM dq.revenue_reconciliation
GROUP BY reconciliation_status
ORDER BY day_count DESC;

SELECT TOP 50
    sales_date,
    revenue_from_sales_file,
    gross_revenue_from_order_items,
    net_revenue_from_order_items,
    revenue_diff_vs_gross,
    revenue_diff_vs_net,
    revenue_diff_pct_vs_gross,
    revenue_diff_pct_vs_net,
    reconciliation_status
FROM dq.revenue_reconciliation
ORDER BY ABS(ISNULL(revenue_diff_vs_net, 0)) DESC;