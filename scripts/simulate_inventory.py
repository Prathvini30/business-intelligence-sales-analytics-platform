from pathlib import Path
import numpy as np
import pandas as pd
from sqlalchemy import text
from db_connection import get_engine

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "data" / "simulated"
rng = np.random.default_rng(42)            # fixed seed = reproducible

engine = get_engine()

# 1. Real demand per product (from sales)
demand = pd.read_sql("""
    SELECT product_key,
           SUM(quantity)            AS units_sold,
           SUM(cost) / SUM(quantity) AS unit_cost
    FROM order_items GROUP BY product_key
""", engine)
demand["daily_demand"] = demand["units_sold"] / 1461      # 2014-01-01 to 2017-12-31

# 2. Simulated suppliers
suppliers = pd.DataFrame({
    "supplier_id": range(1, 9),
    "supplier_name": [f"Simulated Supplier {i}" for i in range(1, 9)],
    "lead_time_days": rng.integers(3, 22, 8),
})

# 3. Simulated inventory, derived from real demand
inv = demand.copy()
inv["supplier_id"] = rng.integers(1, 9, len(inv))
inv = inv.merge(suppliers[["supplier_id", "lead_time_days"]], on="supplier_id")
# lead time + 30-day review period, 1.5x safety factor, plus 2-unit minimum safety stock
inv["reorder_level"] = np.ceil(inv["daily_demand"] * (inv["lead_time_days"] + 30) * 1.5).astype(int) + 2
inv["opening_stock"] = np.ceil(inv["daily_demand"] * rng.uniform(20, 90, len(inv))).astype(int) + 1
inv["stock_on_hand"] = np.floor(inv["reorder_level"] * rng.uniform(0, 3, len(inv))).astype(int)
inv["unit_cost"] = inv["unit_cost"].round(4)

inv = inv[["product_key", "supplier_id", "opening_stock", "reorder_level",
           "unit_cost", "stock_on_hand"]]

# 4. Save CSVs (labelled simulated) and load tables
suppliers.to_csv(OUT / "sim_suppliers.csv", index=False)
inv.to_csv(OUT / "sim_inventory.csv", index=False)

with engine.begin() as conn:
    conn.execute(text("DROP TABLE IF EXISTS sim_inventory"))
    conn.execute(text("DROP TABLE IF EXISTS sim_suppliers"))
    suppliers.to_sql("sim_suppliers", conn, index=False)
    inv.to_sql("sim_inventory", conn, index=False)
    conn.execute(text("COMMENT ON TABLE sim_suppliers IS 'SIMULATED data (seed 42). Not real.'"))
    conn.execute(text("COMMENT ON TABLE sim_inventory IS 'SIMULATED data (seed 42), derived from real sales demand. Not real.'"))

print("sim_suppliers:", len(suppliers))
print("sim_inventory:", len(inv))
print("Below reorder level:", int((inv["stock_on_hand"] < inv["reorder_level"]).sum()))
print("Zero stock:", int((inv["stock_on_hand"] == 0).sum()))