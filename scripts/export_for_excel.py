from pathlib import Path
import pandas as pd
from db_connection import get_engine

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "excel" / "superstore_for_excel.xlsx"

query = """
SELECT o.order_id, o.order_date, o.region, o.state,
       c.customer_id, c.segment,
       p.category, p.sub_category, p.product_name,
       oi.sales, oi.quantity, oi.discount, oi.profit
FROM order_items oi
JOIN orders o    ON o.order_id = oi.order_id
JOIN customers c ON c.customer_id = o.customer_id
JOIN products p  ON p.product_key = oi.product_key
ORDER BY o.order_date, o.order_id
"""

df = pd.read_sql(query, get_engine())
df["sales"] = df["sales"].astype(float)
df["profit"] = df["profit"].astype(float)
df["discount"] = df["discount"].astype(float)
df.to_excel(OUT, index=False, sheet_name="data")

print("Rows, columns:", df.shape)
print("Total sales:", round(df["sales"].sum(), 2))
print("Total profit:", round(df["profit"].sum(), 2))
print("Saved:", OUT)