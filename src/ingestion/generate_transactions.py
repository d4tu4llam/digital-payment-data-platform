from datetime import datetime, timedelta
from pathlib import Path
import random

import pandas as pd
from faker import Faker


# ============================================================
# Configuration
# ============================================================

NUM_TRANSACTIONS = 100_000
NUM_USERS = 10_000
NUM_MERCHANTS = 1_000

RANDOM_SEED = 42

OUTPUT_DIR = Path("data/raw")
OUTPUT_FILE = OUTPUT_DIR / "transactions.csv"

fake = Faker("id_ID")
Faker.seed(RANDOM_SEED)
random.seed(RANDOM_SEED)


# ============================================================
# Reference data
# ============================================================

PAYMENT_METHODS = [
    "QRIS",
    "VIRTUAL_ACCOUNT",
    "DEBIT_CARD",
    "CREDIT_CARD",
    "BALANCE",
]

STATUSES = [
    "SUCCESS",
    "FAILED",
    "PENDING",
]

CITIES = [
    "Jakarta",
    "Bandung",
    "Surabaya",
    "Semarang",
    "Yogyakarta",
    "Medan",
    "Makassar",
    "Denpasar",
]


# ============================================================
# Generate users
# ============================================================

def generate_users():
    users = []

    for i in range(1, NUM_USERS + 1):
        users.append(
            {
                "user_id": f"U{i:06d}",
            }
        )

    return users


# ============================================================
# Generate merchants
# ============================================================

def generate_merchants():
    categories = [
        "Food",
        "Retail",
        "Grocery",
        "Transportation",
        "Entertainment",
        "Healthcare",
        "Education",
    ]

    merchants = []

    for i in range(1, NUM_MERCHANTS + 1):
        merchants.append(
            {
                "merchant_id": f"M{i:05d}",
                "merchant_name": fake.company(),
                "category": random.choice(categories),
                "city": random.choice(CITIES),
            }
        )

    return merchants


# ============================================================
# Generate transactions
# ============================================================

def generate_transactions(users, merchants):
    transactions = []

    start_date = datetime.now() - timedelta(days=30)

    for i in range(1, NUM_TRANSACTIONS + 1):
        user = random.choice(users)
        merchant = random.choice(merchants)

        timestamp = start_date + timedelta(
            seconds=random.randint(0, 30 * 24 * 60 * 60)
        )

        amount = random.choice(
            [
                10_000,
                15_000,
                20_000,
                25_000,
                50_000,
                75_000,
                100_000,
                150_000,
                250_000,
                500_000,
            ]
        )

        transactions.append(
            {
                "transaction_id": f"TX{i:08d}",
                "user_id": user["user_id"],
                "merchant_id": merchant["merchant_id"],
                "transaction_timestamp": timestamp,
                "amount": amount,
                "payment_method": random.choice(PAYMENT_METHODS),
                "status": random.choices(
                    STATUSES,
                    weights=[90, 8, 2],
                    k=1,
                )[0],
                "city": merchant["city"],
                "currencry":"Rupiah",
            }
        )

    return transactions


# ============================================================
# Inject data quality issues
# ============================================================

def inject_data_quality_issues(df):
    """
    Add intentionally corrupted records so that our
    downstream data-quality pipeline has something to detect.
    """

    # 1. Duplicate records
    duplicates = df.sample(
        # n = random.randint(1, 100) Kalau mau random
        n=100,
        random_state=RANDOM_SEED,
    )

    df = pd.concat(
        [df, duplicates],
        ignore_index=True,
    )

    # 2. Missing user IDs
    missing_user_indices = df.sample(
        n=100,
        random_state=1,
    ).index

    df.loc[missing_user_indices, "user_id"] = None

    # 3. Negative amounts
    negative_amount_indices = df.sample(
        n=100,
        random_state=2,
    ).index

    df.loc[
        negative_amount_indices,
        "amount",
    ] *= -1

    # 4. Invalid status
    invalid_status_indices = df.sample(
        n=50,
        random_state=3,
    ).index

    df.loc[
        invalid_status_indices,
        "status",
    ] = "UNKNOWN"

    # 5. Invalid payment method
    invalid_payment_indices = df.sample(
        n=50,
        random_state=4,
    ).index

    df.loc[
        invalid_payment_indices,
        "payment_method",
    ] = "CRYPTO"

    return df


# ============================================================
# Main
# ============================================================

def main():
    print("Generating users...")
    users = generate_users()

    print("Generating merchants...")
    merchants = generate_merchants()

    print(f"Generating {NUM_TRANSACTIONS:,} transactions...")
    transactions = generate_transactions(
        users,
        merchants,
    )

    df = pd.DataFrame(transactions)

    print("Injecting data quality issues...")
    df = inject_data_quality_issues(df)

    OUTPUT_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )

    df.to_csv(
        OUTPUT_FILE,
        index=False,
    )

    print()
    print("=" * 50)
    print("DATA GENERATION COMPLETE")
    print("=" * 50)
    print(f"Output file : {OUTPUT_FILE}")
    print(f"Rows        : {len(df):,}")
    print(f"Columns     : {len(df.columns)}")
    print("=" * 50)


if __name__ == "__main__":
    main()