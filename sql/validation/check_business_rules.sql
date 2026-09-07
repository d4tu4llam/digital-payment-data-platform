-- ============================================================
-- BUSINESS RULE CHECKS
-- ============================================================

-- 1. PAYMENT must have merchant
SELECT
    'PAYMENT requires merchant_id' AS check_name,
    COUNT(*) AS failed_records
FROM source.transactions t
JOIN source.transaction_types tt
    ON t.transaction_type_id = tt.transaction_type_id
WHERE tt.transaction_type = 'PAYMENT'
  AND t.merchant_id IS NULL;


-- 2. PAYMENT must not have counterparty user
SELECT
    'PAYMENT must not have counterparty_user_id' AS check_name,
    COUNT(*) AS failed_records
FROM source.transactions t
JOIN source.transaction_types tt
    ON t.transaction_type_id = tt.transaction_type_id
WHERE tt.transaction_type = 'PAYMENT'
  AND t.counterparty_user_id IS NOT NULL;


-- 3. TRANSFER must have counterparty user
SELECT
    'TRANSFER requires counterparty_user_id' AS check_name,
    COUNT(*) AS failed_records
FROM source.transactions t
JOIN source.transaction_types tt
    ON t.transaction_type_id = tt.transaction_type_id
WHERE tt.transaction_type = 'TRANSFER'
  AND t.counterparty_user_id IS NULL;


-- 4. TRANSFER must not have merchant
SELECT
    'TRANSFER must not have merchant_id' AS check_name,
    COUNT(*) AS failed_records
FROM source.transactions t
JOIN source.transaction_types tt
    ON t.transaction_type_id = tt.transaction_type_id
WHERE tt.transaction_type = 'TRANSFER'
  AND t.merchant_id IS NOT NULL;


-- 5. TRANSFER cannot target the sender
SELECT
    'TRANSFER cannot target sender' AS check_name,
    COUNT(*) AS failed_records
FROM source.transactions t
JOIN source.transaction_types tt
    ON t.transaction_type_id = tt.transaction_type_id
WHERE tt.transaction_type = 'TRANSFER'
  AND t.counterparty_user_id = t.user_id;


-- 6. TOP_UP must not have merchant
SELECT
    'TOP_UP must not have merchant_id' AS check_name,
    COUNT(*) AS failed_records
FROM source.transactions t
JOIN source.transaction_types tt
    ON t.transaction_type_id = tt.transaction_type_id
WHERE tt.transaction_type = 'TOP_UP'
  AND t.merchant_id IS NOT NULL;


-- 7. TOP_UP must not have counterparty user
SELECT
    'TOP_UP must not have counterparty_user_id' AS check_name,
    COUNT(*) AS failed_records
FROM source.transactions t
JOIN source.transaction_types tt
    ON t.transaction_type_id = tt.transaction_type_id
WHERE tt.transaction_type = 'TOP_UP'
  AND t.counterparty_user_id IS NOT NULL;


-- 8. WITHDRAWAL must not have merchant
SELECT
    'WITHDRAWAL must not have merchant_id' AS check_name,
    COUNT(*) AS failed_records
FROM source.transactions t
JOIN source.transaction_types tt
    ON t.transaction_type_id = tt.transaction_type_id
WHERE tt.transaction_type = 'WITHDRAWAL'
  AND t.merchant_id IS NOT NULL;


-- 9. WITHDRAWAL must not have counterparty user
SELECT
    'WITHDRAWAL must not have counterparty_user_id' AS check_name,
    COUNT(*) AS failed_records
FROM source.transactions t
JOIN source.transaction_types tt
    ON t.transaction_type_id = tt.transaction_type_id
WHERE tt.transaction_type = 'WITHDRAWAL'
  AND t.counterparty_user_id IS NOT NULL;


-- 10. REFUND must have merchant
SELECT
    'REFUND requires merchant_id' AS check_name,
    COUNT(*) AS failed_records
FROM source.transactions t
JOIN source.transaction_types tt
    ON t.transaction_type_id = tt.transaction_type_id
WHERE tt.transaction_type = 'REFUND'
  AND t.merchant_id IS NULL;


-- 11. BILL_PAYMENT must have merchant/provider
SELECT
    'BILL_PAYMENT requires merchant_id' AS check_name,
    COUNT(*) AS failed_records
FROM source.transactions t
JOIN source.transaction_types tt
    ON t.transaction_type_id = tt.transaction_type_id
WHERE tt.transaction_type = 'BILL_PAYMENT'
  AND t.merchant_id IS NULL;


-- 12. Transaction amount must be positive
SELECT
    'transaction amount must be > 0' AS check_name,
    COUNT(*) AS failed_records
FROM source.transactions
WHERE amount <= 0;


-- 13. Reference number must not be null
SELECT
    'reference_number must not be null' AS check_name,
    COUNT(*) AS failed_records
FROM source.transactions
WHERE reference_number IS NULL;


-- 14. Channel must not be null
SELECT
    'channel must not be null' AS check_name,
    COUNT(*) AS failed_records
FROM source.transactions
WHERE channel IS NULL;