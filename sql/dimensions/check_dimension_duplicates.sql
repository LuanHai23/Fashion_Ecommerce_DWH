USE FashionEcommerceDW;
GO

SELECT customer_id, COUNT(*) AS duplicate_count
FROM dwh.dim_customer
WHERE customer_id <> -1
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT product_id, COUNT(*) AS duplicate_count
FROM dwh.dim_product
WHERE product_id <> -1
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT promo_id, COUNT(*) AS duplicate_count
FROM dwh.dim_promotion
WHERE promo_id <> 'no_promo'
GROUP BY promo_id
HAVING COUNT(*) > 1;

SELECT payment_method, COUNT(*) AS duplicate_count
FROM dwh.dim_payment_method
WHERE payment_method <> 'unknown'
GROUP BY payment_method
HAVING COUNT(*) > 1;

SELECT device_type, COUNT(*) AS duplicate_count
FROM dwh.dim_device
WHERE device_type <> 'unknown'
GROUP BY device_type
HAVING COUNT(*) > 1;

SELECT order_source, COUNT(*) AS duplicate_count
FROM dwh.dim_order_source
WHERE order_source <> 'unknown'
GROUP BY order_source
HAVING COUNT(*) > 1;

SELECT return_reason, COUNT(*) AS duplicate_count
FROM dwh.dim_return_reason
WHERE return_reason <> 'unknown'
GROUP BY return_reason
HAVING COUNT(*) > 1;