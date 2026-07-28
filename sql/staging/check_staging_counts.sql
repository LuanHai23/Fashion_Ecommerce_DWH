USE FashionEcommerceDW;
GO

-- Check xem số lượng records đã được chuyển qua chưa
-- Đối chiếu bên raw schema là đầy đủ rồi thì bên staging cũng phải vậy
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM stg.customers
UNION ALL
SELECT 'geography', COUNT(*) FROM stg.geography
UNION ALL
SELECT 'inventory', COUNT(*) FROM stg.inventory
UNION ALL
SELECT 'order_items', COUNT(*) FROM stg.order_items
UNION ALL
SELECT 'orders', COUNT(*) FROM stg.orders
UNION ALL
SELECT 'payments', COUNT(*) FROM stg.payments
UNION ALL
SELECT 'products', COUNT(*) FROM stg.products
UNION ALL
SELECT 'promotions', COUNT(*) FROM stg.promotions
UNION ALL
SELECT 'returns', COUNT(*) FROM stg.returns
UNION ALL
SELECT 'reviews', COUNT(*) FROM stg.reviews
UNION ALL
SELECT 'sales', COUNT(*) FROM stg.sales
UNION ALL
SELECT 'shipments', COUNT(*) FROM stg.shipments
UNION ALL
SELECT 'web_traffic', COUNT(*) FROM stg.web_traffic
ORDER BY table_name;