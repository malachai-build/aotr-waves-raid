-- Exercise the production character cache and alive check with retained dead bodies.
local source = readfile("aotr/autofarm_branch.lua")
local a = assert(string.find(source, "local function GetCharacter(", 1, true))
local b = assert(string.find(source, "local function GetTitanHrp(", a, true))
local header = [====[
local LocalPlayer = {Address=1}
local CharacterCache = {[1]={}}
local function IsValid(object) return object and object.Parent end
local function body(address, health)
  local c = {Address=address,Parent=true}
  local h = {Parent=c,Health=health}
  local root = {Parent=c}
  function c:FindFirstChildOfClass(_) return h end
  function c:FindFirstChild(_) return root end
  return c,h,root
end
]====]
local checks = [====[
local old,hum = body(2,100)
LocalPlayer.Character=old
assert(IsLocalAlive(),"living character allowed")
hum.Health=0
assert(not IsLocalAlive(),"retained body with zero HP must stop combat")
hum.Health=-129.2
assert(not IsLocalAlive(),"negative HP must stop combat")
LocalPlayer.Character=nil
assert(not IsLocalAlive(),"missing character must not reuse old body")
assert(CharacterCache[1].Character==nil and CharacterCache[1].Humanoid==nil and CharacterCache[1].Hrp==nil,"clear respawn gap cache")
local fresh,freshHum,root=body(3,100)
LocalPlayer.Character=fresh
assert(IsLocalAlive(),"respawn resumes with fresh humanoid")
assert(CharacterCache[1].Humanoid==freshHum,"old humanoid must not be reused")
root.Parent=nil
assert(not IsLocalAlive(),"missing root blocks combat")
print("PASS: health zero/negative, retained corpse, character removal, respawn cache, missing root")
]====]
assert(loadstring(header .. string.sub(source,a,b-1) .. checks,"character_health_fixtures"))()
