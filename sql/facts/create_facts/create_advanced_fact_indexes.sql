USE FashionEcommerceDW;
GO

CREATE INDEX ix_fact_inventory_snapshot_date_key
ON dwh.fact_inventory_snapshot(snapshot_date_key);
GO

CREATE INDEX ix_fact_inventory_snapshot_product_key
ON dwh.fact_inventory_snapshot(product_key);
GO

CREATE INDEX ix_fact_web_traffic_daily_date_key
ON dwh.fact_web_traffic_daily(traffic_date_key);
GO

CREATE INDEX ix_fact_web_traffic_daily_source
ON dwh.fact_web_traffic_daily(traffic_source);
GO

CREATE INDEX ix_fact_sales_daily_date_key
ON dwh.fact_sales_daily(sales_date_key);
GO

CREATE INDEX ix_revenue_reconciliation_date_key
ON dq.revenue_reconciliation(sales_date_key);
GO

CREATE INDEX ix_revenue_reconciliation_status
ON dq.revenue_reconciliation(reconciliation_status);
GO