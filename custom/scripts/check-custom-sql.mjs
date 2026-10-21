// Lints custom/sql/*.sql against .claude/rules/custom-sql.md
// Usage: node custom/scripts/check-custom-sql.mjs [file.sql ...]   (no args = all files)
import { readFileSync, readdirSync, existsSync } from 'node:fs';
import { resolve, dirname, basename, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const sqlDir = resolve(here, '../sql');
const { lo: LO, hi: HI } = JSON.parse(readFileSync(join(sqlDir, 'reserved-ranges.json'), 'utf8'));

const args = process.argv.slice(2);
const files = (args.length ? args.map((a) => resolve(a)) : readdirSync(sqlDir).map((f) => join(sqlDir, f)))
  .filter((f) => /\.sql$/.test(f));

let errors = 0;
const err = (f, m) => { errors++; console.log(`ERROR ${basename(f)}: ${m}`); };

const stripComments = (s) => s.replace(/\/\*[\s\S]*?\*\//g, '').replace(/^\s*--.*$/gm, '').replace(/#.*$/gm, '');

for (const f of files) {
  const name = basename(f);
  if (!existsSync(f)) { err(f, 'file not found'); continue; }
  if (!/^\d{4}_[a-z0-9_]+(\.rollback)?\.sql$/.test(name)) { err(f, 'name must be NNNN_snake_case.sql or NNNN_snake_case.rollback.sql'); continue; }
  const isRollback = name.endsWith('.rollback.sql');
  const raw = readFileSync(f, 'utf8');
  const code = stripComments(raw);

  if (!isRollback) {
    for (const h of ['Purpose', 'Server/Client', 'Tables', 'Id-range']) {
      if (!new RegExp(`^--\\s*${h}\\s*:\\s*\\S`, 'mi').test(raw)) err(f, `missing header "-- ${h}:"`);
    }
    const m = raw.match(/^--\s*Id-range\s*:\s*(\d+)\s*-\s*(\d+)/mi);
    if (m) {
      const a = Number(m[1]), b = Number(m[2]);
      if (a > b) err(f, 'Id-range lo > hi');
      if (a < LO || b > HI) err(f, `Id-range ${a}-${b} is outside reserved ${LO}-${HI}`);
    }
    const rb = join(sqlDir, name.replace(/\.sql$/, '.rollback.sql'));
    if (!existsSync(rb)) err(f, `missing rollback file ${basename(rb)}`);
  }

  if (!/^\s*START\s+TRANSACTION\s*;/i.test(code)) err(f, 'must begin with START TRANSACTION;');
  if (!/\bCOMMIT\s*;\s*$/i.test(code.trim())) err(f, 'must end with COMMIT;');
  if (/\bDROP\s+(DATABASE|TABLE|SCHEMA|INDEX|COLUMN)\b/i.test(code)) err(f, 'DROP is not allowed');
  if (/\bTRUNCATE\b/i.test(code)) err(f, 'TRUNCATE is not allowed');
  if (/\b(ALTER|CREATE)\s+(TABLE|DATABASE|USER)\b/i.test(code)) err(f, 'schema/user changes are not allowed in content SQL');
  if (/\bGRANT\b|\bSET\s+PASSWORD\b|\bCREATE\s+USER\b/i.test(code)) err(f, 'privilege statements are not allowed');
  for (const stmt of code.split(';')) {
    if (/^\s*(DELETE\s+FROM|UPDATE)\b/i.test(stmt) && !/\bWHERE\b/i.test(stmt)) err(f, `unscoped statement: ${stmt.trim().slice(0, 60)}`);
    if (/^\s*(DELETE\s+FROM|UPDATE)\b/i.test(stmt) && /\bWHERE\b/i.test(stmt) && !/\b(BETWEEN|IN\s*\(|>=|<=|=)\s*\d{7}/i.test(stmt) && !isRollback) {
      err(f, `DELETE/UPDATE must be scoped to the reserved id range (${LO}-${HI}): ${stmt.trim().slice(0, 60)}`);
    }
  }
}
if (errors) { console.log(`\n${errors} problem(s).`); process.exit(1); }
console.log(`custom SQL OK (${files.length} file(s) checked)`);
