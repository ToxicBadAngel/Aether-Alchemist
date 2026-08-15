--!strict
--[[
    test_merchant_gui.luau
    Automatisierter Lune Unit-Test zur Verifikation von MerchantGui.luau.
]]

local ProfileTemplate = require("../src/Shared/Config/ProfileTemplate")
local DataController = require("../src/Client/Controllers/DataController")
local UIController = require("../src/Client/Controllers/UIController")
local AudioController = require("../src/Client/Controllers/AudioController")
local MerchantGui = require("../src/StarterGui/AetherUI/Screens/MerchantGui")

print("🧪 Starte MerchantGui Verifikation...")

-- 1. Test: Initialisierung & Setup
DataController:Init()
DataController:Start()
AudioController:Init()
AudioController:Start()
UIController:Init()
UIController:Start()

local testProfile = ProfileTemplate.GetDefault()
testProfile.Inventory.Ores["EarthTopaz"] = 10
DataController:SetLocalProfile(testProfile)

local merchant = MerchantGui.Create()
assert(merchant ~= nil, "MerchantGui Result darf nicht nil sein")
assert(merchant.Modal:IsOpen() == false, "Modal muss initial geschlossen sein")

-- 2. Test: Öffnen über UIController (Hotkey [M])
UIController:OpenScreen("Merchant")
assert(merchant.Modal:IsOpen() == true, "UIController:OpenScreen('Merchant') muss Händler öffnen")
assert(UIController:GetActiveScreen() == "Merchant", "Aktives Modal muss Merchant sein")

-- 3. Test: Gesamtwert-Berechnung (10x EarthTopaz à 5 Essenz = 50)
local valBase = merchant:CalculateTotalValue()
assert(valBase == 50, string.format("Erwarteter Gesamtwert 50, aber %d erhalten", valBase))

-- 4. Test: Alchemist-Bonus (+15% bei Level 5 -> 5.75 gerundet 6 -> 60 Essenz)
testProfile.Skills.Alchemist = 5
DataController:SetLocalProfile(testProfile)

local valBonus = merchant:CalculateTotalValue()
assert(valBonus == 60, string.format("Erwarteter Gesamtwert mit Bonus 60, aber %d erhalten", valBonus))

-- 5. Test: Einzelverkauf & Alles Verkaufen
local sellSuccess = merchant:SellSingleItem("Ore", "EarthTopaz", 1)
assert(sellSuccess == true, "SellSingleItem muss true zurückgeben")

local sellAllSuccess = merchant:SellAll()
assert(sellAllSuccess == true, "SellAll muss true zurückgeben")

-- 6. Test: Schließen
UIController:CloseScreen("Merchant")
assert(merchant.Modal:IsOpen() == false, "Händler muss geschlossen sein")
assert(UIController:GetActiveScreen() == nil, "Kein aktives Modal mehr")

print("✅ MerchantGui zu 100% erfolgreich validiert!")
