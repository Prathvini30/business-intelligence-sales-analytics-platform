# Learning Log

## Phase 1: Setup
- Implemented: VS Code, Python venv, PostgreSQL, Power BI, Git/GitHub, folder structure, dataset selection
- Why: reproducible environment and credentials kept out of Git
- Learned: venv isolation, .gitignore, URL-encoding special characters in DB passwords
- Errors solved:
  1. "could not translate host name 123@localhost": password contained @, fixed with quote_plus
  2. PermissionError on CSV: unzipping created a folder with the .csv name, fixed by moving the inner file
- Dataset: Superstore (9,994 rows, 21 columns). No inventory or supplier data, so it will be simulated and labelled.