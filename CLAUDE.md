# Jabnaasaadrege — project guide for Claude

Private, non-commercial vMaNGOS (vmangos/core) WoW **1.12.1 / build 5875** server for the owner and a few friends, with custom content (NPCs, enemies, quests, items, later voices/models).
Fork: `frmingest/Jabnaasaadrege` (origin). Upstream: `vmangos/core`. Work branch: **`custom`**. Never commit to `master`/`development`.
Owner: Faiz (Windows, PowerShell, MariaDB). Language of docs/commits: English.

## Read first, every session
1. `custom/memory-bank/activeContext.md` — what we are doing right now
2. `custom/progress.md` — done / not done / how to start & stop / lessons
3. `custom/memory-bank/decisions.md` — decisions and why (do not relitigate without reason)
4. `.claude/rules/*.md` — hard rules (loaded by topic; read the relevant one before acting)

Update `activeContext.md` and `progress.md` at the end of any session that changed something (`/session-end`). The Claude Project "WOW" holds a copy of `progress.md`; say so when it is stale.

## Ground rules (non-negotiable)
- **vMaNGOS is NOT TrinityCore / AzerothCore / CMaNGOS.** Never reuse their table or column names. If not certain a table/column exists, say so, point to `docs/world/<table>.md` in github.com/vmangos/wiki, and ask for `DESCRIBE <table>;` output. Never invent columns.
- You cannot run the game server. Never say something is "tested" unless you ran it and saw the output. Label unverified statements as unverified.
- **Server side vs client side:** always state whether a change needs only the DB/core, or a client MPQ/DBC patch every player must install.
- Prefer **database scripting** (`creature_spells`, `creature_ai_events`, `creature_ai_scripts`) over C++. Upstream has no Lua; do not assume Eluna.
- Ask which `WowPatch`, snapshot/commit and build the user runs before giving version-dependent advice. Current `WowPatch` is the default (10).
- Legal: private and non-commercial only. Never add, link or distribute Blizzard client files, extracted client data, or MPQs containing Blizzard assets to the repo.

## Repo layout (what we own vs upstream)
| Path | Owner | Rule |
| --- | --- | --- |
| `custom/` | us | all our work lives here (scripts, SQL, docs, memory bank) |
| `.claude/`, `CLAUDE.md` | us | AI guardrails |
| `src/`, `sql/`, `dep/`, `cmake/`, `.github/` | upstream | avoid edits; see `rules/cpp-core.md` |
| `src/shared/Progression.h`, `revision.h`, `migrations_list.h` | generated | never edit, never commit |

Outside the repo: build `E:\vmangos-build`, install `E:\vmangos-server` (configs, `.dbpass`, `data\`), client `E:\Wow Classic 1.12.1`, MariaDB `C:\Program Files\MariaDB 13.0`.

## Working method
1. **Understand** — read the relevant doc/table page; state assumptions.
2. **Plan small** — one change at a time, reversible; for anything touching the DB, core, or networking, state the plan and rollback first.
3. **Change** — custom SQL in `custom/sql/` only (`rules/custom-sql.md`); scripts in `custom/scripts/`.
4. **Verify** — `node custom/scripts/check-custom-sql.mjs` for SQL; build via `custom/scripts/build.ps1` for C++; then an in-game check by the user. Report what was and was not verified.
5. **Record** — update memory bank and progress; commit by explicit path.

## Git
- Commit only when asked. `git add custom/ .claude/ CLAUDE.md` by name — **never `git add -A` / `git add .`**.
- Never force-push, never push to `upstream`, never `reset --hard` / `clean -fd` without explicit instruction.
- One-time per clone: `git update-index --skip-worktree src/shared/Progression.h` (CMake rewrites its line endings).
- Sync upstream deliberately: `git fetch upstream` then merge/rebase on `custom` in its own session, then rebuild and re-run all `custom/sql`.

## Secrets & safety
- Never read, print, paste or commit: `E:\vmangos-server\.dbpass`, `mangosd.conf`, `realmd.conf`, any password or token. Hooks block the obvious cases; do not work around them.
- Never expose MariaDB (port 3306) beyond localhost. Only login (3724) and world (8085) may be forwarded.
- Before any destructive DB action (DROP, TRUNCATE, DELETE without a narrow WHERE, bulk UPDATE): ask, and require a fresh backup (`/backup-db`).

## Output style
Concise. Code blocks for commands/SQL. Split answers into **Server side** / **Client side** when relevant. One clarifying question when truly ambiguous, otherwise proceed and say the assumption.

## Guardrail map
- `.claude/settings.json` — permission deny/ask lists + hook wiring
- `.claude/hooks/guard-bash.mjs` — blocks dangerous shell commands
- `.claude/hooks/guard-edit.mjs` — blocks/asks on protected files
- `.claude/hooks/post-sql-check.mjs` — runs the SQL checker after edits to `custom/sql/`
- `custom/scripts/check-custom-sql.mjs` — SQL policy linter (also run before committing)
- `.claude/commands/` — `/status`, `/new-content`, `/backup-db`, `/review`, `/session-end`
