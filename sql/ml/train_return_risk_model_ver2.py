import os
from urllib.parse import quote_plus

import joblib
import numpy as np
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

from sklearn.compose import ColumnTransformer
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    roc_auc_score,
    average_precision_score,
    log_loss,
    confusion_matrix,
    classification_report,
)
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler


load_dotenv()


MODEL_NAME = "logistic_regression_return_risk_v2"
MODEL_PATH = "ml/models/return_risk_model_v2.pkl"
DEFAULT_THRESHOLD = 0.6


def create_sql_engine():
    server = os.getenv("SQL_SERVER", "localhost")
    database = os.getenv("SQL_DATABASE", "FashionEcommerceDW")

    conn_str = (
        "DRIVER={ODBC Driver 17 for SQL Server};"
        f"SERVER={server};"
        f"DATABASE={database};"
        "Trusted_Connection=yes;"
        "TrustServerCertificate=yes;"
    )

    connection_url = f"mssql+pyodbc:///?odbc_connect={quote_plus(conn_str)}"
    return create_engine(connection_url)


def load_features(engine) -> pd.DataFrame:
    query = """
    SELECT
        sales_order_item_key,
        order_id,
        product_id,
        customer_id,

        order_year,
        order_month,
        order_quarter,
        order_day_of_week,
        is_weekend,

        category,
        segment,
        size,
        color,

        quantity,
        unit_price,
        discount_amount,
        gross_revenue,
        net_revenue,
        estimated_cogs,
        gross_profit,
        discount_rate,
        profit_margin,

        gender,
        age_group,
        acquisition_channel,

        region,
        city,

        payment_method,
        device_type,
        order_source,

        shipping_fee,
        days_to_ship,
        days_to_deliver,
        total_fulfillment_days,

        is_returned
    FROM ml.return_prediction_features;
    """

    return pd.read_sql(query, engine)


def build_pipeline(X: pd.DataFrame) -> Pipeline:
    numeric_features = X.select_dtypes(
        include=["int64", "float64", "int32", "float32"]
    ).columns.tolist()

    categorical_features = X.select_dtypes(
        include=["object", "bool"]
    ).columns.tolist()

    numeric_transformer = Pipeline(
        steps=[
            ("imputer", SimpleImputer(strategy="median")),
            ("scaler", StandardScaler()),
        ]
    )

    categorical_transformer = Pipeline(
        steps=[
            ("imputer", SimpleImputer(strategy="most_frequent")),
            ("onehot", OneHotEncoder(handle_unknown="ignore")),
        ]
    )

    preprocessor = ColumnTransformer(
        transformers=[
            ("num", numeric_transformer, numeric_features),
            ("cat", categorical_transformer, categorical_features),
        ]
    )

    model = LogisticRegression(
        max_iter=1000,
        class_weight="balanced",
    )

    return Pipeline(
        steps=[
            ("preprocessor", preprocessor),
            ("model", model),
        ]
    )


def evaluate_at_threshold(y_true, y_proba, threshold: float) -> dict:
    y_pred = (y_proba >= threshold).astype(int)

    tn, fp, fn, tp = confusion_matrix(y_true, y_pred).ravel()

    return {
        "threshold": threshold,
        "accuracy": accuracy_score(y_true, y_pred),
        "precision_score": precision_score(y_true, y_pred, zero_division=0),
        "recall_score": recall_score(y_true, y_pred, zero_division=0),
        "f1_score": f1_score(y_true, y_pred, zero_division=0),
        "true_negative": int(tn),
        "false_positive": int(fp),
        "false_negative": int(fn),
        "true_positive": int(tp),
        "predicted_positive_count": int(y_pred.sum()),
    }


def save_main_evaluation(engine, metrics: dict):
    insert_sql = text("""
        INSERT INTO ml.model_evaluation_metrics (
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
            true_positive
        )
        VALUES (
            :model_name,
            :threshold,
            :training_rows,
            :test_rows,
            :accuracy,
            :precision_score,
            :recall_score,
            :f1_score,
            :roc_auc,
            :pr_auc,
            :log_loss_score,
            :true_negative,
            :false_positive,
            :false_negative,
            :true_positive
        );
    """)

    with engine.begin() as conn:
        conn.execute(insert_sql, metrics)


def save_threshold_evaluation(engine, threshold_df: pd.DataFrame):
    threshold_df.to_sql(
        name="threshold_evaluation",
        con=engine,
        schema="ml",
        if_exists="append",
        index=False,
        chunksize=1000,
    )


def get_feature_names(clf: Pipeline, feature_cols: list[str]) -> list[str]:
    preprocessor = clf.named_steps["preprocessor"]

    numeric_features = preprocessor.transformers_[0][2]
    categorical_features = preprocessor.transformers_[1][2]

    onehot = preprocessor.named_transformers_["cat"].named_steps["onehot"]
    categorical_encoded_features = onehot.get_feature_names_out(categorical_features)

    return list(numeric_features) + list(categorical_encoded_features)


def save_feature_importance(engine, clf: Pipeline, feature_cols: list[str]):
    model = clf.named_steps["model"]
    coefficients = model.coef_[0]

    feature_names = get_feature_names(clf, feature_cols)

    importance_df = pd.DataFrame(
        {
            "model_name": MODEL_NAME,
            "feature_name": feature_names,
            "coefficient_value": coefficients,
        }
    )

    importance_df["absolute_coefficient_value"] = importance_df[
        "coefficient_value"
    ].abs()

    importance_df = importance_df.sort_values(
        "absolute_coefficient_value",
        ascending=False,
    ).reset_index(drop=True)

    importance_df["importance_rank"] = importance_df.index + 1

    importance_df = importance_df.head(100)

    with engine.begin() as conn:
        conn.execute(
            text("DELETE FROM ml.feature_importance WHERE model_name = :model_name"),
            {"model_name": MODEL_NAME},
        )

    importance_df.to_sql(
        name="feature_importance",
        con=engine,
        schema="ml",
        if_exists="append",
        index=False,
        chunksize=1000,
    )


def save_training_log(engine, metrics: dict):
    insert_sql = text("""
        INSERT INTO ml.model_training_log (
            model_name,
            training_rows,
            test_rows,
            accuracy,
            precision_score,
            recall_score,
            f1_score,
            roc_auc
        )
        VALUES (
            :model_name,
            :training_rows,
            :test_rows,
            :accuracy,
            :precision_score,
            :recall_score,
            :f1_score,
            :roc_auc
        );
    """)

    params = {
        "model_name": MODEL_NAME,
        "training_rows": metrics["training_rows"],
        "test_rows": metrics["test_rows"],
        "accuracy": metrics["accuracy"],
        "precision_score": metrics["precision_score"],
        "recall_score": metrics["recall_score"],
        "f1_score": metrics["f1_score"],
        "roc_auc": metrics["roc_auc"],
    }

    with engine.begin() as conn:
        conn.execute(insert_sql, params)


def main():
    engine = create_sql_engine()

    print("Loading ML features from SQL Server...")
    df = load_features(engine)

    print(f"Loaded rows: {len(df):,}")
    print("\nTarget distribution:")
    print(df["is_returned"].value_counts(normalize=True))

    target_col = "is_returned"

    id_cols = [
        "sales_order_item_key",
        "order_id",
        "product_id",
        "customer_id",
    ]

    feature_cols = [col for col in df.columns if col not in id_cols + [target_col]]

    X = df[feature_cols]
    y = df[target_col].astype(int)

    X_train, X_test, y_train, y_test = train_test_split(
        X,
        y,
        test_size=0.2,
        random_state=42,
        stratify=y,
    )

    clf = build_pipeline(X_train)

    print("\nTraining Logistic Regression model...")
    clf.fit(X_train, y_train)

    y_proba = clf.predict_proba(X_test)[:, 1]

    default_eval = evaluate_at_threshold(
        y_true=y_test,
        y_proba=y_proba,
        threshold=DEFAULT_THRESHOLD,
    )

    roc_auc = roc_auc_score(y_test, y_proba)
    pr_auc = average_precision_score(y_test, y_proba)
    loss = log_loss(y_test, y_proba)

    main_metrics = {
        "model_name": MODEL_NAME,
        "training_rows": int(len(X_train)),
        "test_rows": int(len(X_test)),
        "roc_auc": float(roc_auc),
        "pr_auc": float(pr_auc),
        "log_loss_score": float(loss),
        **default_eval,
    }

    print("\nMain evaluation at threshold 0.5:")
    for key, value in main_metrics.items():
        print(f"{key}: {value}")

    y_pred_default = (y_proba >= DEFAULT_THRESHOLD).astype(int)

    print("\nClassification report:")
    print(classification_report(y_test, y_pred_default, zero_division=0))

    print("\nConfusion matrix:")
    print(confusion_matrix(y_test, y_pred_default))

    thresholds = [0.10, 0.20, 0.30, 0.40, 0.50, 0.60, 0.70, 0.80, 0.90]

    threshold_rows = []
    for threshold in thresholds:
        row = evaluate_at_threshold(y_test, y_proba, threshold)
        row["model_name"] = MODEL_NAME
        threshold_rows.append(row)

    threshold_df = pd.DataFrame(threshold_rows)

    threshold_df = threshold_df[
        [
            "model_name",
            "threshold",
            "precision_score",
            "recall_score",
            "f1_score",
            "predicted_positive_count",
        ]
    ]

    print("\nThreshold tuning table:")
    print(threshold_df)

    os.makedirs("ml/models", exist_ok=True)

    joblib.dump(
        {
            "model": clf,
            "feature_cols": feature_cols,
            "model_name": MODEL_NAME,
            "default_threshold": DEFAULT_THRESHOLD,
        },
        MODEL_PATH,
    )

    print(f"\nSaved model to {MODEL_PATH}")

    save_training_log(engine, main_metrics)
    save_main_evaluation(engine, main_metrics)
    save_threshold_evaluation(engine, threshold_df)
    save_feature_importance(engine, clf, feature_cols)

    print("Saved evaluation metrics, threshold tuning, and feature importance to SQL Server.")


if __name__ == "__main__":
    main()