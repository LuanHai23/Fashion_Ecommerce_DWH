import os
import sys
import uuid
import time
from pathlib import Path

import pyodbc
from dotenv import load_dotenv


load_dotenv()


PROJECT_ROOT = Path(__file__).resolve().parents[1]


PIPELINE_NAME = "fashion_ecommerce_dwh_refresh"


SQL_FILES = [
    # Staging refresh
    "sql/02_staging/load_staging_tables.sql",

    # Data quality
    "sql/07_dq/run_dq_checks.sql",

    # Dimension refresh
    "sql/03_dimensions/load_dimension_tables.sql",

    # Core facts
    "sql/04_facts/load_core_fact_tables.sql",

    # Advanced facts
    "sql/04_facts/load_advanced_fact_tables.sql",

    # Power BI marts
    "sql/05_marts/create_powerbi_marts.sql",

    # ML features
    "sql/06_ml/load_return_prediction_features.sql",

    # AI prediction mart view
    "sql/06_ml/create_prediction_mart.sql",
]


def get_connection():
    server = os.getenv("SQL_SERVER", "localhost")
    database = os.getenv("SQL_DATABASE", "FashionEcommerceDW")
    driver = os.getenv("SQL_DRIVER", "ODBC Driver 17 for SQL Server")

    conn_str = (
        f"DRIVER={{{driver}}};"
        f"SERVER={server};"
        f"DATABASE={database};"
        "Trusted_Connection=yes;"
        "TrustServerCertificate=yes;"
    )

    return pyodbc.connect(conn_str, autocommit=False)


def split_sql_batches(sql_text: str):
    batches = []
    current_batch = []

    for line in sql_text.splitlines():
        if line.strip().upper() == "GO":
            batch = "\n".join(current_batch).strip()
            if batch:
                batches.append(batch)
            current_batch = []
        else:
            current_batch.append(line)

    final_batch = "\n".join(current_batch).strip()
    if final_batch:
        batches.append(final_batch)

    return batches


def execute_sql_file(conn, script_path: Path):
    sql_text = script_path.read_text(encoding="utf-8")
    batches = split_sql_batches(sql_text)

    cursor = conn.cursor()

    for batch in batches:
        cursor.execute(batch)

        while cursor.nextset():
            pass


def start_pipeline_run(conn, run_id: str):
    cursor = conn.cursor()
    cursor.execute(
        """
        INSERT INTO audit.etl_run (
            run_id,
            pipeline_name,
            status,
            started_at
        )
        VALUES (?, ?, 'running', SYSDATETIME());
        """,
        run_id,
        PIPELINE_NAME,
    )
    conn.commit()


def finish_pipeline_run(conn, run_id: str, status: str, error_message: str | None = None):
    cursor = conn.cursor()
    cursor.execute(
        """
        UPDATE audit.etl_run
        SET
            status = ?,
            ended_at = SYSDATETIME(),
            duration_seconds = DATEDIFF(SECOND, started_at, SYSDATETIME()),
            error_message = ?
        WHERE run_id = ?;
        """,
        status,
        error_message,
        run_id,
    )
    conn.commit()
    cursor.close()


def start_step(conn, run_id: str, step_name: str, script_path: str):
    cursor = conn.cursor()

    cursor.execute(
        """
        INSERT INTO audit.etl_step_log (
            run_id,
            step_name,
            script_path,
            status,
            started_at
        )
        OUTPUT INSERTED.step_log_id
        VALUES (?, ?, ?, 'running', SYSDATETIME());
        """,
        run_id,
        step_name,
        script_path,
    )

    row = cursor.fetchone()
    step_log_id = int(row[0])

    conn.commit()
    cursor.close()

    return step_log_id


def finish_step(conn, step_log_id: int, status: str, error_message: str | None = None):
    cursor = conn.cursor()
    cursor.execute(
        """
        UPDATE audit.etl_step_log
        SET
            status = ?,
            ended_at = SYSDATETIME(),
            duration_seconds = DATEDIFF(SECOND, started_at, SYSDATETIME()),
            error_message = ?
        WHERE step_log_id = ?;
        """,
        status,
        error_message,
        step_log_id,
    )
    conn.commit()
    cursor.close()

def run_pipeline():
    run_id = str(uuid.uuid4())

    print("=" * 80)
    print(f"Starting pipeline: {PIPELINE_NAME}")
    print(f"Run ID: {run_id}")
    print("=" * 80)

    conn = get_connection()

    try:
        start_pipeline_run(conn, run_id)

        for relative_path in SQL_FILES:
            script_path = PROJECT_ROOT / relative_path
            step_name = Path(relative_path).stem

            if not script_path.exists():
                raise FileNotFoundError(f"SQL file not found: {script_path}")

            print(f"\nRunning step: {step_name}")
            print(f"Script: {relative_path}")

            step_log_id = start_step(
                conn=conn,
                run_id=run_id,
                step_name=step_name,
                script_path=relative_path,
            )

            start_time = time.time()

            try:
                execute_sql_file(conn, script_path)
                conn.commit()

                duration = round(time.time() - start_time, 2)
                finish_step(conn, step_log_id, "success")

                print(f"✅ Success: {step_name} ({duration}s)")

            except Exception as step_error:
                conn.rollback()

                error_message = str(step_error)
                finish_step(conn, step_log_id, "failed", error_message)

                print(f"❌ Failed: {step_name}")
                print(error_message)

                raise

        finish_pipeline_run(conn, run_id, "success")

        print("\n" + "=" * 80)
        print("✅ Pipeline completed successfully")
        print(f"Run ID: {run_id}")
        print("=" * 80)

    except Exception as pipeline_error:
        finish_pipeline_run(conn, run_id, "failed", str(pipeline_error))

        print("\n" + "=" * 80)
        print("❌ Pipeline failed")
        print(f"Run ID: {run_id}")
        print(str(pipeline_error))
        print("=" * 80)

        sys.exit(1)

    finally:
        conn.close()


if __name__ == "__main__":
    run_pipeline()