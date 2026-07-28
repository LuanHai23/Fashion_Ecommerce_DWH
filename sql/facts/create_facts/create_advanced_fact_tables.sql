USE FashionEcommerceDW;
GO

DROP TABLE IF EXISTS dq.revenue_reconciliation;
DROP TABLE IF EXISTS dwh.fact_sales_daily;
DROP TABLE IF EXISTS dwh.fact_web_traffic_daily;
DROP TABLE IF EXISTS dwh.fact_inventory_snapshot;
GO

CREATE TABLE dwh.fact_inventory_snapshot (
    inventory_snapshot_key BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,

    snapshot_date_key INT NULL,
    product_key INT NOT NULL,
    product_id INT NULL,

    stock_on_hand INT NULL,
    units_received INT NULL,
    units_sold INT NULL,
    stockout_days INT NULL,
    days_of_supply DECIMAL(18,4) NULL,
    fill_rate DECIMAL(18,6) NULL,

    stockout_flag BIT NULL,
    overstock_flag BIT NULL,
    reorder_flag BIT NULL,
    sell_through_rate DECIMAL(18,6) NULL,

    inventory_year INT NULL,
    inventory_month INT NULL,

    loaded_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dwh.fact_web_traffic_daily (
    web_traffic_key BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,

    traffic_date_key INT NULL,
    traffic_source VARCHAR(100) NULL,

    sessions INT NULL,
    unique_visitors INT NULL,
    page_views INT NULL,
    bounce_rate DECIMAL(18,6) NULL,
    avg_session_duration_sec DECIMAL(18,4) NULL,

    loaded_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dwh.fact_sales_daily (
    sales_daily_key BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,

    sales_date_key INT NULL,
    sales_date DATE NULL,

    revenue DECIMAL(18,4) NULL,
    cogs DECIMAL(18,4) NULL,
    gross_profit DECIMAL(18,4) NULL,

    loaded_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dq.revenue_reconciliation (
    reconciliation_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,

    sales_date_key INT NULL,
    sales_date DATE NULL,

    revenue_from_sales_file DECIMAL(18,4) NULL,
    cogs_from_sales_file DECIMAL(18,4) NULL,
    gross_profit_from_sales_file DECIMAL(18,4) NULL,

    gross_revenue_from_order_items DECIMAL(18,4) NULL,
    net_revenue_from_order_items DECIMAL(18,4) NULL,
    estimated_cogs_from_order_items DECIMAL(18,4) NULL,
    gross_profit_from_order_items DECIMAL(18,4) NULL,

    revenue_diff_vs_gross DECIMAL(18,4) NULL,
    revenue_diff_vs_net DECIMAL(18,4) NULL,

    revenue_diff_pct_vs_gross DECIMAL(18,6) NULL,
    revenue_diff_pct_vs_net DECIMAL(18,6) NULL,

    reconciliation_status VARCHAR(50) NULL,
    loaded_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO