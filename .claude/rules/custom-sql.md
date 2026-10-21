# Rule: custom SQL content

Applies to anything that changes the `mangos` (world) database: NPCs, enemies, spells lists, AI, quests, items, loot, vendors, spawns.

1. **Files live in `custom/sql/`**, numbered `NNNN_short_name.sql`, each with a paired `NNNN_short_name.rollback.sql`. Never edit upstream `sql/` migrations.
2. **Reserved ID range** (see `custom/sql/reserved-ranges.json`): custom rows use only IDs inside it, so upstream migrations cannot collide. Never overwrite or delete a row outside the range (no `UPDATE`/`DELETE` of upstream rows; to change upstream behaviour prefer inserting a new custom entry).
3. **Header** at top of every file: `-- Purpose:`, `-- Server/Client:` (server only, or needs client patch), `-- Tables:`, `-- Id-range: <lo>-<hi>`.
4. **Transaction**: `START TRANSACTION;` ... `COMMIT;`. Idempotent where possible (`DELETE FROM x WHERE entry BETWEEN lo AND hi;` then `INSERT`, scoped to our range).
5. **Schema discipline**: vMaNGOS keys world tables on `entry` + `patch` where applicable; columns differ from TrinityCore (`display_id1`, not `modelid1`). Before writing a new table's SQL, get `DESCRIBE <table>;` from the user's DB or the vmangos wiki page. Never guess.
6. **Back up first** (`/backup-db`) and apply only through the apply script/command the user runs; Claude does not run SQL against the live DB unless explicitly told to.
7. **Lint**: `node custom/scripts/check-custom-sql.mjs` must pass before commit. It enforces points 1–4 and rejects `DROP`, `TRUNCATE`, unscoped `DELETE`/`UPDATE`.
8. State plainly if the content needs a client patch (new sounds/models/spell visuals) — the server DB alone will not show it.
