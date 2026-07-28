SELECT TOP 100
    oi.*
FROM stg.order_items oi
LEFT JOIN stg.orders o
    ON oi.order_id = o.order_id
WHERE oi.order_id IS NOT NULL
  AND o.order_id IS NULL;

SELECT TOP 100
    oi.*
FROM stg.order_items oi
LEFT JOIN stg.products p
    ON oi.product_id = p.product_id
WHERE oi.product_id IS NOT NULL
  AND p.product_id IS NULL;

SELECT TOP 100
    order_id,
    product_id,
    quantity,
    unit_price,
    discount_amount,
    quantity * unit_price AS gross_revenue
FROM stg.order_items
WHERE discount_amount IS NULL
   OR discount_amount < 0
   OR discount_amount > quantity * unit_price;

SELECT TOP 100
    s.order_id,
    o.order_date,
    s.ship_date,
    s.delivery_date
FROM stg.shipments s
JOIN stg.orders o
    ON s.order_id = o.order_id
WHERE s.ship_date < o.order_date
   OR s.delivery_date < s.ship_date;

SELECT TOP 100
    r.order_id,
    o.order_date,
    r.return_date,
    r.return_reason
FROM stg.returns r
JOIN stg.orders o
    ON r.order_id = o.order_id
WHERE r.return_date < o.order_date;

SELECT TOP 100
    product_id,
    product_name,
    category,
    segment,
    price,
    cogs
FROM stg.products
WHERE cogs > price;

SELECT TOP 100
    *
FROM stg.reviews
WHERE rating IS NULL
   OR rating < 1
   OR rating > 5;