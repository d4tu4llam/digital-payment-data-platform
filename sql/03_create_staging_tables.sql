CREATE TABLE IF NOT EXISTS staging.transactions (
    transaction_id VARCHAR(50),
    user_id VARCHAR(50),
    merchant_id VARCHAR(50),
    transaction_timestamp TIMESTAMP,
    amount NUMERIC(15, 2),
    payment_method VARCHAR(30),
    status VARCHAR(30),
    city VARCHAR(100),
    processed_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);