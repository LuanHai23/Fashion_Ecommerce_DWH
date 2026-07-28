USE FashionEcommerceDW;
GO

DECLARE @run_id UNIQUEIDENTIFIER;

EXEC dq.usp_run_basic_data_quality_checks
    @run_id = @run_id OUTPUT;

SELECT
    dq_log_id,
    run_id,
    check_name,
    table_name,
    check_type,
    severity,
    failed_count,
    check_status,
    description,
    executed_at
FROM dq.data_quality_log
WHERE run_id = @run_id
ORDER BY
    CASE WHEN check_status = 'failed' THEN 0 ELSE 1 END,
    CASE WHEN severity = 'critical' THEN 0 ELSE 1 END,
    failed_count DESC,
    check_name;