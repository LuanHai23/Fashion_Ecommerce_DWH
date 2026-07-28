USE FashionEcommerceDW;
GO

CREATE UNIQUE INDEX ux_dim_date_full_date
ON dwh.dim_date(full_date);
GO

CREATE UNIQUE INDEX ux_dim_geography_zip
ON dwh.dim_geography(zip)
WHERE zip IS NOT NULL AND zip <> 'unknown';
GO

CREATE UNIQUE INDEX ux_dim_customer_customer_id
ON dwh.dim_customer(customer_id)
WHERE customer_id IS NOT NULL AND customer_id <> -1;
GO

CREATE UNIQUE INDEX ux_dim_product_product_id
ON dwh.dim_product(product_id)
WHERE product_id IS NOT NULL AND product_id <> -1;
GO

CREATE UNIQUE INDEX ux_dim_promotion_promo_id
ON dwh.dim_promotion(promo_id)
WHERE promo_id IS NOT NULL AND promo_id <> 'unknown' AND promo_id <> 'no_promo';
GO

CREATE UNIQUE INDEX ux_dim_payment_method
ON dwh.dim_payment_method(payment_method)
WHERE payment_method IS NOT NULL AND payment_method <> 'unknown';
GO

CREATE UNIQUE INDEX ux_dim_device
ON dwh.dim_device(device_type)
WHERE device_type IS NOT NULL AND device_type <> 'unknown';
GO

CREATE UNIQUE INDEX ux_dim_order_source
ON dwh.dim_order_source(order_source)
WHERE order_source IS NOT NULL AND order_source <> 'unknown';
GO

CREATE UNIQUE INDEX ux_dim_return_reason
ON dwh.dim_return_reason(return_reason)
WHERE return_reason IS NOT NULL AND return_reason <> 'unknown';
GO