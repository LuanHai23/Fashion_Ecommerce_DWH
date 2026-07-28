USE FashionEcommerceDW;
GO

SELECT
    risk_level,
    COUNT(*) AS total_rows,
    SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS actual_returned_rows,
    CAST(SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) AS actual_return_rate,
    AVG(return_probability) AS avg_predicted_probability
FROM mart.vw_ai_return_risk_prediction
GROUP BY risk_level
ORDER BY avg_predicted_probability DESC;