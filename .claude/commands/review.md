---
description: Review pending changes against project guardrails before commit
---
1. `git status --short` and `git diff --stat` (read-only). Ignore `src/shared/Progression.h` (skip-worktree/generated).
2. Check every changed path against `.claude/rules/*.md`: secrets, upstream-owned files, game assets, ID range, rollback present, config-gated C++.
3. Run `node custom/scripts/check-custom-sql.mjs`.
4. Output: PASS/FAIL per rule, exact files to stage (`git add <paths>`), a suggested commit message. Do not commit.
