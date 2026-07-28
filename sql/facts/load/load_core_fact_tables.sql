USE FashionEcommerceDW;
GO

TRUNCATE TABLE dwh.fact_review;
TRUNCATE TABLE dwh.fact_return;
TRUNCATE TABLE dwh.fact_shipment;
TRUNCATE TABLE dwh.fact_payment;
TRUNCATE TABLE dwh.fact_sales_order_item;
GO

------------------------------------------------------------
-- 1. Load fact_sales_order_item
------------------------------------------------------------

INSERT INTO dwh.fact_sales_order_item (
    order_id,
    product_id,
    customer_id,

    order_date_key,
    customer_key,
    product_key,
    geography_key,
    payment_method_key,
    device_key,
    order_source_key,
    promotion_key_1,
    promotion_key_2,

    order_status,

    quantity,
    unit_price,
    discount_amount,

    gross_revenue,
    net_revenue,
    estimated_cogs,
    gross_profit
)
SELECT
    oi.order_id,
    oi.product_id,
    o.customer_id,

    dd.date_key AS order_date_key,
    COALESCE(dc.customer_key, -1) AS customer_key,
    COALESCE(dp.product_key, -1) AS product_key,
    COALESCE(dg.geography_key, -1) AS geography_key,
    COALESCE(dpm.payment_method_key, -1) AS payment_method_key,
    COALESCE(ddv.device_key, -1) AS device_key,
    COALESCE(dos.order_source_key, -1) AS order_source_key,
    COALESCE(dp1.promotion_key, -1) AS promotion_key_1,
    COALESCE(dp2.promotion_key, -1) AS promotion_key_2,

    o.order_status,

    oi.quantity,
    oi.unit_price,
    ISNULL(oi.discount_amount, 0) AS discount_amount,

    CAST(oi.quantity * oi.unit_price AS DECIMAL(18,4)) AS gross_revenue,

    CAST(
        oi.quantity * oi.unit_price - ISNULL(oi.discount_amount, 0)
        AS DECIMAL(18,4)
    ) AS net_revenue,

    CAST(
        oi.quantity * ISNULL(dp.standard_cogs, 0)
        AS DECIMAL(18,4)
    ) AS estimated_cogs,

    CAST(
        oi.quantity * oi.unit_price
        - ISNULL(oi.discount_amount, 0)
        - oi.quantity * ISNULL(dp.standard_cogs, 0)
        AS DECIMAL(18,4)
    ) AS gross_profit
FROM stg.order_items oi
LEFT JOIN stg.orders o
    ON oi.order_id = o.order_id
LEFT JOIN dwh.dim_date dd
    ON o.order_date = dd.full_date
LEFT JOIN dwh.dim_customer dc
    ON o.customer_id = dc.customer_id
LEFT JOIN dwh.dim_product dp
    ON oi.product_id = dp.product_id
LEFT JOIN dwh.dim_geography dg
    ON o.zip = dg.zip
LEFT JOIN dwh.dim_payment_method dpm
    ON o.payment_method = dpm.payment_method
LEFT JOIN dwh.dim_device ddv
    ON o.device_type = ddv.device_type
LEFT JOIN dwh.dim_order_source dos
    ON o.order_source = dos.order_source
LEFT JOIN dwh.dim_promotion dp1
    ON oi.promo_id = dp1.promo_id
LEFT JOIN dwh.dim_promotion dp2
    ON oi.promo_id_2 = dp2.promo_id;
GO

------------------------------------------------------------
-- 2. Load fact_payment
------------------------------------------------------------

INSERT INTO dwh.fact_payment (
    order_id,
    customer_id,

    order_date_key,
    customer_key,
    payment_method_key,

    payment_value,
    installments
)
SELECT
    p.order_id,
    o.customer_id,

    dd.date_key AS order_date_key,
    COALESCE(dc.customer_key, -1) AS customer_key,
    COALESCE(dpm.payment_method_key, -1) AS payment_method_key,

    p.payment_value,
    p.installments
FROM stg.payments p
LEFT JOIN stg.orders o
    ON p.order_id = o.order_id
LEFT JOIN dwh.dim_date dd
    ON o.order_date = dd.full_date
LEFT JOIN dwh.dim_customer dc
    ON o.customer_id = dc.customer_id
LEFT JOIN dwh.dim_payment_method dpm
    ON p.payment_method = dpm.payment_method;
GO

------------------------------------------------------------
-- 3. Load fact_shipment
------------------------------------------------------------

INSERT INTO dwh.fact_shipment (
    order_id,
    customer_id,

    order_date_key,
    ship_date_key,
    delivery_date_key,

    customer_key,
    geography_key,

    shipping_fee,
    days_to_ship,
    days_to_deliver,
    total_fulfillment_days
)
SELECT
    s.order_id,
    o.customer_id,

    order_date.date_key AS order_date_key,
    ship_date.date_key AS ship_date_key,
    delivery_date.date_key AS delivery_date_key,

    COALESCE(dc.customer_key, -1) AS customer_key,
    COALESCE(dg.geography_key, -1) AS geography_key,

    s.shipping_fee,

    CASE 
        WHEN o.order_date IS NOT NULL AND s.ship_date IS NOT NULL
        THEN DATEDIFF(DAY, o.order_date, s.ship_date)
        ELSE NULL
    END AS days_to_ship,

    CASE 
        WHEN s.ship_date IS NOT NULL AND s.delivery_date IS NOT NULL
        THEN DATEDIFF(DAY, s.ship_date, s.delivery_date)
        ELSE NULL
    END AS days_to_deliver,

    CASE 
        WHEN o.order_date IS NOT NULL AND s.delivery_date IS NOT NULL
        THEN DATEDIFF(DAY, o.order_date, s.delivery_date)
        ELSE NULL
    END AS total_fulfillment_days
FROM stg.shipments s
LEFT JOIN stg.orders o
    ON s.order_id = o.order_id
LEFT JOIN dwh.dim_date order_date
    ON o.order_date = order_date.full_date
LEFT JOIN dwh.dim_date ship_date
    ON s.ship_date = ship_date.full_date
LEFT JOIN dwh.dim_date delivery_date
    ON s.delivery_date = delivery_date.full_date
LEFT JOIN dwh.dim_customer dc
    ON o.customer_id = dc.customer_id
LEFT JOIN dwh.dim_geography dg
    ON o.zip = dg.zip;
GO

------------------------------------------------------------
-- 4. Load fact_return
------------------------------------------------------------

INSERT INTO dwh.fact_return (
    return_id,
    order_id,
    product_id,
    customer_id,

    order_date_key,
    return_date_key,

    customer_key,
    product_key,
    geography_key,
    return_reason_key,

    return_quantity,
    refund_amount,
    days_to_return
)
SELECT
    r.return_id,
    r.order_id,
    r.product_id,
    o.customer_id,

    order_date.date_key AS order_date_key,
    return_date.date_key AS return_date_key,

    COALESCE(dc.customer_key, -1) AS customer_key,
    COALESCE(dp.product_key, -1) AS product_key,
    COALESCE(dg.geography_key, -1) AS geography_key,
    COALESCE(drr.return_reason_key, -1) AS return_reason_key,

    r.return_quantity,
    r.refund_amount,

    CASE 
        WHEN o.order_date IS NOT NULL AND r.return_date IS NOT NULL
        THEN DATEDIFF(DAY, o.order_date, r.return_date)
        ELSE NULL
    END AS days_to_return
FROM stg.returns r
LEFT JOIN stg.orders o
    ON r.order_id = o.order_id
LEFT JOIN dwh.dim_date order_date
    ON o.order_date = order_date.full_date
LEFT JOIN dwh.dim_date return_date
    ON r.return_date = return_date.full_date
LEFT JOIN dwh.dim_customer dc
    ON o.customer_id = dc.customer_id
LEFT JOIN dwh.dim_product dp
    ON r.product_id = dp.product_id
LEFT JOIN dwh.dim_geography dg
    ON o.zip = dg.zip
LEFT JOIN dwh.dim_return_reason drr
    ON r.return_reason = drr.return_reason;
GO

------------------------------------------------------------
-- 5. Load fact_review
------------------------------------------------------------

INSERT INTO dwh.fact_review (
    review_id,
    order_id,
    product_id,
    customer_id,

    review_date_key,

    customer_key,
    product_key,

    rating,
    review_title
)
SELECT
    rv.review_id,
    rv.order_id,
    rv.product_id,
    rv.customer_id,

    dd.date_key AS review_date_key,

    COALESCE(dc.customer_key, -1) AS customer_key,
    COALESCE(dp.product_key, -1) AS product_key,

    rv.rating,
    rv.review_title
FROM stg.reviews rv
LEFT JOIN dwh.dim_date dd
    ON rv.review_date = dd.full_date
LEFT JOIN dwh.dim_customer dc
    ON rv.customer_id = dc.customer_id
LEFT JOIN dwh.dim_product dp
    ON rv.product_id = dp.product_id;
GO