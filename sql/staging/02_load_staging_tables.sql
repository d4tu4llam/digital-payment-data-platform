-- ============================================================
-- LOAD RAW DATA INTO STAGING
-- ============================================================


-- ============================================================
-- 1. RESET STAGING TABLES
-- ============================================================

TRUNCATE TABLE
    staging.transactions,
    staging.wallets,
    staging.merchants,
    staging.users
RESTART IDENTITY;


-- ============================================================
-- 2. LOAD USERS
-- ============================================================

INSERT INTO staging.users (
    user_id,
    full_name,
    phone_number,
    email,
    city,
    registration_date,
    status,
    created_at,
    processed_at
)
SELECT
    TRIM(user_id),
    TRIM(full_name),
    NULLIF(TRIM(phone_number), ''),
    NULLIF(LOWER(TRIM(email)), ''),
    NULLIF(TRIM(city), ''),
    registration_date,
    UPPER(TRIM(status)),
    created_at,
    CURRENT_TIMESTAMP
FROM raw.users;


-- ============================================================
-- 3. LOAD WALLETS
-- ============================================================

INSERT INTO staging.wallets (
    wallet_id,
    user_id,
    balance,
    currency,
    status,
    created_at,
    updated_at,
    processed_at
)
SELECT
    TRIM(wallet_id),
    TRIM(user_id),
    balance,
    UPPER(TRIM(currency)),
    UPPER(TRIM(status)),
    created_at,
    updated_at,
    CURRENT_TIMESTAMP
FROM raw.wallets;


-- ============================================================
-- 4. LOAD MERCHANTS
-- ============================================================

INSERT INTO staging.merchants (
    merchant_id,
    merchant_name,
    category,
    city,
    merchant_size,
    status,
    created_at,
    processed_at
)
SELECT
    TRIM(merchant_id),
    TRIM(merchant_name),
    TRIM(category),
    NULLIF(TRIM(city), ''),
    UPPER(TRIM(merchant_size)),
    UPPER(TRIM(status)),
    created_at,
    CURRENT_TIMESTAMP
FROM raw.merchants;


-- ============================================================
-- 5. LOAD VALID TRANSACTIONS
-- ============================================================

INSERT INTO staging.transactions (
    transaction_id,
    wallet_id,
    user_id,
    merchant_id,
    counterparty_user_id,
    transaction_type_id,
    payment_method_id,
    transaction_status_id,
    amount,
    transaction_timestamp,
    channel,
    reference_number,
    created_at,
    processed_at
)
SELECT
    TRIM(t.transaction_id),
    TRIM(t.wallet_id),
    TRIM(t.user_id),

    CASE
        WHEN t.merchant_id IS NULL THEN NULL
        ELSE TRIM(t.merchant_id)
    END,

    CASE
        WHEN t.counterparty_user_id IS NULL THEN NULL
        ELSE TRIM(t.counterparty_user_id)
    END,

    t.transaction_type_id,
    t.payment_method_id,
    t.transaction_status_id,
    t.amount,
    t.transaction_timestamp,
    UPPER(TRIM(t.channel)),
    TRIM(t.reference_number),
    t.created_at,
    CURRENT_TIMESTAMP

FROM raw.transactions t

WHERE NOT EXISTS (
    SELECT 1
    FROM quarantine.transactions q
    WHERE q.transaction_id = t.transaction_id
);