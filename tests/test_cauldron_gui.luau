--!strict
--[[
    test_cauldron_gui.luau
    Automatisierter Lune Unit-Test zur Verifikation von CauldronGui.luau.
]]

local ProfileTemplate = require("../src/Shared/Config/ProfileTemplate")
local DataController = require("../src/Client/Controllers/DataController")
local UIController = require("../src/Client/Controllers/UIController")
local AudioController = require("../src/Client/Controllers/AudioController")
local CauldronGui = require("../src/StarterGui/AetherUI/Screens/CauldronGui")

print("🧪 Starte CauldronGui Verifikation...")

-- 1. Test: Initialisierung & Setup
DataController:Init()
DataController:Start()
AudioController:Init()
AudioController:Start()
UIController:Init()
UIController:Start()

local testProfile = ProfileTemplate.GetDefault()
DataController:SetLocalProfile(testProfile)

local cauldron = CauldronGui.Create()
assert(cauldron ~= nil, "CauldronGui Result darf nicht nil sein")
assert(cauldron.SelectedRecipe == "GlacierShield", "Initiales Rezept muss GlacierShield sein")
assert(cauldron.Modal:IsOpen() == false, "Modal muss initial geschlossen sein")

-- 2. Test: Öffnen über UIController (Hotkey [C])
UIController:OpenScreen("Cauldron")
assert(cauldron.Modal:IsOpen() == true, "UIController:OpenScreen('Cauldron') muss Kessel öffnen")
assert(UIController:GetActiveScreen() == "Cauldron", "Aktives Modal muss Cauldron sein")

-- 3. Test: Craft-Validierung ohne Zutaten
assert(cauldron:CanCraftSelected() == false, "Ohne Erze darf CanCraftSelected nicht true sein")
assert(cauldron:CraftSelected() == false, "CraftSelected ohne Zutaten muss false liefern")

-- 4. Test: Craft-Validierung mit ausreichenden Zutaten für GlacierShield (2x OceanSapphire, 1x EarthTopaz)
testProfile.Inventory.Ores["OceanSapphire"] = 2
testProfile.Inventory.Ores["EarthTopaz"] = 1
DataController:SetLocalProfile(testProfile)

assert(cauldron:CanCraftSelected() == true, "Mit 2x OceanSapphire und 1x EarthTopaz muss GlacierShield craftbar sein")
assert(cauldron:CraftSelected() == true, "CraftSelected mit Zutaten muss true liefern")

-- 5. Test: Rezept-Wechsel zu InfernoPotion (fehlt WindEmerald)
cauldron:SelectRecipe("InfernoPotion")
assert(cauldron.SelectedRecipe == "InfernoPotion", "Ausgewähltes Rezept muss InfernoPotion sein")
assert(cauldron:CanCraftSelected() == false, "InfernoPotion benötigt WindEmerald (aktuell 0)")

-- 6. Test: Schließen
UIController:CloseScreen("Cauldron")
assert(cauldron.Modal:IsOpen() == false, "Kessel muss geschlossen sein")
assert(UIController:GetActiveScreen() == nil, "Kein aktives Modal mehr")

print("✅ CauldronGui zu 100% erfolgreich validiert!")
