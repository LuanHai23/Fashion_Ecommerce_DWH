USE FashionEcommerceDW;
GO

CREATE OR ALTER PROCEDURE dq.usp_run_basic_data_quality_checks
    @run_id UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @run_id = COALESCE(@run_id, NEWID());

    ------------------------------------------------------------
    -- 1. ORDERS CHECKS
    ------------------------------------------------------------

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'orders_order_id_not_null',
        'stg.orders',
        'not_null',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'order_id must not be null in stg.orders'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.orders
        WHERE order_id IS NULL
    ) x;

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'orders_order_date_not_null',
        'stg.orders',
        'not_null',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'order_date must not be null in stg.orders'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.orders
        WHERE order_date IS NULL
    ) x;

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'orders_customer_id_not_null',
        'stg.orders',
        'not_null',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'customer_id must not be null in stg.orders'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.orders
        WHERE customer_id IS NULL
    ) x;

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'orders_order_id_unique',
        'stg.orders',
        'duplicate',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'order_id should be unique in stg.orders'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM (
            SELECT order_id
            FROM stg.orders
            WHERE order_id IS NOT NULL
            GROUP BY order_id
            HAVING COUNT(*) > 1
        ) d
    ) x;

    ------------------------------------------------------------
    -- 2. CUSTOMERS CHECKS
    ------------------------------------------------------------

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'customers_customer_id_not_null',
        'stg.customers',
        'not_null',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'customer_id must not be null in stg.customers'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.customers
        WHERE customer_id IS NULL
    ) x;

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'customers_customer_id_unique',
        'stg.customers',
        'duplicate',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'customer_id should be unique in stg.customers'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM (
            SELECT customer_id
            FROM stg.customers
            WHERE customer_id IS NOT NULL
            GROUP BY customer_id
            HAVING COUNT(*) > 1
        ) d
    ) x;

    ------------------------------------------------------------
    -- 3. PRODUCTS CHECKS
    ------------------------------------------------------------

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'products_product_id_not_null',
        'stg.products',
        'not_null',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'product_id must not be null in stg.products'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.products
        WHERE product_id IS NULL
    ) x;

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'products_product_id_unique',
        'stg.products',
        'duplicate',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'product_id should be unique in stg.products'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM (
            SELECT product_id
            FROM stg.products
            WHERE product_id IS NOT NULL
            GROUP BY product_id
            HAVING COUNT(*) > 1
        ) d
    ) x;

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'products_price_non_negative',
        'stg.products',
        'business_rule',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'product price must be greater than or equal to 0'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.products
        WHERE price IS NULL OR price < 0
    ) x;

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'products_cogs_non_negative',
        'stg.products',
        'business_rule',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'product cogs must be greater than or equal to 0'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.products
        WHERE cogs IS NULL OR cogs < 0
    ) x;

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'products_cogs_not_greater_than_price',
        'stg.products',
        'business_rule',
        'warning',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'product cogs should not be greater than product price'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.products
        WHERE cogs > price
    ) x;

    ------------------------------------------------------------
    -- 4. ORDER ITEMS CHECKS
    ------------------------------------------------------------

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'order_items_order_id_not_null',
        'stg.order_items',
        'not_null',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'order_id must not be null in stg.order_items'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.order_items
        WHERE order_id IS NULL
    ) x;

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'order_items_product_id_not_null',
        'stg.order_items',
        'not_null',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'product_id must not be null in stg.order_items'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.order_items
        WHERE product_id IS NULL
    ) x;

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'order_items_quantity_positive',
        'stg.order_items',
        'business_rule',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'quantity must be greater than 0'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.order_items
        WHERE quantity IS NULL OR quantity <= 0
    ) x;

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'order_items_unit_price_non_negative',
        'stg.order_items',
        'business_rule',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'unit_price must be greater than or equal to 0'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.order_items
        WHERE unit_price IS NULL OR unit_price < 0
    ) x;

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'order_items_discount_valid',
        'stg.order_items',
        'business_rule',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'discount_amount must be non-negative and not greater than quantity * unit_price'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.order_items
        WHERE discount_amount IS NULL
           OR discount_amount < 0
           OR discount_amount > quantity * unit_price
    ) x;

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'order_items_order_id_exists_in_orders',
        'stg.order_items',
        'foreign_key',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'order_items.order_id must exist in stg.orders'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.order_items oi
        LEFT JOIN stg.orders o
            ON oi.order_id = o.order_id
        WHERE oi.order_id IS NOT NULL
          AND o.order_id IS NULL
    ) x;

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'order_items_product_id_exists_in_products',
        'stg.order_items',
        'foreign_key',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'order_items.product_id must exist in stg.products'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.order_items oi
        LEFT JOIN stg.products p
            ON oi.product_id = p.product_id
        WHERE oi.product_id IS NOT NULL
          AND p.product_id IS NULL
    ) x;

    ------------------------------------------------------------
    -- 5. PAYMENTS CHECKS
    ------------------------------------------------------------

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'payments_order_id_exists_in_orders',
        'stg.payments',
        'foreign_key',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'payments.order_id must exist in stg.orders'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.payments p
        LEFT JOIN stg.orders o
            ON p.order_id = o.order_id
        WHERE p.order_id IS NOT NULL
          AND o.order_id IS NULL
    ) x;

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'payments_payment_value_non_negative',
        'stg.payments',
        'business_rule',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'payment_value must be greater than or equal to 0'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.payments
        WHERE payment_value IS NULL OR payment_value < 0
    ) x;

    ------------------------------------------------------------
    -- 6. SHIPMENTS CHECKS
    ------------------------------------------------------------

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'shipments_order_id_exists_in_orders',
        'stg.shipments',
        'foreign_key',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'shipments.order_id must exist in stg.orders'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.shipments s
        LEFT JOIN stg.orders o
            ON s.order_id = o.order_id
        WHERE s.order_id IS NOT NULL
          AND o.order_id IS NULL
    ) x;

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'shipments_ship_date_not_before_order_date',
        'stg.shipments',
        'business_rule',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'ship_date should not be before order_date'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.shipments s
        JOIN stg.orders o
            ON s.order_id = o.order_id
        WHERE s.ship_date < o.order_date
    ) x;

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'shipments_delivery_date_not_before_ship_date',
        'stg.shipments',
        'business_rule',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'delivery_date should not be before ship_date'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.shipments
        WHERE delivery_date < ship_date
    ) x;

    ------------------------------------------------------------
    -- 7. RETURNS CHECKS
    ------------------------------------------------------------

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'returns_return_id_not_null',
        'stg.returns',
        'not_null',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'return_id must not be null in stg.returns'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.returns
        WHERE return_id IS NULL
    ) x;

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'returns_order_id_exists_in_orders',
        'stg.returns',
        'foreign_key',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'returns.order_id must exist in stg.orders'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.returns r
        LEFT JOIN stg.orders o
            ON r.order_id = o.order_id
        WHERE r.order_id IS NOT NULL
          AND o.order_id IS NULL
    ) x;

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'returns_product_id_exists_in_products',
        'stg.returns',
        'foreign_key',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'returns.product_id must exist in stg.products'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.returns r
        LEFT JOIN stg.products p
            ON r.product_id = p.product_id
        WHERE r.product_id IS NOT NULL
          AND p.product_id IS NULL
    ) x;

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'returns_return_date_not_before_order_date',
        'stg.returns',
        'business_rule',
        'warning',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'return_date should not be before order_date'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.returns r
        JOIN stg.orders o
            ON r.order_id = o.order_id
        WHERE r.return_date < o.order_date
    ) x;

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'returns_refund_amount_non_negative',
        'stg.returns',
        'business_rule',
        'critical',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'refund_amount must be greater than or equal to 0'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.returns
        WHERE refund_amount IS NULL OR refund_amount < 0
    ) x;

    ------------------------------------------------------------
    -- 8. REVIEWS CHECKS
    ------------------------------------------------------------

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'reviews_order_id_exists_in_orders',
        'stg.reviews',
        'foreign_key',
        'warning',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'reviews.order_id should exist in stg.orders'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.reviews rv
        LEFT JOIN stg.orders o
            ON rv.order_id = o.order_id
        WHERE rv.order_id IS NOT NULL
          AND o.order_id IS NULL
    ) x;

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'reviews_product_id_exists_in_products',
        'stg.reviews',
        'foreign_key',
        'warning',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'reviews.product_id should exist in stg.products'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.reviews rv
        LEFT JOIN stg.products p
            ON rv.product_id = p.product_id
        WHERE rv.product_id IS NOT NULL
          AND p.product_id IS NULL
    ) x;

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'reviews_rating_between_1_and_5',
        'stg.reviews',
        'business_rule',
        'warning',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'rating should be between 1 and 5'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.reviews
        WHERE rating IS NULL OR rating < 1 OR rating > 5
    ) x;

    ------------------------------------------------------------
    -- 9. GEOGRAPHY CHECKS
    ------------------------------------------------------------

    INSERT INTO dq.data_quality_log (
        run_id, check_name, table_name, check_type, severity,
        failed_count, check_status, description
    )
    SELECT
        @run_id,
        'orders_zip_exists_in_geography',
        'stg.orders',
        'foreign_key',
        'warning',
        failed_count,
        CASE WHEN failed_count = 0 THEN 'passed' ELSE 'failed' END,
        'orders.zip should exist in stg.geography'
    FROM (
        SELECT COUNT_BIG(*) AS failed_count
        FROM stg.orders o
        LEFT JOIN stg.geography g
            ON o.zip = g.zip
        WHERE o.zip IS NOT NULL
          AND g.zip IS NULL
    ) x;

    ------------------------------------------------------------
    -- 10. SUMMARY OUTPUT
    ------------------------------------------------------------

    SELECT
        @run_id AS run_id,
        COUNT(*) AS total_checks,
        SUM(CASE WHEN check_status = 'passed' THEN 1 ELSE 0 END) AS passed_checks,
        SUM(CASE WHEN check_status = 'failed' THEN 1 ELSE 0 END) AS failed_checks,
        SUM(CASE WHEN check_status = 'failed' AND severity = 'critical' THEN 1 ELSE 0 END) AS critical_failed_checks,
        SUM(CASE WHEN check_status = 'failed' AND severity = 'warning' THEN 1 ELSE 0 END) AS warning_failed_checks
    FROM dq.data_quality_log
    WHERE run_id = @run_id;
END;
GO