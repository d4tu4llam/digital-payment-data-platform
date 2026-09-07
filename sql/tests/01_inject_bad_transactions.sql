-- ============================================================
-- CONTROLLED BAD DATA INJECTION
-- ============================================================

INSERT INTO raw.transactions (
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
    created_at
)
VALUES

-- 1. Negative amount
(
    'BAD_TX_001',
    'W000001',
    'U000001',
    'M000001',
    NULL,
    1,
    1,
    1,
    -50000,
    '2026-01-01 10:00:00',
    'MOBILE_APP',
    'BAD-REF-001',
    '2026-01-01 10:00:00'
),

-- 2. Invalid wallet
(
    'BAD_TX_002',
    'W999999',
    'U000001',
    NULL,
    'U000002',
    2,
    1,
    1,
    100000,
    '2026-01-01 11:00:00',
    'MOBILE_APP',
    'BAD-REF-002',
    '2026-01-01 11:00:00'
),

-- 3. Transfer without counterparty
(
    'BAD_TX_003',
    'W000001',
    'U000001',
    NULL,
    NULL,
    2,
    1,
    1,
    75000,
    '2026-01-01 12:00:00',
    'MOBILE_APP',
    'BAD-REF-003',
    '2026-01-01 12:00:00'
);