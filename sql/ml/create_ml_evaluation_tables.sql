USE FashionEcommerceDW;
GO

DROP TABLE IF EXISTS ml.feature_importance;
DROP TABLE IF EXISTS ml.threshold_evaluation;
DROP TABLE IF EXISTS ml.model_evaluation_metrics;
GO

CREATE TABLE ml.model_evaluation_metrics (
    evaluation_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,

    model_name VARCHAR(100) NOT NULL,
    threshold DECIMAL(18,6) NOT NULL,

    training_rows INT NULL,
    test_rows INT NULL,

    accuracy DECIMAL(18,6) NULL,
    precision_score DECIMAL(18,6) NULL,
    recall_score DECIMAL(18,6) NULL,
    f1_score DECIMAL(18,6) NULL,
    roc_auc DECIMAL(18,6) NULL,
    pr_auc DECIMAL(18,6) NULL,
    log_loss_score DECIMAL(18,6) NULL,

    true_negative INT NULL,
    false_positive INT NULL,
    false_negative INT NULL,
    true_positive INT NULL,

    evaluated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE ml.threshold_evaluation (
    threshold_evaluation_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,

    model_name VARCHAR(100) NOT NULL,
    threshold DECIMAL(18,6) NOT NULL,

    precision_score DECIMAL(18,6) NULL,
    recall_score DECIMAL(18,6) NULL,
    f1_score DECIMAL(18,6) NULL,
    predicted_positive_count INT NULL,

    evaluated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE ml.feature_importance (
    feature_importance_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,

    model_name VARCHAR(100) NOT NULL,
    feature_name NVARCHAR(500) NOT NULL,
    coefficient_value DECIMAL(18,8) NULL,
    absolute_coefficient_value DECIMAL(18,8) NULL,
    importance_rank INT NULL,

    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO