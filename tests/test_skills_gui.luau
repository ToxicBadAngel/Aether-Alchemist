--!strict
--[[
    test_skills_gui.luau
    Automatisierter Lune Unit-Test zur Verifikation von SkillsGui.luau.
]]

local ProfileTemplate = require("../src/Shared/Config/ProfileTemplate")
local DataController = require("../src/Client/Controllers/DataController")
local UIController = require("../src/Client/Controllers/UIController")
local AudioController = require("../src/Client/Controllers/AudioController")
local SkillsGui = require("../src/StarterGui/AetherUI/Screens/SkillsGui")

print("🧪 Starte SkillsGui Verifikation...")

-- 1. Test: Initialisierung & Setup
DataController:Init()
DataController:Start()
AudioController:Init()
AudioController:Start()
UIController:Init()
UIController:Start()

local testProfile = ProfileTemplate.GetDefault()
testProfile.SkillPoints = 0
DataController:SetLocalProfile(testProfile)

local skills = SkillsGui.Create()
assert(skills ~= nil, "SkillsGui Result darf nicht nil sein")
assert(skills.Modal:IsOpen() == false, "Modal muss initial geschlossen sein")

-- 2. Test: Öffnen über UIController (Hotkey [K])
UIController:OpenScreen("Skills")
assert(skills.Modal:IsOpen() == true, "UIController:OpenScreen('Skills') muss Skill-Tree öffnen")
assert(UIController:GetActiveScreen() == "Skills", "Aktives Modal muss Skills sein")

-- 3. Test: Talentpunkt-Vergabe blockiert bei 0 Punkten
assert(skills:CanAllocate("Harvester") == false, "Ohne Talentpunkte darf CanAllocate nicht true sein")
assert(skills:AllocatePoint("Harvester") == false, "AllocatePoint ohne Punkte muss false liefern")

-- 4. Test: Talentpunkt-Vergabe mit 2 Punkten
testProfile.SkillPoints = 2
DataController:SetLocalProfile(testProfile)

assert(skills:CanAllocate("Harvester") == true, "Mit 2 Punkten muss Harvester steigerbar sein")
assert(skills:AllocatePoint("Harvester") == true, "AllocatePoint mit Punkten muss true liefern")

-- 5. Test: Level-Cap 10 (MAX)
testProfile.Skills.Harvester = 10
DataController:SetLocalProfile(testProfile)

assert(skills:CanAllocate("Harvester") == false, "Bei Stufe 10 (MAX) darf kein weiterer Punkt investiert werden")
assert(skills:AllocatePoint("Harvester") == false, "AllocatePoint auf Level 10 Skill muss false liefern")

-- 6. Test: Schließen
UIController:CloseScreen("Skills")
assert(skills.Modal:IsOpen() == false, "Skills muss geschlossen sein")
assert(UIController:GetActiveScreen() == nil, "Kein aktives Modal mehr")

print("✅ SkillsGui zu 100% erfolgreich validiert!")
