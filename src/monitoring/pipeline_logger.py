from pathlib import Path
import os

from dotenv import load_dotenv
from sqlalchemy import create_engine, text


BASE_DIR = Path(__file__).resolve().parents[2]

load_dotenv(BASE_DIR / ".env")


DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")


DATABASE_URL = (
    f"postgresql+psycopg2://"
    f"{DB_USER}:{DB_PASSWORD}"
    f"@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)


engine = create_engine(
    DATABASE_URL
)


def start_pipeline_run(
    run_id,
    pipeline_name,
    started_at,
):

    query = text(
        """
        INSERT INTO monitoring.pipeline_run_log (
            run_id,
            pipeline_name,
            status,
            started_at
        )
        VALUES (
            :run_id,
            :pipeline_name,
            'RUNNING',
            :started_at
        )
        ON CONFLICT (run_id)
        DO UPDATE SET
            status = 'RUNNING',
            started_at = EXCLUDED.started_at,
            finished_at = NULL,
            rows_processed = NULL,
            error_message = NULL;
        """
    )

    with engine.begin() as connection:
        connection.execute(
            query,
            {
                "run_id": run_id,
                "pipeline_name": pipeline_name,
                "started_at": started_at,
            },
        )

def get_fact_row_count():

    query = text(
        """
        SELECT COUNT(*)
        FROM analytics.fact_transactions
        """
    )

    with engine.connect() as connection:
        return connection.execute(
            query
        ).scalar()

def finish_pipeline_run(
    run_id,
    status,
    finished_at,
    rows_processed=None,
    error_message=None,
):

    query = text(
        """
        UPDATE monitoring.pipeline_run_log
        SET
            status = :status,
            finished_at = :finished_at,
            rows_processed = :rows_processed,
            error_message = :error_message
        WHERE run_id = :run_id;
        """
    )

    with engine.begin() as connection:
        connection.execute(
            query,
            {
                "run_id": run_id,
                "status": status,
                "finished_at": finished_at,
                "rows_processed": rows_processed,
                "error_message": error_message,
            },
        )