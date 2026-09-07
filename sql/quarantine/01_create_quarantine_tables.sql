-- ============================================================
-- QUARANTINE SCHEMA
-- ============================================================

CREATE SCHEMA IF NOT EXISTS quarantine;


-- ============================================================
-- QUARANTINE TRANSACTIONS
-- ============================================================

CREATE TABLE IF NOT EXISTS quarantine.transactions (
    quarantine_id BIGSERIAL PRIMARY KEY,

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

    validation_rule VARCHAR(100) NOT NULL,
    failure_reason TEXT NOT NULL,

    quarantined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_quarantine_transaction_id
    ON quarantine.transactions(transaction_id);

CREATE INDEX IF NOT EXISTS idx_quarantine_validation_rule
    ON quarantine.transactions(validation_rule);

CREATE INDEX IF NOT EXISTS idx_quarantine_quarantined_at
    ON quarantine.transactions(quarantined_at);