-- ============================================================
-- QUARANTINE INVALID TRANSACTIONS
-- ============================================================


-- Reset quarantine untuk full-refresh pipeline MVP
TRUNCATE TABLE quarantine.transactions
RESTART IDENTITY;


-- ============================================================
-- 1. INVALID AMOUNT
-- ============================================================

INSERT INTO quarantine.transactions (
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
    validation_rule,
    failure_reason
)
SELECT
    t.transaction_id,
    t.wallet_id,
    t.user_id,
    t.merchant_id,
    t.counterparty_user_id,
    t.transaction_type_id,
    t.payment_method_id,
    t.transaction_status_id,
    t.amount,
    t.transaction_timestamp,
    t.channel,
    t.reference_number,
    t.created_at,

    'POSITIVE_AMOUNT',
    'Transaction amount must be greater than 0'

FROM raw.transactions t

WHERE
    t.amount IS NULL
    OR t.amount <= 0;


-- ============================================================
-- 2. INVALID USER
-- ============================================================

INSERT INTO quarantine.transactions (
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
    validation_rule,
    failure_reason
)
SELECT
    t.transaction_id,
    t.wallet_id,
    t.user_id,
    t.merchant_id,
    t.counterparty_user_id,
    t.transaction_type_id,
    t.payment_method_id,
    t.transaction_status_id,
    t.amount,
    t.transaction_timestamp,
    t.channel,
    t.reference_number,
    t.created_at,

    'VALID_USER',
    'Transaction user_id does not exist in raw.users'

FROM raw.transactions t

LEFT JOIN raw.users u
    ON t.user_id = u.user_id

WHERE
    u.user_id IS NULL;


-- ============================================================
-- 3. INVALID WALLET
-- ============================================================

INSERT INTO quarantine.transactions (
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
    validation_rule,
    failure_reason
)
SELECT
    t.transaction_id,
    t.wallet_id,
    t.user_id,
    t.merchant_id,
    t.counterparty_user_id,
    t.transaction_type_id,
    t.payment_method_id,
    t.transaction_status_id,
    t.amount,
    t.transaction_timestamp,
    t.channel,
    t.reference_number,
    t.created_at,

    'VALID_WALLET',
    'Transaction wallet_id does not exist in raw.wallets'

FROM raw.transactions t

LEFT JOIN raw.wallets w
    ON t.wallet_id = w.wallet_id

WHERE
    w.wallet_id IS NULL;


-- ============================================================
-- 4. WALLET OWNERSHIP MISMATCH
-- ============================================================

INSERT INTO quarantine.transactions (
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
    validation_rule,
    failure_reason
)
SELECT
    t.transaction_id,
    t.wallet_id,
    t.user_id,
    t.merchant_id,
    t.counterparty_user_id,
    t.transaction_type_id,
    t.payment_method_id,
    t.transaction_status_id,
    t.amount,
    t.transaction_timestamp,
    t.channel,
    t.reference_number,
    t.created_at,

    'WALLET_OWNERSHIP',
    'wallet_id does not belong to transaction user_id'

FROM raw.transactions t

JOIN raw.wallets w
    ON t.wallet_id = w.wallet_id

WHERE
    t.user_id <> w.user_id;


-- ============================================================
-- 5. INVALID MERCHANT REFERENCE
-- ============================================================

INSERT INTO quarantine.transactions (
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
    validation_rule,
    failure_reason
)
SELECT
    t.transaction_id,
    t.wallet_id,
    t.user_id,
    t.merchant_id,
    t.counterparty_user_id,
    t.transaction_type_id,
    t.payment_method_id,
    t.transaction_status_id,
    t.amount,
    t.transaction_timestamp,
    t.channel,
    t.reference_number,
    t.created_at,

    'VALID_MERCHANT',
    'merchant_id does not exist in raw.merchants'

FROM raw.transactions t

LEFT JOIN raw.merchants m
    ON t.merchant_id = m.merchant_id

WHERE
    t.merchant_id IS NOT NULL
    AND m.merchant_id IS NULL;


-- ============================================================
-- 6. TRANSFER MUST HAVE COUNTERPARTY
-- ============================================================

INSERT INTO quarantine.transactions (
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
    validation_rule,
    failure_reason
)
SELECT
    t.transaction_id,
    t.wallet_id,
    t.user_id,
    t.merchant_id,
    t.counterparty_user_id,
    t.transaction_type_id,
    t.payment_method_id,
    t.transaction_status_id,
    t.amount,
    t.transaction_timestamp,
    t.channel,
    t.reference_number,
    t.created_at,

    'TRANSFER_COUNTERPARTY',
    'TRANSFER requires counterparty_user_id'

FROM raw.transactions t

JOIN raw.transaction_types tt
    ON t.transaction_type_id = tt.transaction_type_id

WHERE
    tt.transaction_type = 'TRANSFER'
    AND t.counterparty_user_id IS NULL;


-- ============================================================
-- 7. TRANSFER CANNOT TARGET SENDER
-- ============================================================

INSERT INTO quarantine.transactions (
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
    validation_rule,
    failure_reason
)
SELECT
    t.transaction_id,
    t.wallet_id,
    t.user_id,
    t.merchant_id,
    t.counterparty_user_id,
    t.transaction_type_id,
    t.payment_method_id,
    t.transaction_status_id,
    t.amount,
    t.transaction_timestamp,
    t.channel,
    t.reference_number,
    t.created_at,

    'TRANSFER_SELF',
    'TRANSFER counterparty_user_id cannot equal user_id'

FROM raw.transactions t

JOIN raw.transaction_types tt
    ON t.transaction_type_id = tt.transaction_type_id

WHERE
    tt.transaction_type = 'TRANSFER'
    AND t.counterparty_user_id = t.user_id;


-- ============================================================
-- 8. PAYMENT MUST HAVE MERCHANT
-- ============================================================

INSERT INTO quarantine.transactions (
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
    validation_rule,
    failure_reason
)
SELECT
    t.transaction_id,
    t.wallet_id,
    t.user_id,
    t.merchant_id,
    t.counterparty_user_id,
    t.transaction_type_id,
    t.payment_method_id,
    t.transaction_status_id,
    t.amount,
    t.transaction_timestamp,
    t.channel,
    t.reference_number,
    t.created_at,

    'PAYMENT_MERCHANT',
    'PAYMENT requires merchant_id'

FROM raw.transactions t

JOIN raw.transaction_types tt
    ON t.transaction_type_id = tt.transaction_type_id

WHERE
    tt.transaction_type = 'PAYMENT'
    AND t.merchant_id IS NULL;


-- ============================================================
-- 9. TRANSACTION BEFORE WALLET CREATION
-- ============================================================

INSERT INTO quarantine.transactions (
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
    validation_rule,
    failure_reason
)
SELECT
    t.transaction_id,
    t.wallet_id,
    t.user_id,
    t.merchant_id,
    t.counterparty_user_id,
    t.transaction_type_id,
    t.payment_method_id,
    t.transaction_status_id,
    t.amount,
    t.transaction_timestamp,
    t.channel,
    t.reference_number,
    t.created_at,

    'WALLET_TEMPORAL',
    'Transaction occurred before wallet creation'

FROM raw.transactions t

JOIN raw.wallets w
    ON t.wallet_id = w.wallet_id

WHERE
    t.transaction_timestamp < w.created_at;


-- ============================================================
-- 10. TRANSACTION BEFORE MERCHANT CREATION
-- ============================================================

INSERT INTO quarantine.transactions (
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
    validation_rule,
    failure_reason
)
SELECT
    t.transaction_id,
    t.wallet_id,
    t.user_id,
    t.merchant_id,
    t.counterparty_user_id,
    t.transaction_type_id,
    t.payment_method_id,
    t.transaction_status_id,
    t.amount,
    t.transaction_timestamp,
    t.channel,
    t.reference_number,
    t.created_at,

    'MERCHANT_TEMPORAL',
    'Transaction occurred before merchant creation'

FROM raw.transactions t

JOIN raw.merchants m
    ON t.merchant_id = m.merchant_id

WHERE
    t.merchant_id IS NOT NULL
    AND t.transaction_timestamp < m.created_at;