USE FashionEcommerceDW;
GO

TRUNCATE TABLE ml.return_prediction_features;
GO

WITH return_by_order_item AS (
    SELECT
        order_id,
        product_id,
        1 AS is_returned
    FROM dwh.fact_return
    GROUP BY order_id, product_id
),
shipment_by_order AS (
    SELECT
        order_id,
        MAX(shipping_fee) AS shipping_fee,
        AVG(CAST(days_to_ship AS FLOAT)) AS days_to_ship,
        AVG(CAST(days_to_deliver AS FLOAT)) AS days_to_deliver,
        AVG(CAST(total_fulfillment_days AS FLOAT)) AS total_fulfillment_days
    FROM dwh.fact_shipment
    GROUP BY order_id
)
INSERT INTO ml.return_prediction_features (
    sales_order_item_key,

    order_id,
    product_id,
    customer_id,

    order_year,
    order_month,
    order_quarter,
    order_day_of_week,
    is_weekend,

    category,
    segment,
    size,
    color,

    quantity,
    unit_price,
    discount_amount,
    gross_revenue,
    net_revenue,
    estimated_cogs,
    gross_profit,
    discount_rate,
    profit_margin,

    gender,
    age_group,
    acquisition_channel,

    region,
    city,

    payment_method,
    device_type,
    order_source,

    shipping_fee,
    days_to_ship,
    days_to_deliver,
    total_fulfillment_days,

    is_returned
)
SELECT
    f.sales_order_item_key,

    f.order_id,
    f.product_id,
    f.customer_id,

    dd.[year] AS order_year,
    dd.[month] AS order_month,
    dd.[quarter] AS order_quarter,
    dd.day_of_week AS order_day_of_week,
    dd.is_weekend,

    dp.category,
    dp.segment,
    dp.size,
    dp.color,

    f.quantity,
    f.unit_price,
    f.discount_amount,
    f.gross_revenue,
    f.net_revenue,
    f.estimated_cogs,
    f.gross_profit,

    CAST(
        CASE
            WHEN f.gross_revenue IS NULL OR f.gross_revenue = 0 THEN 0
            ELSE f.discount_amount / f.gross_revenue
        END
        AS DECIMAL(18,6)
    ) AS discount_rate,

    CAST(
        CASE
            WHEN f.net_revenue IS NULL OR f.net_revenue = 0 THEN 0
            ELSE f.gross_profit / f.net_revenue
        END
        AS DECIMAL(18,6)
    ) AS profit_margin,

    dc.gender,
    dc.age_group,
    dc.acquisition_channel,

    dg.region,
    dg.city,

    dpm.payment_method,
    ddv.device_type,
    dos.order_source,

    CAST(sb.shipping_fee AS DECIMAL(18,4)) AS shipping_fee,
    CAST(sb.days_to_ship AS INT) AS days_to_ship,
    CAST(sb.days_to_deliver AS INT) AS days_to_deliver,
    CAST(sb.total_fulfillment_days AS INT) AS total_fulfillment_days,

    CAST(ISNULL(rbi.is_returned, 0) AS BIT) AS is_returned
FROM dwh.fact_sales_order_item f
LEFT JOIN dwh.dim_date dd
    ON f.order_date_key = dd.date_key
LEFT JOIN dwh.dim_product dp
    ON f.product_key = dp.product_key
LEFT JOIN dwh.dim_customer dc
    ON f.customer_key = dc.customer_key
LEFT JOIN dwh.dim_geography dg
    ON f.geography_key = dg.geography_key
LEFT JOIN dwh.dim_payment_method dpm
    ON f.payment_method_key = dpm.payment_method_key
LEFT JOIN dwh.dim_device ddv
    ON f.device_key = ddv.device_key
LEFT JOIN dwh.dim_order_source dos
    ON f.order_source_key = dos.order_source_key
LEFT JOIN shipment_by_order sb
    ON f.order_id = sb.order_id
LEFT JOIN return_by_order_item rbi
    ON f.order_id = rbi.order_id
   AND f.product_id = rbi.product_id;
GO