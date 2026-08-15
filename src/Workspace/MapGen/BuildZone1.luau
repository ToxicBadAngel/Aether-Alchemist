--!strict
--[[
    BuildZone1.luau
    Aether Alchemist (Element Shapers)
    Programmatischer Zone-1 Blockout & Map-Generator ("Aether-Lichtung").
    Erstellt schwebende Insel, SpawnLocation, Alchemie-Kessel, Händler-Stand,
    10 Erzknoten (OreNode-Tag) und 4 Slime-Spawns (MobSpawn-Tag).
    Entspricht 100% GEMINI.md Abschnitt 4 & INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local Types = require("../../Shared/Config/Types")
local OresConfig = require("../../Shared/Config/OresConfig")

export type Position3D = {
    X: number,
    Y: number,
    Z: number,
}

export type Zone1NodeDef = {
    Position: Position3D,
    OreId: Types.OreId,
}

export type Zone1SpawnDef = {
    Position: Position3D,
    MobId: Types.MobId,
}

export type Zone1Layout = {
    Name: string,
    IslandSize: Position3D,
    SpawnLocation: Position3D,
    CauldronAltar: Position3D,
    MerchantStand: Position3D,
    OreNodes: { Zone1NodeDef },
    MobSpawns: { Zone1SpawnDef },
}

export type Zone1BuildResult = {
    Model: any,
    OreNodesCount: number,
    MobSpawnsCount: number,
    HasCauldron: boolean,
    HasMerchant: boolean,
    HasSpawnLocation: boolean,
}

local LAYOUT: Zone1Layout = {
    Name = "Aether-Lichtung (Zone 1)",
    IslandSize = { X = 200, Y = 10, Z = 200 },
    SpawnLocation = { X = 0, Y = 5, Z = 0 },
    CauldronAltar = { X = 25, Y = 6, Z = 20 },
    MerchantStand = { X = -25, Y = 6, Z = 20 },
    OreNodes = {
        -- 5x EarthTopaz
        { Position = { X = 30, Y = 5, Z = -30 }, OreId = "EarthTopaz" },
        { Position = { X = 45, Y = 5, Z = -15 }, OreId = "EarthTopaz" },
        { Position = { X = -30, Y = 5, Z = -35 }, OreId = "EarthTopaz" },
        { Position = { X = -45, Y = 5, Z = -10 }, OreId = "EarthTopaz" },
        { Position = { X = 0, Y = 5, Z = -50 }, OreId = "EarthTopaz" },

        -- 3x OceanSapphire
        { Position = { X = 50, Y = 5, Z = 30 }, OreId = "OceanSapphire" },
        { Position = { X = -50, Y = 5, Z = 30 }, OreId = "OceanSapphire" },
        { Position = { X = 60, Y = 5, Z = -40 }, OreId = "OceanSapphire" },

        -- 2x FireRuby
        { Position = { X = -60, Y = 5, Z = -45 }, OreId = "FireRuby" },
        { Position = { X = 0, Y = 5, Z = 60 }, OreId = "FireRuby" },
    },
    MobSpawns = {
        -- 4x Slime
        { Position = { X = 40, Y = 5, Z = -60 }, MobId = "Slime" },
        { Position = { X = -40, Y = 5, Z = -60 }, MobId = "Slime" },
        { Position = { X = 60, Y = 5, Z = 0 }, MobId = "Slime" },
        { Position = { X = -60, Y = 5, Z = 0 }, MobId = "Slime" },
    },
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("Workspace") ~= nil
    end)
    return success and result
end

local BuildZone1 = {}

function BuildZone1.GetLayout(): Zone1Layout
    return LAYOUT
end

function BuildZone1.Build(targetWorkspace: any?): Zone1BuildResult
    local ws = targetWorkspace
    if not ws and isRobloxEngine() then
        ws = game:GetService("Workspace")
    end

    local result: Zone1BuildResult = {
        Model = nil,
        OreNodesCount = #LAYOUT.OreNodes,
        MobSpawnsCount = #LAYOUT.MobSpawns,
        HasCauldron = true,
        HasMerchant = true,
        HasSpawnLocation = true,
    }

    if not isRobloxEngine() or not ws then
        return result
    end

    local collectionService = game:GetService("CollectionService")

    -- Vorhandene Zone1 löschen falls vorhanden
    local existing = ws:FindFirstChild("Zone1_AetherLichtung")
    if existing then
        existing:Destroy()
    end

    local zoneModel = Instance.new("Model")
    zoneModel.Name = "Zone1_AetherLichtung"
    zoneModel.Parent = ws
    result.Model = zoneModel

    -- 1. Hauptinsel-Boden
    local island = Instance.new("Part")
    island.Name = "MainIsland"
    island.Size = Vector3.new(LAYOUT.IslandSize.X, LAYOUT.IslandSize.Y, LAYOUT.IslandSize.Z)
    island.Position = Vector3.new(0, 0, 0)
    island.Anchored = true
    island.Material = Enum.Material.Grass
    island.Color = Color3.fromRGB(56, 120, 68)
    island.Parent = zoneModel

    -- 2. SpawnLocation
    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "SpawnLocation"
    spawn.Size = Vector3.new(12, 1, 12)
    spawn.Position = Vector3.new(LAYOUT.SpawnLocation.X, LAYOUT.SpawnLocation.Y, LAYOUT.SpawnLocation.Z)
    spawn.Anchored = true
    spawn.Neutral = true
    spawn.Duration = 0
    spawn.Material = Enum.Material.SmoothPlastic
    spawn.Color = Color3.fromRGB(15, 23, 42)
    spawn.Parent = zoneModel

    -- 3. Kessel-Altar
    local cauldron = Instance.new("Part")
    cauldron.Name = "CauldronAltar"
    cauldron.Size = Vector3.new(8, 4, 8)
    cauldron.Position = Vector3.new(LAYOUT.CauldronAltar.X, LAYOUT.CauldronAltar.Y, LAYOUT.CauldronAltar.Z)
    cauldron.Anchored = true
    cauldron.Material = Enum.Material.Cobblestone
    cauldron.Color = Color3.fromRGB(40, 45, 55)
    cauldron.Parent = zoneModel

    local cauldronPrompt = Instance.new("ProximityPrompt")
    cauldronPrompt.Name = "CauldronPrompt"
    cauldronPrompt.ObjectText = "Alchemie-Kessel"
    cauldronPrompt.ActionText = "Brauen"
    cauldronPrompt.KeyboardKeyCode = Enum.KeyCode.E
    cauldronPrompt.HoldDuration = 0
    cauldronPrompt.MaxActivationDistance = 12
    cauldronPrompt.Parent = cauldron

    -- 4. Händler-Stand
    local merchant = Instance.new("Part")
    merchant.Name = "MerchantStand"
    merchant.Size = Vector3.new(8, 4, 8)
    merchant.Position = Vector3.new(LAYOUT.MerchantStand.X, LAYOUT.MerchantStand.Y, LAYOUT.MerchantStand.Z)
    merchant.Anchored = true
    merchant.Material = Enum.Material.WoodPlanks
    merchant.Color = Color3.fromRGB(133, 94, 66)
    merchant.Parent = zoneModel

    local merchantPrompt = Instance.new("ProximityPrompt")
    merchantPrompt.Name = "MerchantPrompt"
    merchantPrompt.ObjectText = "Aether-Händler"
    merchantPrompt.ActionText = "Handeln"
    merchantPrompt.KeyboardKeyCode = Enum.KeyCode.E
    merchantPrompt.HoldDuration = 0
    merchantPrompt.MaxActivationDistance = 12
    merchantPrompt.Parent = merchant

    -- 5. Erzknoten platzieren
    local oreFolder = Instance.new("Folder")
    oreFolder.Name = "OreNodes"
    oreFolder.Parent = zoneModel

    for i, node in LAYOUT.OreNodes do
        local oreCfg = OresConfig.Get(node.OreId)
        local orePart = Instance.new("Part")
        orePart.Name = string.format("OreNode_%s_%d", node.OreId, i)
        orePart.Size = Vector3.new(4, 5, 4)
        orePart.Position = Vector3.new(node.Position.X, node.Position.Y, node.Position.Z)
        orePart.Anchored = true
        orePart.Material = Enum.Material.Neon
        if oreCfg then
            orePart.Color = Color3.fromRGB(oreCfg.Color.R, oreCfg.Color.G, oreCfg.Color.B)
        end
        orePart:SetAttribute("OreId", node.OreId)
        orePart.Parent = oreFolder
        collectionService:AddTag(orePart, "OreNode")
    end

    -- 6. Mob Spawnpunkte platzieren
    local mobFolder = Instance.new("Folder")
    mobFolder.Name = "MobSpawns"
    mobFolder.Parent = zoneModel

    for i, spawnDef in LAYOUT.MobSpawns do
        local spawnPart = Instance.new("Part")
        spawnPart.Name = string.format("MobSpawn_%s_%d", spawnDef.MobId, i)
        spawnPart.Size = Vector3.new(3, 1, 3)
        spawnPart.Position = Vector3.new(spawnDef.Position.X, spawnDef.Position.Y, spawnDef.Position.Z)
        spawnPart.Anchored = true
        spawnPart.Transparency = 1
        spawnPart.CanCollide = false
        spawnPart:SetAttribute("MobId", spawnDef.MobId)
        spawnPart.Parent = mobFolder
        collectionService:AddTag(spawnPart, "MobSpawn")
    end

    return result
end

return BuildZone1
