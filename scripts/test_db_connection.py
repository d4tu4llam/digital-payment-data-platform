from sqlalchemy import create_engine, text


DATABASE_URL = (
    "postgresql+psycopg2://"
    "payment_user:payment_password"
    "@localhost:5432/payment_db"
)


def main():
    engine = create_engine(DATABASE_URL)

    with engine.connect() as connection:
        result = connection.execute(text("SELECT version();"))
        print(result.scalar())


if __name__ == "__main__":
    main()