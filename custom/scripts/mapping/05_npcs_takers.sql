-- READ ONLY. NPCs that RECEIVE (complete) quests, near the two start areas.
SET @vot_x = -600, @vot_y = -4200, @sg_x = 10300, @sg_y = 800, @radius = 400;
SELECT 'takes' AS role, ct.entry AS npc_entry, ct.patch AS npc_patch, ct.name, ct.subname,
       ct.level_min, ct.level_max, ct.npc_flags, ct.gossip_menu_id,
       c.guid, c.map, ROUND(c.position_x) AS x, ROUND(c.position_y) AS y,
       r.quest, q.Title,
       IF((POW(c.position_x - @vot_x, 2) + POW(c.position_y - @vot_y, 2)) < POW(@radius, 2), 'valley_of_trials', 'shadowglen') AS area
FROM creature_involvedrelation r
JOIN creature c ON c.id = r.id AND c.patch_min <= 10 AND c.patch_max >= 10 AND c.map = 1
JOIN creature_template ct ON ct.entry = r.id AND ct.patch = (SELECT MAX(patch) FROM creature_template WHERE entry = r.id AND patch <= 10)
JOIN quest_template q ON q.entry = r.quest AND q.patch = (SELECT MAX(patch) FROM quest_template WHERE entry = r.quest AND patch <= 10)
WHERE r.patch_min <= 10 AND r.patch_max >= 10
  AND ((POW(c.position_x - @vot_x, 2) + POW(c.position_y - @vot_y, 2)) < POW(@radius, 2)
    OR (POW(c.position_x - @sg_x, 2) + POW(c.position_y - @sg_y, 2)) < POW(@radius, 2))
ORDER BY area, ct.entry, r.quest;
