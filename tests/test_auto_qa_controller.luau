--!strict
--[[
    test_auto_qa_controller.luau
    Automatisierter Lune Unit-Test zur Verifikation von AutoQAController.luau.
]]

local ProfileTemplate = require("../src/Shared/Config/ProfileTemplate")
local DataController = require("../src/Client/Controllers/DataController")
local UIController = require("../src/Client/Controllers/UIController")
local AudioController = require("../src/Client/Controllers/AudioController")
local AutoQAController = require("../src/Client/Controllers/AutoQAController")

print("🧪 Starte AutoQAController Verifikation...")

-- 1. Test: Initialisierung & Lifecycle
DataController:Init()
DataController:Start()
AudioController:Init()
AudioController:Start()
UIController:Init()
UIController:Start()

AutoQAController:Init()
assert(AutoQAController:IsInitialized() == true, "AutoQAController muss initialisiert sein")

AutoQAController:Start()
assert(AutoQAController:IsStarted() == true, "AutoQAController muss gestartet sein")

local testProfile = ProfileTemplate.GetDefault()
DataController:SetLocalProfile(testProfile)

-- 2. Test: RunSuite() Ausführung
local report = AutoQAController:RunSuite()
assert(report ~= nil, "AutoQAReport darf nicht nil sein")
assert(report.TotalTests == 6, string.format("Es müssen 6 Tests ausgeführt worden sein, aber %d gefunden", report.TotalTests))
assert(report.FailedTests == 0, string.format("Es dürfen 0 Tests fehlschlagen, aber %d fehlgeschlagen", report.FailedTests))
assert(report.PassedTests == 6, string.format("Es müssen alle 6 Tests bestanden sein, aber %d", report.PassedTests))
assert(report.AllPassed == true, "AllPassed muss true sein")

-- 3. Test: GetLastReport()
local cachedReport = AutoQAController:GetLastReport()
assert(cachedReport ~= nil, "Cached Report darf nicht nil sein")
assert(cachedReport.AllPassed == true, "Cached Report AllPassed muss true sein")

print("✅ AutoQAController zu 100% erfolgreich validiert!")
