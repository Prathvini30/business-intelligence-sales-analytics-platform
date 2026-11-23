# Learning Log

## Phase 1: Setup
- Implemented: VS Code, Python venv, PostgreSQL, Power BI, Git/GitHub, folder structure, dataset selection
- Why: reproducible environment and credentials kept out of Git
- Learned: venv isolation, .gitignore, URL-encoding special characters in DB passwords
- Errors solved:
  1. "could not translate host name 123@localhost": password contained @, fixed with quote_plus
  2. PermissionError on CSV: unzipping created a folder with the .csv name, fixed by moving the inner file
- Dataset: Superstore (9,994 rows, 21 columns). No inventory or supplier data, so it will be simulated and labelled.
## Phase 3: Cleaning script
- Cleaned: dates parsed with %m/%d/%Y, postal codes zero-padded (449 NE-state codes), text whitespace normalized,
  1 near-duplicate dropped (Row ID 3407, assumption: double entry), product_key surrogate key (1,894 products),
  cost = sales - profit (derived)
- Encoding bug: file is cp1252, not latin-1. Curly quotes had become control characters (\x93, \x94),
  and non-breaking spaces (\xa0) were hiding inside product names. Fixed and guarded with an assert.
- Control totals for later cross-checks: sales 2,296,919.49, profit 286,409.08,
  9,993 rows, 5,009 orders, 793 customers, 1,894 products
  ## Phase 3: EDA findings (from actual output)
- Sales: 2014 $484.0k, 2015 $470.5k, 2016 $609.2k, 2017 $733.2k; margin 10.2% -> 13.1% -> 13.4% -> 12.7%
- Furniture margin 2.5% vs Office Supplies 17.0% and Technology 17.4%
- Loss-making sub-categories: Tables (-17.7k), Bookcases (-3.5k), Supplies (-1.2k)
- Region margins: West 14.9%, East 13.5%, South 11.9%, Central 7.9%
- Seasonality: early-year dips, strong year-end peaks
- Hypothesis to test in SQL: deep discounts drive Furniture and Central losses
## Phase 4: Database
- Schema: customers, products (surrogate product_key), orders, order_items; PKs, FKs, CHECK constraints, indexes
- Design basis (verified): each order has one date, ship mode and destination; customer_id never conflicts
- Loader: split flat CSV with drop_duplicates, loaded parent-to-child in one transaction (rolls back on failure)
- Reconciliation: 793 / 1,894 / 5,009 / 9,993 rows; sales 2,296,919.49; profit 286,409.08 all match the Python control totals
## Phase 5: SQL findings
- Q1: 5,009 orders, 793 customers, revenue 2,296,919.49, cost 2,010,510.41, profit 286,409.08, margin 12.5%, AOV 458.56
- Q3: Copiers top (55.6k); Supplies, Bookcases, Tables lose money; Machines margin ~1.8%
- Q4: all categories profitable up to 20% discount, loss-making above it; Furniture over-20% lines lose 54.5k
## Phase 5: trends
- Q6 YoY revenue: 2015 -2.8%, 2016 +29.5%, 2017 +20.4%; matches pandas
- Q5: strong seasonality; Jan/Feb lows, November peaks (Nov 2017 = 118,447.83, highest month)
- Lesson: MoM % is noisy under seasonality; use same-month YoY
## Phase 5: regions and customers
- Q7: West 14.9%, East 13.5%, South 11.9%, Central 7.9% margin (matches pandas)
- Q8: 781 of 793 customers (98.5%) ordered more than once. Simple repeat rate is not discriminating
  over 4 years; use RFM and per-year activity instead.
  ## Phase 5: deep dives
- Q9: Central avg discount 0.240, 27.7% of lines over 20% discount, those lines lose 52.4k (> Central's total profit 39.7k); West lowest discount (0.109) and highest margin
- Q10: customers place 1-17 orders (mode 5-7); only 12 one-time customers, so repeat rate (98.5%) is not discriminating
- To test: category mix by region as an alternative explanation
## Phase 5: top/bottom
- Q11: #1 customer by revenue (Sean Miller, 25.0k) has NEGATIVE profit (-1.98k); #6 (Ken Lonsdale) earns only 0.8k on 14.2k.
  Lesson: rank customers by profit as well as revenue.
- Q12: worst products are mostly Machines (3D printers, Lexmark printer, Cisco TelePresence) and Tables;
  Cubify CubeX Double Head alone loses 8.9k
  - Sean Miller check: one Cisco TelePresence line (22.6k sales, 50% discount, -1.81k profit) is ~90% of his revenue and explains his negative profit.