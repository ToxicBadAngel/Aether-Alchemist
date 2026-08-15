--!strict
--[[
    test_mining_controller.luau
    Automatisierter Lune Unit-Test zur Verifikation von MiningController.luau.
]]

local ProfileTemplate = require("../src/Shared/Config/ProfileTemplate")
local DataController = require("../src/Client/Controllers/DataController")
local MiningController = require("../src/Client/Controllers/MiningController")

print("🧪 Starte MiningController Verifikation...")

-- 1. Test: Initialisierung & Profil setzen
DataController:Init()
DataController:Start()
MiningController:Init()
MiningController:Start()

DataController:SetLocalProfile(ProfileTemplate.GetDefault())

local mockNode = { Name = "EarthTopaz_Node_Test" }
local nodePos = { X = 0, Y = 0, Z = 0 }
local playerPosInRange = { X = 4, Y = 0, Z = 0 }
local playerPosOutOfRange = { X = 20, Y = 0, Z = 0 }

-- 2. Test: Start außerhalb der Reichweite (> 12 Studs)
local failStart = MiningController:StartMining(mockNode, "EarthTopaz", nodePos, playerPosOutOfRange)
assert(failStart == false, "Mining-Start außerhalb von 12 Studs muss blockiert werden")
assert(MiningController:IsMining() == false, "IsMining muss false sein")

-- 3. Test: Erfolgreicher Start in Reichweite
local startedDuration = 0
MiningController.MiningStarted:Connect(function(_node, _oreId, duration)
    startedDuration = duration
end)

local successStart = MiningController:StartMining(mockNode, "EarthTopaz", nodePos, playerPosInRange)
assert(successStart == true, "Mining in Reichweite muss starten")
assert(MiningController:IsMining() == true, "IsMining muss true sein")
assert(startedDuration == 1.0, "Dauer für EarthTopaz (Lvl 0 Harvester) muss 1.0 Sekunden sein")

-- 4. Test: Fortschritt über Update (Halbzeit = 0.5s)
local currentProgress = 0
MiningController.MiningProgress:Connect(function(pct)
    currentProgress = pct
end)

MiningController:Update(0.5, playerPosInRange)
assert(math.abs(currentProgress - 0.5) < 0.05, "Progress nach 0.5s muss 50% betragen")
assert(MiningController:IsMining() == true, "Mining muss noch aktiv sein")

-- 5. Test: Bewegungs-Abbruch (Spieler läuft weg)
local cancelledReason = ""
MiningController.MiningCancelled:Connect(function(reason)
    cancelledReason = reason
end)

MiningController:Update(0.1, playerPosOutOfRange) -- Spieler bewegt sich auf 20 Studs
assert(MiningController:IsMining() == false, "Nach Wegbewegen muss Mining abgebrochen werden")
assert(string.find(cancelledReason, "Zu weit") ~= nil, "Abbruchgrund inkorrekt")

-- 6. Test: Vollständiger Durchlauf bis zum Abschluss
local completedFired = false
MiningController.MiningCompleted:Connect(function(_result)
    completedFired = true
end)

MiningController:StartMining(mockNode, "EarthTopaz", nodePos, playerPosInRange)
MiningController:Update(1.1, playerPosInRange) -- Volle 1.1s abbauen
assert(completedFired == true, "MiningCompleted Signal muss nach Ablauf der Dauer gefeuert werden")
assert(MiningController:IsMining() == false, "Nach Abschluss muss IsMining false sein")

print("✅ MiningController zu 100% erfolgreich validiert!")
