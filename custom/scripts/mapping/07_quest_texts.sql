-- READ ONLY. Full original text of the 55 in-scope quests (effective row = highest patch <= 10).
SELECT q.entry, q.patch, q.Title, q.Details, q.Objectives, q.OfferRewardText, q.RequestItemsText, q.EndText,
       q.ObjectiveText1, q.ObjectiveText2, q.ObjectiveText3, q.ObjectiveText4
FROM quest_template q
JOIN (SELECT entry, MAX(patch) AS mp FROM quest_template WHERE patch <= 10 GROUP BY entry) m
  ON m.entry = q.entry AND m.mp = q.patch
WHERE q.entry IN (456,457,458,459,488,787,788,789,790,792,794,804,805,916,917,920,921,928,1463,1485,1499,1516,1517,1518,1520,1521,2159,2383,3065,3082,3083,3084,3085,3086,3087,3088,3089,3090,3116,3117,3118,3119,3120,3519,3521,3522,4402,4495,4641,5441,5622,5649,5842,5843,6394)
ORDER BY q.entry;
