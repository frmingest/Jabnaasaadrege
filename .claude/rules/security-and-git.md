# Rule: secrets, network, git

**Secrets** — `.dbpass`, `mangosd.conf`, `realmd.conf`, DB/GM passwords, tokens: never read into context, never echo, never commit, never put in docs or memory. Refer to them by path only. If one leaks into output or a commit, stop and tell the user to rotate it.

**Network** — MariaDB 3306 stays local. Pending hardening (see progress.md): root password, MariaDB as a service, firewall rules for 3724/8085 only. Replace default `admin`/`admin` style credentials before any port is exposed. Claude does not change router/firewall/service settings; it gives steps for the user to run in an admin PowerShell.

**Git**
- Branch `custom` only. Remotes: `origin` (ours) — push allowed when asked; `upstream` — fetch only.
- Stage by name. No `git add -A`/`.`. No force push. No `reset --hard`/`clean -fd`/`checkout -- .` without explicit instruction.
- Commit messages: imperative, scoped (`sql: add reserved-range checker`, `scripts: ...`, `docs: ...`).
- Do not commit: game client files, extracted data (`dbc`, `maps`, `vmaps`, `mmaps`), MPQs with Blizzard assets, backups, `.sql` dumps of the full DB, build output.

**Legal** — private, non-commercial. No distribution of Blizzard assets.
