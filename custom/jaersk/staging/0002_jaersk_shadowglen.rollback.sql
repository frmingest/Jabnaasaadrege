-- Purpose: Jaersk quest text overrides (insert-only copies with patch = 10)
-- Server/Client: server only (text); audio needs client patch
-- Tables: quest_template
-- Id-range: n/a (reuses upstream entry ids 456, 457, 458, 459, 488, 916, 917, 920, 921, 928, 2159, 3116, 3117, 3118, 3119, 3120, 3519, 3521, 3522, 4495, 5622, 5842; rows are patch = 10, originals untouched)
START TRANSACTION;
DELETE FROM quest_template WHERE entry IN (456, 457, 458, 459, 488, 916, 917, 920, 921, 928, 2159, 3116, 3117, 3118, 3119, 3120, 3519, 3521, 3522, 4495, 5622, 5842) AND patch = 10;
COMMIT;
