from pathlib import Path
import os

from dotenv import load_dotenv
from sqlalchemy import create_engine, text


# ============================================================
# PATHS
# ============================================================

BASE_DIR = Path(__file__).resolve().parents[2]


# ============================================================
# DATABASE CONFIG
# ============================================================

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

engine = create_engine(DATABASE_URL)


# ============================================================
# TABLES TO INGEST
# ============================================================

TABLES = [
    "users",
    "wallets",
    "merchants",
    "transaction_types",
    "payment_methods",
    "transaction_statuses",
    "transactions",
]


# ============================================================
# EXTRACT SOURCE -> RAW
# ============================================================

def extract_table(connection, table_name):

    print(f"Ingesting source.{table_name} -> raw.{table_name}...")

    # For development/MVP:
    # raw table is refreshed before each ingestion.
    connection.execute(
        text(
            f"TRUNCATE TABLE raw.{table_name}"
        )
    )

    connection.execute(
        text(
            f"""
            INSERT INTO raw.{table_name}
            SELECT
                *,
                CURRENT_TIMESTAMP AS ingested_at
            FROM source.{table_name}
            """
        )
    )

    source_count = connection.execute(
        text(
            f"SELECT COUNT(*) FROM source.{table_name}"
        )
    ).scalar()

    raw_count = connection.execute(
        text(
            f"SELECT COUNT(*) FROM raw.{table_name}"
        )
    ).scalar()

    print(
        f"source.{table_name}: "
        f"{source_count:,} rows"
    )

    print(
        f"raw.{table_name}: "
        f"{raw_count:,} rows"
    )

    if source_count != raw_count:
        raise ValueError(
            f"Row count mismatch for {table_name}: "
            f"source={source_count}, "
            f"raw={raw_count}"
        )

    print("PASS")
    print()


# ============================================================
# MAIN
# ============================================================

def main():

    print("=" * 70)
    print("SOURCE TO RAW INGESTION")
    print("=" * 70)
    print()

    with engine.begin() as connection:

        for table_name in TABLES:
            extract_table(
                connection,
                table_name,
            )

    print("=" * 70)
    print("INGESTION COMPLETE")
    print("=" * 70)


if __name__ == "__main__":
    main()