-- ============================================================
-- RAW TABLES
-- ============================================================

CREATE TABLE IF NOT EXISTS raw.users (
    user_id VARCHAR(50),
    full_name VARCHAR(150),
    phone_number VARCHAR(30),
    email VARCHAR(150),
    city VARCHAR(100),
    registration_date DATE,
    status VARCHAR(30),
    created_at TIMESTAMP,
    ingested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS raw.wallets (
    wallet_id VARCHAR(50),
    user_id VARCHAR(50),
    balance NUMERIC(15, 2),
    currency VARCHAR(10),
    status VARCHAR(30),
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    ingested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS raw.merchants (
    merchant_id VARCHAR(50),
    merchant_name VARCHAR(150),
    category VARCHAR(100),
    city VARCHAR(100),
    merchant_size VARCHAR(20),
    status VARCHAR(30),
    created_at TIMESTAMP,
    ingested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS raw.transactions (
    transaction_id VARCHAR(50),
    wallet_id VARCHAR(50),
    user_id VARCHAR(50),
    merchant_id VARCHAR(50),
    counterparty_user_id VARCHAR(50),
    transaction_type_id SMALLINT,
    payment_method_id SMALLINT,
    transaction_status_id SMALLINT,
    amount NUMERIC(15, 2),
    transaction_timestamp TIMESTAMP,
    channel VARCHAR(50),
    reference_number VARCHAR(100),
    created_at TIMESTAMP,
    ingested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw.transaction_types (
    transaction_type_id SMALLINT,
    transaction_type VARCHAR(50),
    description VARCHAR(255),
    ingested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS raw.payment_methods (
    payment_method_id SMALLINT,
    payment_method VARCHAR(50),
    description VARCHAR(255),
    ingested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS raw.transaction_statuses (
    transaction_status_id SMALLINT,
    transaction_status VARCHAR(50),
    description VARCHAR(255),
    ingested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);