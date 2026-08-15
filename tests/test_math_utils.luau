--!strict
--[[
    test_math_utils.luau
    Automatisierter Lune Unit-Test zur Verifikation von MathUtils.luau.
]]

local MathUtils = require("../src/Shared/Modules/MathUtils")

print("🧪 Starte MathUtils Verifikation...")

-- 1. Test: XP-Kurve
assert(MathUtils.GetRequiredXP(1) == 100, "Level 1 XP muss 100 sein")
assert(MathUtils.GetRequiredXP(2) == 125, "Level 2 XP muss 125 sein")
assert(MathUtils.GetRequiredXP(3) == 156, "Level 3 XP muss 156 sein")
assert(MathUtils.GetRequiredXP(4) == 195, "Level 4 XP muss 195 sein")

-- 2. Test: Harvester Mining-Speed (-4% pro Punkt, max 10 Punkte)
local baseHarvest = 1.5
assert(math.abs(MathUtils.CalculateHarvestTime(baseHarvest, 0) - 1.5) < 0.001, "Harvester Lvl 0 muss 1.5s sein")
assert(math.abs(MathUtils.CalculateHarvestTime(baseHarvest, 5) - 1.2) < 0.001, "Harvester Lvl 5 (-20%) muss 1.2s sein")
assert(math.abs(MathUtils.CalculateHarvestTime(baseHarvest, 10) - 0.9) < 0.001, "Harvester Lvl 10 (-40%) muss 0.9s sein")
assert(math.abs(MathUtils.CalculateHarvestTime(baseHarvest, 20) - 0.9) < 0.001, "Harvester Lvl 20 (gecappt) muss 0.9s sein")

-- 3. Test: Alchemist Essenz-Bonus (+3% pro Punkt, max 10 Punkte)
assert(MathUtils.CalculateEssenceBonus(100, 0) == 100, "Alchemist Lvl 0 muss 100 Essenz sein")
assert(MathUtils.CalculateEssenceBonus(100, 5) == 115, "Alchemist Lvl 5 (+15%) muss 115 Essenz sein")
assert(MathUtils.CalculateEssenceBonus(100, 10) == 130, "Alchemist Lvl 10 (+30%) muss 130 Essenz sein")
assert(MathUtils.CalculateEssenceBonus(100, 20) == 130, "Alchemist Lvl 20 (gecappt) muss 130 Essenz sein")

-- 4. Test: Summoner Cooldown-Reduktion (-3% pro Punkt, max 10 Punkte)
local baseCd = 10.0
assert(math.abs(MathUtils.CalculateSummonCooldown(baseCd, 0) - 10.0) < 0.001, "Summoner Lvl 0 muss 10s sein")
assert(math.abs(MathUtils.CalculateSummonCooldown(baseCd, 10) - 7.0) < 0.001, "Summoner Lvl 10 (-30%) muss 7.0s sein")

-- 5. Test: Distanz-Validierung (Exploit-Schutz)
local posOrigin = { X = 0, Y = 0, Z = 0 }
local posWithin = { X = 10, Y = 0, Z = 0 }
local posTooFar = { X = 16, Y = 0, Z = 0 }
local pos3DTooFar = { X = 10, Y = 10, Z = 10 } -- dist ~ 17.32

assert(MathUtils.IsWithinDistance(posOrigin, posWithin, 15) == true, "10 Studs muss innerhalb 15 Studs liegen")
assert(MathUtils.IsWithinDistance(posOrigin, posTooFar, 15) == false, "16 Studs darf nicht innerhalb 15 Studs liegen")
assert(MathUtils.IsWithinDistance(posOrigin, pos3DTooFar, 15) == false, "17.32 Studs darf nicht innerhalb 15 Studs liegen")

-- 6. Test: Zahlen-Formatierung
assert(MathUtils.FormatNumber(500) == "500", "500 Format inkorrekt")
assert(MathUtils.FormatNumber(1500) == "1.5k", "1500 Format inkorrekt")
assert(MathUtils.FormatNumber(2000) == "2k", "2000 Format inkorrekt")
assert(MathUtils.FormatNumber(2500000) == "2.5M", "2500000 Format inkorrekt")

-- 7. Test: Zeit-Formatierung
assert(MathUtils.FormatTime(65) == "01:05", "65s Format inkorrekt")
assert(MathUtils.FormatTime(300) == "05:00", "300s Format inkorrekt")

print("✅ MathUtils zu 100% erfolgreich validiert!")
