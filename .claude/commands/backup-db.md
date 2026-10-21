---
description: Give the exact commands to back up the four databases (Claude does not run them)
---
Do not read `.dbpass` or any config. Give the user a PowerShell snippet to run themselves that:
- finds `mariadb-dump.exe` under `C:\Program Files\MariaDB*\bin`,
- prompts for the password (no password on the command line),
- dumps `mangos`, `realmd`, `characters`, `logs` with `--single-transaction` to `E:\vmangos-backups\<yyyyMMdd-HHmmss>\<db>.sql`,
- prints file sizes at the end.
Remind: backups stay outside the repo and are never committed.
