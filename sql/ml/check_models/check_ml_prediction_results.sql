USE FashionEcommerceDW;
GO

SELECT
    COUNT(*) AS prediction_rows,
    AVG(return_probability) AS avg_return_probability,
    SUM(CASE WHEN predicted_return_flag = 1 THEN 1 ELSE 0 END) AS predicted_return_rows
FROM ml.return_prediction_results;

SELECT
    risk_level,
    COUNT(*) AS row_count,
    AVG(return_probability) AS avg_return_probability
FROM ml.return_prediction_results
GROUP BY risk_level
ORDER BY avg_return_probability DESC;

SELECT TOP 20
    r.sales_order_item_key,
    r.order_id,
    r.product_id,
    p.product_name,
    p.category,
    p.segment,
    r.customer_id,
    r.return_probability,
    r.predicted_return_flag,
    r.risk_level,
    f.is_returned
FROM ml.return_prediction_results r
JOIN ml.return_prediction_features f
    ON r.sales_order_item_key = f.sales_order_item_key
LEFT JOIN dwh.dim_product p
    ON f.product_id = p.product_id
ORDER BY r.return_probability DESC;

SELECT TOP 10 *
FROM ml.model_training_log
ORDER BY trained_at DESC;