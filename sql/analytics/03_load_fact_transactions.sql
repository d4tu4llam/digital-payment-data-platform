-- ============================================================
-- LOAD FACT TRANSACTIONS
-- ============================================================

TRUNCATE TABLE
    analytics.fact_transactions
RESTART IDENTITY;


INSERT INTO analytics.fact_transactions (
    transaction_id,
    date_key,
    user_key,
    merchant_key,
    transaction_type_key,
    wallet_id,
    payment_method_id,
    transaction_status_id,
    amount,
    transaction_timestamp,
    channel,
    reference_number,
    loaded_at
)
SELECT
    t.transaction_id,

    TO_CHAR(
        t.transaction_timestamp,
        'YYYYMMDD'
    )::INTEGER AS date_key,

    u.user_key,

    m.merchant_key,

    tt.transaction_type_key,

    t.wallet_id,

    t.payment_method_id,

    t.transaction_status_id,

    t.amount,

    t.transaction_timestamp,

    t.channel,

    t.reference_number,

    CURRENT_TIMESTAMP

FROM staging.transactions t

JOIN analytics.dim_users u
    ON t.user_id = u.user_id

LEFT JOIN analytics.dim_merchants m
    ON t.merchant_id = m.merchant_id

JOIN analytics.dim_transaction_types tt
    ON t.transaction_type_id = tt.transaction_type_id;