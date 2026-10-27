-- READ ONLY. Gossip options and text chain details for in-scope NPCs.
DESCRIBE gossip_menu_option;
DESCRIBE locales_gossip_menu_option;
SHOW TABLES LIKE '%train%';
SHOW TABLES LIKE '%greeting%';
SHOW TABLES LIKE '%vendor%';
-- options per menu
SELECT * FROM gossip_menu_option WHERE menu_id IN (64,141,523,2910,3644,4046,4643,4648,4652,4688,4690,4691,4695,4696) ORDER BY menu_id, id;
-- every text row in the menus (all texts, not just the first)
SELECT gm.entry AS menu, gm.text_id, gm.condition_id,
       nt.BroadcastTextID0, nt.BroadcastTextID1, nt.BroadcastTextID2, nt.BroadcastTextID3,
       nt.BroadcastTextID4, nt.BroadcastTextID5, nt.BroadcastTextID6, nt.BroadcastTextID7
FROM gossip_menu gm LEFT JOIN npc_text nt ON nt.ID = gm.text_id
WHERE gm.entry IN (64,141,523,2910,3644,4046,4643,4648,4652,4688,4690,4691,4695,4696) ORDER BY gm.entry, gm.text_id;
-- NPC name, subname (shows under the name), flags, key columns
SELECT ct.entry, ct.patch, ct.name, ct.subname, ct.npc_flags, ct.gossip_menu_id, ct.trainer_id
FROM creature_template ct
JOIN (SELECT entry, MAX(patch) AS mp FROM creature_template WHERE patch <= 10 GROUP BY entry) m
  ON m.entry = ct.entry AND m.mp = ct.patch
WHERE ct.entry IN (1992,2077,2079,2082,2150,3143,3145,3153,3154,3155,3156,3157,3287,3514,3593,3594,3595,3596,3597,3707,5765,5884,5887,5891,6780,8583,9796,10176,11378,11942,11943) ORDER BY ct.entry;
