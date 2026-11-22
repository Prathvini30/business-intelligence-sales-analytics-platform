from pathlib import Path
import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "data" / "raw" / "superstore.csv"
OUT = ROOT / "data" / "cleaned" / "superstore_clean.csv"

# 1. Load
df = pd.read_csv(RAW, encoding="cp1252")
rows_start = len(df)

# 2. Clean text: non-breaking spaces -> normal spaces, collapse repeats, strip ends
text_cols = df.select_dtypes("object").columns
for col in text_cols:
    df[col] = (df[col]
               .str.replace("\u00a0", " ", regex=False)
               .str.replace(r"\s+", " ", regex=True)
               .str.strip())

# 3. Convert dates (format given explicitly so day/month can't be swapped)
df["Order Date"] = pd.to_datetime(df["Order Date"], format="%m/%d/%Y")
df["Ship Date"] = pd.to_datetime(df["Ship Date"], format="%m/%d/%Y")

# 4. Restore postal codes as 5-character text
df["Postal Code"] = df["Postal Code"].astype(str).str.zfill(5)

# 5. Drop exact duplicates, ignoring Row ID (keeps the first occurrence)
dupe_mask = df.duplicated(subset=[c for c in df.columns if c != "Row ID"], keep="first")
print("Near-duplicate rows dropped:", dupe_mask.sum(), "-> Row IDs", df.loc[dupe_mask, "Row ID"].tolist())
df = df[~dupe_mask].copy()

# 6. Rename columns to snake_case
df.columns = (df.columns.str.lower().str.replace("-", "_").str.replace(" ", "_"))

# 7. Surrogate key: one number per distinct (product_id, product_name) pair
df["product_key"] = df.groupby(["product_id", "product_name"]).ngroup() + 1

# 8. Derived financial columns (cost is DERIVED, not source data)
df["cost"] = (df["sales"] - df["profit"]).round(4)
df["profit_margin"] = np.where(df["sales"] > 0, df["profit"] / df["sales"], np.nan)

# 9. Validation: stop with an error if any rule is broken
assert df["row_id"].is_unique
assert df.isna().sum().sum() == 0
assert (df["postal_code"].str.len() == 5).all()
assert (df["ship_date"] >= df["order_date"]).all()
assert (df["sales"] > 0).all() and (df["quantity"] > 0).all()
assert df["discount"].between(0, 1).all()

# 10. Export
df.to_csv(OUT, index=False, encoding="utf-8")

print("Rows: before", rows_start, "-> after", len(df))
print("Orders:", df["order_id"].nunique())
print("Customers:", df["customer_id"].nunique())
print("Products (product_key):", df["product_key"].nunique())
print("Order dates:", df["order_date"].min().date(), "to", df["order_date"].max().date())
print("Total sales:", round(df["sales"].sum(), 2))
print("Total profit:", round(df["profit"].sum(), 2))
# Non-ASCII check, on the columns that are text at this point
obj_cols = df.select_dtypes("object").columns
non_ascii = df[obj_cols].apply(lambda s: s.str.contains(r"[^\x00-\x7F]")).any(axis=1).sum()
print("Rows with non-ASCII text:", non_ascii)
print("All validation checks passed. Saved:", OUT)
assert not df[obj_cols].apply(lambda s: s.str.contains(r"[\x80-\x9f\xa0]")).any().any()