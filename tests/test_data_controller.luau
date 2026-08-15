--!strict
--[[
    test_data_controller.luau
    Automatisierter Lune Unit-Test zur Verifikation von DataController.luau.
]]

local ProfileTemplate = require("../src/Shared/Config/ProfileTemplate")
local DataController = require("../src/Client/Controllers/DataController")

print("🧪 Starte DataController Verifikation...")

-- 1. Test: Initialisierung
DataController:Init()
DataController:Start()

assert(DataController:GetProfile() == nil, "Initial darf noch kein Profil im Client-Cache liegen")
assert(DataController:GetEssence() == 0, "Essenz ohne Profil muss 0 sein")

-- 2. Test: Profil-Replikation (ProfileSync_RE Simulation)
local receivedEssence = 0
local receivedDelta = 0
DataController.EssenceChanged:Connect(function(newEssence, delta)
    receivedEssence = newEssence
    receivedDelta = delta
end)

local receivedLevel = 0
DataController.LevelChanged:Connect(function(level, _xp, _req)
    receivedLevel = level
end)

local defaultProfile = ProfileTemplate.GetDefault()
DataController:SetLocalProfile(defaultProfile)

assert(DataController:GetProfile() ~= nil, "Profil muss nach Sync vorhanden sein")
assert(DataController:GetEssence() == 100, "Essenz muss 100 sein")
assert(receivedEssence == 100 and receivedDelta == 100, "EssenceChanged Signal muss ausgelöst worden sein")
assert(DataController:GetLevel() == 1, "Level muss 1 sein")
assert(receivedLevel == 1, "LevelChanged Signal muss ausgelöst worden sein")
assert(DataController:GetOreCount("EarthTopaz") == 5, "Erd-Topas Count muss 5 sein")
assert(DataController:GetEquippedWeapon() == "BasicBlade", "EquippedWeapon muss BasicBlade sein")
assert(DataController:IsWeaponUnlocked("BasicBlade") == true, "BasicBlade muss freigeschaltet sein")
assert(DataController:IsWeaponUnlocked("FireSaber") == false, "FireSaber darf nicht freigeschaltet sein")

-- 3. Test: Reaktive Deltas bei Zustandsänderungen
local equippedWeaponFired = ""
DataController.WeaponChanged:Connect(function(newWeapon)
    equippedWeaponFired = newWeapon
end)

local updatedProfile = ProfileTemplate.GetDefault()
updatedProfile.AetherEssence = 350
updatedProfile.Level = 2
updatedProfile.XP = 40
table.insert(updatedProfile.UnlockedWeapons, "FireSaber")
updatedProfile.EquippedWeapon = "FireSaber"

DataController:SetLocalProfile(updatedProfile)

assert(DataController:GetEssence() == 350, "Neue Essenz muss 350 sein")
assert(receivedEssence == 350 and receivedDelta == 250, "Delta muss +250 sein")
assert(DataController:GetLevel() == 2, "Level muss 2 sein")
assert(equippedWeaponFired == "FireSaber", "WeaponChanged Signal muss FireSaber melden")
assert(DataController:IsWeaponUnlocked("FireSaber") == true, "FireSaber muss nun freigeschaltet sein")

print("✅ DataController zu 100% erfolgreich validiert!")
