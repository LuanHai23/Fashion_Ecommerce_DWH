USE FashionEcommerceDW;
GO

DECLARE @latest_run_id UNIQUEIDENTIFIER;

SELECT TOP 1
    @latest_run_id = run_id
FROM dq.data_quality_log
ORDER BY executed_at DESC;

SELECT
    check_name,
    table_name,
    check_type,
    severity,
    failed_count,
    description
FROM dq.data_quality_log
WHERE run_id = @latest_run_id
  AND check_status = 'failed'
ORDER BY
    CASE WHEN severity = 'critical' THEN 0 ELSE 1 END,
    failed_count DESC;