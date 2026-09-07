from pathlib import Path
import os

from dotenv import load_dotenv
from sqlalchemy import create_engine, text


# ============================================================
# DATABASE CONFIG
# ============================================================

BASE_DIR = Path(__file__).resolve().parents[1]

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
# HELPERS
# ============================================================

def get_scalar(query):

    with engine.connect() as connection:
        return connection.execute(
            text(query)
        ).scalar()


def get_count(table_name):

    return get_scalar(
        f"""
        SELECT COUNT(*)
        FROM {table_name}
        """
    )


# ============================================================
# TEST 1
# SOURCE -> RAW INGESTION
# ============================================================

def test_source_raw_ingestion_consistency():

    # Reference/entity tables should still match exactly
    tables = [
        "users",
        "wallets",
        "merchants",
        "transaction_types",
        "payment_methods",
        "transaction_statuses",
    ]

    for table in tables:

        source_count = get_count(
            f"source.{table}"
        )

        raw_count = get_count(
            f"raw.{table}"
        )

        assert source_count == raw_count, (
            f"Row count mismatch for {table}: "
            f"source={source_count}, "
            f"raw={raw_count}"
        )

    # Every source transaction must exist in raw
    missing_source_transactions = get_scalar(
        """
        SELECT COUNT(*)
        FROM source.transactions s
        LEFT JOIN raw.transactions r
            ON s.transaction_id = r.transaction_id
        WHERE r.transaction_id IS NULL
        """
    )

    assert missing_source_transactions == 0, (
        f"{missing_source_transactions} source transactions "
        "are missing from raw"
    )

    # Extra transactions in raw are allowed only if they
    # have been identified and quarantined
    unquarantined_extra_transactions = get_scalar(
        """
        SELECT COUNT(*)
        FROM raw.transactions r

        LEFT JOIN source.transactions s
            ON r.transaction_id = s.transaction_id

        WHERE s.transaction_id IS NULL

          AND NOT EXISTS (
              SELECT 1
              FROM quarantine.transactions q
              WHERE q.transaction_id = r.transaction_id
          )
        """
    )

    assert unquarantined_extra_transactions == 0, (
        f"{unquarantined_extra_transactions} extra raw transactions "
        "were not quarantined"
    )

# ============================================================
# TEST 2
# STAGING CONTAINS ONLY VALID TRANSACTIONS
# ============================================================

def test_staging_contains_only_valid_transactions():

    raw_count = get_count(
        "raw.transactions"
    )

    quarantined_count = get_scalar(
        """
        SELECT COUNT(DISTINCT transaction_id)
        FROM quarantine.transactions
        """
    )

    staging_count = get_count(
        "staging.transactions"
    )

    expected_staging_count = (
        raw_count - quarantined_count
    )

    assert (
        staging_count
        == expected_staging_count
    ), (
        "Invalid staging row count: "
        f"expected={expected_staging_count}, "
        f"actual={staging_count}"
    )


# ============================================================
# TEST 3
# QUARANTINED TRANSACTIONS MUST NOT ENTER STAGING
# ============================================================

def test_quarantined_transactions_not_in_staging():

    invalid_count = get_scalar(
        """
        SELECT COUNT(*)
        FROM staging.transactions s
        JOIN (
            SELECT DISTINCT transaction_id
            FROM quarantine.transactions
        ) q
            ON s.transaction_id = q.transaction_id
        """
    )

    assert invalid_count == 0


# ============================================================
# TEST 4
# STAGING -> FACT ROW COUNT
# ============================================================

def test_staging_fact_row_counts_match():

    staging_count = get_count(
        "staging.transactions"
    )

    fact_count = get_count(
        "analytics.fact_transactions"
    )

    assert staging_count == fact_count, (
        "Fact row count does not match staging: "
        f"staging={staging_count}, "
        f"fact={fact_count}"
    )


# ============================================================
# TEST 5
# FACT TABLE MUST NOT BE EMPTY
# ============================================================

def test_fact_transactions_not_empty():

    fact_count = get_count(
        "analytics.fact_transactions"
    )

    assert fact_count > 0


# ============================================================
# TEST 6
# FACT AMOUNT MUST BE POSITIVE
# ============================================================

def test_fact_amount_positive():

    invalid_count = get_scalar(
        """
        SELECT COUNT(*)
        FROM analytics.fact_transactions
        WHERE amount IS NULL
           OR amount <= 0
        """
    )

    assert invalid_count == 0


# ============================================================
# TEST 7
# FACT USER KEYS MUST BE VALID
# ============================================================

def test_fact_user_keys_valid():

    invalid_count = get_scalar(
        """
        SELECT COUNT(*)
        FROM analytics.fact_transactions f

        LEFT JOIN analytics.dim_users u
            ON f.user_key = u.user_key

        WHERE u.user_key IS NULL
        """
    )

    assert invalid_count == 0


# ============================================================
# TEST 8
# FACT TRANSACTION TYPE KEYS MUST BE VALID
# ============================================================

def test_fact_transaction_type_keys_valid():

    invalid_count = get_scalar(
        """
        SELECT COUNT(*)
        FROM analytics.fact_transactions f

        LEFT JOIN analytics.dim_transaction_types tt
            ON (
                f.transaction_type_key
                = tt.transaction_type_key
            )

        WHERE tt.transaction_type_key IS NULL
        """
    )

    assert invalid_count == 0


# ============================================================
# TEST 9
# MERCHANT KEY MUST BE VALID WHEN PRESENT
# ============================================================

def test_fact_merchant_keys_valid():

    invalid_count = get_scalar(
        """
        SELECT COUNT(*)
        FROM analytics.fact_transactions f

        LEFT JOIN analytics.dim_merchants m
            ON f.merchant_key = m.merchant_key

        WHERE f.merchant_key IS NOT NULL
          AND m.merchant_key IS NULL
        """
    )

    assert invalid_count == 0


# ============================================================
# TEST 10
# DATE KEY MUST EXIST
# ============================================================

def test_fact_date_keys_valid():

    invalid_count = get_scalar(
        """
        SELECT COUNT(*)
        FROM analytics.fact_transactions f

        LEFT JOIN analytics.dim_date d
            ON f.date_key = d.date_key

        WHERE d.date_key IS NULL
        """
    )

    assert invalid_count == 0


# ============================================================
# TEST 11
# QUALITY THRESHOLD
# ============================================================

def test_quarantine_ratio_within_threshold():

    quality_threshold = 5.0

    raw_count = get_count(
        "raw.transactions"
    )

    quarantined_count = get_scalar(
        """
        SELECT COUNT(DISTINCT transaction_id)
        FROM quarantine.transactions
        """
    )

    assert raw_count > 0

    invalid_ratio = (
        quarantined_count
        / raw_count
        * 100
    )

    assert invalid_ratio <= quality_threshold, (
        f"Invalid transaction ratio "
        f"{invalid_ratio:.4f}% "
        f"exceeds threshold "
        f"{quality_threshold:.2f}%"
    )