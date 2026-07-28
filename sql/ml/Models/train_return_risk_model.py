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
    classification_report,
)
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler


load_dotenv()


MODEL_NAME = "logistic_regression_return_risk_v1"
MODEL_PATH = "ml/models/return_risk_model.pkl"


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


def train_model(df: pd.DataFrame):
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

    numeric_features = X.select_dtypes(include=["int64", "float64", "int32", "float32"]).columns.tolist()
    categorical_features = X.select_dtypes(include=["object", "bool"]).columns.tolist()

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
        n_jobs=-1,
    )

    clf = Pipeline(
        steps=[
            ("preprocessor", preprocessor),
            ("model", model),
        ]
    )

    X_train, X_test, y_train, y_test = train_test_split(
        X,
        y,
        test_size=0.2,
        random_state=42,
        stratify=y,
    )

    clf.fit(X_train, y_train)

    y_pred = clf.predict(X_test)
    y_proba = clf.predict_proba(X_test)[:, 1]

    metrics = {
        "training_rows": len(X_train),
        "test_rows": len(X_test),
        "accuracy": accuracy_score(y_test, y_pred),
        "precision_score": precision_score(y_test, y_pred, zero_division=0),
        "recall_score": recall_score(y_test, y_pred, zero_division=0),
        "f1_score": f1_score(y_test, y_pred, zero_division=0),
        "roc_auc": roc_auc_score(y_test, y_proba),
    }

    print("Model metrics:")
    for key, value in metrics.items():
        print(f"{key}: {value}")

    print("\nClassification report:")
    print(classification_report(y_test, y_pred, zero_division=0))

    return clf, metrics, feature_cols


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
        **metrics,
    }

    with engine.begin() as conn:
        conn.execute(insert_sql, params)


def main():
    engine = create_sql_engine()

    print("Loading ML features from SQL Server...")
    df = load_features(engine)
    print(f"Loaded rows: {len(df):,}")
    print(df["is_returned"].value_counts(normalize=True))

    clf, metrics, feature_cols = train_model(df)

    os.makedirs("ml/models", exist_ok=True)
    joblib.dump(
        {
            "model": clf,
            "feature_cols": feature_cols,
            "model_name": MODEL_NAME,
        },
        MODEL_PATH,
    )

    print(f"Saved model to {MODEL_PATH}")

    save_training_log(engine, metrics)
    print("Saved training log to SQL Server.")


if __name__ == "__main__":
    main()

    