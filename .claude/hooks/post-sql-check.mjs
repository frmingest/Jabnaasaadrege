// PostToolUse(Write|Edit): lint custom SQL right after it is written. Exit 2 feeds errors back to Claude.
import { readFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

let input = {};
try { input = JSON.parse(readFileSync(0, 'utf8')); } catch { process.exit(0); }
const p = String(input?.tool_input?.file_path ?? '').replace(/\\/g, '/');
if (!/(^|\/)custom\/sql\/[^/]+\.sql$/.test(p)) process.exit(0);

const here = dirname(fileURLToPath(import.meta.url));
const checker = resolve(here, '../../custom/scripts/check-custom-sql.mjs');
const r = spawnSync(process.execPath, [checker, p], { encoding: 'utf8' });
if (r.status !== 0) {
  process.stderr.write(`custom SQL check failed:\n${r.stdout}${r.stderr}`);
  process.exit(2);
}
process.exit(0);
