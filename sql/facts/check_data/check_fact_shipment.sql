USE FashionEcommerceDW;
GO

SELECT
    COUNT(*) AS invalid_shipment_rows
FROM dwh.fact_shipment
WHERE days_to_ship < 0
   OR days_to_deliver < 0
   OR total_fulfillment_days < 0;

SELECT
    AVG(CAST(days_to_ship AS FLOAT)) AS avg_days_to_ship,
    AVG(CAST(days_to_deliver AS FLOAT)) AS avg_days_to_deliver,
    AVG(CAST(total_fulfillment_days AS FLOAT)) AS avg_total_fulfillment_days
FROM dwh.fact_shipment;