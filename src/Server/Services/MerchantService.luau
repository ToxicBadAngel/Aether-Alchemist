--!strict
--[[
    MerchantService.luau
    Aether Alchemist (Element Shapers)
    Server-Singleton für Händler-Verkäufe (SellOre_RF, Alchemist-Skill Bonus,
    Bestands-Validierung, Tutorial-Fortschritt und Essenz-Gutschrift).
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local Types = require("../../Shared/Config/Types")
local OresConfig = require("../../Shared/Config/OresConfig")
local RecipesConfig = require("../../Shared/Config/RecipesConfig")
local Signal = require("../../Shared/Modules/Signal")
local MathUtils = require("../../Shared/Modules/MathUtils")
local NetworkContracts = require("../../Shared/Remotes/NetworkContracts")
local DataService = require("./DataService")
local InventoryService = require("./InventoryService")

export type MerchantServiceType = {
    OreSold: Signal.Signal<any, string, number, number>,
    PotionSold: Signal.Signal<any, string, number, number>,

    Init: (self: any) -> (),
    Start: (self: any) -> (),
    SellOre: (self: any, player: any, oreId: string, amount: number) -> Types.SellResult,
    SellPotion: (self: any, player: any, potionId: string, amount: number) -> Types.SellResult,
}

local MerchantService = {
    OreSold = Signal.new(),
    PotionSold = Signal.new(),

    _initialized = false,
    _started = false,
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("Players") ~= nil
    end)
    return success and result
end

function MerchantService:Init()
    if self._initialized then
        return
    end
    self._initialized = true
end

function MerchantService:Start()
    if self._started then
        return
    end
    self._started = true

    if not isRobloxEngine() then
        return
    end

    local sellOreRF = NetworkContracts.GetRemoteFunction("SellOre_RF")
    if sellOreRF then
        sellOreRF.OnServerInvoke = function(player: any, oreId: string, amount: number)
            return self:SellOre(player, oreId, amount)
        end
    end
end

function MerchantService:SellOre(player: any, oreId: string, amount: number): Types.SellResult
    -- 1. Validierung: Erz-ID & Menge
    if not OresConfig.IsValidOre(oreId) then
        return { success = false, earnedEssence = 0, error = "Ungültiges Erz!" }
    end

    if amount <= 0 or amount ~= math.floor(amount) then
        return { success = false, earnedEssence = 0, error = "Ungültige Anzahl!" }
    end

    local oreConfig = OresConfig.Get(oreId :: Types.OreId)
    if not oreConfig then
        return { success = false, earnedEssence = 0, error = "Erz-Konfiguration nicht gefunden!" }
    end

    -- 2. Transaktions-Mutex
    local lockAcquired = DataService:AcquireLock(player)
    if not lockAcquired then
        return { success = false, earnedEssence = 0, error = "Aktion wird bereits ausgeführt!" }
    end

    local profile = DataService:GetProfile(player)
    if not profile then
        DataService:ReleaseLock(player)
        return { success = false, earnedEssence = 0, error = "Profil nicht geladen!" }
    end

    -- 3. Bestands-Prüfung
    local currentOreCount = InventoryService:GetOreCount(player, oreId)
    if currentOreCount < amount then
        DataService:ReleaseLock(player)
        return { success = false, earnedEssence = 0, error = "Nicht genügend Erze im Inventar!" }
    end

    -- 4. Erze abziehen
    local removeSuccess = InventoryService:RemoveOre(player, oreId, amount)
    if not removeSuccess then
        DataService:ReleaseLock(player)
        return { success = false, earnedEssence = 0, error = "Konnte Erze nicht abziehen!" }
    end

    -- 5. Essenz-Kalkulation mit Alchemist-Skill Bonus (+3% pro Skill-Punkt)
    local baseEssence = oreConfig.SellPrice * amount
    local totalEssence = MathUtils.CalculateEssenceBonus(baseEssence, profile.Skills.Alchemist)

    -- 6. Essenz gutschreiben
    DataService:AddEssence(player, totalEssence)

    -- 7. Tutorial-Fortschritt (Schritt 2: Verkaufe 1 Erz)
    if not profile.Tutorial.Step2Completed then
        DataService:UpdateProfile(player, function(data)
            data.Tutorial.Step2Completed = true
            data.AetherEssence += 50
        end)
    end

    -- 8. Mutex freigeben & Signal
    DataService:ReleaseLock(player)
    self.OreSold:Fire(player, oreId, amount, totalEssence)

    return {
        success = true,
        earnedEssence = totalEssence,
        error = nil,
    }
end

function MerchantService:SellPotion(player: any, potionId: string, amount: number): Types.SellResult
    -- 1. Validierung: Trank-ID & Menge
    if not RecipesConfig.IsValidRecipe(potionId) then
        return { success = false, earnedEssence = 0, error = "Ungültiger Trank!" }
    end

    if amount <= 0 or amount ~= math.floor(amount) then
        return { success = false, earnedEssence = 0, error = "Ungültige Anzahl!" }
    end

    local recipeConfig = RecipesConfig.Get(potionId :: Types.PotionId)
    if not recipeConfig then
        return { success = false, earnedEssence = 0, error = "Rezept-Konfiguration nicht gefunden!" }
    end

    -- 2. Transaktions-Mutex
    local lockAcquired = DataService:AcquireLock(player)
    if not lockAcquired then
        return { success = false, earnedEssence = 0, error = "Aktion wird bereits ausgeführt!" }
    end

    local profile = DataService:GetProfile(player)
    if not profile then
        DataService:ReleaseLock(player)
        return { success = false, earnedEssence = 0, error = "Profil nicht geladen!" }
    end

    -- 3. Bestands-Prüfung
    local currentPotionCount = InventoryService:GetPotionCount(player, potionId)
    if currentPotionCount < amount then
        DataService:ReleaseLock(player)
        return { success = false, earnedEssence = 0, error = "Nicht genügend Tränke im Inventar!" }
    end

    -- 4. Tränke abziehen
    local removeSuccess = InventoryService:RemovePotion(player, potionId, amount)
    if not removeSuccess then
        DataService:ReleaseLock(player)
        return { success = false, earnedEssence = 0, error = "Konnte Tränke nicht abziehen!" }
    end

    -- 5. Essenz-Kalkulation
    local baseEssence = recipeConfig.SellPrice * amount
    local totalEssence = MathUtils.CalculateEssenceBonus(baseEssence, profile.Skills.Alchemist)

    -- 6. Essenz gutschreiben
    DataService:AddEssence(player, totalEssence)

    -- 7. Mutex freigeben & Signal
    DataService:ReleaseLock(player)
    self.PotionSold:Fire(player, potionId, amount, totalEssence)

    return {
        success = true,
        earnedEssence = totalEssence,
        error = nil,
    }
end

return MerchantService
