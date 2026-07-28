USE FashionEcommerceDW;
GO

DROP TABLE IF EXISTS ml.return_prediction_results;
DROP TABLE IF EXISTS ml.model_training_log;
DROP TABLE IF EXISTS ml.return_prediction_features;
GO

CREATE TABLE ml.return_prediction_features (
    sales_order_item_key BIGINT NOT NULL PRIMARY KEY,

    order_id INT NOT NULL,
    product_id INT NULL,
    customer_id INT NULL,

    order_year INT NULL,
    order_month INT NULL,
    order_quarter INT NULL,
    order_day_of_week INT NULL,
    is_weekend BIT NULL,

    category NVARCHAR(100) NULL,
    segment NVARCHAR(100) NULL,
    size VARCHAR(50) NULL,
    color VARCHAR(50) NULL,

    quantity INT NULL,
    unit_price DECIMAL(18,4) NULL,
    discount_amount DECIMAL(18,4) NULL,
    gross_revenue DECIMAL(18,4) NULL,
    net_revenue DECIMAL(18,4) NULL,
    estimated_cogs DECIMAL(18,4) NULL,
    gross_profit DECIMAL(18,4) NULL,
    discount_rate DECIMAL(18,6) NULL,
    profit_margin DECIMAL(18,6) NULL,

    gender VARCHAR(50) NULL,
    age_group VARCHAR(50) NULL,
    acquisition_channel VARCHAR(100) NULL,

    region NVARCHAR(255) NULL,
    city NVARCHAR(255) NULL,

    payment_method VARCHAR(50) NULL,
    device_type VARCHAR(50) NULL,
    order_source VARCHAR(100) NULL,

    shipping_fee DECIMAL(18,4) NULL,
    days_to_ship INT NULL,
    days_to_deliver INT NULL,
    total_fulfillment_days INT NULL,

    is_returned BIT NOT NULL,

    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE ml.return_prediction_results (
    prediction_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,

    sales_order_item_key BIGINT NOT NULL,
    order_id INT NOT NULL,
    product_id INT NULL,
    customer_id INT NULL,

    return_probability DECIMAL(18,6) NOT NULL,
    predicted_return_flag BIT NOT NULL,

    risk_level VARCHAR(50) NULL,
    model_name VARCHAR(100) NOT NULL,
    prediction_date DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE ml.model_training_log (
    training_log_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,

    model_name VARCHAR(100) NOT NULL,
    training_rows INT NULL,
    test_rows INT NULL,

    accuracy DECIMAL(18,6) NULL,
    precision_score DECIMAL(18,6) NULL,
    recall_score DECIMAL(18,6) NULL,
    f1_score DECIMAL(18,6) NULL,
    roc_auc DECIMAL(18,6) NULL,

    trained_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO