USE FashionEcommerceDW;
GO

SELECT
    COUNT(*) AS invalid_inventory_rows
FROM dwh.fact_inventory_snapshot
WHERE stock_on_hand < 0
   OR units_received < 0
   OR units_sold < 0
   OR stockout_days < 0
   OR days_of_supply < 0
   OR fill_rate < 0
   OR sell_through_rate < 0;

SELECT
    SUM(stock_on_hand) AS total_stock_on_hand,
    SUM(units_received) AS total_units_received,
    SUM(units_sold) AS total_units_sold,
    SUM(CASE WHEN stockout_flag = 1 THEN 1 ELSE 0 END) AS stockout_records,
    SUM(CASE WHEN overstock_flag = 1 THEN 1 ELSE 0 END) AS overstock_records,
    SUM(CASE WHEN reorder_flag = 1 THEN 1 ELSE 0 END) AS reorder_records,
    AVG(CAST(days_of_supply AS FLOAT)) AS avg_days_of_supply,
    AVG(CAST(fill_rate AS FLOAT)) AS avg_fill_rate,
    AVG(CAST(sell_through_rate AS FLOAT)) AS avg_sell_through_rate
FROM dwh.fact_inventory_snapshot;