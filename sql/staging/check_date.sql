USE FashionEcommerceDW;
GO

-- Shipment thì không được ship trước order date
SELECT COUNT(*) AS invalid_ship_before_order
FROM stg.shipments s
JOIN stg.orders o
    ON s.order_id = o.order_id
WHERE s.ship_date < o.order_date;

-- Delivery thì không được trước ship date
SELECT COUNT(*) AS invalid_delivery_before_ship
FROM stg.shipments
WHERE delivery_date < ship_date;

-- Return thì không nên trước order date
SELECT COUNT(*) AS invalid_return_before_order
FROM stg.returns r
JOIN stg.orders o
    ON r.order_id = o.order_id
WHERE r.return_date < o.order_date;

-- Review thì không nên trước order date
SELECT COUNT(*) AS invalid_review_before_order
FROM stg.reviews rv
JOIN stg.orders o
    ON rv.order_id = o.order_id
WHERE rv.review_date < o.order_date;