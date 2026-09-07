from pathlib import Path
import random
import uuid

import numpy as np
import pandas as pd


# ============================================================
# CONFIGURATION
# ============================================================

SEED = 42

NUM_USERS = 10_000
NUM_MERCHANTS = 1_000
NUM_TRANSACTIONS = 100_000

OUTPUT_DIR = Path("data/source_seed")

random.seed(SEED)
np.random.seed(SEED)


# ============================================================
# DATE RANGE
# ============================================================

DATA_START = pd.Timestamp("2024-01-01")
DATA_END = pd.Timestamp("2026-08-23")


# ============================================================
# CONSTANTS
# ============================================================

CITIES = [
    "Jakarta",
    "Bandung",
    "Surabaya",
    "Medan",
    "Semarang",
    "Makassar",
    "Yogyakarta",
    "Denpasar",
    "Palembang",
    "Tangerang",
]

USER_STATUSES = [
    "ACTIVE",
    "INACTIVE",
    "SUSPENDED",
]

WALLET_STATUSES = [
    "ACTIVE",
    "FROZEN",
    "CLOSED",
]

MERCHANT_CATEGORIES = [
    "Food & Beverage",
    "Retail",
    "Groceries",
    "Transportation",
    "Entertainment",
    "Healthcare",
    "Education",
    "Fashion",
    "Electronics",
    "Travel",
]

MERCHANT_STATUSES = [
    "ACTIVE",
    "INACTIVE",
    "SUSPENDED",
]

TRANSACTION_TYPES = [
    "PAYMENT",
    "TRANSFER",
    "TOP_UP",
    "WITHDRAWAL",
    "REFUND",
    "BILL_PAYMENT",
]

TRANSACTION_TYPE_PROBABILITIES = [
    0.45,  # PAYMENT
    0.20,  # TRANSFER
    0.15,  # TOP_UP
    0.07,  # WITHDRAWAL
    0.03,  # REFUND
    0.10,  # BILL_PAYMENT
]

PAYMENT_METHODS = [
    "WALLET_BALANCE",
    "QRIS",
    "VIRTUAL_ACCOUNT",
    "DEBIT_CARD",
    "CREDIT_CARD",
    "BANK_TRANSFER",
]

TRANSACTION_STATUSES = [
    "SUCCESS",
    "FAILED",
    "PENDING",
    "CANCELLED",
    "REVERSED",
]

CHANNELS = [
    "MOBILE_APP",
    "WEB",
    "QRIS",
    "BANK",
    "ATM",
]


# ============================================================
# UTILITY FUNCTIONS
# ============================================================

def generate_id(prefix: str, number: int) -> str:
    return f"{prefix}{number:06d}"


def random_timestamp(start, end):
    start = pd.Timestamp(start)
    end = pd.Timestamp(end)

    seconds = int((end - start).total_seconds())

    return start + pd.Timedelta(
        seconds=random.randint(0, seconds)
    )


def weighted_choice(values, probabilities):
    probabilities = np.asarray(
        probabilities,
        dtype=float,
    )

    if len(values) != len(probabilities):
        raise ValueError(
            f"Length mismatch: "
            f"{len(values)} values but "
            f"{len(probabilities)} probabilities"
        )

    if not np.isclose(
        probabilities.sum(),
        1.0,
    ):
        raise ValueError(
            f"Probabilities must sum to 1.0, "
            f"got {probabilities.sum():.6f}"
        )

    return np.random.choice(
        values,
        p=probabilities,
    )


# ============================================================
# USERS
# ============================================================

def generate_users():

    print("Generating users...")

    rows = []

    for i in range(1, NUM_USERS + 1):

        registration_date = random_timestamp(
            DATA_START,
            DATA_END - pd.Timedelta(days=7),
        )

        status = weighted_choice(
            USER_STATUSES,
            [0.90, 0.07, 0.03],
        )

        rows.append({
            "user_id": generate_id("U", i),

            "full_name": f"User {i:06d}",

            "phone_number": (
                f"08{random.randint(1000000000, 9999999999)}"
            ),

            "email": f"user{i:06d}@example.com",

            "city": random.choice(CITIES),

            "registration_date": registration_date.date(),

            "status": status,

            "created_at": registration_date,
        })

    return pd.DataFrame(rows)


# ============================================================
# WALLETS
# ============================================================

def generate_wallets(users):

    print("Generating wallets...")

    rows = []

    for i, user in users.iterrows():

        registration_date = pd.Timestamp(
            user["registration_date"]
        )

        # Wallet is created shortly after user registration
        wallet_created = registration_date + pd.Timedelta(
            days=random.randint(0, 2),
            hours=random.randint(0, 23),
        )

        wallet_created = min(
            wallet_created,
            DATA_END,
        )

        balance = round(
            np.random.lognormal(
                mean=11,
                sigma=1.0,
            ),
            2,
        )

        status = weighted_choice(
            WALLET_STATUSES,
            [0.94, 0.04, 0.02],
        )

        updated_at = min(
            wallet_created
            + pd.Timedelta(
                days=random.randint(0, 500)
            ),
            DATA_END,
        )

        rows.append({
            "wallet_id": generate_id("W", i + 1),

            "user_id": user["user_id"],

            "balance": balance,

            "currency": "IDR",

            "status": status,

            "created_at": wallet_created,

            "updated_at": updated_at,
        })

    return pd.DataFrame(rows)


# ============================================================
# MERCHANTS
# ============================================================

def generate_merchants():

    print("Generating merchants...")

    rows = []

    for i in range(1, NUM_MERCHANTS + 1):

        created_at = random_timestamp(
            pd.Timestamp("2022-01-01"),
            DATA_END - pd.Timedelta(days=30),
        )

        category = random.choice(
            MERCHANT_CATEGORIES
        )

        merchant_size = weighted_choice(
            ["SMALL", "MEDIUM", "LARGE"],
            [0.70, 0.25, 0.05],
        )

        status = weighted_choice(
            MERCHANT_STATUSES,
            [0.90, 0.07, 0.03],
        )

        rows.append({
            "merchant_id": generate_id("M", i),

            "merchant_name": (
                f"{category} Merchant {i:05d}"
            ),

            "category": category,

            "city": random.choice(CITIES),

            "status": status,

            "merchant_size": merchant_size,

            "created_at": created_at,
        })

    return pd.DataFrame(rows)


# ============================================================
# TRANSACTION TIMESTAMP
# ============================================================

def generate_transaction_timestamp(
    user_registration_date,
    wallet_created_at,
    merchant_created_at=None,
):

    start = max(
        pd.Timestamp(user_registration_date),
        pd.Timestamp(wallet_created_at),
        DATA_START,
    )

    if merchant_created_at is not None:
        start = max(
            start,
            pd.Timestamp(merchant_created_at),
        )

    if start >= DATA_END:
        return None

    hour_weights = np.array([
        2,   # 00
        1,   # 01
        1,   # 02
        1,   # 03
        1,   # 04
        2,   # 05
        4,   # 06
        7,   # 07
        10,  # 08
        10,  # 09
        9,   # 10
        10,  # 11
        12,  # 12
        11,  # 13
        9,   # 14
        9,   # 15
        10,  # 16
        12,  # 17
        16,  # 18
        20,  # 19
        18,  # 20
        14,  # 21
        9,   # 22
        5,   # 23
    ], dtype=float)

    hour_probabilities = (
        hour_weights / hour_weights.sum()
    )

    while True:

        max_days = (
            DATA_END.normalize()
            - start.normalize()
        ).days

        random_day = random.randint(
            0,
            max_days,
        )

        date = (
            start.normalize()
            + pd.Timedelta(
                days=random_day
            )
        )

        hour = weighted_choice(
            list(range(24)),
            hour_probabilities,
        )

        candidate = (
            date
            + pd.Timedelta(
                hours=int(hour),
                minutes=random.randint(0, 59),
                seconds=random.randint(0, 59),
            )
        )

        if start <= candidate <= DATA_END:
            return candidate


# ============================================================
# AMOUNT GENERATION
# ============================================================

def generate_amount(
    transaction_type,
    merchant_category=None,
):

    if transaction_type == "PAYMENT":

        category_ranges = {
            "Food & Beverage": (15_000, 250_000),
            "Retail": (25_000, 1_000_000),
            "Groceries": (30_000, 750_000),
            "Transportation": (10_000, 300_000),
            "Entertainment": (30_000, 500_000),
            "Healthcare": (50_000, 2_000_000),
            "Education": (50_000, 3_000_000),
            "Fashion": (50_000, 2_000_000),
            "Electronics": (100_000, 10_000_000),
            "Travel": (100_000, 15_000_000),
        }

        low, high = category_ranges.get(
            merchant_category,
            (10_000, 500_000),
        )

        amount = np.random.lognormal(
            mean=np.log(
                (low + high) / 2
            ),
            sigma=0.6,
        )

        return round(
            min(
                max(amount, low),
                high,
            ),
            2,
        )

    if transaction_type == "TRANSFER":

        return round(
            np.random.lognormal(
                mean=np.log(300_000),
                sigma=1.0,
            ),
            2,
        )

    if transaction_type == "TOP_UP":

        return random.choice([
            20_000,
            50_000,
            100_000,
            200_000,
            500_000,
            1_000_000,
            2_000_000,
            5_000_000,
        ])

    if transaction_type == "WITHDRAWAL":

        return random.choice([
            50_000,
            100_000,
            200_000,
            500_000,
            1_000_000,
            2_000_000,
        ])

    if transaction_type == "REFUND":

        return round(
            np.random.uniform(
                10_000,
                1_000_000,
            ),
            2,
        )

    if transaction_type == "BILL_PAYMENT":

        return round(
            np.random.uniform(
                20_000,
                2_000_000,
            ),
            2,
        )

    raise ValueError(
        f"Unknown transaction type: "
        f"{transaction_type}"
    )


# ============================================================
# PAYMENT METHOD
# ============================================================

def generate_payment_method(
    transaction_type
):

    if transaction_type == "TRANSFER":

        return "WALLET_BALANCE"

    if transaction_type == "TOP_UP":

        return weighted_choice(
            [
                "VIRTUAL_ACCOUNT",
                "BANK_TRANSFER",
                "DEBIT_CARD",
                "CREDIT_CARD",
            ],
            [
                0.35,
                0.35,
                0.20,
                0.10,
            ],
        )

    if transaction_type == "WITHDRAWAL":

        return weighted_choice(
            [
                "BANK_TRANSFER",
                "WALLET_BALANCE",
            ],
            [
                0.80,
                0.20,
            ],
        )

    if transaction_type == "PAYMENT":

        return weighted_choice(
            PAYMENT_METHODS,
            [
                0.20,
                0.35,
                0.10,
                0.10,
                0.05,
                0.20,
            ],
        )

    if transaction_type == "BILL_PAYMENT":

        return weighted_choice(
            [
                "WALLET_BALANCE",
                "VIRTUAL_ACCOUNT",
                "BANK_TRANSFER",
            ],
            [
                0.60,
                0.20,
                0.20,
            ],
        )

    if transaction_type == "REFUND":

        return "WALLET_BALANCE"

    return "WALLET_BALANCE"


# ============================================================
# TRANSACTION STATUS
# ============================================================

def generate_status(
    transaction_type
):

    if transaction_type == "TRANSFER":

        probabilities = [
            0.93,
            0.035,
            0.015,
            0.015,
            0.005,
        ]

    elif transaction_type == "TOP_UP":

        probabilities = [
            0.97,
            0.02,
            0.005,
            0.004,
            0.001,
        ]

    elif transaction_type == "WITHDRAWAL":

        probabilities = [
            0.94,
            0.03,
            0.01,
            0.015,
            0.005,
        ]

    else:

        probabilities = [
            0.94,
            0.03,
            0.015,
            0.01,
            0.005,
        ]

    return weighted_choice(
        TRANSACTION_STATUSES,
        probabilities,
    )


# ============================================================
# TRANSACTION CHANNEL
# ============================================================

def generate_channel(
    transaction_type
):

    if transaction_type == "TOP_UP":

        return weighted_choice(
            [
                "MOBILE_APP",
                "WEB",
                "BANK",
            ],
            [
                0.50,
                0.10,
                0.40,
            ],
        )

    if transaction_type == "WITHDRAWAL":

        return weighted_choice(
            [
                "MOBILE_APP",
                "BANK",
                "ATM",
            ],
            [
                0.20,
                0.50,
                0.30,
            ],
        )

    if transaction_type == "PAYMENT":

        return weighted_choice(
            [
                "MOBILE_APP",
                "QRIS",
                "WEB",
            ],
            [
                0.40,
                0.50,
                0.10,
            ],
        )

    return weighted_choice(
        CHANNELS,
        [
            0.45,
            0.15,
            0.15,
            0.15,
            0.10,
        ],
    )


# ============================================================
# TRANSACTIONS
# ============================================================

def generate_transactions(
    users,
    wallets,
    merchants,
):

    print(
        f"Generating "
        f"{NUM_TRANSACTIONS:,} transactions..."
    )

    user_records = (
        users.to_dict("records")
    )

    merchant_records = (
        merchants.to_dict("records")
    )

    wallet_by_user = {
        row["user_id"]: row
        for row in wallets.to_dict(
            "records"
        )
    }

    merchant_weights = []

    for merchant in merchant_records:

        size = merchant[
            "merchant_size"
        ]

        if size == "SMALL":
            weight = 1

        elif size == "MEDIUM":
            weight = 4

        else:
            weight = 12

        merchant_weights.append(
            weight
        )

    rows = []

    transaction_id = 1

    while (
        transaction_id
        <= NUM_TRANSACTIONS
    ):

        user = random.choice(
            user_records
        )

        wallet = wallet_by_user[
            user["user_id"]
        ]

        transaction_type = (
            weighted_choice(
                TRANSACTION_TYPES,
                TRANSACTION_TYPE_PROBABILITIES,
            )
        )

        merchant = None

        # ----------------------------------------------------
        # MERCHANT RELATIONSHIP
        # ----------------------------------------------------

        if transaction_type in [
            "PAYMENT",
            "REFUND",
            "BILL_PAYMENT",
        ]:

            merchant = (
                random.choices(
                    merchant_records,
                    weights=merchant_weights,
                    k=1,
                )[0]
            )

            timestamp = (
                generate_transaction_timestamp(
                    user_registration_date=
                        user[
                            "registration_date"
                        ],

                    wallet_created_at=
                        wallet[
                            "created_at"
                        ],

                    merchant_created_at=
                        merchant[
                            "created_at"
                        ],
                )
            )

        else:

            timestamp = (
                generate_transaction_timestamp(
                    user_registration_date=
                        user[
                            "registration_date"
                        ],

                    wallet_created_at=
                        wallet[
                            "created_at"
                        ],
                )
            )

        if timestamp is None:
            continue

        # ----------------------------------------------------
        # COUNTERPARTY
        # ----------------------------------------------------

        counterparty_user_id = None

        if (
            transaction_type
            == "TRANSFER"
        ):

            counterparty = (
                random.choice(
                    user_records
                )
            )

            while (
                counterparty["user_id"]
                == user["user_id"]
            ):

                counterparty = (
                    random.choice(
                        user_records
                    )
                )

            counterparty_user_id = (
                counterparty[
                    "user_id"
                ]
            )

        # ----------------------------------------------------
        # AMOUNT
        # ----------------------------------------------------

        merchant_category = (
            merchant["category"]
            if merchant
            else None
        )

        amount = generate_amount(
            transaction_type,
            merchant_category,
        )

        # ----------------------------------------------------
        # PAYMENT METHOD
        # ----------------------------------------------------

        payment_method = (
            generate_payment_method(
                transaction_type
            )
        )

        # ----------------------------------------------------
        # STATUS
        # ----------------------------------------------------

        status = generate_status(
            transaction_type
        )

        # ----------------------------------------------------
        # CHANNEL
        # ----------------------------------------------------

        channel = generate_channel(
            transaction_type
        )

        # ----------------------------------------------------
        # SAVE TRANSACTION
        # ----------------------------------------------------

        rows.append({
            "transaction_id":
                generate_id(
                    "TX",
                    transaction_id,
                ),

            "wallet_id":
                wallet[
                    "wallet_id"
                ],

            "user_id":
                user[
                    "user_id"
                ],

            "merchant_id":
                (
                    merchant[
                        "merchant_id"
                    ]
                    if merchant
                    else None
                ),

            "counterparty_user_id":
                counterparty_user_id,

            "transaction_type_id":
                TRANSACTION_TYPES.index(
                    transaction_type
                ) + 1,

            "payment_method_id":
                PAYMENT_METHODS.index(
                    payment_method
                ) + 1,

            "transaction_status_id":
                TRANSACTION_STATUSES.index(
                    status
                ) + 1,

            "amount":
                amount,

            "transaction_timestamp":
                timestamp,

            "channel":
                channel,

            "reference_number":
                (
                    "REF-"
                    + uuid.uuid4()
                    .hex[:16]
                    .upper()
                ),

            "created_at":
                timestamp,
        })

        transaction_id += 1

    return pd.DataFrame(
        rows
    )


# ============================================================
# SAVE
# ============================================================

def save_data(
    users,
    wallets,
    merchants,
    transactions,
):

    OUTPUT_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )

    users.to_csv(
        OUTPUT_DIR
        / "users.csv",
        index=False,
    )

    wallets.to_csv(
        OUTPUT_DIR
        / "wallets.csv",
        index=False,
    )

    merchants.to_csv(
        OUTPUT_DIR
        / "merchants.csv",
        index=False,
    )

    transactions.to_csv(
        OUTPUT_DIR
        / "transactions.csv",
        index=False,
    )

    print()
    print("=" * 60)
    print(
        "DATA GENERATION COMPLETE"
    )
    print("=" * 60)

    print(
        f"Users        : "
        f"{len(users):,}"
    )

    print(
        f"Wallets      : "
        f"{len(wallets):,}"
    )

    print(
        f"Merchants    : "
        f"{len(merchants):,}"
    )

    print(
        f"Transactions : "
        f"{len(transactions):,}"
    )

    print()
    print(
        "Transaction distribution:"
    )

    print(
        transactions[
            "transaction_type_id"
        ]
        .value_counts()
        .sort_index()
    )

    print()

    print(
        f"Output directory: "
        f"{OUTPUT_DIR}"
    )

    print("=" * 60)


# ============================================================
# MAIN
# ============================================================

def main():

    users = generate_users()

    wallets = generate_wallets(
        users
    )

    merchants = (
        generate_merchants()
    )

    transactions = (
        generate_transactions(
            users,
            wallets,
            merchants,
        )
    )

    save_data(
        users,
        wallets,
        merchants,
        transactions,
    )


if __name__ == "__main__":
    main()