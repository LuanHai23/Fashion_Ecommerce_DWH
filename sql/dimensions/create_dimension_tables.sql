USE FashionEcommerceDW;
GO

DROP TABLE IF EXISTS dwh.dim_return_reason;
DROP TABLE IF EXISTS dwh.dim_order_source;
DROP TABLE IF EXISTS dwh.dim_device;
DROP TABLE IF EXISTS dwh.dim_payment_method;
DROP TABLE IF EXISTS dwh.dim_promotion;
DROP TABLE IF EXISTS dwh.dim_product;
DROP TABLE IF EXISTS dwh.dim_customer;
DROP TABLE IF EXISTS dwh.dim_geography;
DROP TABLE IF EXISTS dwh.dim_date;
GO

CREATE TABLE dwh.dim_date (
    date_key INT NOT NULL PRIMARY KEY,       -- YYYYMMDD
    full_date DATE NOT NULL,
    [day] INT NOT NULL,
    [month] INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    [quarter] INT NOT NULL,
    [year] INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name VARCHAR(20) NOT NULL,
    is_weekend BIT NOT NULL
);
GO

CREATE TABLE dwh.dim_geography (
    geography_key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    zip VARCHAR(20) NULL,
    city NVARCHAR(255) NULL,
    region NVARCHAR(255) NULL,
    district NVARCHAR(255) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dwh.dim_customer (
    customer_key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    customer_id INT NULL,
    zip VARCHAR(20) NULL,
    city NVARCHAR(255) NULL,
    signup_date DATE NULL,
    signup_date_key INT NULL,
    gender VARCHAR(50) NULL,
    age_group VARCHAR(50) NULL,
    acquisition_channel VARCHAR(100) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dwh.dim_product (
    product_key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    product_id INT NULL,
    product_name NVARCHAR(255) NULL,
    category NVARCHAR(100) NULL,
    segment NVARCHAR(100) NULL,
    size VARCHAR(50) NULL,
    color VARCHAR(50) NULL,
    standard_price DECIMAL(18,4) NULL,
    standard_cogs DECIMAL(18,4) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dwh.dim_promotion (
    promotion_key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    promo_id VARCHAR(50) NULL,
    promo_name NVARCHAR(255) NULL,
    promo_type VARCHAR(100) NULL,
    discount_value DECIMAL(18,4) NULL,
    start_date DATE NULL,
    start_date_key INT NULL,
    end_date DATE NULL,
    end_date_key INT NULL,
    applicable_category NVARCHAR(100) NULL,
    promo_channel VARCHAR(100) NULL,
    stackable_flag BIT NULL,
    min_order_value DECIMAL(18,4) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dwh.dim_payment_method (
    payment_method_key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    payment_method VARCHAR(50) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dwh.dim_device (
    device_key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    device_type VARCHAR(50) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dwh.dim_order_source (
    order_source_key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    order_source VARCHAR(100) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dwh.dim_return_reason (
    return_reason_key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    return_reason VARCHAR(100) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO