-- Matcha autoexec entrypoint. Download and spawn before this chunk yields.
-- Main menu, lobby and trade hub must clear the previous mission's beat.
-- "unloaded" also works when the watcher's configured lobby ID is different.
if game.PlaceId == 13379208636 or game.PlaceId == 14916516914 or game.PlaceId == 14932214603 then
  if not isfolder("aotr") then makefolder("aotr") end
  writefile("aotr/heartbeat.txt", "unloaded " .. os.date("%H:%M:%S"))
  return
end
if game.GameId ~= 0 and game.GameId ~= 4658598196 then return end
-- Feature set is selected by the user's loadstring, not by the map.
if not isfolder("aotr") then makefolder("aotr") end

local source = game:HttpGet("https://raw.githubusercontent.com/malachai-build/aotr-waves-raid/34467575564a4ad62c9eceefc57f99bcde4f152e/autofarmraids.lua")
if type(source) ~= "string" or #source < 150000 then
  warn("[AoTR Waves/Raid] source download failed")
  return
end

task.spawn(loadstring(source, "autofarmraids.lua"))
