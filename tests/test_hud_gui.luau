--!strict
--[[
    test_hud_gui.luau
    Automatisierter Lune Unit-Test zur Verifikation von HUDGui.luau.
]]

local ProfileTemplate = require("../src/Shared/Config/ProfileTemplate")
local DataController = require("../src/Client/Controllers/DataController")
local UIController = require("../src/Client/Controllers/UIController")
local HUDGui = require("../src/StarterGui/AetherUI/Screens/HUDGui")

print("🧪 Starte HUDGui Verifikation...")

-- 1. Test: Initialisierung & Setup
DataController:Init()
DataController:Start()
UIController:Init()
UIController:Start()

DataController:SetLocalProfile(ProfileTemplate.GetDefault())

local hud = HUDGui.Create()
assert(hud ~= nil, "HUDGui Result darf nicht nil sein")
assert(hud.ScreenGui.DisplayOrder == 1, "DisplayOrder muss 1 sein")
assert(hud.EssenceLabel.Text == "100", "Start-Essenz muss 100 sein")
assert(hud.LevelLabel.Text == "Lv. 1", "Start-Level muss Lv. 1 sein")

-- 2. Test: Reaktive Essenz-Aktualisierung
DataController.EssenceChanged:Fire(450)
assert(hud.EssenceLabel.Text == "450", "EssenceLabel muss 450 anzeigen")

-- 3. Test: Reaktive Level- & XP-Aktualisierung
DataController.LevelChanged:Fire(3, 50, 200)
assert(hud.LevelLabel.Text == "Lv. 3", "LevelLabel muss Lv. 3 anzeigen")
assert(hud.ExpBarFill.Size.X == 0.25, "XP-Bar Füllung bei 50/200 muss 25% betragen")

-- 4. Test: Zonen-Wechsel
hud:UpdateZone("Zone 2: Sturm-Klippen")
assert(hud.ZoneLabel.Text == "Zone 2: Sturm-Klippen", "ZoneLabel inkorrekt")

print("✅ HUDGui zu 100% erfolgreich validiert!")
