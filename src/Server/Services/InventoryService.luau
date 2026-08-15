--!strict
--[[
    InventoryService.luau
    Aether Alchemist (Element Shapers)
    Server-Singleton für Inventar-Management (Erze, Tränke, Materialien,
    Waffen- & Begleiter-Ausrüstung via EquipWeapon_RF & EquipSummon_RF).
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local Types = require("../../Shared/Config/Types")
local WeaponsConfig = require("../../Shared/Config/WeaponsConfig")
local SummonsConfig = require("../../Shared/Config/SummonsConfig")
local Signal = require("../../Shared/Modules/Signal")
local NetworkContracts = require("../../Shared/Remotes/NetworkContracts")
local DataService = require("./DataService")

export type InventoryServiceType = {
    ItemAdded: Signal.Signal<any, string, number, string>,
    ItemRemoved: Signal.Signal<any, string, number, string>,
    WeaponEquipped: Signal.Signal<any, string>,
    SummonEquipped: Signal.Signal<any, string>,

    Init: (self: any) -> (),
    Start: (self: any) -> (),
    AddOre: (self: any, player: any, oreId: string, amount: number) -> boolean,
    RemoveOre: (self: any, player: any, oreId: string, amount: number) -> boolean,
    GetOreCount: (self: any, player: any, oreId: string) -> number,
    AddPotion: (self: any, player: any, potionId: string, amount: number) -> boolean,
    RemovePotion: (self: any, player: any, potionId: string, amount: number) -> boolean,
    GetPotionCount: (self: any, player: any, potionId: string) -> number,
    AddMaterial: (self: any, player: any, materialId: string, amount: number) -> boolean,
    RemoveMaterial: (self: any, player: any, materialId: string, amount: number) -> boolean,
    GetMaterialCount: (self: any, player: any, materialId: string) -> number,
    EquipWeapon: (self: any, player: any, weaponId: string) -> Types.EquipResult,
    EquipSummon: (self: any, player: any, summonId: string) -> Types.EquipResult,
    UnlockWeapon: (self: any, player: any, weaponId: string) -> boolean,
    UnlockSummon: (self: any, player: any, summonId: string) -> boolean,
}

local InventoryService = {
    ItemAdded = Signal.new(),
    ItemRemoved = Signal.new(),
    WeaponEquipped = Signal.new(),
    SummonEquipped = Signal.new(),

    _initialized = false,
    _started = false,
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("Players") ~= nil
    end)
    return success and result
end

function InventoryService:Init()
    if self._initialized then
        return
    end
    self._initialized = true
end

function InventoryService:Start()
    if self._started then
        return
    end
    self._started = true

    if not isRobloxEngine() then
        return
    end

    local equipWeaponRF = NetworkContracts.GetRemoteFunction("EquipWeapon_RF")
    if equipWeaponRF then
        equipWeaponRF.OnServerInvoke = function(player: any, weaponId: string)
            return self:EquipWeapon(player, weaponId)
        end
    end

    local equipSummonRF = NetworkContracts.GetRemoteFunction("EquipSummon_RF")
    if equipSummonRF then
        equipSummonRF.OnServerInvoke = function(player: any, summonId: string)
            return self:EquipSummon(player, summonId)
        end
    end
end

-- // 1. Erze
function InventoryService:AddOre(player: any, oreId: string, amount: number): boolean
    if amount <= 0 then
        return false
    end

    local success = DataService:UpdateProfile(player, function(profile)
        local current = profile.Inventory.Ores[oreId] or 0
        profile.Inventory.Ores[oreId] = current + amount
        profile.Stats.TotalOresMined += amount
    end)

    if success then
        self.ItemAdded:Fire(player, oreId, amount, "Ore")
    end

    return success
end

function InventoryService:RemoveOre(player: any, oreId: string, amount: number): boolean
    if amount <= 0 then
        return false
    end

    local profile = DataService:GetProfile(player)
    if not profile then
        return false
    end

    local current = profile.Inventory.Ores[oreId] or 0
    if current < amount then
        return false
    end

    local success = DataService:UpdateProfile(player, function(data)
        local newAmount = (data.Inventory.Ores[oreId] or 0) - amount
        if newAmount <= 0 then
            data.Inventory.Ores[oreId] = nil
        else
            data.Inventory.Ores[oreId] = newAmount
        end
    end)

    if success then
        self.ItemRemoved:Fire(player, oreId, amount, "Ore")
    end

    return success
end

function InventoryService:GetOreCount(player: any, oreId: string): number
    local profile = DataService:GetProfile(player)
    if not profile then
        return 0
    end
    return profile.Inventory.Ores[oreId] or 0
end

-- // 2. Tränke
function InventoryService:AddPotion(player: any, potionId: string, amount: number): boolean
    if amount <= 0 then
        return false
    end

    local success = DataService:UpdateProfile(player, function(profile)
        local current = profile.Inventory.Potions[potionId] or 0
        profile.Inventory.Potions[potionId] = current + amount
    end)

    if success then
        self.ItemAdded:Fire(player, potionId, amount, "Potion")
    end

    return success
end

function InventoryService:RemovePotion(player: any, potionId: string, amount: number): boolean
    if amount <= 0 then
        return false
    end

    local profile = DataService:GetProfile(player)
    if not profile then
        return false
    end

    local current = profile.Inventory.Potions[potionId] or 0
    if current < amount then
        return false
    end

    local success = DataService:UpdateProfile(player, function(data)
        local newAmount = (data.Inventory.Potions[potionId] or 0) - amount
        if newAmount <= 0 then
            data.Inventory.Potions[potionId] = nil
        else
            data.Inventory.Potions[potionId] = newAmount
        end
    end)

    if success then
        self.ItemRemoved:Fire(player, potionId, amount, "Potion")
    end

    return success
end

function InventoryService:GetPotionCount(player: any, potionId: string): number
    local profile = DataService:GetProfile(player)
    if not profile then
        return 0
    end
    return profile.Inventory.Potions[potionId] or 0
end

-- // 3. Materialien
function InventoryService:AddMaterial(player: any, materialId: string, amount: number): boolean
    if amount <= 0 then
        return false
    end

    local success = DataService:UpdateProfile(player, function(profile)
        local current = profile.Inventory.Materials[materialId] or 0
        profile.Inventory.Materials[materialId] = current + amount
    end)

    if success then
        self.ItemAdded:Fire(player, materialId, amount, "Material")
    end

    return success
end

function InventoryService:RemoveMaterial(player: any, materialId: string, amount: number): boolean
    if amount <= 0 then
        return false
    end

    local profile = DataService:GetProfile(player)
    if not profile then
        return false
    end

    local current = profile.Inventory.Materials[materialId] or 0
    if current < amount then
        return false
    end

    local success = DataService:UpdateProfile(player, function(data)
        local newAmount = (data.Inventory.Materials[materialId] or 0) - amount
        if newAmount <= 0 then
            data.Inventory.Materials[materialId] = nil
        else
            data.Inventory.Materials[materialId] = newAmount
        end
    end)

    if success then
        self.ItemRemoved:Fire(player, materialId, amount, "Material")
    end

    return success
end

function InventoryService:GetMaterialCount(player: any, materialId: string): number
    local profile = DataService:GetProfile(player)
    if not profile then
        return 0
    end
    return profile.Inventory.Materials[materialId] or 0
end

-- // 4. Waffen & Begleiter Ausrüstung
function InventoryService:EquipWeapon(player: any, weaponId: string): Types.EquipResult
    if not WeaponsConfig.IsValidWeapon(weaponId) then
        return { success = false, equipped = "", error = "Ungültige Waffe" }
    end

    local profile = DataService:GetProfile(player)
    if not profile then
        return { success = false, equipped = "", error = "Profil nicht geladen" }
    end

    local isUnlocked = false
    for _, unlockedId in profile.UnlockedWeapons do
        if unlockedId == weaponId then
            isUnlocked = true
            break
        end
    end

    if not isUnlocked then
        return { success = false, equipped = "", error = "Waffe ist noch nicht freigeschaltet!" }
    end

    DataService:UpdateProfile(player, function(data)
        data.EquippedWeapon = weaponId
    end)

    self.WeaponEquipped:Fire(player, weaponId)
    return { success = true, equipped = weaponId, error = nil }
end

function InventoryService:EquipSummon(player: any, summonId: string): Types.EquipResult
    if not SummonsConfig.IsValidSummon(summonId) then
        return { success = false, equipped = "", error = "Ungültiger Begleiter" }
    end

    local profile = DataService:GetProfile(player)
    if not profile then
        return { success = false, equipped = "", error = "Profil nicht geladen" }
    end

    local isUnlocked = false
    for _, unlockedId in profile.UnlockedSummons do
        if unlockedId == summonId then
            isUnlocked = true
            break
        end
    end

    if not isUnlocked then
        return { success = false, equipped = "", error = "Begleiter ist noch nicht freigeschaltet!" }
    end

    DataService:UpdateProfile(player, function(data)
        data.EquippedSummon = summonId
    end)

    self.SummonEquipped:Fire(player, summonId)
    return { success = true, equipped = summonId, error = nil }
end

function InventoryService:UnlockWeapon(player: any, weaponId: string): boolean
    if not WeaponsConfig.IsValidWeapon(weaponId) then
        return false
    end

    local profile = DataService:GetProfile(player)
    if not profile then
        return false
    end

    for _, id in profile.UnlockedWeapons do
        if id == weaponId then
            return true -- Bereits freigeschaltet
        end
    end

    return DataService:UpdateProfile(player, function(data)
        table.insert(data.UnlockedWeapons, weaponId)
    end)
end

function InventoryService:UnlockSummon(player: any, summonId: string): boolean
    if not SummonsConfig.IsValidSummon(summonId) then
        return false
    end

    local profile = DataService:GetProfile(player)
    if not profile then
        return false
    end

    for _, id in profile.UnlockedSummons do
        if id == summonId then
            return true -- Bereits freigeschaltet
        end
    end

    return DataService:UpdateProfile(player, function(data)
        table.insert(data.UnlockedSummons, summonId)
    end)
end

return InventoryService
