// PreToolUse(Write|Edit): deny protected files, ask before touching upstream-owned areas.
import { readFileSync } from 'node:fs';

let input = {};
try { input = JSON.parse(readFileSync(0, 'utf8')); } catch { process.exit(0); }
const raw = String(input?.tool_input?.file_path ?? '');
const p = raw.replace(/\\/g, '/');
const content = String(input?.tool_input?.content ?? input?.tool_input?.new_string ?? '');

const deny = (msg) => { process.stderr.write(`BLOCKED by guard-edit: ${msg}\nFile: ${raw}\n`); process.exit(2); };
const ask = (msg) => {
  process.stdout.write(JSON.stringify({ hookSpecificOutput: { hookEventName: 'PreToolUse', permissionDecision: 'ask', permissionDecisionReason: msg } }));
  process.exit(0);
};

if (/(^|\/)\.git\//.test(p)) deny('Do not edit .git internals.');
if (/\.dbpass$/i.test(p) || /(^|\/)(mangosd|realmd)\.conf$/i.test(p)) deny('Secret/config file. The user edits these by hand.');
if (/(^|\/)src\/shared\/(Progression|revision|migrations_list)\.h$/.test(p)) deny('Generated header (CMake rewrites it). Never edit.');
if (/\.(mpq|dbc|m2|blp|wmo|adt|wdt)$/i.test(p)) deny('Game assets are not stored in this repo.');

// Secret-looking content going into tracked docs/scripts
if (/(password|passwd|pwd|secret|token)\s*[:=]\s*['"]?[A-Za-z0-9!@#$%^&*_\-]{8,}/i.test(content) && !/\bplaceholder|example|<[^>]+>|\$env:|\$\{?\w+\}?/i.test(content)) {
  deny('Content looks like it contains a credential. Use an env var or prompt instead.');
}

if (/(^|\/)sql\/(?!.*custom)/.test(p) && !/(^|\/)custom\/sql\//.test(p)) ask('Editing upstream sql/ (migrations). Put custom changes in custom/sql/ instead. Continue?');
if (/(^|\/)(src|dep|cmake)\//.test(p)) ask('Editing upstream-owned core code. See .claude/rules/cpp-core.md: prefer DB scripting, config-gated, minimal diff. Continue?');
process.exit(0);
