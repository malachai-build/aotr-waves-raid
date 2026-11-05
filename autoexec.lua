-- Matcha autoexec entrypoint. Download and spawn before this chunk yields.
if game.PlaceId == 0 or game.PlaceId == 14638336319 or game.PlaceId == 14916516914 then return end
if game.GameId ~= 0 and game.GameId ~= 4658598196 then return end
if not isfolder("aotr") then makefolder("aotr") end

local source = game:HttpGet("https://raw.githubusercontent.com/malachai-build/aotr-waves-raid/a081d1d3a660f6175dddfee9dfd56da8610aa46c/autofarmraids.lua")
if type(source) ~= "string" or #source < 150000 then
  warn("[AoTR Waves/Raid] source download failed")
  return
end

task.spawn(loadstring(source, "autofarmraids.lua"))
