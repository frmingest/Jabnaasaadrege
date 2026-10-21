# vMaNGOS private server: assessment and system prompt

Oct 21, 2026 · @Faiz Malik

## Bottom line

A small vMaNGOS server for you and friends is a weekend project: $0 at home or roughly $5-15/month on a VPS. New NPCs, enemies, quests and items are database work. Anything the client must show or play itself (new voices, new models) needs a client patch that every player installs, and a new playable race or class is not realistic on the 1.12.1 client.

- **Effort:** a few hands-on hours, plus unattended waits for compiling and for client data extraction.
- **Cost:** hosting is the only real expense; the core is free software (GPL-2.0).
- **Biggest risks:** the wrong database version, missing client map data, and port forwarding.
- **Custom work:** easy on the server side, harder the closer it gets to the client (see the table under Customization).

## Scope

The project has four moving parts, and you need your own legitimate 1.12.1 client (build 5875) before you start.

| Part | What it is |
| --- | --- |
| Server binaries | `mangosd` (world) and `realmd` (login). Prebuilt development releases exist for Linux, macOS and Windows, or you compile from source with g++, CMake and Git. |
| Databases | Four databases: `realmd`, `mangos` (world), `characters`, `logs`. MariaDB or MySQL 5.5 is supported; MySQL 8.0 is not. A ready-made database snapshot is published as a release. |
| Client data | DBC, maps, vmaps and mmaps extracted from your own client with the project's extractors (or obtained separately). |
| Client setup | Each player edits `realmlist.wtf` to point at your server's address. |

vMaNGOS also supports older client builds back to 1.5.1, and you pick the content patch (1.2 to 1.12) with the `WowPatch` setting in `mangosd.conf`. Pick one before you invite anyone, since it decides which raids, items and zones exist.

## Cost

Hosting is the only real cost, and running at home is free. These figures are my estimates, not from the project docs.

| Option | Monthly cost | Notes |
| --- | --- | --- |
| Your own PC or home server | $0 | Needs port forwarding on your router; the server only runs while the machine is on. |
| Budget VPS (Ubuntu LTS, 2 vCPU, 4 GB RAM) | about $5-15 | Enough for under 10 players. Open the realm and world ports in the VPS firewall. |
| Software and tools | $0 | The core is GPL-2.0; MariaDB and a free SQL client such as DBeaver or HeidiSQL cover the database work. |

Pick a VPS region near your group to keep latency low. The one-off compile and data extraction need more CPU than day-to-day play, so a temporary larger instance or your own PC can do that step.

## Effort

Plan on 2-4 hands-on hours if you use the prebuilt release and the database snapshot, plus unattended waiting. Treat it as a weekend if it is your first time, or if you compile and extract everything yourself. Those times are my estimate; the project docs only say compiling and extraction "can take quite a while".

1. **Check your client.** Confirm the login screen shows build 5875.
2. **Get the binaries.** Download the latest development release, or compile from source. The wiki's flags are out of date: current CMake uses `-DBUILD_EXTRACTORS=ON` to build the extractors (the old `USE_EXTRACTORS` flag is deprecated). The client build already defaults to 1.12.1, so you don't pass a build number.
3. **Prepare client data.** Run the map, vmap and movement-map extractors against your client (movement maps are the slow step), or obtain extracted data separately. The server expects `dbc`, `maps`, `vmaps` and `mmaps` under its data directory.
4. **Set up the databases.** Install MariaDB, create the four databases and a `mangos` user, then import the latest database snapshot, which already includes the migrations.
5. **Configure.** Copy the `.conf.dist` files to `mangosd.conf` and `realmd.conf`, then set `DataDir`, the database connection strings and `WowPatch`.
6. **Register the realm.** Insert a row into `realmlist` in the `realmd` database with your public IP, port 8085 and game build 5875.
7. **Start and create accounts.** Run `realmd` and `mangosd` (screen or tmux keep them alive), then create accounts from the `mangosd` console.
8. **Open the ports and connect.** Forward or open the ports, then have each friend set `set realmlist <your address>` in `realmlist.wtf`.

Ongoing work is small: database backups, and pulling and rebuilding updates when you want them. I'd estimate under an hour a week.

## Customization

Server-side content is easy and needs no client changes. Anything the client has to render or play needs an MPQ patch installed by every player, and a new playable race or class is not realistic.

| Goal | Difficulty | How | Players need a patch? |
| --- | --- | --- | --- |
| New NPCs and enemies on existing models | Easy | Rows in `creature_template` (stats, `display_id1`, `faction`, `loot_id`, `vendor_id`) and `creature` (spawns) | No |
| Custom boss abilities and AI | Easy to moderate | Spell lists in `creature_spells` (up to 8 spells per creature), plus the EventAI tables `creature_ai_events` and `creature_ai_scripts`; C++ only when DB scripting falls short | No, unless the spells need new names, icons or effects the client doesn't know |
| Custom quests, items, loot | Easy | `quest_template`, `item_template`, loot tables; reuse existing item display IDs | No for existing models and icons |
| Custom spells | Moderate to advanced | `spell_template` and `spell_mod` on the server; the client usually needs matching `Spell.dbc` data to show tooltips and effects correctly (general knowledge, not checked in the docs) | Usually yes |
| New voices and sounds | Moderate | Audio files and edited sound DBCs shipped in a client MPQ patch; the world DB table `sound_entries` only maps sound IDs to file names | Yes |
| New 3D models | Advanced | Custom M2 models and display-info DBC entries in a client MPQ patch | Yes |
| New playable race or class | Not realistic | The 1.12.1 client has a fixed set of races and classes. Alternatives: custom NPC characters, reskins, or new content for existing classes | n/a |
| Core C++ changes | Advanced | Edit the core; upstream prefers DB scripting and keeps custom behavior behind config options that default to off | No |

Two vMaNGOS-specific points. First, `creature_template` is keyed on both `entry` and `patch`, and the column names differ from TrinityCore (for example `display_id1`, not `modelid1`), so don't reuse TrinityCore queries. Second, upstream has no Lua support. An unofficial community fork merges the Eluna engine into vMaNGOS; I haven't opened it, so evaluate it before building on it.

For editing, the project links a [script editor](https://github.com/brotalnia/scripteditor) and a [script converter](https://github.com/vmangos/ScriptConverter) from its README.

## Risks and gotchas

Most first-run failures come from the database, missing client data, or networking.

- **Database version:** MySQL 8.0 is not supported. Use MariaDB (or MySQL 5.5 if you can source it).
- **Default credentials:** the wiki's setup uses `mangos`/`mangos` for the database and an `admin`/`admin` game account. Change both before exposing the server to the internet.
- **Missing data:** a crash after "Starting Map System" usually means maps or vmaps are missing. A server that shuts itself down right after start usually means MySQL is down or migrations are missing; the database snapshot avoids the latter.
- **Memory:** 32-bit builds hit the memory limit when map preloading is on. Build for 64-bit.
- **Friends can't connect:** the realm address in the `realmlist` table must be your real public IP (not 127.0.0.1), the ports must be reachable, and `mangosd` must have finished loading.
- **Content patch:** set `WowPatch` once and keep it. Some progression gates need manual setup; for example the Ahn'Qiraj gate stays closed until a world variable is set.
- **Custom content vs updates:** your own rows can collide with future upstream migrations. Use a high, reserved ID range and keep all your SQL in one file so you can reapply it.
- **Legal:** private servers sit in a gray area. Blizzard owns the game client and assets, so keep the server private and non-commercial, and never distribute game files; client patches should contain only your own assets. This is general information, not legal advice.

## System prompt

This replaces your original prompt. It drops TrinityCore, uses vMaNGOS's real schema conventions, and tells the assistant to admit uncertainty instead of inventing column names.

```markdown
You are an expert on vmangos/core ("Progressive Vanilla"), the World of Warcraft 1.12.1 (build 5875) emulator, which also supports earlier client builds back to 1.5.1. You help one hobbyist run a small private, non-commercial server for friends and customize it.

## Ground rules
- vmangos is NOT TrinityCore, AzerothCore or CMaNGOS. Never reuse their table or column names. If you are not certain a table or column exists in vmangos, say so, point to the vmangos wiki page for that table (docs/world/<table>.md in github.com/vmangos/wiki), and ask the user to run `DESCRIBE <table>;` and paste the result.
- You cannot run or test anything. Never claim a query, command or patch is "tested". Label anything you are unsure of.
- Before giving version-dependent advice, ask which client build, which `WowPatch` content patch, which database snapshot or commit, which OS, and whether the user runs prebuilt binaries or compiled from source.
- Do not provide or link to Blizzard's game client or extracted copyrighted game data. Assume the user owns a legitimate client. Keep advice to private, non-commercial use.

## Facts to rely on
- Databases: realmd, mangos (world), characters, logs. MariaDB or MySQL 5.5 is supported; MySQL 8.0 is not. Build 64-bit.
- World tables are keyed by entry plus a `patch` column (for example `creature_template` is keyed on `entry` and `patch`). Ask how the core selects rows for the configured `WowPatch` before bulk-inserting custom rows.
- `creature_template` uses columns such as `display_id1`, `level_min`, `level_max`, `faction`, `health_multiplier`, `spell_list_id` (points to `creature_spells.entry`), `ai_name`, `script_name`, `loot_id`, `vendor_id`, `trainer_id`, `equipment_id`. Spawns live in `creature`.
- Prefer database scripting (creature_spells, creature_ai_events, creature_ai_scripts, generic script tables) over C++. Upstream keeps custom behavior behind config options that default to off.
- Upstream has no Lua engine. Do not assume Eluna APIs exist; an unofficial fork merges Eluna, so ask which build the user runs.

## How to answer
- Split every answer into Server side (DB or core, no client change) and Client side (DBC or MPQ patch, every player must install it). State clearly when a change needs a client patch.
- For SQL: tell the user to back up first, use a high reserved ID range for custom entries, wrap changes in a transaction, and include a rollback statement.
- For C++: keep patches small and match the surrounding code style; mention thread safety and performance only where relevant.
- For the client: explain DBC edits and MPQ patch layout, and note that the server's copy of a DBC may also need to match.
- Be concise. Use code blocks for commands, SQL and code. Ask one clarifying question when a request is ambiguous instead of guessing.
```

## Sources

Checked 2026-10-21. Pages I opened:

- [vmangos/core README](https://github.com/vmangos/core): supported builds, prebuilt releases, database snapshot, project guidelines.
- [Compiling on Linux](https://github.com/vmangos/wiki/blob/master/docs/Compiling-on-Linux.md): dependencies, database version support, CMake flags.
- [Getting it working on Linux](https://github.com/vmangos/wiki/blob/master/docs/Getting-it-working-Linux.md): data extraction, database import, configuration, realm row, first start.
- [FAQ](https://github.com/vmangos/wiki/blob/master/docs/Frequently-Asked-Questions.md): common startup failures, `WowPatch`, 32-bit memory note, Ahn'Qiraj gate.
- [World database tables](https://github.com/vmangos/wiki/blob/master/docs/World-Database.md) and [creature\_template](https://github.com/vmangos/wiki/blob/master/docs/world/creature_template.md): table list, `entry` plus `patch` key, column names.

Not verified against sources, so treat as approximate: hosting prices and sizing, setup and extraction times, the default realm port of 3724, what the client needs for custom spells, sounds and models, and the unofficial Eluna fork (named in a search result, not opened).
