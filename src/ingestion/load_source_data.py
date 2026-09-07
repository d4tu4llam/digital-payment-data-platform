from pathlib import Path
import os

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
BASE_DIR = Path(__file__).resolve().parents[2]


load_dotenv(BASE_DIR / ".env")


DATA_DIR = BASE_DIR / "data" / "source_seed"

DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
print("Password correct:", DB_PASSWORD == "payment_password")

print("DB_HOST:", DB_HOST)
print("DB_PORT:", DB_PORT)
print("DB_NAME:", DB_NAME)
print("DB_USER:", DB_USER)

DATABASE_URL = (
    f"postgresql+psycopg2://"
    f"{DB_USER}:{DB_PASSWORD}"
    f"@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

engine = create_engine(DATABASE_URL)


def load_table(file_name, table_name):
    print(f"Loading {table_name}...")

    df = pd.read_csv(DATA_DIR / file_name)

    df.to_sql(
        name=table_name,
        con=engine,
        schema="source",
        if_exists="append",
        index=False,
        method="multi",
        chunksize=1000,
    )

    print(f"Loaded {len(df):,} rows into source.{table_name}")


def verify_row_counts():
    tables = [
        "users",
        "wallets",
        "merchants",
        "transactions",
    ]

    print("\nSOURCE ROW COUNTS")
    print("=" * 50)

    with engine.connect() as connection:
        for table in tables:
            count = connection.execute(
                text(f"SELECT COUNT(*) FROM source.{table}")
            ).scalar()

            print(f"{table:<15}: {count:,}")


def main():
    load_table("users.csv", "users")
    load_table("wallets.csv", "wallets")
    load_table("merchants.csv", "merchants")
    load_table("transactions.csv", "transactions")

    verify_row_counts()


if __name__ == "__main__":
    main()