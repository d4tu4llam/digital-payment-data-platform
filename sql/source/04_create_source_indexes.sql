CREATE INDEX IF NOT EXISTS idx_transactions_user
ON source.transactions(user_id);

CREATE INDEX IF NOT EXISTS idx_transactions_wallet
ON source.transactions(wallet_id);

CREATE INDEX IF NOT EXISTS idx_transactions_merchant
ON source.transactions(merchant_id);

CREATE INDEX IF NOT EXISTS idx_transactions_timestamp
ON source.transactions(transaction_timestamp);

CREATE INDEX IF NOT EXISTS idx_transactions_type
ON source.transactions(transaction_type_id);

CREATE INDEX IF NOT EXISTS idx_transactions_status
ON source.transactions(transaction_status_id);