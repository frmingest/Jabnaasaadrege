-- Purpose: Jaersk quest text overrides (insert-only copies with patch = 10)
-- Server/Client: server only (text); audio needs client patch
-- Tables: quest_template
-- Id-range: n/a (reuses upstream entry ids 788; rows are patch = 10, originals untouched)
START TRANSACTION;
DELETE FROM quest_template WHERE entry IN (788) AND patch = 10;
COMMIT;
