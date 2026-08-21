CREATE TABLE IF NOT EXISTS source.users (
    user_id VARCHAR(50) PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    phone_number VARCHAR(30) UNIQUE NOT NULL,
    email VARCHAR(150) UNIQUE,
    city VARCHAR(100),
    registration_date DATE NOT NULL,
    status VARCHAR(30) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_user_status
        CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED'))
);

CREATE TABLE IF NOT EXISTS source.wallets (
    wallet_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) UNIQUE NOT NULL,
    balance NUMERIC(15, 2) NOT NULL DEFAULT 0,
    currency VARCHAR(10) NOT NULL DEFAULT 'IDR',
    status VARCHAR(30) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_wallet_user
        FOREIGN KEY (user_id)
        REFERENCES source.users(user_id),

    CONSTRAINT chk_wallet_balance
        CHECK (balance >= 0),

    CONSTRAINT chk_wallet_status
        CHECK (status IN ('ACTIVE', 'FROZEN', 'CLOSED')),

    CONSTRAINT chk_wallet_currency
        CHECK (currency = 'IDR')
);

CREATE TABLE IF NOT EXISTS source.merchants (
    merchant_id VARCHAR(50) PRIMARY KEY,
    merchant_name VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    status VARCHAR(30) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_merchant_status
        CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED'))
);

CREATE TABLE IF NOT EXISTS source.transaction_types (
    transaction_type_id SMALLSERIAL PRIMARY KEY,
    transaction_type VARCHAR(30) UNIQUE NOT NULL,
    description VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS source.payment_methods (
    payment_method_id SMALLSERIAL PRIMARY KEY,
    payment_method VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS source.transaction_statuses (
    transaction_status_id SMALLSERIAL PRIMARY KEY,
    status VARCHAR(30) UNIQUE NOT NULL,
    description VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS source.transactions (
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

    reference_number VARCHAR(100) UNIQUE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_transaction_wallet
        FOREIGN KEY (wallet_id)
        REFERENCES source.wallets(wallet_id),

    CONSTRAINT fk_transaction_user
        FOREIGN KEY (user_id)
        REFERENCES source.users(user_id),

    CONSTRAINT fk_transaction_merchant
        FOREIGN KEY (merchant_id)
        REFERENCES source.merchants(merchant_id),

    CONSTRAINT fk_transaction_counterparty
        FOREIGN KEY (counterparty_user_id)
        REFERENCES source.users(user_id),

    CONSTRAINT fk_transaction_type
        FOREIGN KEY (transaction_type_id)
        REFERENCES source.transaction_types(transaction_type_id),

    CONSTRAINT fk_transaction_payment_method
        FOREIGN KEY (payment_method_id)
        REFERENCES source.payment_methods(payment_method_id),

    CONSTRAINT fk_transaction_status
        FOREIGN KEY (transaction_status_id)
        REFERENCES source.transaction_statuses(transaction_status_id),

    CONSTRAINT chk_transaction_amount
        CHECK (amount > 0)
);


-- 12. Business Rules

-- Ada beberapa rule yang tidak kita paksa menggunakan CHECK constraint, karena kondisinya bergantung pada transaction_type.

-- Contohnya:

-- TRANSFER
-- transaction_type = TRANSFER

-- harus:

-- counterparty_user_id IS NOT NULL
-- merchant_id IS NULL
-- PAYMENT
-- transaction_type = PAYMENT

-- harus:

-- merchant_id IS NOT NULL
-- TOP_UP
-- transaction_type = TOP_UP

-- harus:

-- counterparty_user_id IS NULL

-- dan seterusnya.

-- Rule seperti ini akan kita implementasikan di data quality validation pipeline, bukan semuanya sebagai database constraint.

-- Ini penting karena nanti kita bisa menunjukkan:

-- "I implemented business-level data quality validation in the ETL layer."