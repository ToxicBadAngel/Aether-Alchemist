--!strict
--[[
    test_inventory_gui.luau
    Automatisierter Lune Unit-Test zur Verifikation von InventoryGui.luau.
]]

local ProfileTemplate = require("../src/Shared/Config/ProfileTemplate")
local DataController = require("../src/Client/Controllers/DataController")
local UIController = require("../src/Client/Controllers/UIController")
local AudioController = require("../src/Client/Controllers/AudioController")
local InventoryGui = require("../src/StarterGui/AetherUI/Screens/InventoryGui")

print("🧪 Starte InventoryGui Verifikation...")

-- 1. Test: Initialisierung & Setup
DataController:Init()
DataController:Start()
AudioController:Init()
AudioController:Start()
UIController:Init()
UIController:Start()

DataController:SetLocalProfile(ProfileTemplate.GetDefault())

local inv = InventoryGui.Create()
assert(inv ~= nil, "InventoryGui Result darf nicht nil sein")
assert(inv.CurrentTab == "Erze", "Start-Tab muss Erze sein")
assert(inv.Modal:IsOpen() == false, "Modal muss initial geschlossen sein")

-- 2. Test: Öffnen über UIController (Hotkey / Action-Bar)
UIController:OpenScreen("Inventory")
assert(inv.Modal:IsOpen() == true, "UIController:OpenScreen('Inventory') muss Inventar öffnen")
assert(UIController:GetActiveScreen() == "Inventory", "Aktives Modal muss Inventory sein")

-- 3. Test: Tab-Umschaltung
inv:SetTab("Tränke")
assert(inv.CurrentTab == "Tränke", "Tab muss Tränke sein")

inv:SetTab("Waffen")
assert(inv.CurrentTab == "Waffen", "Tab muss Waffen sein")

inv:SetTab("Begleiter")
assert(inv.CurrentTab == "Begleiter", "Tab muss Begleiter sein")

inv:SetTab("Erze")
assert(inv.CurrentTab == "Erze", "Tab muss Erze sein")

-- 4. Test: Schließen
UIController:CloseScreen("Inventory")
assert(inv.Modal:IsOpen() == false, "Inventar muss geschlossen sein")
assert(UIController:GetActiveScreen() == nil, "Kein aktives Modal mehr")

print("✅ InventoryGui zu 100% erfolgreich validiert!")
