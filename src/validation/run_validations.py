from pathlib import Path
import os

from dotenv import load_dotenv
from sqlalchemy import create_engine, text


# ============================================================
# PATHS
# ============================================================

BASE_DIR = Path(__file__).resolve().parents[2]
SQL_DIR = BASE_DIR / "sql" / "validation"


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
# VALIDATION FILES
# ============================================================

VALIDATION_FILES = [
    "check_duplicates.sql",
    "check_referential_integrity.sql",
    "check_business_rules.sql",
    "check_temporal_integrity.sql",
]


# ============================================================
# RUN VALIDATION
# ============================================================

def run_validation_file(connection, file_name):
    file_path = SQL_DIR / file_name

    print()
    print("=" * 70)
    print(file_name)
    print("=" * 70)

    sql_content = file_path.read_text(encoding="utf-8")

    statements = [
        statement.strip()
        for statement in sql_content.split(";")
        if statement.strip()
    ]

    total_failed_records = 0

    for statement in statements:
        result = connection.execute(text(statement))

        rows = result.fetchall()

        for row in rows:
            check_name = row[0]
            failed_records = row[1]

            status = (
                "PASS"
                if failed_records == 0
                else "FAIL"
            )

            print(
                f"{status:<5} | "
                f"{failed_records:<8} | "
                f"{check_name}"
            )

            total_failed_records += failed_records

    return total_failed_records


# ============================================================
# MAIN
# ============================================================

def main():
    print("=" * 70)
    print("DATA QUALITY VALIDATION")
    print("=" * 70)

    total_failures = 0

    with engine.connect() as connection:
        for file_name in VALIDATION_FILES:
            failures = run_validation_file(
                connection,
                file_name,
            )

            total_failures += failures

    print()
    print("=" * 70)
    print("VALIDATION SUMMARY")
    print("=" * 70)

    if total_failures == 0:
        print("PASS - All validation checks passed.")
    else:
        print(
            f"FAIL - {total_failures:,} "
            f"invalid records detected."
        )


if __name__ == "__main__":
    main()