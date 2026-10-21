---
description: Add custom server content (NPC, enemy, quest, item) the safe way
argument-hint: <what you want, e.g. "a level 10 wolf boss in Elwynn">
---
Request: $ARGUMENTS

Follow `.claude/rules/custom-sql.md` strictly:
1. Restate the request; say if it is **server only** or **needs a client patch**.
2. List the tables involved. For each, either cite the vmangos wiki page (`docs/world/<table>.md`) or ask me to run `DESCRIBE <table>;` and paste it. Do not guess columns.
3. Ask me for `WowPatch` / snapshot only if it changes the answer.
4. Draft `custom/sql/NNNN_name.sql` + `NNNN_name.rollback.sql` from the template (header, transaction, reserved IDs, idempotent).
5. Run `node custom/scripts/check-custom-sql.mjs`. Fix until it passes.
6. Tell me: backup first (`/backup-db`), how to apply, how to verify in game, how to roll back. Label what is untested.
