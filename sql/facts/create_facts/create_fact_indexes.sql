USE FashionEcommerceDW;
GO

CREATE INDEX ix_fact_sales_order_item_order_id
ON dwh.fact_sales_order_item(order_id);
GO

CREATE INDEX ix_fact_sales_order_item_order_date_key
ON dwh.fact_sales_order_item(order_date_key);
GO

CREATE INDEX ix_fact_sales_order_item_customer_key
ON dwh.fact_sales_order_item(customer_key);
GO

CREATE INDEX ix_fact_sales_order_item_product_key
ON dwh.fact_sales_order_item(product_key);
GO

CREATE INDEX ix_fact_sales_order_item_geography_key
ON dwh.fact_sales_order_item(geography_key);
GO

CREATE INDEX ix_fact_payment_order_id
ON dwh.fact_payment(order_id);
GO

CREATE INDEX ix_fact_shipment_order_id
ON dwh.fact_shipment(order_id);
GO

CREATE INDEX ix_fact_return_order_id_product_id
ON dwh.fact_return(order_id, product_id);
GO

CREATE INDEX ix_fact_review_order_id_product_id
ON dwh.fact_review(order_id, product_id);
GO