--!strict
--[[
    MiningController.luau
    Aether Alchemist (Element Shapers)
    Client-Singleton für Erz-Bergbau-Interaktion (E-Halten, Harvester-Skill Dauer-Reduktion,
    Progress-Feedback, Bewegungs-Abbruch und HarvestOre_RF Server-Aufruf).
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local Types = require("../../Shared/Config/Types")
local OresConfig = require("../../Shared/Config/OresConfig")
local Signal = require("../../Shared/Modules/Signal")
local MathUtils = require("../../Shared/Modules/MathUtils")
local NetworkContracts = require("../../Shared/Remotes/NetworkContracts")
local DataController = require("./DataController")

export type MiningControllerType = {
    MiningStarted: Signal.Signal<any, string, number>,
    MiningProgress: Signal.Signal<number>,
    MiningCompleted: Signal.Signal<Types.HarvestResult>,
    MiningCancelled: Signal.Signal<string>,

    Init: (self: any) -> (),
    Start: (self: any) -> (),
    StartMining: (self: any, nodeInstance: any, oreId: Types.OreId, nodePos: Types.Vector3Data?, customPlayerPos: Types.Vector3Data?) -> boolean,
    CancelMining: (self: any, reason: string?) -> (),
    Update: (self: any, dt: number, customPlayerPos: Types.Vector3Data?) -> (),
    IsMining: (self: any) -> boolean,
}

local MiningController = {
    MiningStarted = Signal.new(),
    MiningProgress = Signal.new(),
    MiningCompleted = Signal.new(),
    MiningCancelled = Signal.new(),

    _isMining = false,
    _currentNode = nil :: any,
    _currentOreId = nil :: Types.OreId?,
    _nodePosition = nil :: Types.Vector3Data?,
    _miningDuration = 0,
    _elapsedTime = 0,
    _initialized = false,
    _started = false,
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("Players") ~= nil and game:GetService("Players").LocalPlayer ~= nil
    end)
    return success and result
end

function MiningController:Init()
    if self._initialized then
        return
    end
    self._initialized = true
end

function MiningController:Start()
    if self._started then
        return
    end
    self._started = true

    if not isRobloxEngine() then
        return
    end

    local RunService = game:GetService("RunService")
    RunService.RenderStepped:Connect(function(dt: number)
        self:Update(dt)
    end)
end

function MiningController:StartMining(
    nodeInstance: any,
    oreId: Types.OreId,
    nodePos: Types.Vector3Data?,
    customPlayerPos: Types.Vector3Data?
): boolean
    if self._isMining then
        return false
    end

    local oreConfig = OresConfig.Get(oreId)
    if not oreConfig then
        return false
    end

    -- Distanz-Prüfung zum Startzeitpunkt (max 12 Studs)
    local playerPos: Types.Vector3Data? = customPlayerPos
    if not playerPos and isRobloxEngine() then
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrpPos = player.Character.HumanoidRootPart.Position
            playerPos = { X = hrpPos.X, Y = hrpPos.Y, Z = hrpPos.Z }
        end
    end

    local targetNodePos = nodePos
    if not targetNodePos and isRobloxEngine() and typeof(nodeInstance) == "Instance" and nodeInstance:IsA("BasePart") then
        local p = nodeInstance.Position
        targetNodePos = { X = p.X, Y = p.Y, Z = p.Z }
    end

    if playerPos and targetNodePos then
        if not MathUtils.IsWithinDistance(playerPos, targetNodePos, 12) then
            return false
        end
    end

    -- Dauer mit Harvester-Skill berechnen (-4% pro Punkt, max -40%)
    local harvesterLevel = 0
    local profile = DataController:GetProfile()
    if profile then
        harvesterLevel = profile.Skills.Harvester
    end

    local duration = MathUtils.CalculateHarvestTime(oreConfig.BaseHarvestTime, harvesterLevel)

    self._isMining = true
    self._currentNode = nodeInstance
    self._currentOreId = oreId
    self._nodePosition = targetNodePos
    self._miningDuration = duration
    self._elapsedTime = 0

    self.MiningStarted:Fire(nodeInstance, oreId, duration)
    return true
end

function MiningController:CancelMining(reason: string?)
    if not self._isMining then
        return
    end

    local cancelReason = reason or "Abgebrochen"
    self._isMining = false
    self._currentNode = nil
    self._currentOreId = nil
    self._nodePosition = nil
    self._miningDuration = 0
    self._elapsedTime = 0

    self.MiningCancelled:Fire(cancelReason)
end

function MiningController:Update(dt: number, customPlayerPos: Types.Vector3Data?)
    if not self._isMining then
        return
    end

    -- 1. Bewegungs- & Distanz-Prüfung während des Abbaus
    local playerPos: Types.Vector3Data? = customPlayerPos
    if not playerPos and isRobloxEngine() then
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrpPos = player.Character.HumanoidRootPart.Position
            playerPos = { X = hrpPos.X, Y = hrpPos.Y, Z = hrpPos.Z }
        end
    end

    if playerPos and self._nodePosition then
        if not MathUtils.IsWithinDistance(playerPos, self._nodePosition, 14) then
            self:CancelMining("Zu weit vom Erzkristall entfernt!")
            return
        end
    end

    -- 2. Fortschritt aktualisieren
    self._elapsedTime += dt
    local progressPercent = math.clamp(self._elapsedTime / math.max(0.1, self._miningDuration), 0, 1)
    self.MiningProgress:Fire(progressPercent)

    -- 3. Abschluss nach Ablauf der Zeit
    if self._elapsedTime >= self._miningDuration then
        self._isMining = false
        local targetNode = self._currentNode
        self._currentNode = nil
        self._currentOreId = nil
        self._nodePosition = nil

        if isRobloxEngine() then
            local harvestRF = NetworkContracts.GetRemoteFunction("HarvestOre_RF")
            if harvestRF then
                task.spawn(function()
                    local result: Types.HarvestResult = harvestRF:InvokeServer(targetNode)
                    self.MiningCompleted:Fire(result)
                end)
            end
        else
            -- Fallback für Unit-Tests
            local mockResult: Types.HarvestResult = {
                success = true,
                oreId = self._currentOreId,
                amount = 1,
                error = nil,
            }
            self.MiningCompleted:Fire(mockResult)
        end
    end
end

function MiningController:IsMining(): boolean
    return self._isMining
end

return MiningController
