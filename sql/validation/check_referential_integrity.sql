-- ============================================================
-- REFERENTIAL INTEGRITY CHECKS
-- ============================================================

-- 1. Transactions with invalid user_id
SELECT
    'transactions.user_id -> users.user_id' AS check_name,
    COUNT(*) AS failed_records
FROM raw.transactions t
LEFT JOIN raw.users u
    ON t.user_id = u.user_id
WHERE u.user_id IS NULL;


-- 2. Transactions with invalid wallet_id
SELECT
    'transactions.wallet_id -> wallets.wallet_id' AS check_name,
    COUNT(*) AS failed_records
FROM raw.transactions t
LEFT JOIN raw.wallets w
    ON t.wallet_id = w.wallet_id
WHERE w.wallet_id IS NULL;


-- 3. Transactions with invalid merchant_id
-- merchant_id is nullable, so only validate non-null values
SELECT
    'transactions.merchant_id -> merchants.merchant_id' AS check_name,
    COUNT(*) AS failed_records
FROM raw.transactions t
LEFT JOIN raw.merchants m
    ON t.merchant_id = m.merchant_id
WHERE t.merchant_id IS NOT NULL
  AND m.merchant_id IS NULL;


-- 4. Transactions with invalid counterparty_user_id
-- counterparty_user_id is nullable
SELECT
    'transactions.counterparty_user_id -> users.user_id' AS check_name,
    COUNT(*) AS failed_records
FROM raw.transactions t
LEFT JOIN raw.users u
    ON t.counterparty_user_id = u.user_id
WHERE t.counterparty_user_id IS NOT NULL
  AND u.user_id IS NULL;


-- 5. Invalid transaction_type_id
SELECT
    'transactions.transaction_type_id -> transaction_types' AS check_name,
    COUNT(*) AS failed_records
FROM raw.transactions t
LEFT JOIN raw.transaction_types tt
    ON t.transaction_type_id = tt.transaction_type_id
WHERE tt.transaction_type_id IS NULL;


-- 6. Invalid payment_method_id
SELECT
    'transactions.payment_method_id -> payment_methods' AS check_name,
    COUNT(*) AS failed_records
FROM raw.transactions t
LEFT JOIN raw.payment_methods pm
    ON t.payment_method_id = pm.payment_method_id
WHERE pm.payment_method_id IS NULL;


-- 7. Invalid transaction_status_id
SELECT
    'transactions.transaction_status_id -> transaction_statuses' AS check_name,
    COUNT(*) AS failed_records
FROM raw.transactions t
LEFT JOIN raw.transaction_statuses ts
    ON t.transaction_status_id = ts.transaction_status_id
WHERE ts.transaction_status_id IS NULL;


-- 8. Wallet ownership consistency
-- The wallet used in a transaction must belong to the same user
SELECT
    'transaction wallet belongs to transaction user' AS check_name,
    COUNT(*) AS failed_records
FROM raw.transactions t
JOIN raw.wallets w
    ON t.wallet_id = w.wallet_id
WHERE t.user_id <> w.user_id;