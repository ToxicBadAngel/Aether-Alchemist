--!strict
--[[
    MobService.luau
    Aether Alchemist (Element Shapers)
    Server-Singleton für Mob-Spawns, State-Machine (Idle, Patrol, Chase, Attack, Reset),
    Aggro- & Leash-Distanzen, Target-Verfolgung und Respawn-Lifecycle.
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local Types = require("../../Shared/Config/Types")
local MobsConfig = require("../../Shared/Config/MobsConfig")
local Signal = require("../../Shared/Modules/Signal")
local CombatService = require("./CombatService")
local CauldronService = require("./CauldronService")

export type MobState = "Idle" | "Patrol" | "Chase" | "Attack" | "Reset"

export type MobEntity = {
    Instance: any,
    MobId: Types.MobId,
    SpawnerId: string,
    State: MobState,
    HomePosition: Types.Vector3Data,
    CurrentPosition: Types.Vector3Data,
    TargetPlayer: any?,
    LastAttackTime: number,
    AttackCooldown: number,
    NextWanderTime: number,
}

export type MobSpawner = {
    Id: string,
    MobId: Types.MobId,
    Position: Types.Vector3Data,
    MaxCount: number,
    SpawnRadius: number,
    SpawnedInstances: { any },
}

export type MobServiceType = {
    MobSpawned: Signal.Signal<any, string, Types.Vector3Data>,
    MobDespawned: Signal.Signal<any, string>,
    MobStateChanged: Signal.Signal<any, string, MobState>,

    Init: (self: any) -> (),
    Start: (self: any) -> (),
    RegisterSpawner: (self: any, spawnerId: string, mobId: Types.MobId, position: Types.Vector3Data, maxCount: number?, spawnRadius: number?) -> MobSpawner,
    SpawnMob: (self: any, spawnerId: string) -> MobEntity?,
    UpdateAI: (self: any, dt: number, customPlayerPositions: { [any]: Types.Vector3Data }?) -> (),
    GetEntity: (self: any, instance: any) -> MobEntity?,
}

local MobService = {
    MobSpawned = Signal.new(),
    MobDespawned = Signal.new(),
    MobStateChanged = Signal.new(),

    _spawners = {} :: { [string]: MobSpawner },
    _entities = {} :: { [any]: MobEntity },
    _initialized = false,
    _started = false,
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("Players") ~= nil
    end)
    return success and result
end

function MobService:Init()
    if self._initialized then
        return
    end
    self._initialized = true
end

function MobService:Start()
    if self._started then
        return
    end
    self._started = true

    CombatService.MobKilled:Connect(function(_player, mobInstance, mobId)
        local entity = self._entities[mobInstance]
        if entity then
            self._entities[mobInstance] = nil
            local spawner = self._spawners[entity.SpawnerId]
            if spawner then
                for i, inst in spawner.SpawnedInstances do
                    if inst == mobInstance then
                        table.remove(spawner.SpawnedInstances, i)
                        break
                    end
                end

                local mobConfig = MobsConfig.Get(mobId)
                local respawnDelay = if mobConfig then mobConfig.RespawnTime else 10

                task.delay(respawnDelay, function()
                    self:SpawnMob(entity.SpawnerId)
                end)
            end
        end
    end)

    if isRobloxEngine() then
        local RunService = game:GetService("RunService")
        RunService.Heartbeat:Connect(function(dt: number)
            self:UpdateAI(dt)
        end)
    end
end

function MobService:RegisterSpawner(
    spawnerId: string,
    mobId: Types.MobId,
    position: Types.Vector3Data,
    maxCount: number?,
    spawnRadius: number?
): MobSpawner
    local spawner: MobSpawner = {
        Id = spawnerId,
        MobId = mobId,
        Position = position,
        MaxCount = maxCount or 3,
        SpawnRadius = spawnRadius or 12,
        SpawnedInstances = {},
    }

    self._spawners[spawnerId] = spawner
    return spawner
end

function MobService:SpawnMob(spawnerId: string): MobEntity?
    local spawner = self._spawners[spawnerId]
    if not spawner or #spawner.SpawnedInstances >= spawner.MaxCount then
        return nil
    end

    local mobConfig = MobsConfig.Get(spawner.MobId)
    if not mobConfig then
        return nil
    end

    -- Zufällige Position im SpawnRadius
    local offsetX = (math.random() - 0.5) * 2 * spawner.SpawnRadius
    local offsetZ = (math.random() - 0.5) * 2 * spawner.SpawnRadius
    local spawnPos: Types.Vector3Data = {
        X = spawner.Position.X + offsetX,
        Y = spawner.Position.Y,
        Z = spawner.Position.Z + offsetZ,
    }

    local mockOrRealInstance = { Name = string.format("%s_%s", spawner.MobId, spawnerId) }

    local entity: MobEntity = {
        Instance = mockOrRealInstance,
        MobId = spawner.MobId,
        SpawnerId = spawnerId,
        State = "Idle",
        HomePosition = spawnPos,
        CurrentPosition = spawnPos,
        TargetPlayer = nil,
        LastAttackTime = 0,
        AttackCooldown = 1.5,
        NextWanderTime = os.clock() + math.random(3, 6),
    }

    table.insert(spawner.SpawnedInstances, mockOrRealInstance)
    self._entities[mockOrRealInstance] = entity

    CombatService:RegisterMob(mockOrRealInstance, spawner.MobId, spawnPos)
    self.MobSpawned:Fire(mockOrRealInstance, spawner.MobId, spawnPos)

    return entity
end

function MobService:GetEntity(instance: any): MobEntity?
    return self._entities[instance]
end

function MobService:UpdateAI(dt: number, customPlayerPositions: { [any]: Types.Vector3Data }?)
    local currentTime = os.clock()

    -- Spieler-Positionen sammeln
    local playerPositions: { [any]: Types.Vector3Data } = customPlayerPositions or {}
    if not customPlayerPositions and isRobloxEngine() then
        local Players = game:GetService("Players")
        for _, player in Players:GetPlayers() do
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart.Position
                playerPositions[player] = { X = hrp.X, Y = hrp.Y, Z = hrp.Z }
            end
        end
    end

    for instance, entity in self._entities do
        local mobConfig = MobsConfig.Get(entity.MobId)
        if not mobConfig then
            continue
        end

        local combatMob = CombatService:GetMob(instance)
        if not combatMob or combatMob.IsDead then
            continue
        end

        -- 1. Nächsten Spieler für Aggro suchen
        local nearestPlayer: any = nil
        local nearestDistSq = math.huge
        local aggroDistSq = mobConfig.AggroRadius * mobConfig.AggroRadius

        for player, pos in playerPositions do
            local dx = pos.X - entity.CurrentPosition.X
            local dy = pos.Y - entity.CurrentPosition.Y
            local dz = pos.Z - entity.CurrentPosition.Z
            local distSq = dx * dx + dy * dy + dz * dz

            if distSq <= aggroDistSq and distSq < nearestDistSq then
                nearestDistSq = distSq
                nearestPlayer = player
            end
        end

        -- 2. State Machine Ausführung
        local previousState = entity.State

        if entity.State == "Reset" then
            -- Rückkehr zur Home-Position
            local dx = entity.HomePosition.X - entity.CurrentPosition.X
            local dz = entity.HomePosition.Z - entity.CurrentPosition.Z
            local dist = math.sqrt(dx * dx + dz * dz)

            if dist <= 1.0 then
                entity.CurrentPosition = entity.HomePosition
                entity.State = "Idle"
                combatMob.CurrentHp = combatMob.MaxHp -- Volle Heilung beim Reset
            else
                local speed = 14 * dt
                entity.CurrentPosition.X += (dx / dist) * math.min(speed, dist)
                entity.CurrentPosition.Z += (dz / dist) * math.min(speed, dist)
            end
        elseif entity.State == "Idle" or entity.State == "Patrol" then
            if nearestPlayer then
                entity.TargetPlayer = nearestPlayer
                entity.State = "Chase"
            elseif currentTime >= entity.NextWanderTime then
                entity.NextWanderTime = currentTime + math.random(3, 6)
                entity.State = if entity.State == "Idle" then "Patrol" else "Idle"
            end
        elseif entity.State == "Chase" then
            local targetPos = if entity.TargetPlayer then playerPositions[entity.TargetPlayer] else nil

            if not targetPos then
                entity.State = "Reset"
                entity.TargetPlayer = nil
            else
                -- Leash-Radius prüfen (Distanz zur HomePosition > LeashRadius -> Reset)
                local hx = entity.CurrentPosition.X - entity.HomePosition.X
                local hz = entity.CurrentPosition.Z - entity.HomePosition.Z
                local leashDistSq = hx * hx + hz * hz

                if leashDistSq > (mobConfig.LeashRadius * mobConfig.LeashRadius) then
                    entity.State = "Reset"
                    entity.TargetPlayer = nil
                else
                    local px = targetPos.X - entity.CurrentPosition.X
                    local pz = targetPos.Z - entity.CurrentPosition.Z
                    local distToPlayer = math.sqrt(px * px + pz * pz)

                    if distToPlayer <= 4.0 then
                        entity.State = "Attack"
                    else
                        local speed = 10 * dt
                        entity.CurrentPosition.X += (px / distToPlayer) * speed
                        entity.CurrentPosition.Z += (pz / distToPlayer) * speed
                    end
                end
            end
        elseif entity.State == "Attack" then
            local targetPos = if entity.TargetPlayer then playerPositions[entity.TargetPlayer] else nil

            local hx = entity.CurrentPosition.X - entity.HomePosition.X
            local hz = entity.CurrentPosition.Z - entity.HomePosition.Z
            local leashDistSq = hx * hx + hz * hz

            if not targetPos or leashDistSq > (mobConfig.LeashRadius * mobConfig.LeashRadius) then
                entity.State = "Reset"
                entity.TargetPlayer = nil
            else
                local px = targetPos.X - entity.CurrentPosition.X
                local pz = targetPos.Z - entity.CurrentPosition.Z
                local distToPlayer = math.sqrt(px * px + pz * pz)

                if distToPlayer > 5.5 then
                    entity.State = "Chase"
                elseif (currentTime - entity.LastAttackTime) >= entity.AttackCooldown then
                    entity.LastAttackTime = currentTime
                    self:_executeMobAttack(entity, mobConfig)
                end
            end
        end

        if entity.State ~= previousState then
            self.MobStateChanged:Fire(instance, entity.MobId, entity.State)
        end
    end
end

function MobService:_executeMobAttack(entity: MobEntity, mobConfig: Types.MobConfig)
    local targetPlayer = entity.TargetPlayer
    if not targetPlayer then
        return
    end

    local incomingDamage = mobConfig.Damage

    -- Schild-Pool Absorption via CauldronService
    local unabsorbedDamage = CauldronService:ConsumeShield(targetPlayer, incomingDamage)

    if isRobloxEngine() and unabsorbedDamage > 0 then
        local character = targetPlayer.Character
        if character and character:FindFirstChildOfClass("Humanoid") then
            character.Humanoid:TakeDamage(unabsorbedDamage)
        end
    end
end

return MobService
