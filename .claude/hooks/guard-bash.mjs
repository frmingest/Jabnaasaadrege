// PreToolUse(Bash): block dangerous shell commands. Exit 2 = block, message goes to Claude.
import { readFileSync } from 'node:fs';

let input = {};
try { input = JSON.parse(readFileSync(0, 'utf8')); } catch { process.exit(0); }
const cmd = String(input?.tool_input?.command ?? '');

const rules = [
  [/\bgit\s+add\s+(-A|--all|\.)(\s|$)/i, 'git add -A/--all/. is forbidden. Stage by explicit path: git add custom/ .claude/ CLAUDE.md'],
  [/\bgit\s+push\b[^\n]*(\s-f\b|--force(?!-with-lease))/i, 'Force push is forbidden.'],
  [/\bgit\s+push\b[^\n]*\bupstream\b/i, 'Never push to upstream (vmangos/core). origin only.'],
  [/\bgit\s+(reset\s+--hard|clean\s+-[a-z]*[fd]|checkout\s+--\s+\.|restore\s+\.)/i, 'Destructive git command needs explicit user instruction; ask first.'],
  [/\.dbpass|mangosd\.conf(?!\.dist)|realmd\.conf(?!\.dist)/i, 'Secrets/config files must not be read or printed. Refer to them by path only.'],
  [/\b(drop\s+(database|table|schema)|truncate\s+table|delete\s+from\s+\w+\s*;)/i, 'Destructive SQL blocked. Back up first (/backup-db) and ask the user to run it.'],
  [/\b(rm\s+-[a-z]*r[a-z]*f?|rm\s+-rf|rmdir\s+\/s|del\s+\/s|Remove-Item\b[^\n]*-Recurse)/i, 'Recursive delete blocked. Ask the user to confirm the exact path and run it themselves.'],
  [/\b(netsh|New-NetFirewallRule|Set-NetFirewall|Install-Service|sc\.exe\s+(create|config)|mariadbd(\.exe)?\s+--install)/i, 'Firewall/service changes are done by the user in an admin shell; give steps instead.'],
  [/\b(curl|wget|Invoke-WebRequest|iwr)\b[^\n|]*\|\s*(sh|bash|iex|Invoke-Expression)/i, 'Piping downloads into a shell is forbidden.'],
  [/(\.mpq|WoW\.exe|Data[\\\/]\w+\.MPQ)[^\n]*\b(git\s+add|git\s+commit)/i, 'Blizzard client files must never be committed.']
];

for (const [re, msg] of rules) {
  if (re.test(cmd)) {
    process.stderr.write(`BLOCKED by guard-bash: ${msg}\nCommand: ${cmd.slice(0, 200)}\n`);
    process.exit(2);
  }
}
process.exit(0);
