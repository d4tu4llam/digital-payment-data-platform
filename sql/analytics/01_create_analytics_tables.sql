-- ============================================================
-- ANALYTICS / STAR SCHEMA TABLES
-- ============================================================


-- ============================================================
-- 1. DIMENSION: USERS
-- ============================================================

CREATE TABLE IF NOT EXISTS analytics.dim_users (
    user_key BIGSERIAL PRIMARY KEY,
    user_id VARCHAR(50) UNIQUE NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    city VARCHAR(100),
    registration_date DATE NOT NULL,
    status VARCHAR(30) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 2. DIMENSION: MERCHANTS
-- ============================================================

CREATE TABLE IF NOT EXISTS analytics.dim_merchants (
    merchant_key BIGSERIAL PRIMARY KEY,
    merchant_id VARCHAR(50) UNIQUE NOT NULL,
    merchant_name VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    merchant_size VARCHAR(20) NOT NULL,
    status VARCHAR(30) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 3. DIMENSION: TRANSACTION TYPES
-- ============================================================

CREATE TABLE IF NOT EXISTS analytics.dim_transaction_types (
    transaction_type_key BIGSERIAL PRIMARY KEY,
    transaction_type_id SMALLINT UNIQUE NOT NULL,
    transaction_type VARCHAR(50) NOT NULL,
    description VARCHAR(255),
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 4. DIMENSION: DATE
-- ============================================================

CREATE TABLE IF NOT EXISTS analytics.dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE UNIQUE NOT NULL,

    day INTEGER NOT NULL,
    day_name VARCHAR(20) NOT NULL,

    week INTEGER NOT NULL,

    month INTEGER NOT NULL,
    month_name VARCHAR(20) NOT NULL,

    quarter INTEGER NOT NULL,
    year INTEGER NOT NULL,

    is_weekend BOOLEAN NOT NULL
);


-- ============================================================
-- 5. FACT: TRANSACTIONS
-- ============================================================

CREATE TABLE IF NOT EXISTS analytics.fact_transactions (
    transaction_key BIGSERIAL PRIMARY KEY,

    transaction_id VARCHAR(50) UNIQUE NOT NULL,

    date_key INTEGER NOT NULL,
    user_key BIGINT NOT NULL,
    merchant_key BIGINT,
    transaction_type_key BIGINT NOT NULL,

    wallet_id VARCHAR(50) NOT NULL,

    payment_method_id SMALLINT NOT NULL,
    transaction_status_id SMALLINT NOT NULL,

    amount NUMERIC(15, 2) NOT NULL,

    transaction_timestamp TIMESTAMP NOT NULL,

    channel VARCHAR(50) NOT NULL,

    reference_number VARCHAR(100) NOT NULL,

    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_fact_date
        FOREIGN KEY (date_key)
        REFERENCES analytics.dim_date(date_key),

    CONSTRAINT fk_fact_user
        FOREIGN KEY (user_key)
        REFERENCES analytics.dim_users(user_key),

    CONSTRAINT fk_fact_merchant
        FOREIGN KEY (merchant_key)
        REFERENCES analytics.dim_merchants(merchant_key),

    CONSTRAINT fk_fact_transaction_type
        FOREIGN KEY (transaction_type_key)
        REFERENCES analytics.dim_transaction_types(
            transaction_type_key
        ),

    CONSTRAINT chk_fact_amount
        CHECK (amount > 0)
);


-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_fact_transactions_date_key
    ON analytics.fact_transactions(date_key);

CREATE INDEX IF NOT EXISTS idx_fact_transactions_user_key
    ON analytics.fact_transactions(user_key);

CREATE INDEX IF NOT EXISTS idx_fact_transactions_merchant_key
    ON analytics.fact_transactions(merchant_key);

CREATE INDEX IF NOT EXISTS idx_fact_transactions_type_key
    ON analytics.fact_transactions(transaction_type_key);

CREATE INDEX IF NOT EXISTS idx_fact_transactions_timestamp
    ON analytics.fact_transactions(transaction_timestamp);