--!strict
--[[
    OresConfig.luau
    Aether Alchemist (Element Shapers)
    Single Source of Truth für alle Erz-Arten, Preise, Drop-Chancen und Visuals.
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local Types = require("./Types")

local Ores: { [Types.OreId]: Types.OreConfig } = {
    EarthTopaz = {
        Id = "EarthTopaz",
        Name = "Erd-Topas",
        Element = "Earth",
        Rarity = "Common",
        Zone = 1,
        SellPrice = 5,
        BaseHarvestTime = 1.0,
        DropMin = 1,
        DropMax = 2,
        ExtraDropChance = nil,
        RespawnTime = 12,
        PointLightColor = { R = 245, G = 158, B = 11 },
        PointLightRange = 10,
        PointLightBrightness = 1.5,
    },

    FireRuby = {
        Id = "FireRuby",
        Name = "Feuer-Rubin",
        Element = "Fire",
        Rarity = "Rare",
        Zone = 1,
        SellPrice = 20,
        BaseHarvestTime = 1.5,
        DropMin = 1,
        DropMax = 1,
        ExtraDropChance = nil,
        RespawnTime = 25,
        PointLightColor = { R = 239, G = 68, B = 68 },
        PointLightRange = 12,
        PointLightBrightness = 2.0,
    },

    OceanSapphire = {
        Id = "OceanSapphire",
        Name = "Ozean-Saphir",
        Element = "Ocean",
        Rarity = "Rare",
        Zone = 1,
        SellPrice = 20,
        BaseHarvestTime = 1.5,
        DropMin = 1,
        DropMax = 1,
        ExtraDropChance = nil,
        RespawnTime = 25,
        PointLightColor = { R = 59, G = 130, B = 246 },
        PointLightRange = 12,
        PointLightBrightness = 2.0,
    },

    WindEmerald = {
        Id = "WindEmerald",
        Name = "Wind-Smaragd",
        Element = "Wind",
        Rarity = "Rare",
        Zone = 2,
        SellPrice = 20,
        BaseHarvestTime = 1.5,
        DropMin = 1,
        DropMax = 1,
        ExtraDropChance = nil,
        RespawnTime = 25,
        PointLightColor = { R = 16, G = 185, B = 129 },
        PointLightRange = 12,
        PointLightBrightness = 2.0,
    },

    LightningAmethyst = {
        Id = "LightningAmethyst",
        Name = "Blitz-Amethyst",
        Element = "Lightning",
        Rarity = "Epic",
        Zone = 2,
        SellPrice = 60,
        BaseHarvestTime = 2.0,
        DropMin = 1,
        DropMax = 1,
        ExtraDropChance = 0.10,
        RespawnTime = 45,
        PointLightColor = { R = 168, G = 85, B = 247 },
        PointLightRange = 14,
        PointLightBrightness = 2.5,
    },

    VoidCrystal = {
        Id = "VoidCrystal",
        Name = "Void-Kristall",
        Element = "Void",
        Rarity = "Mythic",
        Zone = 3,
        SellPrice = 200,
        BaseHarvestTime = 3.0,
        DropMin = 1,
        DropMax = 1,
        ExtraDropChance = nil,
        RespawnTime = 90,
        PointLightColor = { R = 217, G = 70, B = 239 },
        PointLightRange = 16,
        PointLightBrightness = 3.0,
    },
}

local OresConfig = {}

function OresConfig.Get(oreId: Types.OreId): Types.OreConfig?
    return Ores[oreId]
end

function OresConfig.GetAll(): { [Types.OreId]: Types.OreConfig }
    return Ores
end

function OresConfig.GetOresForZone(zoneId: number): { Types.OreConfig }
    local result: { Types.OreConfig } = {}
    for _, config in Ores do
        if config.Zone == zoneId then
            table.insert(result, config)
        end
    end
    return result
end

function OresConfig.IsValidOre(oreId: string): boolean
    return Ores[oreId :: Types.OreId] ~= nil
end

return OresConfig
