--!strict
--[[
    CombatService.luau
    Aether Alchemist (Element Shapers)
    Server-Singleton für Kampfsystem (AttackSwing_RE, CastSummon_RE,
    Cooldown-Tracking, Server-Treffer-Validierung <= 15 Studs, Trank-Boni,
    Kritische Treffer, Mob-HP-Abzug, Beute-Drops und CombatFeedback_RE).
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local Types = require("../../Shared/Config/Types")
local OresConfig = require("../../Shared/Config/OresConfig")
local RecipesConfig = require("../../Shared/Config/RecipesConfig")
local WeaponsConfig = require("../../Shared/Config/WeaponsConfig")
local SummonsConfig = require("../../Shared/Config/SummonsConfig")
local MobsConfig = require("../../Shared/Config/MobsConfig")
local Signal = require("../../Shared/Modules/Signal")
local MathUtils = require("../../Shared/Modules/MathUtils")
local NetworkContracts = require("../../Shared/Remotes/NetworkContracts")
local DataService = require("./DataService")
local InventoryService = require("./InventoryService")
local CauldronService = require("./CauldronService")

export type ActiveMob = {
    Instance: any,
    MobId: Types.MobId,
    CurrentHp: number,
    MaxHp: number,
    Position: Types.Vector3Data,
    IsDead: boolean,
}

export type CombatServiceType = {
    DamageDealt: Signal.Signal<any, any, number, boolean>,
    MobKilled: Signal.Signal<any, any, Types.MobId>,
    SummonCast: Signal.Signal<any, string>,

    Init: (self: any) -> (),
    Start: (self: any) -> (),
    RegisterMob: (self: any, mobInstance: any, mobId: Types.MobId, position: Types.Vector3Data, hp: number?) -> ActiveMob,
    UnregisterMob: (self: any, mobInstance: any) -> (),
    GetMob: (self: any, mobInstance: any) -> ActiveMob?,
    ProcessAttack: (self: any, player: any, targetMobInstance: any, customPlayerPos: Types.Vector3Data?) -> boolean,
    ProcessSummonCast: (self: any, player: any) -> boolean,
}

local CombatService = {
    DamageDealt = Signal.new(),
    MobKilled = Signal.new(),
    SummonCast = Signal.new(),

    _activeMobs = {} :: { [any]: ActiveMob },
    _lastAttackTimes = {} :: { [any]: number },
    _lastSummonTimes = {} :: { [any]: number },
    _initialized = false,
    _started = false,
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("Players") ~= nil
    end)
    return success and result
end

function CombatService:Init()
    if self._initialized then
        return
    end
    self._initialized = true
end

function CombatService:Start()
    if self._started then
        return
    end
    self._started = true

    if not isRobloxEngine() then
        return
    end

    local attackRE = NetworkContracts.GetRemoteEvent("AttackSwing_RE")
    if attackRE then
        attackRE.OnServerEvent:Connect(function(player: any, targetMobInstance: any)
            self:ProcessAttack(player, targetMobInstance)
        end)
    end

    local summonRE = NetworkContracts.GetRemoteEvent("CastSummon_RE")
    if summonRE then
        summonRE.OnServerEvent:Connect(function(player: any)
            self:ProcessSummonCast(player)
        end)
    end
end

function CombatService:RegisterMob(mobInstance: any, mobId: Types.MobId, position: Types.Vector3Data, customHp: number?): ActiveMob
    local config = MobsConfig.Get(mobId)
    local maxHp = if config then config.MaxHp else 100
    local hp = customHp or maxHp

    local mobData: ActiveMob = {
        Instance = mobInstance,
        MobId = mobId,
        CurrentHp = hp,
        MaxHp = maxHp,
        Position = position,
        IsDead = false,
    }

    self._activeMobs[mobInstance] = mobData
    return mobData
end

function CombatService:UnregisterMob(mobInstance: any)
    self._activeMobs[mobInstance] = nil
end

function CombatService:GetMob(mobInstance: any): ActiveMob?
    return self._activeMobs[mobInstance]
end

function CombatService:ProcessAttack(player: any, targetMobInstance: any, customPlayerPos: Types.Vector3Data?): boolean
    local mob = self._activeMobs[targetMobInstance]
    if not mob or mob.IsDead then
        return false
    end

    local profile = DataService:GetProfile(player)
    if not profile then
        return false
    end

    local weaponConfig = WeaponsConfig.Get(profile.EquippedWeapon :: Types.WeaponId)
    if not weaponConfig then
        return false
    end

    -- 1. Cooldown-Validierung (Anti-Speedhack Schutz mit 50ms Toleranz)
    local currentTime = os.clock()
    local lastAttack = self._lastAttackTimes[player] or 0
    if (currentTime - lastAttack) < (weaponConfig.AttackCooldown - 0.05) then
        return false
    end
    self._lastAttackTimes[player] = currentTime

    -- 2. Distanz-Validierung (Waffen-Reichweite + 4 Studs Toleranz, max 15 Studs)
    local playerPos: Types.Vector3Data? = customPlayerPos
    if not playerPos and isRobloxEngine() then
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local hrpPos = character.HumanoidRootPart.Position
            playerPos = { X = hrpPos.X, Y = hrpPos.Y, Z = hrpPos.Z }
        end
    end

    if playerPos then
        local maxRange = math.min(weaponConfig.AttackRange + 4, 15)
        if not MathUtils.IsWithinDistance(playerPos, mob.Position, maxRange) then
            return false
        end
    end

    -- 3. Schadensberechnung
    local baseDamage = weaponConfig.Damage

    -- Trank-Schadens-Buff (z.B. InfernoPotion +20%)
    local potionBonus = CauldronService:GetBuffMagnitude(player, "DamageBoost")
    local damageMultiplier = 1.0 + potionBonus

    -- Spezifische Waffen-Passives (z.B. FireSaber +50% vs Slimes)
    if weaponConfig.Id == "FireSaber" and mob.MobId == "EarthSlime" then
        damageMultiplier += 0.50
    end

    local finalDamage = math.round(baseDamage * damageMultiplier)

    -- Kritischer Treffer Check (VoidShadowBlade +25% Crit, Basis 5%)
    local critChance = if weaponConfig.Id == "VoidShadowBlade" then 0.30 else 0.05
    local isCrit = math.random() <= critChance
    if isCrit then
        finalDamage = math.round(finalDamage * 1.5)
    end

    -- 4. Mob Schaden anwenden
    mob.CurrentHp = math.max(0, mob.CurrentHp - finalDamage)
    self.DamageDealt:Fire(player, targetMobInstance, finalDamage, isCrit)

    -- 5. Treffer-Feedback (CombatFeedback_RE an alle Clients in der Nähe)
    if isRobloxEngine() then
        local feedbackRE = NetworkContracts.GetRemoteEvent("CombatFeedback_RE")
        if feedbackRE then
            local feedbackData: Types.CombatFeedbackData = {
                targetModel = targetMobInstance,
                damage = finalDamage,
                isCrit = isCrit,
                isHeal = false,
            }
            feedbackRE:FireAllClients(feedbackData)
        end
    end

    -- 6. Mob Tod & Beute
    if mob.CurrentHp <= 0 then
        mob.IsDead = true
        self:_handleMobDeath(player, mob)
    end

    return true
end

function CombatService:_handleMobDeath(player: any, mob: ActiveMob)
    local mobConfig = MobsConfig.Get(mob.MobId)
    if not mobConfig then
        return
    end

    -- XP & Essenz Vergabe
    DataService:AddXP(player, mobConfig.XP)
    if mobConfig.EssenceReward > 0 then
        DataService:AddEssence(player, mobConfig.EssenceReward)
    end

    -- Statistik
    DataService:UpdateProfile(player, function(data)
        data.Stats.TotalMobsDefeated += 1
    end)

    -- Garantierte Drops
    for itemId, amount in mobConfig.GuaranteedDrops do
        if OresConfig.IsValidOre(itemId) then
            InventoryService:AddOre(player, itemId, amount)
        elseif RecipesConfig.IsValidRecipe(itemId) then
            InventoryService:AddPotion(player, itemId, amount)
        else
            InventoryService:AddMaterial(player, itemId, amount)
        end
    end

    -- Zufällige Chance-Drops
    for _, drop in mobConfig.ChanceDrops do
        local roll = math.random()
        if roll <= drop.Chance then
            local amount = math.random(drop.MinAmount, drop.MaxAmount)
            if OresConfig.IsValidOre(drop.ItemId) then
                InventoryService:AddOre(player, drop.ItemId, amount)
            elseif RecipesConfig.IsValidRecipe(drop.ItemId) then
                InventoryService:AddPotion(player, drop.ItemId, amount)
            else
                InventoryService:AddMaterial(player, drop.ItemId, amount)
            end
        end
    end

    self.MobKilled:Fire(player, mob.Instance, mob.MobId)
end

function CombatService:ProcessSummonCast(player: any): boolean
    local profile = DataService:GetProfile(player)
    if not profile or not profile.EquippedSummon or profile.EquippedSummon == "" then
        return false
    end

    local summonConfig = SummonsConfig.Get(profile.EquippedSummon :: Types.SummonId)
    if not summonConfig then
        return false
    end

    -- Cooldown mit Summoner-Skill Reduktion berechnen
    local reducedCooldown = MathUtils.CalculateSummonCooldown(summonConfig.Cooldown, profile.Skills.Summoner)
    local currentTime = os.clock()
    local lastSummon = self._lastSummonTimes[player] or 0

    if (currentTime - lastSummon) < reducedCooldown then
        return false
    end

    self._lastSummonTimes[player] = currentTime
    self.SummonCast:Fire(player, summonConfig.Id)
    return true
end

return CombatService
