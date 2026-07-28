USE FashionEcommerceDW;
GO

DROP TABLE IF EXISTS audit.etl_step_log;
DROP TABLE IF EXISTS audit.etl_run;
GO

CREATE TABLE audit.etl_run (
    run_id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    pipeline_name VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL,
    started_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    ended_at DATETIME2 NULL,
    duration_seconds INT NULL,
    error_message NVARCHAR(MAX) NULL
);
GO

CREATE TABLE audit.etl_step_log (
    step_log_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    run_id UNIQUEIDENTIFIER NOT NULL,
    step_name VARCHAR(255) NOT NULL,
    script_path NVARCHAR(500) NULL,
    status VARCHAR(50) NOT NULL,
    started_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    ended_at DATETIME2 NULL,
    duration_seconds INT NULL,
    error_message NVARCHAR(MAX) NULL,

    CONSTRAINT fk_etl_step_log_run
        FOREIGN KEY (run_id)
        REFERENCES audit.etl_run(run_id)
);
GO