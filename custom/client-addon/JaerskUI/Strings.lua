-- Strings.lua - Jærsk-tekster for quest-vinduene. UTKAST: Faiz retter.
-- Rediger bare teksten mellom anførselstegnene. Engelsk original står som kommentar.
-- Behold %s, %d og |cffffffff ... |r uendret der de står.

-- 1) Globale strenger (brukes også når spillet bygger tekst mens du spiller)
JAERSK_GLOBALS = {
  QUEST_DESCRIPTION       = "Ka dæ gjeld",                 -- Description
  QUEST_OBJECTIVES        = "Ka du må gjera",              -- Quest Objectives
  QUEST_REWARDS           = "Løn",                         -- Rewards
  REWARD_CHOICES          = "Du kan velja ein av desse:",  -- You will be able to choose one of these rewards:
  REWARD_CHOOSE           = "Velj løna di:",               -- Choose your reward:
  REWARD_ITEMS            = "Du får også:",                -- You will also receive:
  REWARD_ITEMS_ONLY       = "Du får:",                     -- You will receive:
  REWARD_SPELL            = "Du lærer:",                   -- You will learn:
  REWARD_TRADESKILL_SPELL = "Du lærer å laga:",            -- You will learn how to create:
  TURN_IN_ITEMS           = "Dæ du må ha med:",            -- Required items:
  REQUIRED_MONEY          = "Du må ha pengar:",            -- Required Money:
  CURRENT_QUESTS          = "Oppdrag du held på med",      -- Current Quests
  AVAILABLE_QUESTS        = "Oppdrag du kan ta",           -- Available Quests
  ABANDON_QUEST           = "Gi opp",                      -- Abandon Quest
  SHARE_QUEST             = "Del oppdrag",                 -- Share Quest
  TRACK_QUEST             = "Fylg oppdrag",                -- Track Quest
  QUEST_LOG               = "Oppdragsbok",                 -- Quest Log
  QUESTLOG_BUTTON         = "Oppdragsbok",                 -- Quest Log (knapp)
  QUESTLOG_NO_QUESTS_TEXT = "Ingen oppdrag",               -- No Active Quests
  QUEST_LOG_COUNT_TEMPLATE = "Oppdrag: |cffffffff%d/%d|r", -- Quests: 1/20
  QUEST_MONSTERS_KILLED   = "%s drepe: %d/%d",             -- %s slain: %d/%d
  QUEST_COMPLETE          = "Oppdrag ferdig",              -- Quest completed
  QUEST_FAILED_TAG        = "- Mislukka",                  -- - Failed
  ERR_QUEST_ACCEPTED_S    = "Oppdrag tatt: %s",            -- Quest accepted: %s
  ERR_QUEST_COMPLETE_S    = "%s ferdig.",                  -- %s completed.
  ERR_QUEST_REWARD_EXP_I  = "Erfaring: %d.",               -- Experience gained: %d.
}

-- 2) Elementer som får tekst satt rett på knappen eller etiketten
--    (navnet er elementets navn i quest-vinduet; verdien er teksten)
JAERSK_WIDGETS = {
  -- Quest-loggen
  QuestLogCollapseAllButton   = "Alle",          -- All
  QuestLogFrameAbandonButton  = "Gi opp",        -- Abandon Quest
  QuestFramePushQuestButton   = "Del oppdrag",   -- Share Quest
  QuestFrameExitButton        = "Gå ut",         -- Exit
  -- Samtalevinduet med NPC-en
  QuestFrameAcceptButton        = "Ta imot",       -- Accept
  QuestFrameDeclineButton       = "Nei takk",      -- Decline
  QuestFrameCompleteButton      = "Fortsett",      -- Continue
  QuestFrameCompleteQuestButton = "Lever inn",     -- Complete Quest
  QuestFrameGoodbyeButton       = "Avbryt",        -- Cancel
  QuestFrameCancelButton        = "Avbryt",        -- Cancel
  QuestFrameGreetingGoodbyeButton = "Ha dæ bra",   -- Goodbye
  GossipFrameGreetingGoodbyeButton = "Ha dæ bra", -- Goodbye (samtale med trener/NPC)
}

-- 3) Faste overskrifter som leser en global streng når vinduet lages.
--    Navn på etikett -> nøkkel i JAERSK_GLOBALS.
JAERSK_LABELS = {
  QuestLogTitleText            = "QUEST_LOG",
  QuestLogTrackTitle           = "TRACK_QUEST",
  QuestLogNoQuestsText         = "QUESTLOG_NO_QUESTS_TEXT",
  QuestLogRequiredMoneyText    = "REQUIRED_MONEY",
  QuestLogDescriptionTitle     = "QUEST_DESCRIPTION",
  QuestLogRewardTitleText      = "QUEST_REWARDS",
  QuestLogItemChooseText       = "REWARD_CHOICES",
  QuestRewardRewardTitleText   = "QUEST_REWARDS",
  QuestRewardItemChooseText    = "REWARD_CHOOSE",
  QuestProgressRequiredItemsText = "TURN_IN_ITEMS",
  QuestProgressRequiredMoneyText = "REQUIRED_MONEY",
  QuestDetailObjectiveTitleText  = "QUEST_OBJECTIVES",
  QuestDetailRewardTitleText     = "QUEST_REWARDS",
  QuestDetailItemChooseText      = "REWARD_CHOICES",
  CurrentQuestsText            = "CURRENT_QUESTS",
  AvailableQuestsText          = "AVAILABLE_QUESTS",
}
