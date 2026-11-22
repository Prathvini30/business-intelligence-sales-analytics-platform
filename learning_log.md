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