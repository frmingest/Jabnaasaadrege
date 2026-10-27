-- READ ONLY. Quests given or completed by NPCs that spawn near Valley of Trials or Shadowglen (map 1).
-- Effective row per quest = highest patch <= 10. "patches" lists all patch rows that exist.
-- Centers are approximate; radius 400 is a guess.
SET @vot_x = -600, @vot_y = -4200, @sg_x = 10300, @sg_y = 800, @radius = 400;
SELECT q.entry, q.patch AS used_patch,
       (SELECT GROUP_CONCAT(patch ORDER BY patch) FROM quest_template WHERE entry = q.entry AND patch <= 10) AS patches,
       q.Title, q.MinLevel, q.QuestLevel, q.RequiredRaces, q.ZoneOrSort,
       q.PrevQuestId, q.NextQuestId, q.ExclusiveGroup, q.StartScript, q.CompleteScript,
       CHAR_LENGTH(q.Details) AS len_details, CHAR_LENGTH(q.Objectives) AS len_objectives,
       CHAR_LENGTH(q.OfferRewardText) AS len_offerreward, CHAR_LENGTH(q.RequestItemsText) AS len_requestitems,
       CHAR_LENGTH(q.EndText) AS len_endtext
FROM (
  SELECT r.quest
    FROM creature_questrelation r
    JOIN (SELECT DISTINCT id FROM creature
           WHERE map = 1 AND patch_min <= 10 AND patch_max >= 10
             AND ((POW(position_x - @vot_x, 2) + POW(position_y - @vot_y, 2)) < POW(@radius, 2)
               OR (POW(position_x - @sg_x, 2) + POW(position_y - @sg_y, 2)) < POW(@radius, 2))) n ON n.id = r.id
   WHERE r.patch_min <= 10 AND r.patch_max >= 10
  UNION
  SELECT r.quest
    FROM creature_involvedrelation r
    JOIN (SELECT DISTINCT id FROM creature
           WHERE map = 1 AND patch_min <= 10 AND patch_max >= 10
             AND ((POW(position_x - @vot_x, 2) + POW(position_y - @vot_y, 2)) < POW(@radius, 2)
               OR (POW(position_x - @sg_x, 2) + POW(position_y - @sg_y, 2)) < POW(@radius, 2))) n ON n.id = r.id
   WHERE r.patch_min <= 10 AND r.patch_max >= 10
) rel
JOIN (SELECT entry, MAX(patch) AS mp FROM quest_template WHERE patch <= 10 GROUP BY entry) m ON m.entry = rel.quest
JOIN quest_template q ON q.entry = m.entry AND q.patch = m.mp
ORDER BY q.ZoneOrSort, q.QuestLevel, q.entry;
