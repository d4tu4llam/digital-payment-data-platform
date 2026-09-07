from datetime import datetime

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator

import sys



sys.path.append("/opt/airflow")

from src.monitoring.pipeline_logger import (
    start_pipeline_run,
    finish_pipeline_run,
    get_fact_row_count,
)


# ============================================================
# CALLBACKS
# ============================================================

def pipeline_success_callback(context):

    dag_run = context["dag_run"]

    run_id = dag_run.run_id

    finished_at = datetime.utcnow()

    rows_processed = get_fact_row_count()

    finish_pipeline_run(
        run_id=run_id,
        status="SUCCESS",
        finished_at=finished_at,
        rows_processed=rows_processed,
    )


def pipeline_failure_callback(context):

    dag_run = context["dag_run"]

    run_id = dag_run.run_id

    exception = context.get("exception")

    finished_at = datetime.utcnow()

    finish_pipeline_run(
        run_id=run_id,
        status="FAILED",
        finished_at=finished_at,
        error_message=str(exception),
    )


def start_pipeline_log(**context):

    dag_run = context["dag_run"]

    run_id = dag_run.run_id

    start_pipeline_run(
        run_id=run_id,
        pipeline_name="digital_payment_pipeline",
        started_at=datetime.utcnow(),
    )


# ============================================================
# DAG CONFIGURATION
# ============================================================

default_args = {
    "owner": "hilmi",
    "retries": 1,
}


with DAG(
    dag_id="digital_payment_pipeline",
    default_args=default_args,
    description="Digital Payment Data Platform Pipeline",

    start_date=datetime(
        2026,
        9,
        1,
    ),

    schedule=None,

    catchup=False,

    tags=[
        "payment",
        "data-engineering",
    ],

    on_success_callback=
        pipeline_success_callback,

    on_failure_callback=
        pipeline_failure_callback,

) as dag:


    # ========================================================
    # START MONITORING
    # ========================================================

    start_monitoring = PythonOperator(
        task_id="start_monitoring",
        python_callable=start_pipeline_log,
    )


    # ========================================================
    # EXTRACT SOURCE -> RAW
    # ========================================================

    extract_source_to_raw = BashOperator(
        task_id="extract_source_to_raw",

        bash_command=(
            "cd /opt/airflow && "
            "python "
            "src/ingestion/"
            "extract_source_to_raw.py"
        ),
    )

    quarantine_invalid_transactions = BashOperator(
        task_id="quarantine_invalid_transactions",

        bash_command=(
            "psql "
            "-h postgres "
            "-p 5432 "
            "-U payment_user "
            "-d payment_db "
            "-f "
            "/opt/airflow/sql/"
            "quarantine/"
            "02_quarantine_invalid_transactions.sql"
        ),

        env={
            "PGPASSWORD": "payment_password",
        },
    )
    check_quality_threshold = BashOperator(
        task_id="check_quality_threshold",

        bash_command=(
            "cd /opt/airflow && "
            "python "
            "src/validation/"
            "check_quality_threshold.py"
        ),
    )

    # ========================================================
    # RAW -> STAGING
    # ========================================================

    load_staging = BashOperator(
        task_id="load_staging",

        bash_command=(
            "psql "
            "-h postgres "
            "-p 5432 "
            "-U payment_user "
            "-d payment_db "
            "-f "
            "/opt/airflow/sql/"
            "staging/"
            "02_load_staging_tables.sql"
        ),

        env={
            "PGPASSWORD":
                "payment_password",
        },
    )


    # ========================================================
    # LOAD DIMENSIONS
    # ========================================================

    load_dimensions = BashOperator(
        task_id="load_dimensions",

        bash_command=(
            "psql "
            "-h postgres "
            "-p 5432 "
            "-U payment_user "
            "-d payment_db "
            "-f "
            "/opt/airflow/sql/"
            "analytics/"
            "02_load_dimensions.sql"
        ),

        env={
            "PGPASSWORD":
                "payment_password",
        },
    )


    # ========================================================
    # LOAD FACT
    # ========================================================

    load_fact_transactions = BashOperator(
        task_id="load_fact_transactions",

        bash_command=(
            "psql "
            "-h postgres "
            "-p 5432 "
            "-U payment_user "
            "-d payment_db "
            "-f "
            "/opt/airflow/sql/"
            "analytics/"
            "03_load_fact_transactions.sql"
        ),

        env={
            "PGPASSWORD":
                "payment_password",
        },
    )


    # ========================================================
    # DEPENDENCIES
    # ========================================================

    (
        start_monitoring
        >> extract_source_to_raw
        >> quarantine_invalid_transactions
        >> check_quality_threshold
        >> load_staging
        >> load_dimensions
        >> load_fact_transactions
    )