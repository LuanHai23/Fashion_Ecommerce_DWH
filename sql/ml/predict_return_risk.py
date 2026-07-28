import os
from urllib.parse import quote_plus

import joblib
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text


load_dotenv()


MODEL_PATH = "ml/models/return_risk_model_v2.pkl"


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


def risk_level(probability: float) -> str:
    if probability >= 0.60:
        return "high"
    if probability >= 0.45:
        return "medium"
    return "low"


def save_predictions(engine, predictions: pd.DataFrame):
    with engine.begin() as conn:
        conn.execute(text("TRUNCATE TABLE ml.return_prediction_results;"))

    predictions.to_sql(
        name="return_prediction_results",
        con=engine,
        schema="ml",
        if_exists="append",
        index=False,
        chunksize=5000,
        method=None,
    )


def main():
    engine = create_sql_engine()

    print("Loading model...")
    artifact = joblib.load(MODEL_PATH)

    model = artifact["model"]
    feature_cols = artifact["feature_cols"]
    model_name = artifact["model_name"]
    default_threshold = artifact.get("default_threshold", 0.6)

    print("Loading features...")
    df = load_features(engine)

    X = df[feature_cols]
    probabilities = model.predict_proba(X)[:, 1]

    results = pd.DataFrame(
        {
            "sales_order_item_key": df["sales_order_item_key"],
            "order_id": df["order_id"],
            "product_id": df["product_id"],
            "customer_id": df["customer_id"],
            "return_probability": probabilities,
        }
    )

    results["predicted_return_flag"] = (
        results["return_probability"] >= default_threshold
    ).astype(int)
    results["risk_level"] = results["return_probability"].apply(risk_level)
    results["model_name"] = model_name

    print(results.head())
    print(results["risk_level"].value_counts())

    print("Saving predictions to SQL Server...")
    save_predictions(engine, results)

    print("Prediction results saved.")

if __name__ == "__main__":
    main()
    