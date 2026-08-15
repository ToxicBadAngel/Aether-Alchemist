--!strict
--[[
    test_ui_controller.luau
    Automatisierter Lune Unit-Test zur Verifikation von UIController.luau.
]]

local AudioController = require("../src/Client/Controllers/AudioController")
local UIController = require("../src/Client/Controllers/UIController")

print("🧪 Starte UIController Verifikation...")

-- 1. Test: Initialisierung
AudioController:Init()
AudioController:Start()
UIController:Init()
UIController:Start()

-- 2. Test: Screen-Registrierung
local inventoryVisible = false
UIController:RegisterScreen("Inventory", function(vis)
    inventoryVisible = vis
end)

local cauldronVisible = false
UIController:RegisterScreen("Cauldron", function(vis)
    cauldronVisible = vis
end)

assert(UIController:IsScreenOpen("Inventory") == false, "Screen muss initial geschlossen sein")

-- 3. Test: Screen Öffnen
local openedScreen = ""
UIController.ScreenOpened:Connect(function(name)
    openedScreen = name
end)

local openSuccess = UIController:OpenScreen("Inventory")
assert(openSuccess == true, "OpenScreen muss true zurückgeben")
assert(UIController:IsScreenOpen("Inventory") == true, "IsScreenOpen muss true sein")
assert(inventoryVisible == true, "Callback für Sichtbarkeit muss true gesetzt worden sein")
assert(UIController:GetActiveScreen() == "Inventory", "GetActiveScreen muss Inventory liefern")
assert(openedScreen == "Inventory", "ScreenOpened Signal muss Inventory melden")

-- 4. Test: Exklusivitäts-Garantie (Öffnen von Cauldron schließt Inventory)
local closedScreen = ""
UIController.ScreenClosed:Connect(function(name)
    closedScreen = name
end)

UIController:OpenScreen("Cauldron")
assert(UIController:IsScreenOpen("Cauldron") == true, "Cauldron muss geöffnet sein")
assert(cauldronVisible == true, "Cauldron Callback muss true sein")
assert(UIController:IsScreenOpen("Inventory") == false, "Inventory muss automatisch geschlossen worden sein")
assert(inventoryVisible == false, "Inventory Callback muss false sein")
assert(closedScreen == "Inventory", "ScreenClosed Signal muss Inventory gemeldet haben")
assert(UIController:GetActiveScreen() == "Cauldron", "Aktives Modal muss Cauldron sein")

-- 5. Test: Toggle
UIController:ToggleScreen("Cauldron")
assert(UIController:IsScreenOpen("Cauldron") == false, "Toggle auf geöffneten Screen muss ihn schließen")
assert(UIController:GetActiveScreen() == nil, "Kein aktives Modal mehr vorhanden")

-- 6. Test: CloseAllModals
UIController:OpenScreen("Inventory")
assert(UIController:IsScreenOpen("Inventory") == true, "Inventory offen")

UIController:CloseAllModals()
assert(UIController:IsScreenOpen("Inventory") == false, "CloseAllModals muss alle Fenster schließen")
assert(UIController:GetActiveScreen() == nil, "ActiveModal muss nil sein")

print("✅ UIController zu 100% erfolgreich validiert!")
