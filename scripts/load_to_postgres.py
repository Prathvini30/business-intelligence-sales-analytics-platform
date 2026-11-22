from pathlib import Path
import pandas as pd
from sqlalchemy import text
from db_connection import get_engine

ROOT = Path(__file__).resolve().parent.parent
CSV = ROOT / "data" / "cleaned" / "superstore_clean.csv"

df = pd.read_csv(CSV, dtype={"postal_code": str},
                 parse_dates=["order_date", "ship_date"])

# 1. Split the flat file into four tables (drop_duplicates = one row per key)
customers = (df[["customer_id", "customer_name", "segment"]]
             .drop_duplicates())

products = (df[["product_key", "product_id", "product_name", "category", "sub_category"]]
            .drop_duplicates())

orders = (df[["order_id", "customer_id", "order_date", "ship_date", "ship_mode",
              "country", "state", "city", "postal_code", "region"]]
          .drop_duplicates())

order_items = df[["row_id", "order_id", "product_key",
                  "sales", "quantity", "discount", "profit", "cost"]]

# 2. Check that each table has exactly one row per primary key
assert customers["customer_id"].is_unique
assert products["product_key"].is_unique
assert orders["order_id"].is_unique
assert order_items["row_id"].is_unique

# 3. Load in parent-to-child order, inside one transaction
engine = get_engine()
with engine.begin() as conn:
    conn.execute(text("TRUNCATE order_items, orders, products, customers"))
    customers.to_sql("customers", conn, if_exists="append", index=False)
    products.to_sql("products", conn, if_exists="append", index=False)
    orders.to_sql("orders", conn, if_exists="append", index=False)
    order_items.to_sql("order_items", conn, if_exists="append", index=False)

print("customers:", len(customers))
print("products:", len(products))
print("orders:", len(orders))
print("order_items:", len(order_items))
print("Load complete.")