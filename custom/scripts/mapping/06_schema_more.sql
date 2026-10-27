-- READ ONLY. Tables needed for texts, sounds and quest scripts.
DESCRIBE quest_start_scripts;
DESCRIBE quest_end_scripts;
DESCRIBE sound_entries;
DESCRIBE broadcast_text;
DESCRIBE npc_text;
DESCRIBE gossip_menu;
DESCRIBE locales_quest;
SELECT MAX(entry) AS max_quest_entry FROM quest_template;
SELECT * FROM sound_entries ORDER BY id DESC LIMIT 5;
