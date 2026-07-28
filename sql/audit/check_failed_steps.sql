USE FashionEcommerceDW;
GO

SELECT TOP 50
    r.run_id,
    r.pipeline_name,
    s.step_name,
    s.script_path,
    s.status,
    s.started_at,
    s.ended_at,
    s.duration_seconds,
    s.error_message
FROM audit.etl_step_log s
JOIN audit.etl_run r
    ON s.run_id = r.run_id
WHERE s.status = 'failed'
ORDER BY s.started_at DESC;
GO