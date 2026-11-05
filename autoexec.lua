-- Matcha autoexec entrypoint. Download and spawn before this chunk yields.
if game.PlaceId == 14638336319 or game.PlaceId == 14916516914 then return end
if game.GameId ~= 0 and game.GameId ~= 4658598196 then return end
if not isfolder("aotr") then makefolder("aotr") end

local source = game:HttpGet("https://raw.githubusercontent.com/malachai-build/aotr-waves-raid/6eed69f18a860ea055ea08877c0a636beb80a225/autofarmraids.lua")
if type(source) ~= "string" or #source < 150000 then
  warn("[AoTR Waves/Raid] source download failed")
  return
end

task.spawn(loadstring(source, "autofarmraids.lua"))
