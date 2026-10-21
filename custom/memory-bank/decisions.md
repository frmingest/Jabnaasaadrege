# Decisions (append-only)

- 2026-10-21 — Base: vmangos/core fork `frmingest/Jabnaasaadrege`, work on branch `custom`. Why: keeps upstream mergeable.
- 2026-10-21 — Native Windows build (VS 2022 Build Tools, CMake), 64-bit Release. Install to `E:\vmangos-server`.
- 2026-10-21 — Database: MariaDB (not MySQL 8.0, unsupported by vMaNGOS).
- 2026-10-21 — `WowPatch` left at default (10). Revisit only before inviting friends.
- 2026-10-21 — Custom server content = SQL files in `custom/sql/` inside a reserved ID range, never edits to upstream rows or `sql/`. Range 5,000,000–5,999,999 is PROPOSED, to be verified against the live DB.
- 2026-10-21 — Client-side changes (voices, models, spell visuals) only via a custom MPQ patch with our own assets. No new races/classes.
- 2026-10-21 — Core C++ only when DB scripting cannot do it; config-gated, default off.
- 2026-10-21 — Guardrails: CLAUDE.md + `.claude/rules` + hooks (bash/edit guards, SQL lint). Secrets and generated files are never touched by Claude.
