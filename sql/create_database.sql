USE master;
GO

IF DB_ID('FashionEcommerceDW') IS NOT NULL
BEGIN
    ALTER DATABASE FashionEcommerceDW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE FashionEcommerceDW;
END;
GO

CREATE DATABASE FashionEcommerceDW;
GO

USE FashionEcommerceDW;
GO

CREATE SCHEMA raw;
GO

CREATE SCHEMA stg;
GO

CREATE SCHEMA dwh;
GO

CREATE SCHEMA mart;
GO

CREATE SCHEMA ml;
GO

CREATE SCHEMA dq;
GO

CREATE SCHEMA audit;
GO

-- Check schema creation
SELECT 
    name AS schema_name
FROM sys.schemas
WHERE name IN ('raw', 'stg', 'dwh', 'mart', 'ml', 'dq', 'audit');
