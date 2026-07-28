USE FashionEcommerceDW;
GO

DROP TABLE IF EXISTS dq.data_quality_log;
GO

CREATE TABLE dq.data_quality_log (
    dq_log_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    run_id UNIQUEIDENTIFIER NOT NULL,
    check_name VARCHAR(255) NOT NULL,
    table_name VARCHAR(255) NOT NULL,
    check_type VARCHAR(100) NOT NULL,
    severity VARCHAR(50) NOT NULL,
    failed_count BIGINT NOT NULL,
    check_status VARCHAR(50) NOT NULL,
    description NVARCHAR(1000) NULL,
    executed_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO