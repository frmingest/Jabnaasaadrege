# vMaNGOS private server: progress

Last updated: 2026-10-21. Goal: a private 1.12.1 (build 5875) vMaNGOS server for a small group of friends, plus custom content (new NPCs and enemies, new voices).

Planning document with scope, cost, effort and a customization table: https://claude.ai/artifact/B5pa4MqwSWNJn7BGBYTVbV

## Where things are

| What | Location |
| --- | --- |
| Source (your fork) | `E:\Jabnaasaadrege-development`, branch `custom`. Remotes: `origin` = frmingest/Jabnaasaadrege, `upstream` = vmangos/core |
| Helper scripts | `E:\Jabnaasaadrege-development\custom\scripts\` |
| Build output (CMake) | `E:\vmangos-build` |
| Installed server | `E:\vmangos-server` (`realmd.exe`, `mangosd.exe`, `mangosd.conf`, `realmd.conf`) |
| Extracted client data | `E:\vmangos-server\data` (`5875\dbc`, `maps`, `vmaps`, `mmaps`) |
| Game client | `E:\Wow Classic 1.12.1` (verified 1.12.1, build 5875) |
| Database server | MariaDB 13.0.2 in `C:\Program Files\MariaDB 13.0` |
| Databases | `realmd`, `mangos` (world), `characters`, `logs`; DB user `mangos`, its random password is in `E:\vmangos-server\.dbpass` |
| Ports | login 3724, world 8085, database 3306 (local only) |

## Done

- [x] Assessment of scope, cost and effort written, then corrected against the real repo docs.
- [x] Fork cloned into the local folder and linked to GitHub; working branch `custom` created.
- [x] Build tools installed: Visual Studio 2022 Build Tools (C++), CMake, Git.
- [x] Core compiled (Release, x64) and installed to `E:\vmangos-server`, including the data extractors.
- [x] Client data extracted from the 1.12.1 client: DBC, maps, vmaps, and movement maps for all 41 maps (about 2 GB). The client folder was only read.
- [x] MariaDB set up; four databases created; latest published database snapshot imported; realm entry added (address `127.0.0.1`, build 5875).
- [x] `mangosd.conf` and `realmd.conf` generated (data folder, log folder, database logins).
- [x] World server starts and reads the database, so the bundled MySQL library works with MariaDB.
- [x] GM account `GEXTE` created at security level 6.
- [x] First login test passed: logged in with the 1.12.1 client against `127.0.0.1` and started a level 1 character.

## Not done yet

In rough order:

1. **Finish the gameplay check.** Login works. Still to confirm in-game: monsters path around obstacles and chase properly (validates the movement maps), quests give rewards, a dungeon or city loads, and GM commands work (e.g. `.help` in chat).
2. **Commit to GitHub.** Nothing is committed yet. Commit `custom/` by name (`git add custom/`), never `git add -A`. Run `git update-index --skip-worktree src/shared/Progression.h` once, because CMake regenerates that file with different line endings on every configure.
3. **Make MariaDB start on its own.** It currently runs only in a console window; closing it stops the database. Register it as a service from an administrator PowerShell (`mariadbd.exe --install MariaDB`, then `Start-Service MariaDB`).
4. **Secure the database.** MariaDB's root account has no password and the server listens on all network interfaces. Set a root password and never forward port 3306.
5. **Let friends connect.**
   - Decide hosting: this PC at home (free, only online while it's on) or a VPS.
   - Set the realm address in `realmd.realmlist` to your public IP or hostname.
   - Forward ports 3724 and 8085 on the router and allow them in Windows Firewall.
   - Friends need a 1.12.1 client with `set realmlist <your address>` in `realmlist.wtf`.
6. **Keep the servers running** without open windows (services or scheduled tasks), plus a routine database backup.
7. **Tune.** MariaDB reserves about 8 GB of RAM for its buffer by default; lower it if memory is tight. Review `mangosd.conf` settings (content patch `WowPatch` is at its default, 10).
8. **Custom content.**
   - Server-side (NPCs, enemies, quests, items): SQL files kept in `custom/sql/`, using a high reserved ID range so upstream updates don't collide; apply with a script.
   - Client-side (new voices, models, spell visuals): a custom MPQ patch every player must install.
   - A new playable race or class is not realistic on the 1.12.1 client.
9. **Optional:** decide whether to evaluate the unofficial Eluna Lua fork; upstream vMaNGOS has no Lua.

## How to start and stop

Start in this order, each in its own PowerShell window, and leave them open:

1. MariaDB: `& 'C:\Program Files\MariaDB 13.0\bin\mariadbd.exe' --console`
2. Login server: `cd E:\vmangos-server; .\realmd.exe`
3. World server: `cd E:\vmangos-server; .\mangosd.exe` (wait until the console accepts typing)

Create accounts in the `mangos>` console: `account create <name> <password>` then `account set gmlevel <name> 6`. Type the real name and password with no angle brackets.

## Scripts (`custom/scripts/`)

| Script | What it does |
| --- | --- |
| `build.ps1` | Configures with CMake (x64, extractors on), builds Release, installs to `E:\vmangos-server` |
| `extract-data.ps1` | Extracts DBC, maps, vmaps and mmaps; each step writes a `.done-*` marker only when finished, so an interrupted run is safe to repeat |
| `setup-db.ps1` | Creates databases and the `mangos` user, imports the snapshot, adds the realm row, writes both config files |

## Lessons from setup (so we don't repeat them)

- The wiki's build flags are outdated. The extractor option is `BUILD_EXTRACTORS`, and the client build defaults to 1.12.1, so no build number is passed.
- Do not pass `-DPREFIX` to CMake: it leaks into CMake's compiler detection and breaks configure. `CMAKE_INSTALL_PREFIX` is enough.
- Windows MySQL, OpenSSL and zlib libraries are bundled in the repo; nothing extra is needed to compile.
- The Visual Studio Build Tools install failed once with a disk-space error before succeeding.
- The movement-map generator cannot resume; an interrupted run must start over (the script now handles this).
- The client's `realmlist.wtf` originally pointed at another private server; keep the backup of the original.

## Risks to keep in mind

- Private servers are a legal gray area: keep it private and non-commercial, and never distribute Blizzard's client files.
- Never share the contents of `.dbpass` or the `.conf` files; they contain the database password.

## AI workflow & guardrails (added 2026-10-21)

- `CLAUDE.md` (repo root) is the entry point for Claude; rules in `.claude/rules/`, hooks in `.claude/hooks/`, commands in `.claude/commands/` (`/status`, `/new-content`, `/backup-db`, `/review`, `/session-end`).
- Memory bank: `custom/memory-bank/` (activeContext, decisions).
- Custom SQL: `custom/sql/` with `node custom/scripts/check-custom-sql.mjs` as the linter. Reserved ID range is a proposal until verified against the live DB.
- Hooks/linter tested with sample inputs on 2026-10-21; hook wiring inside Claude Code itself has not yet been observed live.
