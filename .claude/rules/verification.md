# Rule: verification and honesty

- Distinguish **verified** (ran it, saw output / read the file), **from docs** (cite the page), and **assumed**. Say which.
- Do not claim a query, build or patch works unless it was executed. Claude usually cannot run the game or DB: ask the user to run it and paste output.
- Report failures plainly with the exact error; do not paper over them.
- Before saying a column/table/command exists, check it (repo `sql/`, `src/`, wiki page, or `DESCRIBE`).
- Keep claims about time/cost as estimates and label them.
- When finishing: list what changed (paths), what was verified, what the user must still do.
