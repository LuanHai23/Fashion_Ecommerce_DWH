USE FashionEcommerceDW;
GO

SELECT
    MIN(full_date) AS min_date,
    MAX(full_date) AS max_date,
    COUNT(*) AS total_days
FROM dwh.dim_date;

SELECT TOP 10 *
FROM dwh.dim_date
ORDER BY full_date;

SELECT TOP 10 *
FROM dwh.dim_date
ORDER BY full_date DESC;