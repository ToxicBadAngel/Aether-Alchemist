--!strict
--[[
    test_inventory_service.luau
    Automatisierter Lune Unit-Test zur Verifikation von InventoryService.luau.
]]

local DataService = require("../src/Server/Services/DataService")
local InventoryService = require("../src/Server/Services/InventoryService")

print("🧪 Starte InventoryService Verifikation...")

-- 1. Test: Init & Start
DataService:Init()
DataService:Start()
InventoryService:Init()
InventoryService:Start()

local mockPlayer = {
    UserId = 87654321,
    Name = "TestMiner",
}

DataService:LoadMockProfile(mockPlayer)

-- 2. Test: Erz-Management
assert(InventoryService:GetOreCount(mockPlayer, "EarthTopaz") == 5, "Start-Erze müssen 5 EarthTopaz sein")

local addOreSuccess = InventoryService:AddOre(mockPlayer, "FireRuby", 3)
assert(addOreSuccess == true, "Hinzufügen von 3 FireRuby muss erfolgreich sein")
assert(InventoryService:GetOreCount(mockPlayer, "FireRuby") == 3, "FireRuby Count muss 3 sein")

local removeOreSuccess = InventoryService:RemoveOre(mockPlayer, "FireRuby", 2)
assert(removeOreSuccess == true, "Entfernen von 2 FireRuby muss erfolgreich sein")
assert(InventoryService:GetOreCount(mockPlayer, "FireRuby") == 1, "FireRuby Count muss nach Abzug 1 sein")

local removeTooMany = InventoryService:RemoveOre(mockPlayer, "FireRuby", 5)
assert(removeTooMany == false, "Entfernen von mehr Erzen als vorhanden muss abgewiesen werden")
assert(InventoryService:GetOreCount(mockPlayer, "FireRuby") == 1, "Anzahl darf sich bei Fehlschlag nicht ändern")

-- 3. Test: Trank-Management
local addPotionSuccess = InventoryService:AddPotion(mockPlayer, "InfernoPotion", 2)
assert(addPotionSuccess == true, "Trank hinzufügen muss erfolgreich sein")
assert(InventoryService:GetPotionCount(mockPlayer, "InfernoPotion") == 2, "Trank Count muss 2 sein")

local removePotionSuccess = InventoryService:RemovePotion(mockPlayer, "InfernoPotion", 1)
assert(removePotionSuccess == true, "Trank entfernen muss erfolgreich sein")
assert(InventoryService:GetPotionCount(mockPlayer, "InfernoPotion") == 1, "Trank Count muss 1 sein")

-- 4. Test: Material-Management
InventoryService:AddMaterial(mockPlayer, "ColossusCore", 1)
assert(InventoryService:GetMaterialCount(mockPlayer, "ColossusCore") == 1, "Material Count muss 1 sein")

-- 5. Test: Waffen-Ausrüstung (Gesperrt -> Entsperrt -> Ausgerüstet)
local equipDefault = InventoryService:EquipWeapon(mockPlayer, "BasicBlade")
assert(equipDefault.success == true and equipDefault.equipped == "BasicBlade", "Standardwaffe muss ausrüstbar sein")

local equipLocked = InventoryService:EquipWeapon(mockPlayer, "FireSaber")
assert(equipLocked.success == false, "Gesperrte Waffe darf nicht ausrüstbar sein")

InventoryService:UnlockWeapon(mockPlayer, "FireSaber")
local equipUnlocked = InventoryService:EquipWeapon(mockPlayer, "FireSaber")
assert(equipUnlocked.success == true and equipUnlocked.equipped == "FireSaber", "Nach Freischaltung muss Waffe ausrüstbar sein")
assert(DataService:GetProfile(mockPlayer).EquippedWeapon == "FireSaber", "EquippedWeapon im Profil muss aktualisiert sein")

-- 6. Test: Begleiter-Ausrüstung
local equipLockedSummon = InventoryService:EquipSummon(mockPlayer, "IceGolem")
assert(equipLockedSummon.success == false, "Gesperrter Begleiter darf nicht ausrüstbar sein")

InventoryService:UnlockSummon(mockPlayer, "IceGolem")
local equipUnlockedSummon = InventoryService:EquipSummon(mockPlayer, "IceGolem")
assert(equipUnlockedSummon.success == true and equipUnlockedSummon.equipped == "IceGolem", "Nach Freischaltung muss Begleiter ausrüstbar sein")
assert(DataService:GetProfile(mockPlayer).EquippedSummon == "IceGolem", "EquippedSummon im Profil muss aktualisiert sein")

DataService:UnloadMockProfile(mockPlayer)

print("✅ InventoryService zu 100% erfolgreich validiert!")
