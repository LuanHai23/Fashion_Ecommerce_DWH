USE FashionEcommerceDW;
GO

TRUNCATE TABLE stg.customers;
TRUNCATE TABLE stg.geography;
TRUNCATE TABLE stg.inventory;
TRUNCATE TABLE stg.order_items;
TRUNCATE TABLE stg.orders;
TRUNCATE TABLE stg.payments;
TRUNCATE TABLE stg.products;
TRUNCATE TABLE stg.promotions;
TRUNCATE TABLE stg.returns;
TRUNCATE TABLE stg.reviews;
TRUNCATE TABLE stg.sales;
TRUNCATE TABLE stg.shipments;
TRUNCATE TABLE stg.web_traffic;
GO

INSERT INTO stg.customers (
    customer_id,
    zip,
    city,
    signup_date,
    gender,
    age_group,
    acquisition_channel
)
SELECT
    TRY_CONVERT(INT, NULLIF(TRIM(customer_id), '')) AS customer_id,
    NULLIF(TRIM(zip), '') AS zip,
    NULLIF(TRIM(city), '') AS city,
    TRY_CONVERT(DATE, NULLIF(TRIM(signup_date), '')) AS signup_date,
    LOWER(NULLIF(TRIM(gender), '')) AS gender,
    NULLIF(TRIM(age_group), '') AS age_group,
    LOWER(NULLIF(TRIM(acquisition_channel), '')) AS acquisition_channel
FROM raw.customers;
GO

INSERT INTO stg.geography (
    zip,
    city,
    region,
    district
)
SELECT
    NULLIF(TRIM(zip), '') AS zip,
    NULLIF(TRIM(city), '') AS city,
    NULLIF(TRIM(region), '') AS region,
    NULLIF(TRIM(district), '') AS district
FROM raw.geography;
GO

INSERT INTO stg.inventory (
    snapshot_date,
    product_id,
    stock_on_hand,
    units_received,
    units_sold,
    stockout_days,
    days_of_supply,
    fill_rate,
    stockout_flag,
    overstock_flag,
    reorder_flag,
    sell_through_rate,
    product_name,
    category,
    segment,
    [year],
    [month]
)
SELECT
    TRY_CONVERT(DATE, NULLIF(TRIM(snapshot_date), '')) AS snapshot_date,
    TRY_CONVERT(INT, NULLIF(TRIM(product_id), '')) AS product_id,
    TRY_CONVERT(INT, NULLIF(TRIM(stock_on_hand), '')) AS stock_on_hand,
    TRY_CONVERT(INT, NULLIF(TRIM(units_received), '')) AS units_received,
    TRY_CONVERT(INT, NULLIF(TRIM(units_sold), '')) AS units_sold,
    TRY_CONVERT(INT, NULLIF(TRIM(stockout_days), '')) AS stockout_days,
    TRY_CONVERT(DECIMAL(18,4), NULLIF(TRIM(days_of_supply), '')) AS days_of_supply,
    TRY_CONVERT(DECIMAL(18,6), NULLIF(TRIM(fill_rate), '')) AS fill_rate,
    TRY_CONVERT(BIT, NULLIF(TRIM(stockout_flag), '')) AS stockout_flag,
    TRY_CONVERT(BIT, NULLIF(TRIM(overstock_flag), '')) AS overstock_flag,
    TRY_CONVERT(BIT, NULLIF(TRIM(reorder_flag), '')) AS reorder_flag,
    TRY_CONVERT(DECIMAL(18,6), NULLIF(TRIM(sell_through_rate), '')) AS sell_through_rate,
    NULLIF(TRIM(product_name), '') AS product_name,
    NULLIF(TRIM(category), '') AS category,
    NULLIF(TRIM(segment), '') AS segment,
    TRY_CONVERT(INT, NULLIF(TRIM([year]), '')) AS [year],
    TRY_CONVERT(INT, NULLIF(TRIM([month]), '')) AS [month]
FROM raw.inventory;
GO

INSERT INTO stg.order_items (
    order_id,
    product_id,
    quantity,
    unit_price,
    discount_amount,
    promo_id,
    promo_id_2
)
SELECT
    TRY_CONVERT(INT, NULLIF(TRIM(order_id), '')) AS order_id,
    TRY_CONVERT(INT, NULLIF(TRIM(product_id), '')) AS product_id,
    TRY_CONVERT(INT, NULLIF(TRIM(quantity), '')) AS quantity,
    TRY_CONVERT(DECIMAL(18,4), NULLIF(TRIM(unit_price), '')) AS unit_price,
    TRY_CONVERT(DECIMAL(18,4), NULLIF(TRIM(discount_amount), '')) AS discount_amount,

    CASE 
        WHEN NULLIF(TRIM(promo_id), '') IS NULL THEN NULL
        WHEN LOWER(TRIM(promo_id)) IN ('nan', 'null', 'none') THEN NULL
        ELSE TRIM(promo_id)
    END AS promo_id,

    CASE 
        WHEN NULLIF(TRIM(promo_id_2), '') IS NULL THEN NULL
        WHEN LOWER(TRIM(promo_id_2)) IN ('nan', 'null', 'none') THEN NULL
        ELSE TRIM(promo_id_2)
    END AS promo_id_2
FROM raw.order_items;
GO

INSERT INTO stg.orders (
    order_id,
    order_date,
    customer_id,
    zip,
    order_status,
    payment_method,
    device_type,
    order_source
)
SELECT
    TRY_CONVERT(INT, NULLIF(TRIM(order_id), '')) AS order_id,
    TRY_CONVERT(DATE, NULLIF(TRIM(order_date), '')) AS order_date,
    TRY_CONVERT(INT, NULLIF(TRIM(customer_id), '')) AS customer_id,
    NULLIF(TRIM(zip), '') AS zip,
    LOWER(NULLIF(TRIM(order_status), '')) AS order_status,
    LOWER(NULLIF(TRIM(payment_method), '')) AS payment_method,
    LOWER(NULLIF(TRIM(device_type), '')) AS device_type,
    LOWER(NULLIF(TRIM(order_source), '')) AS order_source
FROM raw.orders;
GO

INSERT INTO stg.payments (
    order_id,
    payment_method,
    payment_value,
    installments
)
SELECT
    TRY_CONVERT(INT, NULLIF(TRIM(order_id), '')) AS order_id,
    LOWER(NULLIF(TRIM(payment_method), '')) AS payment_method,
    TRY_CONVERT(DECIMAL(18,4), NULLIF(TRIM(payment_value), '')) AS payment_value,
    TRY_CONVERT(INT, NULLIF(TRIM(installments), '')) AS installments
FROM raw.payments;
GO

INSERT INTO stg.products (
    product_id,
    product_name,
    category,
    segment,
    size,
    color,
    price,
    cogs
)
SELECT
    TRY_CONVERT(INT, NULLIF(TRIM(product_id), '')) AS product_id,
    NULLIF(TRIM(product_name), '') AS product_name,
    NULLIF(TRIM(category), '') AS category,
    NULLIF(TRIM(segment), '') AS segment,
    NULLIF(TRIM(size), '') AS size,
    LOWER(NULLIF(TRIM(color), '')) AS color,
    TRY_CONVERT(DECIMAL(18,4), NULLIF(TRIM(price), '')) AS price,
    TRY_CONVERT(DECIMAL(18,4), NULLIF(TRIM(cogs), '')) AS cogs
FROM raw.products;
GO

INSERT INTO stg.promotions (
    promo_id,
    promo_name,
    promo_type,
    discount_value,
    start_date,
    end_date,
    applicable_category,
    promo_channel,
    stackable_flag,
    min_order_value
)
SELECT
    NULLIF(TRIM(promo_id), '') AS promo_id,
    NULLIF(TRIM(promo_name), '') AS promo_name,
    LOWER(NULLIF(TRIM(promo_type), '')) AS promo_type,
    TRY_CONVERT(DECIMAL(18,4), NULLIF(TRIM(discount_value), '')) AS discount_value,
    TRY_CONVERT(DATE, NULLIF(TRIM(start_date), '')) AS start_date,
    TRY_CONVERT(DATE, NULLIF(TRIM(end_date), '')) AS end_date,
    CASE 
        WHEN NULLIF(TRIM(applicable_category), '') IS NULL THEN NULL
        WHEN LOWER(TRIM(applicable_category)) IN ('nan', 'null', 'none') THEN NULL
        ELSE TRIM(applicable_category)
    END AS applicable_category,
    LOWER(NULLIF(TRIM(promo_channel), '')) AS promo_channel,
    TRY_CONVERT(BIT, NULLIF(TRIM(stackable_flag), '')) AS stackable_flag,
    TRY_CONVERT(DECIMAL(18,4), NULLIF(TRIM(min_order_value), '')) AS min_order_value
FROM raw.promotions;
GO

INSERT INTO stg.returns (
    return_id,
    order_id,
    product_id,
    return_date,
    return_reason,
    return_quantity,
    refund_amount
)
SELECT
    NULLIF(TRIM(return_id), '') AS return_id,
    TRY_CONVERT(INT, NULLIF(TRIM(order_id), '')) AS order_id,
    TRY_CONVERT(INT, NULLIF(TRIM(product_id), '')) AS product_id,
    TRY_CONVERT(DATE, NULLIF(TRIM(return_date), '')) AS return_date,
    LOWER(NULLIF(TRIM(return_reason), '')) AS return_reason,
    TRY_CONVERT(INT, NULLIF(TRIM(return_quantity), '')) AS return_quantity,
    TRY_CONVERT(DECIMAL(18,4), NULLIF(TRIM(refund_amount), '')) AS refund_amount
FROM raw.returns;
GO

INSERT INTO stg.reviews (
    review_id,
    order_id,
    product_id,
    customer_id,
    review_date,
    rating,
    review_title
)
SELECT
    NULLIF(TRIM(review_id), '') AS review_id,
    TRY_CONVERT(INT, NULLIF(TRIM(order_id), '')) AS order_id,
    TRY_CONVERT(INT, NULLIF(TRIM(product_id), '')) AS product_id,
    TRY_CONVERT(INT, NULLIF(TRIM(customer_id), '')) AS customer_id,
    TRY_CONVERT(DATE, NULLIF(TRIM(review_date), '')) AS review_date,
    TRY_CONVERT(INT, NULLIF(TRIM(rating), '')) AS rating,
    NULLIF(TRIM(review_title), '') AS review_title
FROM raw.reviews;
GO

INSERT INTO stg.sales (
    sales_date,
    revenue,
    cogs
)
SELECT
    TRY_CONVERT(DATE, NULLIF(TRIM([Date]), '')) AS sales_date,
    TRY_CONVERT(DECIMAL(18,4), NULLIF(TRIM(Revenue), '')) AS revenue,
    TRY_CONVERT(DECIMAL(18,4), NULLIF(TRIM(COGS), '')) AS cogs
FROM raw.sales;
GO

INSERT INTO stg.shipments (
    order_id,
    ship_date,
    delivery_date,
    shipping_fee
)
SELECT
    TRY_CONVERT(INT, NULLIF(TRIM(order_id), '')) AS order_id,
    TRY_CONVERT(DATE, NULLIF(TRIM(ship_date), '')) AS ship_date,
    TRY_CONVERT(DATE, NULLIF(TRIM(delivery_date), '')) AS delivery_date,
    TRY_CONVERT(DECIMAL(18,4), NULLIF(TRIM(shipping_fee), '')) AS shipping_fee
FROM raw.shipments;
GO

INSERT INTO stg.web_traffic (
    traffic_date,
    sessions,
    unique_visitors,
    page_views,
    bounce_rate,
    avg_session_duration_sec,
    traffic_source
)
SELECT
    TRY_CONVERT(DATE, NULLIF(TRIM([date]), '')) AS traffic_date,
    TRY_CONVERT(INT, NULLIF(TRIM(sessions), '')) AS sessions,
    TRY_CONVERT(INT, NULLIF(TRIM(unique_visitors), '')) AS unique_visitors,
    TRY_CONVERT(INT, NULLIF(TRIM(page_views), '')) AS page_views,
    TRY_CONVERT(DECIMAL(18,6), NULLIF(TRIM(bounce_rate), '')) AS bounce_rate,
    TRY_CONVERT(DECIMAL(18,4), NULLIF(TRIM(avg_session_duration_sec), '')) AS avg_session_duration_sec,
    LOWER(NULLIF(TRIM(traffic_source), '')) AS traffic_source
FROM raw.web_traffic;
GO