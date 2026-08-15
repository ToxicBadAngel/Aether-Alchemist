--!strict
--[[
    test_data_service.luau
    Automatisierter Lune Unit-Test zur Verifikation von DataService.luau.
]]

local DataService = require("../src/Server/Services/DataService")

print("🧪 Starte DataService Verifikation...")

-- 1. Test: Init & Start
DataService:Init()
DataService:Start()

-- 2. Test: Mock-Player Profil laden
local mockPlayer = {
    UserId = 12345678,
    Name = "TestAlchemist",
}

local loadedProfile = DataService:LoadMockProfile(mockPlayer)
assert(loadedProfile ~= nil, "Mock-Profil konnte nicht geladen werden")
assert(loadedProfile.Level == 1, "Startlevel muss 1 sein")
assert(loadedProfile.AetherEssence == 100, "Start-Essenz muss 100 sein")

-- 3. Test: Essenz-Transaktionen
local balance1 = DataService:AddEssence(mockPlayer, 50)
assert(balance1 == 150, "Essenz nach +50 muss 150 sein")

local successDeduct = DataService:RemoveEssence(mockPlayer, 70)
assert(successDeduct == true, "Abzug von 70 Essenz muss erfolgreich sein")
assert(DataService:GetProfile(mockPlayer) ~= nil and DataService:GetProfile(mockPlayer).AetherEssence == 80, "Rest-Essenz muss 80 sein")

local failDeduct = DataService:RemoveEssence(mockPlayer, 500) -- Zu viel
assert(failDeduct == false, "Abzug von 500 Essenz (mehr als Guthaben) muss fehlschlagen")
assert(DataService:GetProfile(mockPlayer).AetherEssence == 80, "Guthaben darf sich bei Fehlschlag nicht ändern")

-- 4. Test: XP & Level-Up
local newLevel, didLevelUp = DataService:AddXP(mockPlayer, 100) -- Level 1 -> 2 braucht 100 XP
assert(didLevelUp == true, "Level-Up muss ausgelöst werden")
assert(newLevel == 2, "Neues Level muss 2 sein")
assert(DataService:GetProfile(mockPlayer).SkillPoints == 1, "Level-Up muss +1 Skill-Punkt vergeben")
assert(DataService:GetProfile(mockPlayer).XP == 0, "Überschüssige XP muss 0 sein")

-- 5. Test: Transaktions-Mutex (Anti-Exploit Race Condition Schutz)
local lock1 = DataService:AcquireLock(mockPlayer)
assert(lock1 == true, "Erster Lock-Erwerb muss erfolgreich sein")

local lock2 = DataService:AcquireLock(mockPlayer)
assert(lock2 == false, "Zweiter Lock-Erwerb während aktiver Transaktion muss abgelehnt werden (Mutex)")

DataService:ReleaseLock(mockPlayer)
local lock3 = DataService:AcquireLock(mockPlayer)
assert(lock3 == true, "Nach ReleaseLock muss Lock wieder erwerbbar sein")
DataService:ReleaseLock(mockPlayer)

-- 6. Test: Unload
DataService:UnloadMockProfile(mockPlayer)
assert(DataService:GetProfile(mockPlayer) == nil, "Nach Unload darf kein Profil mehr im Cache sein")

print("✅ DataService zu 100% erfolgreich validiert!")
