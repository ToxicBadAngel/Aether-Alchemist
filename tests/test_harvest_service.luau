--!strict
--[[
    test_harvest_service.luau
    Automatisierter Lune Unit-Test zur Verifikation von HarvestService.luau.
]]

local DataService = require("../src/Server/Services/DataService")
local InventoryService = require("../src/Server/Services/InventoryService")
local HarvestService = require("../src/Server/Services/HarvestService")

print("🧪 Starte HarvestService Verifikation...")

-- 1. Test: Services Initialisieren
DataService:Init()
DataService:Start()
InventoryService:Init()
InventoryService:Start()
HarvestService:Init()
HarvestService:Start()

local mockPlayer = {
    UserId = 99887766,
    Name = "MiningPro",
}

DataService:LoadMockProfile(mockPlayer)

-- 2. Test: Erz-Knoten registrieren
local mockNodeInstance = { Name = "EarthTopaz_Node_01" }
HarvestService:RegisterOreNode(mockNodeInstance, "EarthTopaz", { X = 0, Y = 0, Z = 0 })

local nodeData = HarvestService:GetNode(mockNodeInstance)
assert(nodeData ~= nil, "Erz-Knoten wurde nicht registriert")
assert(nodeData.OreId == "EarthTopaz", "OreId inkorrekt")
assert(nodeData.IsActive == true, "Knoten muss initial aktiv sein")

-- 3. Test: Erfolgreicher Abbau in Reichweite (5 Studs Entfernung)
local playerPosInRange = { X = 5, Y = 0, Z = 0 }
local initialOres = InventoryService:GetOreCount(mockPlayer, "EarthTopaz")

local harvestResult = HarvestService:HarvestOre(mockPlayer, mockNodeInstance, playerPosInRange)
assert(harvestResult.success == true, "Abbau in Reichweite muss erfolgreich sein")
assert(harvestResult.oreId == "EarthTopaz", "Abgebautes Erz muss EarthTopaz sein")
assert(harvestResult.amount ~= nil and harvestResult.amount >= 1, "Drop-Menge muss >= 1 sein")

local newOreCount = InventoryService:GetOreCount(mockPlayer, "EarthTopaz")
assert(newOreCount == initialOres + harvestResult.amount, "Inventar muss die abgebauten Erze enthalten")

-- 4. Test: Exploit-Schutz (Zu weit entfernt: 20 Studs)
local playerPosOutOfRange = { X = 20, Y = 0, Z = 0 }
local exploitAttempt = HarvestService:HarvestOre(mockPlayer, mockNodeInstance, playerPosOutOfRange)
assert(exploitAttempt.success == false, "Abbau über 15 Studs Distanz muss fehlschlagen (Exploit-Schutz)")
assert(string.find(exploitAttempt.error or "", "Zu weit entfernt") ~= nil, "Fehlermeldung für Distanzüberschreitung inkorrekt")

-- 5. Test: Ungültiger Erz-Knoten
local fakeNode = { Name = "Fake" }
local invalidHarvest = HarvestService:HarvestOre(mockPlayer, fakeNode, playerPosInRange)
assert(invalidHarvest.success == false, "Abbau an ungültigem Part muss abgewiesen werden")

-- 6. Test: Tutorial-Fortschritt
local profile = DataService:GetProfile(mockPlayer)
assert(profile ~= nil, "Profil fehlt")
assert(profile.Tutorial.Step1MinedOres >= 1, "Tutorial Step 1 Fortschritt muss gezählt werden")

DataService:UnloadMockProfile(mockPlayer)

print("✅ HarvestService zu 100% erfolgreich validiert!")
