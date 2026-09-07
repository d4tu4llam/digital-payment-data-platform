-- ============================================================
-- DUPLICATE CHECKS
-- ============================================================

-- 1. Duplicate user_id
SELECT
    'users.user_id' AS check_name,
    COUNT(*) AS duplicate_groups
FROM (
    SELECT user_id
    FROM raw.users
    GROUP BY user_id
    HAVING COUNT(*) > 1
) dup;


-- 2. Duplicate wallet_id
SELECT
    'wallets.wallet_id' AS check_name,
    COUNT(*) AS duplicate_groups
FROM (
    SELECT wallet_id
    FROM raw.wallets
    GROUP BY wallet_id
    HAVING COUNT(*) > 1
) dup;


-- 3. Duplicate merchant_id
SELECT
    'merchants.merchant_id' AS check_name,
    COUNT(*) AS duplicate_groups
FROM (
    SELECT merchant_id
    FROM raw.merchants
    GROUP BY merchant_id
    HAVING COUNT(*) > 1
) dup;


-- 4. Duplicate transaction_id
SELECT
    'transactions.transaction_id' AS check_name,
    COUNT(*) AS duplicate_groups
FROM (
    SELECT transaction_id
    FROM raw.transactions
    GROUP BY transaction_id
    HAVING COUNT(*) > 1
) dup;


-- 5. Duplicate reference_number
SELECT
    'transactions.reference_number' AS check_name,
    COUNT(*) AS duplicate_groups
FROM (
    SELECT reference_number
    FROM raw.transactions
    WHERE reference_number IS NOT NULL
    GROUP BY reference_number
    HAVING COUNT(*) > 1
) dup;