USE FashionEcommerceDW;
GO

SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS returned_rows,
    SUM(CASE WHEN is_returned = 0 THEN 1 ELSE 0 END) AS non_returned_rows,
    CAST(SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) AS return_rate
FROM ml.return_prediction_features;

SELECT TOP 20 *
FROM ml.return_prediction_features
ORDER BY sales_order_item_key;

SELECT
    category,
    COUNT(*) AS total_rows,
    SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS returned_rows,
    CAST(SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) AS return_rate
FROM ml.return_prediction_features
GROUP BY category
ORDER BY return_rate DESC;