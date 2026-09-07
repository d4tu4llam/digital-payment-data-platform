-- ============================================================
-- STAGING TABLES
-- ============================================================

CREATE TABLE IF NOT EXISTS staging.users (
    user_id VARCHAR(50) PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    phone_number VARCHAR(30),
    email VARCHAR(150),
    city VARCHAR(100),
    registration_date DATE NOT NULL,
    status VARCHAR(30) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    processed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS staging.wallets (
    wallet_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    balance NUMERIC(15, 2) NOT NULL,
    currency VARCHAR(10) NOT NULL,
    status VARCHAR(30) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    processed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_staging_wallet_user
        FOREIGN KEY (user_id)
        REFERENCES staging.users(user_id)
);


CREATE TABLE IF NOT EXISTS staging.merchants (
    merchant_id VARCHAR(50) PRIMARY KEY,
    merchant_name VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    merchant_size VARCHAR(20) NOT NULL,
    status VARCHAR(30) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    processed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS staging.transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    wallet_id VARCHAR(50) NOT NULL,
    user_id VARCHAR(50) NOT NULL,
    merchant_id VARCHAR(50),
    counterparty_user_id VARCHAR(50),
    transaction_type_id SMALLINT NOT NULL,
    payment_method_id SMALLINT NOT NULL,
    transaction_status_id SMALLINT NOT NULL,
    amount NUMERIC(15, 2) NOT NULL,
    transaction_timestamp TIMESTAMP NOT NULL,
    channel VARCHAR(50) NOT NULL,
    reference_number VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    processed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_staging_transaction_wallet
        FOREIGN KEY (wallet_id)
        REFERENCES staging.wallets(wallet_id),

    CONSTRAINT fk_staging_transaction_user
        FOREIGN KEY (user_id)
        REFERENCES staging.users(user_id),

    CONSTRAINT fk_staging_transaction_merchant
        FOREIGN KEY (merchant_id)
        REFERENCES staging.merchants(merchant_id),

    CONSTRAINT fk_staging_transaction_counterparty
        FOREIGN KEY (counterparty_user_id)
        REFERENCES staging.users(user_id),

    CONSTRAINT chk_staging_transaction_amount
        CHECK (amount > 0)
);