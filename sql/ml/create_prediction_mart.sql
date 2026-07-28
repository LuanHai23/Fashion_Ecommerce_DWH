USE FashionEcommerceDW;
GO

CREATE OR ALTER VIEW mart.vw_ai_return_risk_prediction AS
SELECT
    r.sales_order_item_key,
    r.order_id,
    r.product_id,
    r.customer_id,

    f.order_year,
    f.order_month,
    f.order_quarter,
    f.order_day_of_week,
    f.is_weekend,

    f.category,
    f.segment,
    f.size,
    f.color,

    f.quantity,
    f.unit_price,
    f.discount_amount,
    f.net_revenue,
    f.gross_profit,
    f.discount_rate,
    f.profit_margin,

    f.gender,
    f.age_group,
    f.acquisition_channel,

    f.region,
    f.city,

    f.payment_method,
    f.device_type,
    f.order_source,

    f.shipping_fee,
    f.days_to_ship,
    f.days_to_deliver,
    f.total_fulfillment_days,

    f.is_returned,

    r.return_probability,
    r.predicted_return_flag,
    r.risk_level,
    r.model_name,
    r.prediction_date
FROM ml.return_prediction_results r
JOIN ml.return_prediction_features f
    ON r.sales_order_item_key = f.sales_order_item_key;
GO

USE FashionEcommerceDW;
GO

SELECT COUNT(*) AS row_count
FROM mart.vw_ai_return_risk_prediction;

SELECT TOP 20 *
FROM mart.vw_ai_return_risk_prediction
ORDER BY return_probability DESC;