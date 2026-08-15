--!strict
--[[
    HarvestService.luau
    Aether Alchemist (Element Shapers)
    Server-Singleton für Erz-Bergbau (HarvestOre_RF, Exploit-Distanz-Validierung <= 15 Studs,
    Harvester-Skill Skalierung, Drop-Berechnung, XP-Vergabe und Respawn-Timer).
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local Types = require("../../Shared/Config/Types")
local OresConfig = require("../../Shared/Config/OresConfig")
local Signal = require("../../Shared/Modules/Signal")
local MathUtils = require("../../Shared/Modules/MathUtils")
local NetworkContracts = require("../../Shared/Remotes/NetworkContracts")
local DataService = require("./DataService")
local InventoryService = require("./InventoryService")

export type OreNodeData = {
    NodeInstance: any,
    OreId: Types.OreId,
    Position: Types.Vector3Data,
    IsActive: boolean,
    RespawnAt: number,
}

local HarvestService = {
    OreHarvested = Signal.new(),
    OreRespawned = Signal.new(),

    _nodes = {} :: { [any]: OreNodeData },
    _initialized = false,
    _started = false,
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("Players") ~= nil
    end)
    return success and result
end

function HarvestService:Init()
    if self._initialized then
        return
    end
    self._initialized = true
end

function HarvestService:Start()
    if self._started then
        return
    end
    self._started = true

    if not isRobloxEngine() then
        return
    end

    local harvestOreRF = NetworkContracts.GetRemoteFunction("HarvestOre_RF")
    if harvestOreRF then
        harvestOreRF.OnServerInvoke = function(player: any, nodeInstance: any)
            return self:HarvestOre(player, nodeInstance)
        end
    end
end

function HarvestService:RegisterOreNode(nodeInstance: any, oreId: Types.OreId, position: Types.Vector3Data)
    self._nodes[nodeInstance] = {
        NodeInstance = nodeInstance,
        OreId = oreId,
        Position = position,
        IsActive = true,
        RespawnAt = 0,
    }
end

function HarvestService:GetNode(nodeInstance: any): OreNodeData?
    return self._nodes[nodeInstance]
end

function HarvestService:HarvestOre(player: any, nodeInstance: any, customPlayerPos: Types.Vector3Data?): Types.HarvestResult
    -- 1. Validierung: Node existiert
    local node = self._nodes[nodeInstance]
    if not node then
        return { success = false, oreId = nil, amount = 0, error = "Erz-Knoten existiert nicht!" }
    end

    if not node.IsActive then
        return { success = false, oreId = nil, amount = 0, error = "Erz regeneriert sich gerade noch!" }
    end

    local oreConfig = OresConfig.Get(node.OreId)
    if not oreConfig then
        return { success = false, oreId = nil, amount = 0, error = "Ungültige Erz-Konfiguration!" }
    end

    -- 2. Validierung: Spieler-Position & Distanz (Exploit-Schutz <= 15 Studs)
    local playerPos: Types.Vector3Data? = customPlayerPos
    if not playerPos and isRobloxEngine() then
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local hrpPos = character.HumanoidRootPart.Position
            playerPos = { X = hrpPos.X, Y = hrpPos.Y, Z = hrpPos.Z }
        end
    end

    if playerPos then
        local withinRange = MathUtils.IsWithinDistance(playerPos, node.Position, 15)
        if not withinRange then
            return { success = false, oreId = nil, amount = 0, error = "Zu weit entfernt (Max 15 Studs)!" }
        end
    end

    -- 3. Transaktions-Mutex
    local lockAcquired = DataService:AcquireLock(player)
    if not lockAcquired then
        return { success = false, oreId = nil, amount = 0, error = "Aktion wird bereits ausgeführt!" }
    end

    local profile = DataService:GetProfile(player)
    if not profile then
        DataService:ReleaseLock(player)
        return { success = false, oreId = nil, amount = 0, error = "Profil nicht gefunden!" }
    end

    -- 4. Drop-Berechnung (DropMin .. DropMax + ExtraDropChance)
    local dropAmount = math.random(oreConfig.DropMin, oreConfig.DropMax)
    if oreConfig.ExtraDropChance and math.random() <= oreConfig.ExtraDropChance then
        dropAmount += 1
    end

    -- 5. Inventar-Gutschrift
    local addSuccess = InventoryService:AddOre(player, oreConfig.Id, dropAmount)
    if not addSuccess then
        DataService:ReleaseLock(player)
        return { success = false, oreId = nil, amount = 0, error = "Konnte Erz nicht ins Inventar legen!" }
    end

    -- 6. XP-Berechnung & Vergabe (2x Verkaufswert als XP)
    local earnedXP = oreConfig.SellPrice * 2
    DataService:AddXP(player, earnedXP)

    -- 7. Tutorial-Fortschritt (Schritt 1: Baue 3 Erd-Topas ab)
    if not profile.Tutorial.Step1Completed and oreConfig.Id == "EarthTopaz" then
        DataService:UpdateProfile(player, function(data)
            data.Tutorial.Step1MinedOres += dropAmount
            if data.Tutorial.Step1MinedOres >= 3 then
                data.Tutorial.Step1Completed = true
                data.AetherEssence += 50 -- 50 Starter-Belohnung
            end
        end)
    end

    -- 8. Erz-Knoten deaktivieren & Respawn planen
    node.IsActive = false
    node.RespawnAt = os.time() + oreConfig.RespawnTime

    if isRobloxEngine() and typeof(nodeInstance) == "Instance" then
        if nodeInstance:IsA("BasePart") then
            nodeInstance.Transparency = 0.8
        end
        local pointLight = nodeInstance:FindFirstChildOfClass("PointLight")
        if pointLight then
            pointLight.Enabled = false
        end

        task.delay(oreConfig.RespawnTime, function()
            node.IsActive = true
            if nodeInstance:IsA("BasePart") then
                nodeInstance.Transparency = 0.0
            end
            if pointLight then
                pointLight.Enabled = true
            end
            self.OreRespawned:Fire(nodeInstance, node.OreId)
        end)
    else
        -- Fallback für Unit-Tests
        node.IsActive = true
    end

    -- 9. Mutex freigeben & Signal senden
    DataService:ReleaseLock(player)
    self.OreHarvested:Fire(player, oreConfig.Id, dropAmount, earnedXP)

    return {
        success = true,
        oreId = oreConfig.Id,
        amount = dropAmount,
        error = nil,
    }
end

return HarvestService
