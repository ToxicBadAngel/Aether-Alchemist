--!strict
--[[
    test_skill_service.luau
    Automatisierter Lune Unit-Test zur Verifikation von SkillService.luau.
]]

local DataService = require("../src/Server/Services/DataService")
local SkillService = require("../src/Server/Services/SkillService")

print("🧪 Starte SkillService Verifikation...")

-- 1. Test: Initialisierung
DataService:Init()
DataService:Start()
SkillService:Init()
SkillService:Start()

local mockPlayer = {
    UserId = 33221100,
    Name = "TalentMaster",
}

DataService:LoadMockProfile(mockPlayer)

-- 2. Test: Ungültiger Skill-Name
local invalidSkill = SkillService:UpgradeSkill(mockPlayer, "FlySpeed")
assert(invalidSkill.success == false, "Ungültiger Skill-Name muss abgewiesen werden")

-- 3. Test: Upgrade ohne verfügbare Skill-Punkte
local noPointsUpgrade = SkillService:UpgradeSkill(mockPlayer, "Harvester")
assert(noPointsUpgrade.success == false, "Upgrade ohne Skill-Punkte muss fehlschlagen")
assert(noPointsUpgrade.error == "Keine Skill-Punkte verfügbar!", "Fehlermeldung inkorrekt")

-- 4. Test: Skill-Punkte hinzufügen (z.B. 15 Punkte) & Erfolgreiches Upgrade
DataService:UpdateProfile(mockPlayer, function(data)
    data.SkillPoints = 15
end)

local upgrade1 = SkillService:UpgradeSkill(mockPlayer, "Harvester")
assert(upgrade1.success == true, "Upgrade mit Skill-Punkten muss erfolgreich sein")
assert(upgrade1.newLevel == 1, "Harvester Level muss 1 sein")
assert(SkillService:GetSkillLevel(mockPlayer, "Harvester") == 1, "GetSkillLevel muss 1 zurückgeben")
assert(DataService:GetProfile(mockPlayer).SkillPoints == 14, "SkillPoints muss um 1 gesunken sein")

-- 5. Test: Bis Max-Level (10) leveln & Cap-Schutz
for i = 2, 10 do
    local up = SkillService:UpgradeSkill(mockPlayer, "Harvester")
    assert(up.success == true and up.newLevel == i, string.format("Upgrade auf Level %d fehlgeschlagen", i))
end

assert(SkillService:GetSkillLevel(mockPlayer, "Harvester") == 10, "Harvester muss auf Max-Level 10 sein")

-- 11. Upgrade-Versuch über das Cap hinaus
local overCapUpgrade = SkillService:UpgradeSkill(mockPlayer, "Harvester")
assert(overCapUpgrade.success == false, "Upgrade über Level 10 muss blockiert werden")
assert(overCapUpgrade.error == "Skill hat bereits das Maximal-Level erreicht (10)!", "Cap-Fehlermeldung inkorrekt")
assert(DataService:GetProfile(mockPlayer).SkillPoints == 5, "SkillPoints dürfen bei Cap-Blockierung nicht abgezogen werden")

-- 6. Test: Alchemist & Summoner Upgrades
SkillService:UpgradeSkill(mockPlayer, "Alchemist")
assert(SkillService:GetSkillLevel(mockPlayer, "Alchemist") == 1, "Alchemist Level muss 1 sein")

SkillService:UpgradeSkill(mockPlayer, "Summoner")
assert(SkillService:GetSkillLevel(mockPlayer, "Summoner") == 1, "Summoner Level muss 1 sein")

local allSkills = SkillService:GetSkills(mockPlayer)
assert(allSkills ~= nil, "Skills-Tabelle fehlt")
assert(allSkills.Harvester == 10 and allSkills.Alchemist == 1 and allSkills.Summoner == 1, "Skill-Zustand inkonsistent")

DataService:UnloadMockProfile(mockPlayer)

print("✅ SkillService zu 100% erfolgreich validiert!")
