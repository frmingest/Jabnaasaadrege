-- JaerskUI.lua - bytter ut engelske overskrifter og knapper i quest-vinduene med tekstene i Strings.lua.
-- Rører ingen Blizzard-filer. Skrevet for 1.12.1 (Lua 5.0): bruker getglobal/setglobal og this/event.

local function JaerskApply()
  -- 1) globale strenger
  for key, text in pairs(JAERSK_GLOBALS) do
    setglobal(key, text)
  end
  -- 2) knapper og elementer satt direkte
  for name, text in pairs(JAERSK_WIDGETS) do
    local w = getglobal(name)
    if w and w.SetText then w:SetText(text) end
  end
  -- 3) faste overskrifter
  for name, key in pairs(JAERSK_LABELS) do
    local w = getglobal(name)
    if w and w.SetText and JAERSK_GLOBALS[key] then w:SetText(JAERSK_GLOBALS[key]) end
  end
end

JaerskApply()

local f = CreateFrame("Frame", "JaerskUIFrame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
  JaerskApply()
end)
