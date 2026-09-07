-- ============================================================
-- LOAD DIMENSION TABLES
-- ============================================================


-- ============================================================
-- 1. RESET DIMENSIONS
-- ============================================================

TRUNCATE TABLE
    analytics.fact_transactions,
    analytics.dim_users,
    analytics.dim_merchants,
    analytics.dim_transaction_types,
    analytics.dim_date
RESTART IDENTITY CASCADE;


-- ============================================================
-- 2. LOAD DIM USERS
-- ============================================================

INSERT INTO analytics.dim_users (
    user_id,
    full_name,
    city,
    registration_date,
    status,
    created_at,
    loaded_at
)
SELECT
    user_id,
    full_name,
    city,
    registration_date,
    status,
    created_at,
    CURRENT_TIMESTAMP
FROM staging.users;


-- ============================================================
-- 3. LOAD DIM MERCHANTS
-- ============================================================

INSERT INTO analytics.dim_merchants (
    merchant_id,
    merchant_name,
    category,
    city,
    merchant_size,
    status,
    created_at,
    loaded_at
)
SELECT
    merchant_id,
    merchant_name,
    category,
    city,
    merchant_size,
    status,
    created_at,
    CURRENT_TIMESTAMP
FROM staging.merchants;


-- ============================================================
-- 4. LOAD DIM TRANSACTION TYPES
-- ============================================================

INSERT INTO analytics.dim_transaction_types (
    transaction_type_id,
    transaction_type,
    description,
    loaded_at
)
SELECT
    transaction_type_id,
    transaction_type,
    description,
    CURRENT_TIMESTAMP
FROM raw.transaction_types;


-- ============================================================
-- 5. LOAD DIM DATE
-- ============================================================

INSERT INTO analytics.dim_date (
    date_key,
    full_date,
    day,
    day_name,
    week,
    month,
    month_name,
    quarter,
    year,
    is_weekend
)
SELECT
    TO_CHAR(date_value, 'YYYYMMDD')::INTEGER AS date_key,

    date_value::DATE AS full_date,

    EXTRACT(DAY FROM date_value)::INTEGER AS day,

    TRIM(
        TO_CHAR(date_value, 'Day')
    ) AS day_name,

    EXTRACT(WEEK FROM date_value)::INTEGER AS week,

    EXTRACT(MONTH FROM date_value)::INTEGER AS month,

    TRIM(
        TO_CHAR(date_value, 'Month')
    ) AS month_name,

    EXTRACT(QUARTER FROM date_value)::INTEGER AS quarter,

    EXTRACT(YEAR FROM date_value)::INTEGER AS year,

    EXTRACT(ISODOW FROM date_value) IN (6, 7) AS is_weekend

FROM GENERATE_SERIES(
    (
        SELECT MIN(transaction_timestamp)::DATE
        FROM staging.transactions
    ),
    (
        SELECT MAX(transaction_timestamp)::DATE
        FROM staging.transactions
    ),
    INTERVAL '1 day'
) AS date_value;