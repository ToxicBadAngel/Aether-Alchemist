--!strict
--[[
    test_profile_template.luau
    Automatisierter Lune Unit-Test zur Verifikation von ProfileTemplate.luau.
]]

local ProfileTemplate = require("../src/Shared/Config/ProfileTemplate")

print("🧪 Starte ProfileTemplate Verifikation...")

-- 1. Test: Default Profile Initialwerte
local profile1 = ProfileTemplate.GetDefault()
assert(profile1.Version == 1, "Profile Version muss 1 sein")
assert(profile1.Level == 1, "Startlevel muss 1 sein")
assert(profile1.AetherEssence == 100, "Start-Essenz muss 100 sein")
assert(profile1.Inventory.Ores["EarthTopaz"] == 5, "Start-Inventar muss 5 Erd-Topas enthalten")
assert(profile1.EquippedWeapon == "BasicBlade", "Startwaffe muss BasicBlade sein")
assert(profile1.EquippedSummon == "FirePhoenix", "Start-Summon muss FirePhoenix sein")
assert(profile1.Settings.LowPerformanceMode == false, "LowPerformanceMode muss initial false sein")
assert(profile1.DailyStreak.CurrentStreak == 1, "Start-Streak muss 1 sein")

-- 2. Test: Deep-Copy Isolation (Keine Mutation des Masters)
profile1.AetherEssence = 999999
profile1.Inventory.Ores["EarthTopaz"] = 999
profile1.Skills.Harvester = 5

local profile2 = ProfileTemplate.GetDefault()
assert(profile2.AetherEssence == 100, "DeepCopy fehlgeschlagen: Master Essenz wurde mutiert!")
assert(profile2.Inventory.Ores["EarthTopaz"] == 5, "DeepCopy fehlgeschlagen: Master Ores wurden mutiert!")
assert(profile2.Skills.Harvester == 0, "DeepCopy fehlgeschlagen: Master Skills wurden mutiert!")

-- 3. Test: Reconcile Funktion (Migration veralteter Datenstände)
local legacyProfile = {
    Level = 5,
    AetherEssence = 500,
    -- Fehlende Sektionen: Settings, DailyStreak, PlaytimeGift, Stats
}

local reconciled = ProfileTemplate.Reconcile(legacyProfile)
assert(reconciled.Level == 5, "Bestehende Daten (Level 5) dürfen nicht überschrieben werden")
assert(reconciled.AetherEssence == 500, "Bestehende Daten (500 Essenz) dürfen nicht überschrieben werden")
assert(reconciled.Settings ~= nil and reconciled.Settings.MusicVolume == 0.5, "Fehlende Settings müssen ergänzt werden")
assert(reconciled.DailyStreak ~= nil and reconciled.DailyStreak.CurrentStreak == 1, "Fehlende DailyStreak muss ergänzt werden")
assert(reconciled.Stats ~= nil and reconciled.Stats.TotalOresMined == 0, "Fehlende Stats müssen ergänzt werden")

print("✅ ProfileTemplate zu 100% erfolgreich validiert!")
