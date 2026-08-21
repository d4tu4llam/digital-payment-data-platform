CREATE TABLE IF NOT EXISTS analytics.dim_users (
    user_key SERIAL PRIMARY KEY,
    user_id VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS analytics.dim_merchants (
    merchant_key SERIAL PRIMARY KEY,
    merchant_id VARCHAR(50) UNIQUE NOT NULL,
    merchant_name VARCHAR(150),
    category VARCHAR(100),
    city VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS analytics.dim_payment_methods (
    payment_method_key SERIAL PRIMARY KEY,
    payment_method VARCHAR(30) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS analytics.dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE UNIQUE NOT NULL,
    year INTEGER,
    month INTEGER,
    day INTEGER,
    day_of_week INTEGER
);

CREATE TABLE IF NOT EXISTS analytics.fact_transactions (
    transaction_key BIGSERIAL PRIMARY KEY,
    transaction_id VARCHAR(50) UNIQUE NOT NULL,
    user_key INTEGER,
    merchant_key INTEGER,
    payment_method_key INTEGER,
    date_key INTEGER,
    transaction_timestamp TIMESTAMP,
    amount NUMERIC(15, 2),
    status VARCHAR(30)
);