-- READ ONLY. Greeting/gossip text chain for the 31 in-scope NPCs.
SELECT ct.entry, ct.name, ct.gossip_menu_id, gm.text_id,
       nt.BroadcastTextID0, bt.male_text, bt.sound_id
FROM creature_template ct
JOIN (SELECT entry, MAX(patch) AS mp FROM creature_template WHERE patch <= 10 GROUP BY entry) m
  ON m.entry = ct.entry AND m.mp = ct.patch
LEFT JOIN gossip_menu gm ON gm.entry = ct.gossip_menu_id
LEFT JOIN npc_text nt ON nt.ID = gm.text_id
LEFT JOIN broadcast_text bt ON bt.entry = nt.BroadcastTextID0
WHERE ct.entry IN (1992,2077,2079,2082,2150,3143,3145,3153,3154,3155,3156,3157,3287,3514,3593,3594,3595,3596,3597,3707,5765,5884,5887,5891,6780,8583,9796,10176,11378,11942,11943)
ORDER BY ct.entry;
