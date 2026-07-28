USE FashionEcommerceDW;
GO

TRUNCATE TABLE dwh.dim_return_reason;
TRUNCATE TABLE dwh.dim_order_source;
TRUNCATE TABLE dwh.dim_device;
TRUNCATE TABLE dwh.dim_payment_method;
TRUNCATE TABLE dwh.dim_promotion;
TRUNCATE TABLE dwh.dim_product;
TRUNCATE TABLE dwh.dim_customer;
TRUNCATE TABLE dwh.dim_geography;
TRUNCATE TABLE dwh.dim_date;
GO

------------------------------------------------------------
-- 1. Load dim_date
------------------------------------------------------------

DECLARE @start_date DATE;
DECLARE @end_date DATE;

SELECT 
    @start_date = MIN(date_value),
    @end_date = MAX(date_value)
FROM (
    SELECT order_date AS date_value FROM stg.orders WHERE order_date IS NOT NULL
    UNION ALL
    SELECT signup_date FROM stg.customers WHERE signup_date IS NOT NULL
    UNION ALL
    SELECT ship_date FROM stg.shipments WHERE ship_date IS NOT NULL
    UNION ALL
    SELECT delivery_date FROM stg.shipments WHERE delivery_date IS NOT NULL
    UNION ALL
    SELECT return_date FROM stg.returns WHERE return_date IS NOT NULL
    UNION ALL
    SELECT review_date FROM stg.reviews WHERE review_date IS NOT NULL
    UNION ALL
    SELECT snapshot_date FROM stg.inventory WHERE snapshot_date IS NOT NULL
    UNION ALL
    SELECT sales_date FROM stg.sales WHERE sales_date IS NOT NULL
    UNION ALL
    SELECT traffic_date FROM stg.web_traffic WHERE traffic_date IS NOT NULL
    UNION ALL
    SELECT start_date FROM stg.promotions WHERE start_date IS NOT NULL
    UNION ALL
    SELECT end_date FROM stg.promotions WHERE end_date IS NOT NULL
) d;

SET @start_date = ISNULL(@start_date, '2012-07-04');
SET @end_date = ISNULL(@end_date, '2022-12-31');

;WITH date_spine AS (
    SELECT @start_date AS full_date
    UNION ALL
    SELECT DATEADD(DAY, 1, full_date)
    FROM date_spine
    WHERE full_date < @end_date
)
INSERT INTO dwh.dim_date (
    date_key,
    full_date,
    [day],
    [month],
    month_name,
    [quarter],
    [year],
    day_of_week,
    day_name,
    is_weekend
)
SELECT
    YEAR(full_date) * 10000 + MONTH(full_date) * 100 + DAY(full_date) AS date_key,
    full_date,
    DAY(full_date) AS [day],
    MONTH(full_date) AS [month],
    DATENAME(MONTH, full_date) AS month_name,
    DATEPART(QUARTER, full_date) AS [quarter],
    YEAR(full_date) AS [year],
    DATEPART(WEEKDAY, full_date) AS day_of_week,
    DATENAME(WEEKDAY, full_date) AS day_name,
    CASE 
        -- 1900-01-01 là Monday. Mod 5 = Saturday, mod 6 = Sunday.
        WHEN DATEDIFF(DAY, '19000101', full_date) % 7 IN (5, 6) THEN 1 
        ELSE 0 
    END AS is_weekend
FROM date_spine
OPTION (MAXRECURSION 0);
GO

------------------------------------------------------------
-- 2. Load dim_geography
------------------------------------------------------------

SET IDENTITY_INSERT dwh.dim_geography ON;

INSERT INTO dwh.dim_geography (
    geography_key,
    zip,
    city,
    region,
    district
)
VALUES (
    -1,
    'unknown',
    'unknown',
    'unknown',
    'unknown'
);

SET IDENTITY_INSERT dwh.dim_geography OFF;
GO

;WITH geo_dedup AS (
    SELECT
        zip,
        city,
        region,
        district,
        ROW_NUMBER() OVER (
            PARTITION BY zip 
            ORDER BY city, region, district
        ) AS rn
    FROM stg.geography
    WHERE zip IS NOT NULL
)
INSERT INTO dwh.dim_geography (
    zip,
    city,
    region,
    district
)
SELECT
    zip,
    city,
    region,
    district
FROM geo_dedup
WHERE rn = 1;
GO

------------------------------------------------------------
-- 3. Load dim_customer
------------------------------------------------------------

SET IDENTITY_INSERT dwh.dim_customer ON;

INSERT INTO dwh.dim_customer (
    customer_key,
    customer_id,
    zip,
    city,
    signup_date,
    signup_date_key,
    gender,
    age_group,
    acquisition_channel
)
VALUES (
    -1,
    -1,
    'unknown',
    'unknown',
    NULL,
    NULL,
    'unknown',
    'unknown',
    'unknown'
);

SET IDENTITY_INSERT dwh.dim_customer OFF;
GO

INSERT INTO dwh.dim_customer (
    customer_id,
    zip,
    city,
    signup_date,
    signup_date_key,
    gender,
    age_group,
    acquisition_channel
)
SELECT
    customer_id,
    zip,
    city,
    signup_date,
    CASE 
        WHEN signup_date IS NOT NULL 
        THEN YEAR(signup_date) * 10000 + MONTH(signup_date) * 100 + DAY(signup_date)
        ELSE NULL
    END AS signup_date_key,
    ISNULL(gender, 'unknown') AS gender,
    ISNULL(age_group, 'unknown') AS age_group,
    ISNULL(acquisition_channel, 'unknown') AS acquisition_channel
FROM stg.customers
WHERE customer_id IS NOT NULL;
GO

------------------------------------------------------------
-- 4. Load dim_product
------------------------------------------------------------

SET IDENTITY_INSERT dwh.dim_product ON;

INSERT INTO dwh.dim_product (
    product_key,
    product_id,
    product_name,
    category,
    segment,
    size,
    color,
    standard_price,
    standard_cogs
)
VALUES (
    -1,
    -1,
    'unknown',
    'unknown',
    'unknown',
    'unknown',
    'unknown',
    0,
    0
);

SET IDENTITY_INSERT dwh.dim_product OFF;
GO

INSERT INTO dwh.dim_product (
    product_id,
    product_name,
    category,
    segment,
    size,
    color,
    standard_price,
    standard_cogs
)
SELECT
    product_id,
    ISNULL(product_name, 'unknown') AS product_name,
    ISNULL(category, 'unknown') AS category,
    ISNULL(segment, 'unknown') AS segment,
    ISNULL(size, 'unknown') AS size,
    ISNULL(color, 'unknown') AS color,
    price AS standard_price,
    cogs AS standard_cogs
FROM stg.products
WHERE product_id IS NOT NULL;
GO

------------------------------------------------------------
-- 5. Load dim_promotion
------------------------------------------------------------

SET IDENTITY_INSERT dwh.dim_promotion ON;

INSERT INTO dwh.dim_promotion (
    promotion_key,
    promo_id,
    promo_name,
    promo_type,
    discount_value,
    start_date,
    start_date_key,
    end_date,
    end_date_key,
    applicable_category,
    promo_channel,
    stackable_flag,
    min_order_value
)
VALUES (
    -1,
    'no_promo',
    'No Promotion',
    'none',
    0,
    NULL,
    NULL,
    NULL,
    NULL,
    'all',
    'none',
    0,
    0
);

SET IDENTITY_INSERT dwh.dim_promotion OFF;
GO

INSERT INTO dwh.dim_promotion (
    promo_id,
    promo_name,
    promo_type,
    discount_value,
    start_date,
    start_date_key,
    end_date,
    end_date_key,
    applicable_category,
    promo_channel,
    stackable_flag,
    min_order_value
)
SELECT
    promo_id,
    ISNULL(promo_name, 'unknown') AS promo_name,
    ISNULL(promo_type, 'unknown') AS promo_type,
    discount_value,
    start_date,
    CASE 
        WHEN start_date IS NOT NULL 
        THEN YEAR(start_date) * 10000 + MONTH(start_date) * 100 + DAY(start_date)
        ELSE NULL
    END AS start_date_key,
    end_date,
    CASE 
        WHEN end_date IS NOT NULL 
        THEN YEAR(end_date) * 10000 + MONTH(end_date) * 100 + DAY(end_date)
        ELSE NULL
    END AS end_date_key,
    ISNULL(applicable_category, 'all') AS applicable_category,
    ISNULL(promo_channel, 'unknown') AS promo_channel,
    ISNULL(stackable_flag, 0) AS stackable_flag,
    ISNULL(min_order_value, 0) AS min_order_value
FROM stg.promotions
WHERE promo_id IS NOT NULL;
GO

------------------------------------------------------------
-- 6. Load dim_payment_method
------------------------------------------------------------

SET IDENTITY_INSERT dwh.dim_payment_method ON;

INSERT INTO dwh.dim_payment_method (
    payment_method_key,
    payment_method
)
VALUES (
    -1,
    'unknown'
);

SET IDENTITY_INSERT dwh.dim_payment_method OFF;
GO

INSERT INTO dwh.dim_payment_method (
    payment_method
)
SELECT DISTINCT payment_method
FROM (
    SELECT payment_method FROM stg.orders
    UNION
    SELECT payment_method FROM stg.payments
) p
WHERE payment_method IS NOT NULL;
GO

------------------------------------------------------------
-- 7. Load dim_device
------------------------------------------------------------

SET IDENTITY_INSERT dwh.dim_device ON;

INSERT INTO dwh.dim_device (
    device_key,
    device_type
)
VALUES (
    -1,
    'unknown'
);

SET IDENTITY_INSERT dwh.dim_device OFF;
GO

INSERT INTO dwh.dim_device (
    device_type
)
SELECT DISTINCT
    device_type
FROM stg.orders
WHERE device_type IS NOT NULL;
GO

------------------------------------------------------------
-- 8. Load dim_order_source
------------------------------------------------------------

SET IDENTITY_INSERT dwh.dim_order_source ON;

INSERT INTO dwh.dim_order_source (
    order_source_key,
    order_source
)
VALUES (
    -1,
    'unknown'
);

SET IDENTITY_INSERT dwh.dim_order_source OFF;
GO

INSERT INTO dwh.dim_order_source (
    order_source
)
SELECT DISTINCT
    order_source
FROM stg.orders
WHERE order_source IS NOT NULL;
GO

------------------------------------------------------------
-- 9. Load dim_return_reason
------------------------------------------------------------

SET IDENTITY_INSERT dwh.dim_return_reason ON;

INSERT INTO dwh.dim_return_reason (
    return_reason_key,
    return_reason
)
VALUES (
    -1,
    'unknown'
);

SET IDENTITY_INSERT dwh.dim_return_reason OFF;
GO

INSERT INTO dwh.dim_return_reason (
    return_reason
)
SELECT DISTINCT
    return_reason
FROM stg.returns
WHERE return_reason IS NOT NULL;
GO