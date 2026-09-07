INSERT INTO source.transaction_types
    (transaction_type, description)
VALUES
    ('PAYMENT', 'Payment to a merchant'),
    ('TRANSFER', 'Transfer between users'),
    ('TOP_UP', 'Adding funds to wallet'),
    ('WITHDRAWAL', 'Withdrawal from wallet'),
    ('REFUND', 'Refund from merchant'),
    ('BILL_PAYMENT', 'Payment for bills or services')
ON CONFLICT (transaction_type) DO NOTHING;

INSERT INTO source.payment_methods
    (payment_method, description)
VALUES
    ('WALLET_BALANCE', 'Payment using wallet balance'),
    ('QRIS', 'QRIS payment'),
    ('VIRTUAL_ACCOUNT', 'Virtual account payment'),
    ('DEBIT_CARD', 'Debit card payment'),
    ('CREDIT_CARD', 'Credit card payment'),
    ('BANK_TRANSFER', 'Bank transfer')
ON CONFLICT (payment_method) DO NOTHING;

INSERT INTO source.transaction_statuses
    (status, description)
VALUES
    ('SUCCESS', 'Transaction completed successfully'),
    ('FAILED', 'Transaction failed'),
    ('PENDING', 'Transaction is still processing'),
    ('CANCELLED', 'Transaction was cancelled'),
    ('REVERSED', 'Transaction was reversed')
ON CONFLICT (status) DO NOTHING;