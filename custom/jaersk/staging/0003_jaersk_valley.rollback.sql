-- Purpose: Jaersk quest text overrides (insert-only copies with patch = 10)
-- Server/Client: server only (text); audio needs client patch
-- Tables: quest_template
-- Id-range: n/a (reuses upstream entry ids 787, 789, 790, 792, 794, 804, 805, 1463, 1485, 1499, 1516, 1517, 1518, 2383, 3065, 3082, 3083, 3084, 3085, 3086, 3087, 3088, 3089, 3090, 4402, 4641, 5441, 5649, 5843, 6394; rows are patch = 10, originals untouched)
START TRANSACTION;
DELETE FROM quest_template WHERE entry IN (787, 789, 790, 792, 794, 804, 805, 1463, 1485, 1499, 1516, 1517, 1518, 2383, 3065, 3082, 3083, 3084, 3085, 3086, 3087, 3088, 3089, 3090, 4402, 4641, 5441, 5649, 5843, 6394) AND patch = 10;
COMMIT;
