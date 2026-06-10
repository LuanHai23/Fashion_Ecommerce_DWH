USE FashionEcommerceDW;
GO

DROP TABLE IF EXISTS raw.customers;
DROP TABLE IF EXISTS raw.geography;
DROP TABLE IF EXISTS raw.inventory;
DROP TABLE IF EXISTS raw.order_items;
DROP TABLE IF EXISTS raw.orders;
DROP TABLE IF EXISTS raw.payments;
DROP TABLE IF EXISTS raw.products;
DROP TABLE IF EXISTS raw.promotions;
DROP TABLE IF EXISTS raw.returns;
DROP TABLE IF EXISTS raw.reviews;
DROP TABLE IF EXISTS raw.sales;
DROP TABLE IF EXISTS raw.shipments;
DROP TABLE IF EXISTS raw.web_traffic;
GO

CREATE TABLE raw.customers (
    customer_id NVARCHAR(50),
    zip NVARCHAR(50),
    city NVARCHAR(255),
    signup_date NVARCHAR(50),
    gender NVARCHAR(50),
    age_group NVARCHAR(50),
    acquisition_channel NVARCHAR(100)
);
GO

CREATE TABLE raw.geography (
    zip NVARCHAR(50),
    city NVARCHAR(255),
    region NVARCHAR(255),
    district NVARCHAR(255)
);
GO

CREATE TABLE raw.inventory (
    snapshot_date NVARCHAR(50),
    product_id NVARCHAR(50),
    stock_on_hand NVARCHAR(50),
    units_received NVARCHAR(50),
    units_sold NVARCHAR(50),
    stockout_days NVARCHAR(50),
    days_of_supply NVARCHAR(50),
    fill_rate NVARCHAR(50),
    stockout_flag NVARCHAR(50),
    overstock_flag NVARCHAR(50),
    reorder_flag NVARCHAR(50),
    sell_through_rate NVARCHAR(50),
    product_name NVARCHAR(255),
    category NVARCHAR(100),
    segment NVARCHAR(100),
    [year] NVARCHAR(50),
    [month] NVARCHAR(50)
);
GO

CREATE TABLE raw.order_items (
    order_id NVARCHAR(50),
    product_id NVARCHAR(50),
    quantity NVARCHAR(50),
    unit_price NVARCHAR(50),
    discount_amount NVARCHAR(50),
    promo_id NVARCHAR(50),
    promo_id_2 NVARCHAR(50)
);
GO

CREATE TABLE raw.orders (
    order_id NVARCHAR(50),
    order_date NVARCHAR(50),
    customer_id NVARCHAR(50),
    zip NVARCHAR(50),
    order_status NVARCHAR(50),
    payment_method NVARCHAR(50),
    device_type NVARCHAR(50),
    order_source NVARCHAR(100)
);
GO

CREATE TABLE raw.payments (
    order_id NVARCHAR(50),
    payment_method NVARCHAR(50),
    payment_value NVARCHAR(50),
    installments NVARCHAR(50)
);
GO

CREATE TABLE raw.products (
    product_id NVARCHAR(50),
    product_name NVARCHAR(255),
    category NVARCHAR(100),
    segment NVARCHAR(100),
    size NVARCHAR(50),
    color NVARCHAR(50),
    price NVARCHAR(50),
    cogs NVARCHAR(50)
);
GO

CREATE TABLE raw.promotions (
    promo_id NVARCHAR(50),
    promo_name NVARCHAR(255),
    promo_type NVARCHAR(100),
    discount_value NVARCHAR(50),
    start_date NVARCHAR(50),
    end_date NVARCHAR(50),
    applicable_category NVARCHAR(100),
    promo_channel NVARCHAR(100),
    stackable_flag NVARCHAR(50),
    min_order_value NVARCHAR(50)
);
GO

CREATE TABLE raw.returns (
    return_id NVARCHAR(50),
    order_id NVARCHAR(50),
    product_id NVARCHAR(50),
    return_date NVARCHAR(50),
    return_reason NVARCHAR(100),
    return_quantity NVARCHAR(50),
    refund_amount NVARCHAR(50)
);
GO

CREATE TABLE raw.reviews (
    review_id NVARCHAR(50),
    order_id NVARCHAR(50),
    product_id NVARCHAR(50),
    customer_id NVARCHAR(50),
    review_date NVARCHAR(50),
    rating NVARCHAR(50),
    review_title NVARCHAR(255)
);
GO

CREATE TABLE raw.sales (
    [Date] NVARCHAR(50),
    Revenue NVARCHAR(50),
    COGS NVARCHAR(50)
);
GO

CREATE TABLE raw.shipments (
    order_id NVARCHAR(50),
    ship_date NVARCHAR(50),
    delivery_date NVARCHAR(50),
    shipping_fee NVARCHAR(50)
);
GO

CREATE TABLE raw.web_traffic (
    [date] NVARCHAR(50),
    sessions NVARCHAR(50),
    unique_visitors NVARCHAR(50),
    page_views NVARCHAR(50),
    bounce_rate NVARCHAR(50),
    avg_session_duration_sec NVARCHAR(50),
    traffic_source NVARCHAR(100)
);
GO

-- Check raw table creation
USE FashionEcommerceDW;
GO

SELECT 
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'raw'
ORDER BY TABLE_NAME;