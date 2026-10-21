# custom/sql

All custom world-DB content. See `.claude/rules/custom-sql.md`.

- Files: `NNNN_name.sql` + `NNNN_name.rollback.sql`. Copy from `0000_template*.example`.
- Reserved IDs: `reserved-ranges.json` (proposed 5,000,000–5,999,999 — verify first).
- Lint: `node custom/scripts/check-custom-sql.mjs` (all files) or pass one path.
- Back up the DB before applying. Apply in numeric order; re-applying must be safe.
- After every upstream sync, re-apply all files in order and re-test.
