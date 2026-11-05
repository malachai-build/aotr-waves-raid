-- Run in Matcha after staging the source at aotr/autofarm_branch.lua.
-- Tests extract production functions so the fixtures exercise the actual controller.
local source = readfile("aotr/autofarm_branch.lua")
local function section(first, last)
  local a = assert(string.find(source, first, 1, true))
  local b = assert(string.find(source, last, a, true))
  return string.sub(source, a, b - 1)
end
local header = [====[

local Stats = { Colossal = { LastShot = -math.huge, RetryAt = 0, Opened = false } }
local function node(name, children, value)
 local t={Name=name,ClassName="Model",Value=value,Parent=true,Address=math.random(1000,1000000)}
 function t:FindFirstChild(k) return (children or {})[k] end
 function t:GetAttribute(k) return self[k] end
 return t
end
local erenRoot={Position=Vector3.new(0,80,0)}
local collider={Position=Vector3.new(0,0,0)}
local eren=node("Attack_Titan",{HumanoidRootPart=erenRoot})
local erenHp=node("Health",nil,50)
local bossHp=node("Health",nil,1000)
local objective=node("Objective",{Defend_Eren_2=node("Defend_Eren_2",{Reference=node("Reference",nil,eren),Collider=collider,Health=erenHp}),Colossal_Boss=node("Colossal_Boss",{Health=bossHp})})
local Workspace=node("Workspace",{Unclimbable=node("Unclimbable",{Objective=objective})})
local function GetPath(root, _, ...) for _, k in ipairs({...}) do root=root and root:FindFirstChild(k) end return root end
local game={PlaceId=13379349730}
local nearPlayer=node("near player",{HumanoidRootPart={Position=Vector3.new(990,20,0)}})
local nearEren=node("near Eren",{HumanoidRootPart={Position=Vector3.new(40,20,0)}})
local colossal=node("Colossal_Titan",{HumanoidRootPart={Position=Vector3.new(1,20,0)}})
local KnownTitans={nearPlayer,nearEren,colossal,eren}
local TitansFolder=node("Titans",{Colossal_Titan=colossal})
local LocalPlayer={Name="test"}
local UserConfigs={ColossalDangerRadius=180}
local function GetPlayerHrp(_) return {Position=Vector3.new(1000,20,0)} end
local function GetTitanHrp(t) return t:FindFirstChild("HumanoidRootPart") end
local function IsTitanAlive(t) return t.Parent ~= nil end
local function IsTitanIgnored(_) return false end
local function DebugPrint(...) end
local LastNearestUpdate=-math.huge
local CachedNearestTitan
]====]
local skillHeader = [====[

-- Hidden cooldown labels retain their old number. Opening must still tap ready skills.
local tapped = {}
local task = { wait = function() end }
local Qte = { Active = false }
local function Stopped() return false end
local function IsLocalAlive() return true end
local function isrbxactive() return true end
local function Boot(_) end
local function TapKey(vk) tapped[#tapped + 1] = vk end
local function KeyToVk(text) return tonumber(text) and 48 + tonumber(text) end
local function IsObjectVisible(t) return t.Visible == true end
UserConfigs.Autofarm = true
UserConfigs.HumanSkills = true
UserConfigs.AwakeningSlot = 1
Stats.HumanSkills = { AwakeningActive = false }
Stats.CutsceneSkip = { Visible = false }
function LocalPlayer:GetAttribute(_) return nil end
local slots = {}
for i=1,5 do
  local label = {Text="90s"}
  local cooldown = node("Cooldown", {Label=label}); cooldown.Visible=false
  slots["Skill_" .. i] = node("Skill_" .. i, {Cooldown=cooldown,Key=node("Key",{Key={Text=tostring(i)}})})
end
local Interface=node("Interface",{HUD=node("HUD",{Main=node("Main",{Top=node("Top",{["7"]=node("7",{Hotbar=node("Hotbar",slots)})})})})})
]====]
local checks = [====[
local _, origin=GetDefenseEren()
assert(origin==collider,"use Eren's ground collider")
assert(GetNearestTitan().Name=="near Eren","prioritize ground attacker and exclude colossal from swords")
assert(not Stats.Colossal.ShouldCannon(),"first allow ground defense while Eren threatened")
Stats.Colossal.DefenseCredit=true
assert(Stats.Colossal.ShouldCannon(),"ground kill permits ready cannon shot")
Stats.Colossal.DefenseCredit=false
Stats.Colossal.DueSince=os.clock()-1.1
assert(Stats.Colossal.ShouldCannon(),"continuous attackers cannot starve cannon")
erenHp.Value=10
assert(not Stats.Colossal.ShouldCannon(),"Eren emergency overrides cannon")
erenHp.Value=50
Stats.Colossal.Health,Stats.Colossal.HealthAt,Stats.Colossal.LastDamage=nil,nil,nil
nearEren.Parent=nil;LastNearestUpdate=-math.huge
assert(GetNearestTitan().Name=="near player","colossal never becomes sword fallback")
assert(Stats.Colossal.ShouldCannon(),"clear Eren area permits cannon")
Stats.Colossal.LastShot=os.clock();Stats.Colossal.Cooldown=2.7
assert(not Stats.Colossal.ShouldCannon(),"respect confirmed shot cooldown")
Stats.Colossal.LastShot=-math.huge
Stats.Colossal.Cannon=node("Cannon");Stats.Colossal.Cannon.Cooldown=2
assert(not Stats.Colossal.ShouldCannon(),"respect native remaining cooldown")
Stats.Colossal.Cannon.Cooldown=0.5
assert(Stats.Colossal.ShouldCannon(),"prepare shortly before cooldown ends")
erenHp.Value=0
assert(not Stats.Colossal.Active(),"stop when Eren dies")
erenHp.Value=50;bossHp.Value=0
assert(not Stats.Colossal.Active(),"stop when boss objective completes")
print("PASS: cannon scheduler, ground sword priority, colossal exclusion, emergency and cooldown gates")
]====]
local code = header
  .. section("function Stats.Colossal.Path(", "-- Raid bosses (the Female")
  .. section("local function GetDefenseEren()", "local function TpAboveTitan(")
  .. section("function Stats.Colossal.Active()", "-- Each ready raid skill")
  .. section("function Stats.Colossal.Danger()", "function Stats.Colossal.FindCannon()")
  .. section("function Stats.Colossal.Evaluate(", "function Stats.Colossal.SolveAim(")
  .. [====[
local origin={X=0,Y=500,Z=0}
local boxes={{name="Head",x=900,y=600,z=0,hx=30,hy=30,hz=30},
  {name="UpperTorso",x=900,y=480,z=0,hx=75,hy=100,hz=60}}
local plan=Stats.Colossal.Plan(origin,boxes,0)
assert(plan and plan.margin>=12,"choose a safe body path when reachable")
local actual=Stats.Colossal.Evaluate(origin,boxes,plan.yaw,plan.pitch,nil,plan.part)
assert(actual.margin>=12,"planned shot intersects the target interior")
local near=Stats.Colossal.Plan(origin,{{name="Head",x=200,y=500,z=0,hx=30,hy=30,hz=30}},0)
assert(near and near.pitch<plan.pitch,"lower elevation as titan approaches")
local impossible=Stats.Colossal.Plan(origin,{{name="Head",x=1800,y=700,z=0,hx=20,hy=20,hz=20}},0)
assert(not impossible or impossible.margin<8,"reject unreachable arcs instead of firing blind")
print("PASS: measured ballistic arc, head preference, near-range lowering, unreachable-shot rejection")
]====]
  .. checks
  .. skillHeader
  .. [====[
local function keypress(vk) tapped[#tapped+1]=vk end
local function keyrelease(_) end
]====]
  .. section("function Stats.Colossal.UseReadySkills()", "-- Cannon / Eren defense scheduler.")
  .. [====[
assert(Stats.Colossal.UseReadySkills())
assert(#tapped==5 and tapped[1]==49 and tapped[5]==53,"all five ready skills tapped in one scan")
Stats.Colossal.SkillScanAt=-math.huge
Stats.Colossal.UseReadySkills()
assert(#tapped==5,"per-slot debounce prevents input spam")
Stats.Colossal.SkillScanAt=-math.huge
Stats.Colossal.SkillTaps={}
slots.Skill_3:FindFirstChild("Cooldown").Visible=true
Stats.Colossal.UseReadySkills()
assert(#tapped==9,"active cooldown is respected while other skills still fire")
Stats.Colossal.SkillScanAt=-math.huge
Stats.Colossal.SkillTaps={}
for i=1,5 do slots["Skill_"..i]:FindFirstChild("Cooldown").Visible=true end
slots.Skill_3:FindFirstChild("Cooldown").Visible=false
Stats.Colossal.UseReadySkills()
assert(#tapped==10 and tapped[10]==51,"skill fires immediately when cooldown ends without global gap")
print("PASS: immediate skills 1-5, independent debounces, active cooldown exclusion, prompt reuse")
]====]
assert(loadstring(code, "colossal_cannon_fixtures"))()
