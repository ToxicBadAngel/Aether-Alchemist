--!strict
--[[
    DataController.luau
    Aether Alchemist (Element Shapers)
    Client-Singleton für lokale Profil-Replikation & reaktive UI-Signale.
    Abonniert ProfileSync_RE und stellt granulare Event-Streams für die UI bereit.
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local Types = require("../../Shared/Config/Types")
local Signal = require("../../Shared/Modules/Signal")
local MathUtils = require("../../Shared/Modules/MathUtils")
local NetworkContracts = require("../../Shared/Remotes/NetworkContracts")

export type DataControllerType = {
    ProfileChanged: Signal.Signal<Types.PlayerProfileData>,
    EssenceChanged: Signal.Signal<number, number>,
    LevelChanged: Signal.Signal<number, number, number>,
    InventoryChanged: Signal.Signal<Types.PlayerInventory>,
    WeaponChanged: Signal.Signal<string>,
    SummonChanged: Signal.Signal<string>,

    Init: (self: any) -> (),
    Start: (self: any) -> (),
    GetProfile: (self: any) -> Types.PlayerProfileData?,
    GetEssence: (self: any) -> number,
    GetLevel: (self: any) -> number,
    GetXP: (self: any) -> (number, number),
    GetInventory: (self: any) -> Types.PlayerInventory?,
    GetOreCount: (self: any, oreId: string) -> number,
    GetPotionCount: (self: any, potionId: string) -> number,
    GetEquippedWeapon: (self: any) -> string,
    GetEquippedSummon: (self: any) -> string,
    IsWeaponUnlocked: (self: any, weaponId: string) -> boolean,
    IsSummonUnlocked: (self: any, summonId: string) -> boolean,
    SetLocalProfile: (self: any, newProfile: Types.PlayerProfileData) -> (),
}

local DataController = {
    ProfileChanged = Signal.new(),
    EssenceChanged = Signal.new(),
    LevelChanged = Signal.new(),
    InventoryChanged = Signal.new(),
    WeaponChanged = Signal.new(),
    SummonChanged = Signal.new(),

    _profile = nil :: Types.PlayerProfileData?,
    _initialized = false,
    _started = false,
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("Players") ~= nil and game:GetService("Players").LocalPlayer ~= nil
    end)
    return success and result
end

function DataController:Init()
    if self._initialized then
        return
    end
    self._initialized = true
end

function DataController:Start()
    if self._started then
        return
    end
    self._started = true

    if not isRobloxEngine() then
        return
    end

    local syncRE = NetworkContracts.GetRemoteEvent("ProfileSync_RE")
    if syncRE then
        syncRE.OnClientEvent:Connect(function(newProfile: Types.PlayerProfileData)
            self:SetLocalProfile(newProfile)
        end)
    end
end

function DataController:SetLocalProfile(newProfile: Types.PlayerProfileData)
    local oldProfile = self._profile
    self._profile = newProfile

    -- Vollständiges Profil Signal
    self.ProfileChanged:Fire(newProfile)

    -- Granulare Deltas für performante UI-Updates
    if not oldProfile or oldProfile.AetherEssence ~= newProfile.AetherEssence then
        local delta = if oldProfile then newProfile.AetherEssence - oldProfile.AetherEssence else newProfile.AetherEssence
        self.EssenceChanged:Fire(newProfile.AetherEssence, delta)
    end

    if not oldProfile or oldProfile.Level ~= newProfile.Level or oldProfile.XP ~= newProfile.XP then
        local reqXP = MathUtils.GetRequiredXP(newProfile.Level)
        self.LevelChanged:Fire(newProfile.Level, newProfile.XP, reqXP)
    end

    if not oldProfile or oldProfile.Inventory ~= newProfile.Inventory then
        self.InventoryChanged:Fire(newProfile.Inventory)
    end

    if not oldProfile or oldProfile.EquippedWeapon ~= newProfile.EquippedWeapon then
        self.WeaponChanged:Fire(newProfile.EquippedWeapon)
    end

    if not oldProfile or oldProfile.EquippedSummon ~= newProfile.EquippedSummon then
        self.SummonChanged:Fire(newProfile.EquippedSummon)
    end
end

function DataController:GetProfile(): Types.PlayerProfileData?
    return self._profile
end

function DataController:GetEssence(): number
    return if self._profile then self._profile.AetherEssence else 0
end

function DataController:GetLevel(): number
    return if self._profile then self._profile.Level else 1
end

function DataController:GetXP(): (number, number)
    if not self._profile then
        return 0, 100
    end
    local reqXP = MathUtils.GetRequiredXP(self._profile.Level)
    return self._profile.XP, reqXP
end

function DataController:GetInventory(): Types.PlayerInventory?
    return if self._profile then self._profile.Inventory else nil
end

function DataController:GetOreCount(oreId: string): number
    if not self._profile or not self._profile.Inventory or not self._profile.Inventory.Ores then
        return 0
    end
    return self._profile.Inventory.Ores[oreId] or 0
end

function DataController:GetPotionCount(potionId: string): number
    if not self._profile or not self._profile.Inventory or not self._profile.Inventory.Potions then
        return 0
    end
    return self._profile.Inventory.Potions[potionId] or 0
end

function DataController:GetEquippedWeapon(): string
    return if self._profile then self._profile.EquippedWeapon else "BasicBlade"
end

function DataController:GetEquippedSummon(): string
    return if self._profile then self._profile.EquippedSummon else "FirePhoenix"
end

function DataController:IsWeaponUnlocked(weaponId: string): boolean
    if not self._profile then
        return false
    end
    for _, id in self._profile.UnlockedWeapons do
        if id == weaponId then
            return true
        end
    end
    return false
end

function DataController:IsSummonUnlocked(summonId: string): boolean
    if not self._profile then
        return false
    end
    for _, id in self._profile.UnlockedSummons do
        if id == summonId then
            return true
        end
    end
    return false
end

return DataController
