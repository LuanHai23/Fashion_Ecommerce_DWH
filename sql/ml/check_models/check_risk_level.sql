USE FashionEcommerceDW;
GO

SELECT
    risk_level,
    predicted_return_flag,
    COUNT(*) AS row_count,
    AVG(return_probability) AS avg_return_probability
FROM ml.return_prediction_results
GROUP BY risk_level, predicted_return_flag
ORDER BY avg_return_probability DESC;