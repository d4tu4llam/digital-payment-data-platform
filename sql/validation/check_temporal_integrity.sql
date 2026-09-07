-- ============================================================
-- TEMPORAL INTEGRITY CHECKS
-- ============================================================

-- 1. Transaction must not happen before user registration
SELECT
    'transaction_timestamp >= user.registration_date' AS check_name,
    COUNT(*) AS failed_records
FROM raw.transactions t
JOIN raw.users u
    ON t.user_id = u.user_id
WHERE t.transaction_timestamp < u.registration_date;


-- 2. Transaction must not happen before wallet creation
SELECT
    'transaction_timestamp >= wallet.created_at' AS check_name,
    COUNT(*) AS failed_records
FROM raw.transactions t
JOIN raw.wallets w
    ON t.wallet_id = w.wallet_id
WHERE t.transaction_timestamp < w.created_at;


-- 3. Merchant transaction must not happen before merchant onboarding
SELECT
    'merchant transaction >= merchant.created_at' AS check_name,
    COUNT(*) AS failed_records
FROM raw.transactions t
JOIN raw.merchants m
    ON t.merchant_id = m.merchant_id
WHERE t.merchant_id IS NOT NULL
  AND t.transaction_timestamp < m.created_at;


-- 4. Wallet creation must not happen before user registration
SELECT
    'wallet.created_at >= user.registration_date' AS check_name,
    COUNT(*) AS failed_records
FROM raw.wallets w
JOIN raw.users u
    ON w.user_id = u.user_id
WHERE w.created_at < u.registration_date;


-- 5. Wallet updated_at must not happen before created_at
SELECT
    'wallet.updated_at >= wallet.created_at' AS check_name,
    COUNT(*) AS failed_records
FROM raw.wallets
WHERE updated_at < created_at;


-- 6. Transaction created_at must not happen before transaction_timestamp
SELECT
    'transaction.created_at >= transaction_timestamp' AS check_name,
    COUNT(*) AS failed_records
FROM raw.transactions
WHERE created_at < transaction_timestamp;