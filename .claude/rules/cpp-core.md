# Rule: C++ core changes

- Default answer is **no C++**: try DB scripting first (`creature_spells`, `creature_ai_events`, `creature_ai_scripts`, script tables).
- If C++ is unavoidable: smallest possible diff, match surrounding style (`.clang-format`, `.editorconfig`: 4 spaces, no tabs, LF-tolerant), put custom behaviour behind a **config option defaulting to off** (add to `mangosd.conf.dist.in` style), and mark custom blocks with `// CUSTOM(jabnaasaadrege): reason`.
- Prefer new files under `src/game/` custom subfolder or hooks over rewriting upstream functions — keeps upstream merges clean.
- Never edit generated headers: `src/shared/Progression.h`, `revision.h`, `migrations_list.h`.
- Always state the thread-safety / performance impact if the code runs in the world update loop.
- Build only via `custom/scripts/build.ps1`. Do not pass `-DPREFIX` to CMake. Extractor flag is `BUILD_EXTRACTORS`. 64-bit only.
- After a core change: note it in `decisions.md` (what, why, upstream-merge risk).
