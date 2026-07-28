USE FashionEcommerceDW;
GO

------------------------------------------------------------
-- 1. Actual return rate by predicted risk level
------------------------------------------------------------

SELECT
    risk_level,
    COUNT(*) AS total_rows,
    SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS actual_returned_rows,
    CAST(SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) AS actual_return_rate,
    AVG(return_probability) AS avg_predicted_probability
FROM mart.vw_ai_return_risk_prediction
GROUP BY risk_level
ORDER BY avg_predicted_probability DESC;
GO

------------------------------------------------------------
-- 2. Return risk by category
------------------------------------------------------------

SELECT TOP 20
    category,
    COUNT(*) AS total_rows,
    AVG(return_probability) AS avg_return_probability,
    SUM(CASE WHEN predicted_return_flag = 1 THEN 1 ELSE 0 END) AS predicted_return_rows,
    SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS actual_returned_rows,
    CAST(SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) AS actual_return_rate
FROM mart.vw_ai_return_risk_prediction
GROUP BY category
ORDER BY avg_return_probability DESC;
GO

------------------------------------------------------------
-- 3. Return risk by size
------------------------------------------------------------

SELECT TOP 20
    size,
    COUNT(*) AS total_rows,
    AVG(return_probability) AS avg_return_probability,
    SUM(CASE WHEN predicted_return_flag = 1 THEN 1 ELSE 0 END) AS predicted_return_rows,
    SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS actual_returned_rows,
    CAST(SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) AS actual_return_rate
FROM mart.vw_ai_return_risk_prediction
GROUP BY size
ORDER BY avg_return_probability DESC;
GO

------------------------------------------------------------
-- 4. Return risk by delivery delay bucket
------------------------------------------------------------

WITH delivery_bucket AS (
    SELECT
        *,
        CASE
            WHEN total_fulfillment_days IS NULL THEN 'unknown'
            WHEN total_fulfillment_days <= 2 THEN '0-2 days'
            WHEN total_fulfillment_days <= 5 THEN '3-5 days'
            WHEN total_fulfillment_days <= 10 THEN '6-10 days'
            ELSE '10+ days'
        END AS delivery_bucket
    FROM mart.vw_ai_return_risk_prediction
)
SELECT
    delivery_bucket,
    COUNT(*) AS total_rows,
    AVG(return_probability) AS avg_return_probability,
    SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS actual_returned_rows,
    CAST(SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) AS actual_return_rate
FROM delivery_bucket
GROUP BY delivery_bucket
ORDER BY avg_return_probability DESC;
GO

------------------------------------------------------------
-- 5. Top high-risk products
------------------------------------------------------------

SELECT TOP 30
    product_id,
    category,
    segment,
    size,
    color,
    COUNT(*) AS total_rows,
    AVG(return_probability) AS avg_return_probability,
    SUM(CASE WHEN predicted_return_flag = 1 THEN 1 ELSE 0 END) AS predicted_return_rows,
    SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS actual_returned_rows
FROM mart.vw_ai_return_risk_prediction
GROUP BY
    product_id,
    category,
    segment,
    size,
    color
HAVING COUNT(*) >= 20
ORDER BY avg_return_probability DESC;
GO