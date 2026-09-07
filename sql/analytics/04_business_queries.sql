-- ============================================================
-- BUSINESS ANALYTICS QUERIES
-- ============================================================


-- ============================================================
-- 1. DAILY TRANSACTION VOLUME AND VALUE
-- ============================================================

SELECT
    d.full_date,
    COUNT(*) AS total_transactions,
    SUM(f.amount) AS total_transaction_value,
    AVG(f.amount) AS average_transaction_value
FROM analytics.fact_transactions f
JOIN analytics.dim_date d
    ON f.date_key = d.date_key
GROUP BY
    d.full_date
ORDER BY
    d.full_date;


-- ============================================================
-- 2. TRANSACTION VALUE BY TYPE
-- ============================================================

SELECT
    tt.transaction_type,
    COUNT(*) AS total_transactions,
    SUM(f.amount) AS total_transaction_value,
    AVG(f.amount) AS average_transaction_value
FROM analytics.fact_transactions f
JOIN analytics.dim_transaction_types tt
    ON f.transaction_type_key = tt.transaction_type_key
GROUP BY
    tt.transaction_type
ORDER BY
    total_transaction_value DESC;


-- ============================================================
-- 3. TRANSACTION ACTIVITY BY USER CITY
-- ============================================================

SELECT
    u.city,
    COUNT(*) AS total_transactions,
    SUM(f.amount) AS total_transaction_value,
    AVG(f.amount) AS average_transaction_value
FROM analytics.fact_transactions f
JOIN analytics.dim_users u
    ON f.user_key = u.user_key
GROUP BY
    u.city
ORDER BY
    total_transaction_value DESC;


-- ============================================================
-- 4. TOP MERCHANT CATEGORIES
-- ============================================================

SELECT
    m.category,
    COUNT(*) AS total_transactions,
    SUM(f.amount) AS total_transaction_value,
    AVG(f.amount) AS average_transaction_value
FROM analytics.fact_transactions f
JOIN analytics.dim_merchants m
    ON f.merchant_key = m.merchant_key
GROUP BY
    m.category
ORDER BY
    total_transaction_value DESC;


-- ============================================================
-- 5. TOP 10 MERCHANTS BY TRANSACTION VALUE
-- ============================================================

SELECT
    m.merchant_id,
    m.merchant_name,
    m.category,
    COUNT(*) AS total_transactions,
    SUM(f.amount) AS total_transaction_value
FROM analytics.fact_transactions f
JOIN analytics.dim_merchants m
    ON f.merchant_key = m.merchant_key
GROUP BY
    m.merchant_id,
    m.merchant_name,
    m.category
ORDER BY
    total_transaction_value DESC
LIMIT 10;


-- ============================================================
-- 6. MONTHLY TRANSACTION TREND
-- ============================================================

SELECT
    d.year,
    d.month,
    d.month_name,
    COUNT(*) AS total_transactions,
    SUM(f.amount) AS total_transaction_value
FROM analytics.fact_transactions f
JOIN analytics.dim_date d
    ON f.date_key = d.date_key
GROUP BY
    d.year,
    d.month,
    d.month_name
ORDER BY
    d.year,
    d.month;


-- ============================================================
-- 7. WEEKDAY VS WEEKEND ACTIVITY
-- ============================================================

SELECT
    CASE
        WHEN d.is_weekend THEN 'WEEKEND'
        ELSE 'WEEKDAY'
    END AS day_type,

    COUNT(*) AS total_transactions,

    SUM(f.amount) AS total_transaction_value,

    AVG(f.amount) AS average_transaction_value

FROM analytics.fact_transactions f
JOIN analytics.dim_date d
    ON f.date_key = d.date_key

GROUP BY
    d.is_weekend

ORDER BY
    day_type;


-- ============================================================
-- 8. TRANSACTION ACTIVITY BY CHANNEL
-- ============================================================

SELECT
    channel,
    COUNT(*) AS total_transactions,
    SUM(amount) AS total_transaction_value,
    AVG(amount) AS average_transaction_value
FROM analytics.fact_transactions
GROUP BY
    channel
ORDER BY
    total_transactions DESC;


-- ============================================================
-- 9. TOP USERS BY TRANSACTION VALUE
-- ============================================================

SELECT
    u.user_id,
    u.full_name,
    u.city,
    COUNT(*) AS total_transactions,
    SUM(f.amount) AS total_transaction_value
FROM analytics.fact_transactions f
JOIN analytics.dim_users u
    ON f.user_key = u.user_key
GROUP BY
    u.user_id,
    u.full_name,
    u.city
ORDER BY
    total_transaction_value DESC
LIMIT 10;