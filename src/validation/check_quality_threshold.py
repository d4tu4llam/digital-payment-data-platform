from pathlib import Path
import os

from dotenv import load_dotenv
from sqlalchemy import create_engine, text


# ============================================================
# CONFIG
# ============================================================

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

engine = create_engine(DATABASE_URL)


# Maximum tolerated percentage of invalid transactions
QUALITY_THRESHOLD_PERCENT = 5.0


def get_count(connection, query):
    return connection.execute(
        text(query)
    ).scalar()


def main():

    print("=" * 70)
    print("DATA QUALITY SUMMARY")
    print("=" * 70)

    with engine.connect() as connection:

        raw_count = get_count(
            connection,
            """
            SELECT COUNT(*)
            FROM raw.transactions
            """
        )

        quarantined_count = get_count(
            connection,
            """
            SELECT COUNT(DISTINCT transaction_id)
            FROM quarantine.transactions
            """
        )

    valid_count = (
        raw_count - quarantined_count
    )

    if raw_count == 0:
        invalid_ratio = 0
    else:
        invalid_ratio = (
            quarantined_count
            / raw_count
            * 100
        )

    print(
        f"Raw transactions         : "
        f"{raw_count:,}"
    )

    print(
        f"Quarantined transactions : "
        f"{quarantined_count:,}"
    )

    print(
        f"Valid transactions       : "
        f"{valid_count:,}"
    )

    print(
        f"Invalid ratio            : "
        f"{invalid_ratio:.4f}%"
    )

    print(
        f"Threshold                : "
        f"{QUALITY_THRESHOLD_PERCENT:.2f}%"
    )

    print("=" * 70)

    if raw_count == 0:
        raise RuntimeError(
            "FAIL - raw.transactions is empty."
        )

    if invalid_ratio > QUALITY_THRESHOLD_PERCENT:

        raise RuntimeError(
            "FAIL - Data quality threshold exceeded. "
            f"Invalid ratio={invalid_ratio:.4f}% "
            f"> threshold={QUALITY_THRESHOLD_PERCENT:.2f}%"
        )

    print(
        "PASS - Data quality threshold satisfied."
    )


if __name__ == "__main__":
    main()