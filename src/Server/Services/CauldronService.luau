--!strict
--[[
    CauldronService.luau
    Aether Alchemist (Element Shapers)
    Server-Singleton für Alchemie-Kessel (CraftPotion_RF, DrinkPotion_RF,
    Zutaten-Verifikation, Buff-Verwaltung mit Verfalls-Timern und Schild-Pool).
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local Types = require("../../Shared/Config/Types")
local RecipesConfig = require("../../Shared/Config/RecipesConfig")
local Signal = require("../../Shared/Modules/Signal")
local NetworkContracts = require("../../Shared/Remotes/NetworkContracts")
local DataService = require("./DataService")
local InventoryService = require("./InventoryService")

export type CauldronServiceType = {
    PotionCrafted: Signal.Signal<any, string>,
    BuffApplied: Signal.Signal<any, string, string, number, number>,
    BuffExpired: Signal.Signal<any, string, string>,

    Init: (self: any) -> (),
    Start: (self: any) -> (),
    CraftPotion: (self: any, player: any, recipeId: Types.PotionId) -> Types.CraftResult,
    DrinkPotion: (self: any, player: any, potionId: Types.PotionId) -> Types.PotionResult,
    GetActiveBuff: (self: any, player: any, potionId: string) -> Types.ActiveBuff?,
    GetBuffMagnitude: (self: any, player: any, buffType: Types.BuffType) -> number,
    ConsumeShield: (self: any, player: any, incomingDamage: number) -> number,
}

local CauldronService = {
    PotionCrafted = Signal.new(),
    BuffApplied = Signal.new(),
    BuffExpired = Signal.new(),

    _initialized = false,
    _started = false,
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("Players") ~= nil
    end)
    return success and result
end

function CauldronService:Init()
    if self._initialized then
        return
    end
    self._initialized = true
end

function CauldronService:Start()
    if self._started then
        return
    end
    self._started = true

    if not isRobloxEngine() then
        return
    end

    local craftPotionRF = NetworkContracts.GetRemoteFunction("CraftPotion_RF")
    if craftPotionRF then
        craftPotionRF.OnServerInvoke = function(player: any, recipeId: string)
            return self:CraftPotion(player, recipeId :: Types.PotionId)
        end
    end

    local drinkPotionRF = NetworkContracts.GetRemoteFunction("DrinkPotion_RF")
    if drinkPotionRF then
        drinkPotionRF.OnServerInvoke = function(player: any, potionId: string)
            return self:DrinkPotion(player, potionId :: Types.PotionId)
        end
    end
end

function CauldronService:CraftPotion(player: any, recipeId: Types.PotionId): Types.CraftResult
    -- 1. Validierung: Rezept existiert
    local recipe = RecipesConfig.Get(recipeId)
    if not recipe then
        return { success = false, craftedItem = nil, error = "Ungültiges Rezept!" }
    end

    -- 2. Transaktions-Mutex
    local lockAcquired = DataService:AcquireLock(player)
    if not lockAcquired then
        return { success = false, craftedItem = nil, error = "Aktion wird bereits ausgeführt!" }
    end

    local profile = DataService:GetProfile(player)
    if not profile then
        DataService:ReleaseLock(player)
        return { success = false, craftedItem = nil, error = "Profil nicht geladen!" }
    end

    -- 3. Zutaten-Prüfung
    if not RecipesConfig.CanCraft(recipeId, profile.Inventory.Ores) then
        DataService:ReleaseLock(player)
        return { success = false, craftedItem = nil, error = "Nicht genügend Erze im Inventar!" }
    end

    -- 4. Zutaten abziehen
    for oreId, requiredAmount in recipe.Ingredients do
        InventoryService:RemoveOre(player, oreId, requiredAmount)
    end

    -- 5. Trank hinzufügen
    InventoryService:AddPotion(player, recipeId, 1)

    -- 6. XP & Statistik
    local xpEarned = recipe.SellPrice * 2
    DataService:AddXP(player, xpEarned)

    DataService:UpdateProfile(player, function(data)
        data.Stats.TotalPotionsCrafted += 1

        -- Tutorial Schritt 3: Braue 1 Trank
        if not data.Tutorial.Step3Completed then
            data.Tutorial.Step3Completed = true
            data.AetherEssence += 50
        end
    end)

    -- 7. Mutex freigeben & Signal
    DataService:ReleaseLock(player)
    self.PotionCrafted:Fire(player, recipeId)

    return {
        success = true,
        craftedItem = recipeId,
        error = nil,
    }
end

function CauldronService:DrinkPotion(player: any, potionId: Types.PotionId): Types.PotionResult
    -- 1. Validierung: Rezept & Trank
    local recipe = RecipesConfig.Get(potionId)
    if not recipe then
        return { success = false, appliedBuff = nil, duration = 0, error = "Ungültiger Trank!" }
    end

    -- 2. Transaktions-Mutex
    local lockAcquired = DataService:AcquireLock(player)
    if not lockAcquired then
        return { success = false, appliedBuff = nil, duration = 0, error = "Aktion wird bereits ausgeführt!" }
    end

    local count = InventoryService:GetPotionCount(player, potionId)
    if count < 1 then
        DataService:ReleaseLock(player)
        return { success = false, appliedBuff = nil, duration = 0, error = "Trank nicht im Inventar!" }
    end

    -- 3. Trank konsumieren
    InventoryService:RemovePotion(player, potionId, 1)

    -- 4. Buff anwenden
    local currentTime = os.time()
    local expiresAt = if recipe.Duration > 0 then currentTime + recipe.Duration else 0
    local shieldAmount = if recipe.BuffType == "Shield" then recipe.Magnitude else nil

    DataService:UpdateProfile(player, function(data)
        data.ActiveBuffs[potionId] = {
            BuffType = recipe.BuffType,
            Magnitude = recipe.Magnitude,
            ExpiresAt = expiresAt,
            ShieldHp = shieldAmount,
        }
    end)

    -- 5. Mutex freigeben & Signal
    DataService:ReleaseLock(player)
    self.BuffApplied:Fire(player, potionId, recipe.BuffType, recipe.Magnitude, recipe.Duration)

    return {
        success = true,
        appliedBuff = recipe.BuffType,
        duration = recipe.Duration,
        error = nil,
    }
end

function CauldronService:GetActiveBuff(player: any, potionId: string): Types.ActiveBuff?
    local profile = DataService:GetProfile(player)
    if not profile or not profile.ActiveBuffs[potionId] then
        return nil
    end

    local buff = profile.ActiveBuffs[potionId]
    if buff.ExpiresAt > 0 and os.time() > buff.ExpiresAt then
        -- Buff ist abgelaufen -> Bereinigen
        DataService:UpdateProfile(player, function(data)
            data.ActiveBuffs[potionId] = nil
        end)
        self.BuffExpired:Fire(player, potionId, buff.BuffType)
        return nil
    end

    return buff
end

function CauldronService:GetBuffMagnitude(player: any, buffType: Types.BuffType): number
    local profile = DataService:GetProfile(player)
    if not profile then
        return 0
    end

    local totalMagnitude = 0
    local currentTime = os.time()

    for potionId, buff in profile.ActiveBuffs do
        if buff.BuffType == buffType then
            if buff.ExpiresAt == 0 or currentTime <= buff.ExpiresAt then
                totalMagnitude += buff.Magnitude
            else
                -- Abgelaufenen Buff aufräumen
                task.spawn(function()
                    DataService:UpdateProfile(player, function(data)
                        data.ActiveBuffs[potionId] = nil
                    end)
                    self.BuffExpired:Fire(player, potionId, buffType)
                end)
            end
        end
    end

    return totalMagnitude
end

function CauldronService:ConsumeShield(player: any, incomingDamage: number): number
    local profile = DataService:GetProfile(player)
    if not profile or incomingDamage <= 0 then
        return incomingDamage
    end

    local remainingDamage = incomingDamage

    for potionId, buff in profile.ActiveBuffs do
        if buff.BuffType == "Shield" and buff.ShieldHp and buff.ShieldHp > 0 then
            local absorbed = math.min(remainingDamage, buff.ShieldHp)
            local newShieldHp = buff.ShieldHp - absorbed
            remainingDamage -= absorbed

            DataService:UpdateProfile(player, function(data)
                local b = data.ActiveBuffs[potionId]
                if b then
                    if newShieldHp <= 0 then
                        data.ActiveBuffs[potionId] = nil
                    else
                        b.ShieldHp = newShieldHp
                    end
                end
            end)

            if newShieldHp <= 0 then
                self.BuffExpired:Fire(player, potionId, "Shield")
            end

            if remainingDamage <= 0 then
                break
            end
        end
    end

    return remainingDamage
end

return CauldronService
