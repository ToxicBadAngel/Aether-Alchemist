--!strict
--[[
    test_weapons_config.luau
    Automatisierter Lune Unit-Test zur Verifikation von WeaponsConfig.luau.
]]

local WeaponsConfig = require("../src/Shared/Config/WeaponsConfig")

print("🧪 Starte WeaponsConfig Verifikation...")

-- 1. Test: Genau 5 Waffen müssen existieren
local allWeapons = WeaponsConfig.GetAll()
local count = 0
for _ in allWeapons do
    count += 1
end
assert(count == 5, string.format("Erwartet 5 Waffen, aber %d gefunden", count))

-- 2. Test: Tier 1 Anfänger-Klinge
local basic = WeaponsConfig.Get("BasicBlade")
assert(basic ~= nil, "BasicBlade nicht gefunden")
assert(basic.Tier == 1, "BasicBlade Tier muss 1 sein")
assert(basic.Damage == 10, "BasicBlade Damage muss 10 sein")
assert(basic.AttackRange == 12, "BasicBlade AttackRange muss 12 sein")

-- 3. Test: Tier 2 Feuer-Säbel
local fire = WeaponsConfig.Get("FireSaber")
assert(fire ~= nil, "FireSaber nicht gefunden")
assert(fire.Tier == 2, "FireSaber Tier muss 2 sein")
assert(fire.Damage == 25, "FireSaber Damage muss 25 sein")
assert(fire.Ingredients["FireRuby"] == 2, "FireSaber benötigt 2x FireRuby")

-- 4. Test: Tier 3 Ozean-Dreizack
local ocean = WeaponsConfig.Get("OceanTrident")
assert(ocean ~= nil, "OceanTrident nicht gefunden")
assert(ocean.Tier == 3, "OceanTrident Tier muss 3 sein")
assert(ocean.Damage == 45, "OceanTrident Damage muss 45 sein")
assert(ocean.Ingredients["OceanSapphire"] == 2, "OceanTrident benötigt 2x OceanSapphire")
assert(ocean.Ingredients["EarthTopaz"] == 1, "OceanTrident benötigt 1x EarthTopaz")

-- 5. Test: Tier 4 Sturm-Schneide
local storm = WeaponsConfig.Get("StormEdge")
assert(storm ~= nil, "StormEdge nicht gefunden")
assert(storm.Tier == 4, "StormEdge Tier muss 4 sein")
assert(storm.Damage == 75, "StormEdge Damage muss 75 sein")
assert(storm.Ingredients["LightningAmethyst"] == 3, "StormEdge benötigt 3x LightningAmethyst")
assert(storm.Ingredients["ColossusCore"] == 1, "StormEdge benötigt 1x ColossusCore")

-- 6. Test: Tier 5 Void-Schattenklinge
local void = WeaponsConfig.Get("VoidShadowBlade")
assert(void ~= nil, "VoidShadowBlade nicht gefunden")
assert(void.Tier == 5, "VoidShadowBlade Tier muss 5 sein")
assert(void.Damage == 110, "VoidShadowBlade Damage muss 110 sein")
assert(void.Ingredients["VoidCrystal"] == 3, "VoidShadowBlade benötigt 3x VoidCrystal")
assert(void.Ingredients["ColossusHeart"] == 1, "VoidShadowBlade benötigt 1x ColossusHeart")

-- 7. Test: GetByTier Helper
local tier3 = WeaponsConfig.GetByTier(3)
assert(tier3 ~= nil and tier3.Id == "OceanTrident", "GetByTier(3) muss OceanTrident liefern")

-- 8. Test: IsValidWeapon
assert(WeaponsConfig.IsValidWeapon("FireSaber") == true, "FireSaber muss gültig sein")
assert(WeaponsConfig.IsValidWeapon("LaserGun") == false, "LaserGun darf nicht gültig sein")

print("✅ WeaponsConfig zu 100% erfolgreich validiert!")
