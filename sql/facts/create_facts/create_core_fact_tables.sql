USE FashionEcommerceDW;
GO

DROP TABLE IF EXISTS dwh.fact_review;
DROP TABLE IF EXISTS dwh.fact_return;
DROP TABLE IF EXISTS dwh.fact_shipment;
DROP TABLE IF EXISTS dwh.fact_payment;
DROP TABLE IF EXISTS dwh.fact_sales_order_item;
GO

CREATE TABLE dwh.fact_sales_order_item (
    sales_order_item_key BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,

    order_id INT NOT NULL,
    product_id INT NULL,
    customer_id INT NULL,

    order_date_key INT NULL,
    customer_key INT NOT NULL,
    product_key INT NOT NULL,
    geography_key INT NOT NULL,
    payment_method_key INT NOT NULL,
    device_key INT NOT NULL,
    order_source_key INT NOT NULL,
    promotion_key_1 INT NOT NULL,
    promotion_key_2 INT NOT NULL,

    order_status VARCHAR(50) NULL,

    quantity INT NULL,
    unit_price DECIMAL(18,4) NULL,
    discount_amount DECIMAL(18,4) NULL,

    gross_revenue DECIMAL(18,4) NULL,
    net_revenue DECIMAL(18,4) NULL,
    estimated_cogs DECIMAL(18,4) NULL,
    gross_profit DECIMAL(18,4) NULL,

    loaded_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dwh.fact_payment (
    payment_key BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,

    order_id INT NOT NULL,
    customer_id INT NULL,

    order_date_key INT NULL,
    customer_key INT NOT NULL,
    payment_method_key INT NOT NULL,

    payment_value DECIMAL(18,4) NULL,
    installments INT NULL,

    loaded_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dwh.fact_shipment (
    shipment_key BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,

    order_id INT NOT NULL,
    customer_id INT NULL,

    order_date_key INT NULL,
    ship_date_key INT NULL,
    delivery_date_key INT NULL,

    customer_key INT NOT NULL,
    geography_key INT NOT NULL,

    shipping_fee DECIMAL(18,4) NULL,
    days_to_ship INT NULL,
    days_to_deliver INT NULL,
    total_fulfillment_days INT NULL,

    loaded_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dwh.fact_return (
    return_key BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,

    return_id VARCHAR(50) NULL,
    order_id INT NOT NULL,
    product_id INT NULL,
    customer_id INT NULL,

    order_date_key INT NULL,
    return_date_key INT NULL,

    customer_key INT NOT NULL,
    product_key INT NOT NULL,
    geography_key INT NOT NULL,
    return_reason_key INT NOT NULL,

    return_quantity INT NULL,
    refund_amount DECIMAL(18,4) NULL,
    days_to_return INT NULL,

    loaded_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dwh.fact_review (
    review_key BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,

    review_id VARCHAR(50) NULL,
    order_id INT NOT NULL,
    product_id INT NULL,
    customer_id INT NULL,

    review_date_key INT NULL,

    customer_key INT NOT NULL,
    product_key INT NOT NULL,

    rating INT NULL,
    review_title NVARCHAR(255) NULL,

    loaded_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO