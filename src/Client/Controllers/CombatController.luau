--!strict
--[[
    CombatController.luau
    Aether Alchemist (Element Shapers)
    Client-Singleton für Nahkampf-Steuerung (M1-Klick, Cooldown-Gate, Target-Erkennung,
    AttackSwing_RE, Begleiter-Auslösung via CastSummon_RE und CombatFeedback_RE Empfang).
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local Types = require("../../Shared/Config/Types")
local WeaponsConfig = require("../../Shared/Config/WeaponsConfig")
local SummonsConfig = require("../../Shared/Config/SummonsConfig")
local Signal = require("../../Shared/Modules/Signal")
local MathUtils = require("../../Shared/Modules/MathUtils")
local NetworkContracts = require("../../Shared/Remotes/NetworkContracts")
local DataController = require("./DataController")

export type CombatControllerType = {
    AttackAttempted: Signal.Signal<string>,
    AttackPerformed: Signal.Signal<string, any?>,
    SummonTriggered: Signal.Signal<string>,
    DamageFeedbackReceived: Signal.Signal<Types.CombatFeedbackData>,

    Init: (self: any) -> (),
    Start: (self: any) -> (),
    PerformAttack: (self: any, targetMobInstance: any?, customPlayerPos: Types.Vector3Data?, targetPos: Types.Vector3Data?) -> boolean,
    CastSummon: (self: any) -> boolean,
    CanAttack: (self: any) -> boolean,
    CanCastSummon: (self: any) -> boolean,
}

local CombatController = {
    AttackAttempted = Signal.new(),
    AttackPerformed = Signal.new(),
    SummonTriggered = Signal.new(),
    DamageFeedbackReceived = Signal.new(),

    _lastAttackTime = 0,
    _lastSummonTime = 0,
    _initialized = false,
    _started = false,
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("Players") ~= nil and game:GetService("Players").LocalPlayer ~= nil
    end)
    return success and result
end

function CombatController:Init()
    if self._initialized then
        return
    end
    self._initialized = true
end

function CombatController:Start()
    if self._started then
        return
    end
    self._started = true

    if not isRobloxEngine() then
        return
    end

    -- Feedback-Remote abonnieren (Schadenszahlen & Screenshake)
    local feedbackRE = NetworkContracts.GetRemoteEvent("CombatFeedback_RE")
    if feedbackRE then
        feedbackRE.OnClientEvent:Connect(function(feedbackData: Types.CombatFeedbackData)
            self.DamageFeedbackReceived:Fire(feedbackData)
        end)
    end

    -- UserInputService für M1-Klick & Tastatur
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(input: any, gameProcessed: boolean)
        if gameProcessed then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.F then
            self:PerformAttack()
        elseif input.KeyCode == Enum.KeyCode.Q then
            self:CastSummon()
        end
    end)
end

function CombatController:CanAttack(): boolean
    local weaponId = DataController:GetEquippedWeapon()
    local weaponConfig = WeaponsConfig.Get(weaponId :: Types.WeaponId)
    if not weaponConfig then
        return false
    end

    local currentTime = os.clock()
    return (currentTime - self._lastAttackTime) >= weaponConfig.AttackCooldown
end

function CombatController:CanCastSummon(): boolean
    local summonId = DataController:GetEquippedSummon()
    local summonConfig = SummonsConfig.Get(summonId :: Types.SummonId)
    if not summonConfig then
        return false
    end

    local profile = DataController:GetProfile()
    local summonerLevel = if profile then profile.Skills.Summoner else 0
    local reducedCD = MathUtils.CalculateSummonCooldown(summonConfig.Cooldown, summonerLevel)

    local currentTime = os.clock()
    return (currentTime - self._lastSummonTime) >= reducedCD
end

function CombatController:PerformAttack(
    targetMobInstance: any?,
    customPlayerPos: Types.Vector3Data?,
    targetPos: Types.Vector3Data?
): boolean
    local weaponId = DataController:GetEquippedWeapon()
    local weaponConfig = WeaponsConfig.Get(weaponId :: Types.WeaponId)
    if not weaponConfig then
        return false
    end

    local currentTime = os.clock()
    if (currentTime - self._lastAttackTime) < weaponConfig.AttackCooldown then
        self.AttackAttempted:Fire(weaponId)
        return false
    end

    -- Reichweiten-Prüfung wenn Target-Position übergeben wurde
    if customPlayerPos and targetPos then
        if not MathUtils.IsWithinDistance(customPlayerPos, targetPos, weaponConfig.AttackRange) then
            return false
        end
    end

    self._lastAttackTime = currentTime
    self.AttackPerformed:Fire(weaponId, targetMobInstance)

    if isRobloxEngine() then
        local attackRE = NetworkContracts.GetRemoteEvent("AttackSwing_RE")
        if attackRE then
            attackRE:FireServer(targetMobInstance)
        end
    end

    return true
end

function CombatController:CastSummon(): boolean
    local summonId = DataController:GetEquippedSummon()
    local summonConfig = SummonsConfig.Get(summonId :: Types.SummonId)
    if not summonConfig then
        return false
    end

    if not self:CanCastSummon() then
        return false
    end

    self._lastSummonTime = os.clock()
    self.SummonTriggered:Fire(summonId)

    if isRobloxEngine() then
        local summonRE = NetworkContracts.GetRemoteEvent("CastSummon_RE")
        if summonRE then
            summonRE:FireServer()
        end
    end

    return true
end

return CombatController
