USE FashionEcommerceDW;
GO

SELECT TOP 10
    model_name,
    threshold,
    training_rows,
    test_rows,
    accuracy,
    precision_score,
    recall_score,
    f1_score,
    roc_auc,
    pr_auc,
    log_loss_score,
    true_negative,
    false_positive,
    false_negative,
    true_positive,
    evaluated_at
FROM ml.model_evaluation_metrics
ORDER BY evaluated_at DESC;
GO

SELECT TOP 100
    model_name,
    threshold,
    precision_score,
    recall_score,
    f1_score,
    predicted_positive_count,
    evaluated_at
FROM ml.threshold_evaluation
ORDER BY evaluated_at DESC, threshold;
GO

SELECT TOP 30
    model_name,
    importance_rank,
    feature_name,
    coefficient_value,
    absolute_coefficient_value,
    created_at
FROM ml.feature_importance
ORDER BY created_at DESC, importance_rank;
GO