--!strict
--[[
    test_merchant_service.luau
    Automatisierter Lune Unit-Test zur Verifikation von MerchantService.luau.
]]

local DataService = require("../src/Server/Services/DataService")
local InventoryService = require("../src/Server/Services/InventoryService")
local MerchantService = require("../src/Server/Services/MerchantService")

print("🧪 Starte MerchantService Verifikation...")

-- 1. Test: Initialisierung
DataService:Init()
DataService:Start()
InventoryService:Init()
InventoryService:Start()
MerchantService:Init()
MerchantService:Start()

local mockPlayer = {
    UserId = 11223344,
    Name = "MerchantKing",
}

DataService:LoadMockProfile(mockPlayer)

-- 2. Test: Ungültige Verkaufsversuche
local invalidOre = MerchantService:SellOre(mockPlayer, "FakeDiamond", 1)
assert(invalidOre.success == false, "Ungültiges Erz darf nicht verkaufbar sein")

local invalidAmount = MerchantService:SellOre(mockPlayer, "EarthTopaz", -5)
assert(invalidAmount.success == false, "Negative Verkaufsmenge muss abgefangen werden")

local insufficient = MerchantService:SellOre(mockPlayer, "EarthTopaz", 100) -- Start hat nur 5
assert(insufficient.success == false, "Verkauf von mehr Erzen als im Inventar muss fehlschlagen")

-- 3. Test: Erfolgreicher Erz-Verkauf (Alchemist Lvl 0)
-- 2x EarthTopaz (5 Essenz * 2 = 10 Essenz)
local sellResult1 = MerchantService:SellOre(mockPlayer, "EarthTopaz", 2)
assert(sellResult1.success == true, "Erzverkauf muss erfolgreich sein")
assert(sellResult1.earnedEssence == 10, "Verdienst für 2x EarthTopaz muss 10 sein")
assert(InventoryService:GetOreCount(mockPlayer, "EarthTopaz") == 3, "Restliche Erze müssen 3 sein")
-- Durch Tutorial Step 2 (+50 Essenz) und Verkauf (+10) -> 100 + 10 + 50 = 160
assert(DataService:GetProfile(mockPlayer).AetherEssence == 160, "Essenz nach Verkauf + Tutorial muss 160 sein")

-- 4. Test: Alchemist Skill-Bonus (+15% bei Lvl 5)
DataService:UpdateProfile(mockPlayer, function(data)
    data.Skills.Alchemist = 5
end)

-- 2x FireRuby (20 Essenz * 2 = 40 Basis-Essenz -> +15% = 46 Essenz)
InventoryService:AddOre(mockPlayer, "FireRuby", 2)
local sellResult2 = MerchantService:SellOre(mockPlayer, "FireRuby", 2)
assert(sellResult2.success == true, "FireRuby Verkauf muss erfolgreich sein")
assert(sellResult2.earnedEssence == 46, string.format("Erwartet 46 Essenz (+15%% Bonus), aber %d erhalten", sellResult2.earnedEssence))

-- 5. Test: Trank-Verkauf
-- 1x InfernoPotion (90 Basis-Essenz -> +15% = 104 Essenz)
InventoryService:AddPotion(mockPlayer, "InfernoPotion", 1)
local potionSell = MerchantService:SellPotion(mockPlayer, "InfernoPotion", 1)
assert(potionSell.success == true, "Trankverkauf muss erfolgreich sein")
assert(potionSell.earnedEssence == 104, string.format("Erwartet 104 Essenz für InfernoPotion, aber %d erhalten", potionSell.earnedEssence))
assert(InventoryService:GetPotionCount(mockPlayer, "InfernoPotion") == 0, "Trank muss nach Verkauf aus Inventar entfernt sein")

DataService:UnloadMockProfile(mockPlayer)

print("✅ MerchantService zu 100% erfolgreich validiert!")
