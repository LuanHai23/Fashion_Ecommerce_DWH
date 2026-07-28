USE FashionEcommerceDW;
GO

SELECT
    COUNT(*) AS invalid_web_traffic_rows
FROM dwh.fact_web_traffic_daily
WHERE sessions < 0
   OR unique_visitors < 0
   OR page_views < 0
   OR bounce_rate < 0
   OR bounce_rate > 1
   OR avg_session_duration_sec < 0;

SELECT
    traffic_source,
    COUNT(*) AS row_count,
    SUM(sessions) AS total_sessions,
    SUM(unique_visitors) AS total_unique_visitors,
    SUM(page_views) AS total_page_views,
    AVG(CAST(bounce_rate AS FLOAT)) AS avg_bounce_rate,
    AVG(CAST(avg_session_duration_sec AS FLOAT)) AS avg_session_duration_sec
FROM dwh.fact_web_traffic_daily
GROUP BY traffic_source
ORDER BY total_sessions DESC;