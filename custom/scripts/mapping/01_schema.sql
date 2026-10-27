-- READ ONLY. Sprint 0 step 0: confirm schema.
SELECT 'patch distribution' AS info;
SELECT patch, COUNT(*) AS n FROM quest_template GROUP BY patch ORDER BY patch;
DESCRIBE quest_template;
DESCRIBE creature_template;
DESCRIBE creature_questrelation;
DESCRIBE creature_involvedrelation;
DESCRIBE creature;
SHOW FULL COLUMNS FROM quest_template;
SHOW TABLES LIKE '%text%';
SHOW TABLES LIKE '%gossip%';
SHOW TABLES LIKE '%sound%';
SHOW TABLES LIKE '%locale%';
SHOW TABLES LIKE '%script%';
