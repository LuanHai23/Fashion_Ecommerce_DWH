USE FashionEcommerceDW;
GO

SELECT 
    'customers' AS table_name,
    customer_id,
    COUNT(*) AS duplicate_count
FROM stg.customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT 
    'products' AS table_name,
    product_id,
    COUNT(*) AS duplicate_count
FROM stg.products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT 
    'orders' AS table_name,
    order_id,
    COUNT(*) AS duplicate_count
FROM stg.orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT 
    'promotions' AS table_name,
    promo_id,
    COUNT(*) AS duplicate_count
FROM stg.promotions
WHERE promo_id IS NOT NULL
GROUP BY promo_id
HAVING COUNT(*) > 1;

SELECT 
    'returns' AS table_name,
    return_id,
    COUNT(*) AS duplicate_count
FROM stg.returns
GROUP BY return_id
HAVING COUNT(*) > 1;

SELECT 
    'reviews' AS table_name,
    review_id,
    COUNT(*) AS duplicate_count
FROM stg.reviews
GROUP BY review_id
HAVING COUNT(*) > 1;
