--!strict
--[[
    test_ores_config.luau
    Automatisierter Lune Unit-Test zur Verifikation von OresConfig.luau.
]]

local OresConfig = require("../src/Shared/Config/OresConfig")

print("🧪 Starte OresConfig Verifikation...")

-- 1. Test: Alle 6 Erze müssen existieren
local allOres = OresConfig.GetAll()
local expectedOreCount = 6
local actualCount = 0
for _ in allOres do
    actualCount += 1
end
assert(actualCount == expectedOreCount, string.format("Erwartet 6 Erze, aber %d gefunden", actualCount))

-- 2. Test: Spezifische Werte für Erd-Topas (Common Zone 1)
local earthTopaz = OresConfig.Get("EarthTopaz")
assert(earthTopaz ~= nil, "EarthTopaz nicht gefunden")
assert(earthTopaz.SellPrice == 5, "EarthTopaz SellPrice muss 5 sein")
assert(earthTopaz.BaseHarvestTime == 1.0, "EarthTopaz BaseHarvestTime muss 1.0s sein")
assert(earthTopaz.RespawnTime == 12, "EarthTopaz RespawnTime muss 12s sein")
assert(earthTopaz.DropMin == 1 and earthTopaz.DropMax == 2, "EarthTopaz DropRange muss 1..2 sein")

-- 3. Test: Spezifische Werte für Feuer-Rubin & Ozean-Saphir
local fireRuby = OresConfig.Get("FireRuby")
assert(fireRuby ~= nil, "FireRuby nicht gefunden")
assert(fireRuby.SellPrice == 20, "FireRuby SellPrice muss 20 sein")
assert(fireRuby.RespawnTime == 25, "FireRuby RespawnTime muss 25s sein")

local oceanSapphire = OresConfig.Get("OceanSapphire")
assert(oceanSapphire ~= nil, "OceanSapphire nicht gefunden")
assert(oceanSapphire.SellPrice == 20, "OceanSapphire SellPrice muss 20 sein")

-- 4. Test: Spezifische Werte für Blitz-Amethyst & Void-Kristall
local lightning = OresConfig.Get("LightningAmethyst")
assert(lightning ~= nil, "LightningAmethyst nicht gefunden")
assert(lightning.SellPrice == 60, "LightningAmethyst SellPrice muss 60 sein")
assert(lightning.ExtraDropChance == 0.10, "LightningAmethyst ExtraDropChance muss 10% sein")

local voidCrystal = OresConfig.Get("VoidCrystal")
assert(voidCrystal ~= nil, "VoidCrystal nicht gefunden")
assert(voidCrystal.SellPrice == 200, "VoidCrystal SellPrice muss 200 sein")
assert(voidCrystal.RespawnTime == 90, "VoidCrystal RespawnTime muss 90s sein")

-- 5. Test: Zonen-Filter
local zone1Ores = OresConfig.GetOresForZone(1)
assert(#zone1Ores == 3, string.format("Zone 1 muss 3 Erze enthalten, hat %d", #zone1Ores))

-- 6. Test: Validierungs-Funktion
assert(OresConfig.IsValidOre("EarthTopaz") == true, "EarthTopaz muss gültig sein")
assert(OresConfig.IsValidOre("FakeOre") == false, "FakeOre darf nicht gültig sein")

print("✅ OresConfig zu 100% erfolgreich validiert!")
