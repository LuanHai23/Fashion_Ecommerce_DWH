USE FashionEcommerceDW;
GO

SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM raw.customers
UNION ALL
SELECT 'geography', COUNT(*) FROM raw.geography
UNION ALL
SELECT 'inventory', COUNT(*) FROM raw.inventory
UNION ALL
SELECT 'order_items', COUNT(*) FROM raw.order_items
UNION ALL
SELECT 'orders', COUNT(*) FROM raw.orders
UNION ALL
SELECT 'payments', COUNT(*) FROM raw.payments
UNION ALL
SELECT 'products', COUNT(*) FROM raw.products
UNION ALL
SELECT 'promotions', COUNT(*) FROM raw.promotions
UNION ALL
SELECT 'returns', COUNT(*) FROM raw.returns
UNION ALL
SELECT 'reviews', COUNT(*) FROM raw.reviews
UNION ALL
SELECT 'sales', COUNT(*) FROM raw.sales
UNION ALL
SELECT 'shipments', COUNT(*) FROM raw.shipments
UNION ALL
SELECT 'web_traffic', COUNT(*) FROM raw.web_traffic
ORDER BY table_name;