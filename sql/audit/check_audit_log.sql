USE FashionEcommerceDW;
GO

SELECT TOP 20
    run_id,
    pipeline_name,
    status,
    started_at,
    ended_at,
    duration_seconds,
    error_message
FROM audit.etl_run
ORDER BY started_at DESC;
GO

SELECT TOP 100
    r.pipeline_name,
    r.status AS pipeline_status,
    s.step_name,
    s.script_path,
    s.status AS step_status,
    s.started_at,
    s.ended_at,
    s.duration_seconds,
    s.error_message
FROM audit.etl_step_log s
JOIN audit.etl_run r
    ON s.run_id = r.run_id
ORDER BY s.started_at DESC;
GO