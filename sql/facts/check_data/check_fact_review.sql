USE FashionEcommerceDW;
GO

SELECT
    COUNT(*) AS invalid_review_rows
FROM dwh.fact_review
WHERE rating < 1
   OR rating > 5
   OR rating IS NULL;

SELECT
    AVG(CAST(rating AS FLOAT)) AS avg_rating,
    COUNT(*) AS total_reviews
FROM dwh.fact_review;