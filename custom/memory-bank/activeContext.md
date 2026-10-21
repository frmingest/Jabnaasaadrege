# Active context

Updated: 2026-10-21

## Goal
Private vMaNGOS 1.12.1 (build 5875) server for Faiz + friends, then custom content (NPCs/enemies first; voices/models later via client MPQ patch).

## State
Core built, client data extracted, MariaDB + 4 DBs ready, servers start, first local login and level-1 character worked *(verified by user)*. Nothing committed yet. AI guardrails (CLAUDE.md, .claude/, SQL checker) added 2026-10-21 — untracked, not yet committed.

## Next (in order)
1. Finish in-game check: pathing/chase (validates mmaps), quest rewards, dungeon/city load, GM commands.
2. Commit `custom/`, `.claude/`, `CLAUDE.md` by name; run `git update-index --skip-worktree src/shared/Progression.h`.
3. Harden: MariaDB root password, MariaDB as a service, then decide hosting before opening ports.
4. Confirm reserved ID range against live DB, then first custom content (one NPC) end-to-end via `/new-content`.

## Open questions
- Hosting: home PC vs VPS?
- Voices/sounds: which approach and who installs the client patch?
- Evaluate unofficial Eluna fork? (default: no)
- Align guardrails with the Aladdin project's setup (repo path not yet provided).
