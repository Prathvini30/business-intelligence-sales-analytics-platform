import os
from urllib.parse import quote_plus
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()

user = os.getenv("DB_USER")
password = os.getenv("DB_PASSWORD")
host = os.getenv("DB_HOST")
port = os.getenv("DB_PORT")
database = os.getenv("DB_NAME")

def get_engine():
    url = f"postgresql+psycopg2://{user}:{quote_plus(password)}@{host}:{port}/{database}"
    return create_engine(url)

if __name__ == "__main__":
    with get_engine().connect() as conn:
        print(conn.execute(text("SELECT current_database();")).scalar())
        print("Connection via .env works!")