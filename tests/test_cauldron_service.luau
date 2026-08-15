--!strict
--[[
    test_cauldron_service.luau
    Automatisierter Lune Unit-Test zur Verifikation von CauldronService.luau.
]]

local DataService = require("../src/Server/Services/DataService")
local InventoryService = require("../src/Server/Services/InventoryService")
local CauldronService = require("../src/Server/Services/CauldronService")

print("🧪 Starte CauldronService Verifikation...")

-- 1. Test: Initialisierung
DataService:Init()
DataService:Start()
InventoryService:Init()
InventoryService:Start()
CauldronService:Init()
CauldronService:Start()

local mockPlayer = {
    UserId = 55443322,
    Name = "MasterAlchemist",
}

DataService:LoadMockProfile(mockPlayer)

-- 2. Test: Crafting mit fehlenden Zutaten
local failCraft = CauldronService:CraftPotion(mockPlayer, "InfernoPotion")
assert(failCraft.success == false, "Crafting ohne Zutaten muss fehlschlagen")
assert(failCraft.error == "Nicht genügend Erze im Inventar!", "Fehlermeldung für fehlende Erze inkorrekt")

-- 3. Test: Zutaten bereitstellen & Inferno-Trank brauen
InventoryService:AddOre(mockPlayer, "FireRuby", 2)
InventoryService:AddOre(mockPlayer, "WindEmerald", 1)

local successCraft = CauldronService:CraftPotion(mockPlayer, "InfernoPotion")
assert(successCraft.success == true, "Crafting mit korrekten Zutaten muss erfolgreich sein")
assert(successCraft.craftedItem == "InfernoPotion", "Gebrauter Trank muss InfernoPotion sein")
assert(InventoryService:GetPotionCount(mockPlayer, "InfernoPotion") == 1, "Inventar muss 1 InfernoPotion enthalten")
assert(InventoryService:GetOreCount(mockPlayer, "FireRuby") == 0, "Zutaten müssen nach Brauen verbraucht sein")

-- 4. Test: Trank trinken & Buff-Aktivierung
local drinkResult = CauldronService:DrinkPotion(mockPlayer, "InfernoPotion")
assert(drinkResult.success == true, "Trank trinken muss erfolgreich sein")
assert(drinkResult.appliedBuff == "DamageBoost", "Angewendeter Buff muss DamageBoost sein")
assert(InventoryService:GetPotionCount(mockPlayer, "InfernoPotion") == 0, "Trank muss nach Trinken aus Inventar verschwinden")

local damageMultiplier = CauldronService:GetBuffMagnitude(mockPlayer, "DamageBoost")
assert(math.abs(damageMultiplier - 0.20) < 0.001, "Schadens-Buff Magnitude muss 0.20 (+20%) sein")

-- 5. Test: Gletscher-Schutz (Schild-Pool) & Schadens-Absorption
InventoryService:AddOre(mockPlayer, "OceanSapphire", 2)
InventoryService:AddOre(mockPlayer, "EarthTopaz", 1)

local shieldCraft = CauldronService:CraftPotion(mockPlayer, "GlacierShield")
assert(shieldCraft.success == true, "Gletscher-Schutz Crafting muss erfolgreich sein")

local shieldDrink = CauldronService:DrinkPotion(mockPlayer, "GlacierShield")
assert(shieldDrink.success == true and shieldDrink.appliedBuff == "Shield", "Schild muss aktiv sein")

-- 40 Schaden absorbieren (100 Schild -> 60 Rest-Schild, 0 Restschaden)
local remainingDmg1 = CauldronService:ConsumeShield(mockPlayer, 40)
assert(remainingDmg1 == 0, "40 Schaden müssen vollständig absorbiert werden")

local activeShield = CauldronService:GetActiveBuff(mockPlayer, "GlacierShield")
assert(activeShield ~= nil and activeShield.ShieldHp == 60, "Schild-HP muss nach 40 DMG auf 60 sinken")

-- 80 Schaden absorbieren (60 Rest-Schild -> 0 Schild, 20 Restschaden)
local remainingDmg2 = CauldronService:ConsumeShield(mockPlayer, 80)
assert(remainingDmg2 == 20, "Nach Erschöpfung des Schilds müssen 20 Restschaden übrig bleiben")
assert(CauldronService:GetActiveBuff(mockPlayer, "GlacierShield") == nil, "Erschöpfter Schild muss entfernt werden")

DataService:UnloadMockProfile(mockPlayer)

print("✅ CauldronService zu 100% erfolgreich validiert!")
