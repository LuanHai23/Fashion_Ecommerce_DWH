USE FashionEcommerceDW;
GO

DROP TABLE IF EXISTS stg.customers;
DROP TABLE IF EXISTS stg.geography;
DROP TABLE IF EXISTS stg.inventory;
DROP TABLE IF EXISTS stg.order_items;
DROP TABLE IF EXISTS stg.orders;
DROP TABLE IF EXISTS stg.payments;
DROP TABLE IF EXISTS stg.products;
DROP TABLE IF EXISTS stg.promotions;
DROP TABLE IF EXISTS stg.returns;
DROP TABLE IF EXISTS stg.reviews;
DROP TABLE IF EXISTS stg.sales;
DROP TABLE IF EXISTS stg.shipments;
DROP TABLE IF EXISTS stg.web_traffic;
GO

CREATE TABLE stg.customers (
    customer_id INT,
    zip VARCHAR(20),
    city NVARCHAR(255),
    signup_date DATE,
    gender VARCHAR(50),
    age_group VARCHAR(50),
    acquisition_channel VARCHAR(100),
    loaded_at DATETIME2 DEFAULT SYSDATETIME()
);
GO

CREATE TABLE stg.geography (
    zip VARCHAR(20),
    city NVARCHAR(255),
    region NVARCHAR(255),
    district NVARCHAR(255),
    loaded_at DATETIME2 DEFAULT SYSDATETIME()
);
GO

CREATE TABLE stg.inventory (
    snapshot_date DATE,
    product_id INT,
    stock_on_hand INT,
    units_received INT,
    units_sold INT,
    stockout_days INT,
    days_of_supply DECIMAL(18,4),
    fill_rate DECIMAL(18,6),
    stockout_flag BIT,
    overstock_flag BIT,
    reorder_flag BIT,
    sell_through_rate DECIMAL(18,6),
    product_name NVARCHAR(255),
    category NVARCHAR(100),
    segment NVARCHAR(100),
    [year] INT,
    [month] INT,
    loaded_at DATETIME2 DEFAULT SYSDATETIME()
);
GO

CREATE TABLE stg.order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(18,4),
    discount_amount DECIMAL(18,4),
    promo_id VARCHAR(50),
    promo_id_2 VARCHAR(50),
    loaded_at DATETIME2 DEFAULT SYSDATETIME()
);
GO

CREATE TABLE stg.orders (
    order_id INT,
    order_date DATE,
    customer_id INT,
    zip VARCHAR(20),
    order_status VARCHAR(50),
    payment_method VARCHAR(50),
    device_type VARCHAR(50),
    order_source VARCHAR(100),
    loaded_at DATETIME2 DEFAULT SYSDATETIME()
);
GO

CREATE TABLE stg.payments (
    order_id INT,
    payment_method VARCHAR(50),
    payment_value DECIMAL(18,4),
    installments INT,
    loaded_at DATETIME2 DEFAULT SYSDATETIME()
);
GO

CREATE TABLE stg.products (
    product_id INT,
    product_name NVARCHAR(255),
    category NVARCHAR(100),
    segment NVARCHAR(100),
    size VARCHAR(50),
    color VARCHAR(50),
    price DECIMAL(18,4),
    cogs DECIMAL(18,4),
    loaded_at DATETIME2 DEFAULT SYSDATETIME()
);
GO

CREATE TABLE stg.promotions (
    promo_id VARCHAR(50),
    promo_name NVARCHAR(255),
    promo_type VARCHAR(100),
    discount_value DECIMAL(18,4),
    start_date DATE,
    end_date DATE,
    applicable_category NVARCHAR(100),
    promo_channel VARCHAR(100),
    stackable_flag BIT,
    min_order_value DECIMAL(18,4),
    loaded_at DATETIME2 DEFAULT SYSDATETIME()
);
GO

CREATE TABLE stg.returns (
    return_id VARCHAR(50),
    order_id INT,
    product_id INT,
    return_date DATE,
    return_reason VARCHAR(100),
    return_quantity INT,
    refund_amount DECIMAL(18,4),
    loaded_at DATETIME2 DEFAULT SYSDATETIME()
);
GO

CREATE TABLE stg.reviews (
    review_id VARCHAR(50),
    order_id INT,
    product_id INT,
    customer_id INT,
    review_date DATE,
    rating INT,
    review_title NVARCHAR(255),
    loaded_at DATETIME2 DEFAULT SYSDATETIME()
);
GO

CREATE TABLE stg.sales (
    sales_date DATE,
    revenue DECIMAL(18,4),
    cogs DECIMAL(18,4),
    gross_profit AS (revenue - cogs) PERSISTED,
    loaded_at DATETIME2 DEFAULT SYSDATETIME()
);
GO

CREATE TABLE stg.shipments (
    order_id INT,
    ship_date DATE,
    delivery_date DATE,
    shipping_fee DECIMAL(18,4),
    loaded_at DATETIME2 DEFAULT SYSDATETIME()
);
GO

CREATE TABLE stg.web_traffic (
    traffic_date DATE,
    sessions INT,
    unique_visitors INT,
    page_views INT,
    bounce_rate DECIMAL(18,6),
    avg_session_duration_sec DECIMAL(18,4),
    traffic_source VARCHAR(100),
    loaded_at DATETIME2 DEFAULT SYSDATETIME()
);
GO