--!strict
--[[
    test_mobs_config.luau
    Automatisierter Lune Unit-Test zur Verifikation von MobsConfig.luau.
]]

local MobsConfig = require("../src/Shared/Config/MobsConfig")

print("🧪 Starte MobsConfig Verifikation...")

-- 1. Test: Genau 6 Mobs müssen existieren
local allMobs = MobsConfig.GetAll()
local count = 0
for _ in allMobs do
    count += 1
end
assert(count == 6, string.format("Erwartet 6 Mobs, aber %d gefunden", count))

-- 2. Test: Erd-Schleim (Zone 1)
local slime = MobsConfig.Get("EarthSlime")
assert(slime ~= nil, "EarthSlime nicht gefunden")
assert(slime.Zone == 1, "EarthSlime Zone muss 1 sein")
assert(slime.MaxHp == 50, "EarthSlime MaxHp muss 50 sein")
assert(slime.Damage == 8, "EarthSlime Damage muss 8 sein")
assert(slime.AggroRadius == 16, "EarthSlime AggroRadius muss 16 sein")
assert(slime.LeashRadius == 35, "EarthSlime LeashRadius muss 35 sein")
assert(slime.RespawnTime == 8, "EarthSlime RespawnTime muss 8s sein")
assert(slime.GuaranteedDrops["EarthTopaz"] == 1, "EarthSlime muss 1 EarthTopaz garantieren")

-- 3. Test: Kristall-Krabbe & Elite (Zone 2)
local crab = MobsConfig.Get("CrystalCrab")
assert(crab ~= nil, "CrystalCrab nicht gefunden")
assert(crab.MaxHp == 180 and crab.Damage == 22, "CrystalCrab Stats inkorrekt")

local crabElite = MobsConfig.Get("CrystalCrabElite")
assert(crabElite ~= nil, "CrystalCrabElite nicht gefunden")
assert(crabElite.MaxHp == 380 and crabElite.Damage == 40, "CrystalCrabElite Stats inkorrekt")
assert(crabElite.ChanceDrops[1].ItemId == "LightningAmethyst", "Elite Drop muss LightningAmethyst sein")
assert(crabElite.ChanceDrops[1].Chance == 0.50, "Elite Drop Chance muss 50% sein")

-- 4. Test: Void-Pirscher (Zone 3)
local stalker = MobsConfig.Get("VoidStalker")
assert(stalker ~= nil, "VoidStalker nicht gefunden")
assert(stalker.MaxHp == 420 and stalker.Damage == 50, "VoidStalker Stats inkorrekt")
assert(stalker.GuaranteedDrops["VoidCrystal"] == 1, "VoidStalker muss VoidCrystal droppen")

-- 5. Test: Kristall-Koloss (Boss)
local colossus = MobsConfig.Get("CrystalColossus")
assert(colossus ~= nil, "CrystalColossus nicht gefunden")
assert(colossus.MaxHp == 2500, "CrystalColossus MaxHp muss 2500 sein")
assert(colossus.Damage == 65, "CrystalColossus Damage muss 65 sein")
assert(colossus.RespawnTime == 120, "CrystalColossus RespawnTime muss 120s sein")
assert(colossus.GuaranteedDrops["ColossusCore"] == 1, "Boss muss ColossusCore garantieren")
assert(colossus.GuaranteedDrops["LightningAmethyst"] == 3, "Boss muss 3x LightningAmethyst garantieren")

-- 6. Test: Zonen-Filter
local zone1Mobs = MobsConfig.GetMobsForZone(1)
assert(#zone1Mobs == 1 and zone1Mobs[1].Id == "EarthSlime", "Zone 1 darf nur EarthSlime enthalten")

local zone2Mobs = MobsConfig.GetMobsForZone(2)
assert(#zone2Mobs == 4, string.format("Zone 2 muss 4 Mob-Arten enthalten, hat %d", #zone2Mobs))

-- 7. Test: IsValidMob
assert(MobsConfig.IsValidMob("EarthSlime") == true, "EarthSlime muss gültig sein")
assert(MobsConfig.IsValidMob("Godzilla") == false, "Godzilla darf nicht existieren")

print("✅ MobsConfig zu 100% erfolgreich validiert!")
