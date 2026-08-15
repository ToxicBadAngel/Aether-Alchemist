--!strict
--[[
    ZonesConfig.luau
    Aether Alchemist (Element Shapers)
    Single Source of Truth für alle 3 Spielzonen, Levelgrenzen, Barrieren und Lichtverhältnisse.
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local Types = require("./Types")

local Zones: { [number]: Types.ZoneConfig } = {
    [1] = {
        Id = 1,
        Name = "Aether-Wald & Alchemisten-Dorf",
        LevelMin = 1,
        LevelMax = 4,
        CenterPosition = { X = 0, Y = 0, Z = 0 },
        Dimensions = { X = 250, Y = 60, Z = 250 },
        BarrierPosition = { X = 125, Y = 10, Z = 0 },
        ClockTime = 14.5,
        Brightness = 2.2,
        BGMId = "BGM_Zone1",
    },

    [2] = {
        Id = 2,
        Name = "Kristall-Höhle & Koloss-Arena",
        LevelMin = 5,
        LevelMax = 9,
        CenterPosition = { X = 300, Y = 0, Z = 0 },
        Dimensions = { X = 300, Y = 80, Z = 300 },
        BarrierPosition = { X = 450, Y = 10, Z = 0 },
        ClockTime = 17.8,
        Brightness = 1.2,
        BGMId = "BGM_Zone2",
    },

    [3] = {
        Id = 3,
        Name = "Void-Riss & Astral-Zitadelle",
        LevelMin = 10,
        LevelMax = 20,
        CenterPosition = { X = 650, Y = 0, Z = 0 },
        Dimensions = { X = 350, Y = 100, Z = 350 },
        BarrierPosition = nil,
        ClockTime = 21.0,
        Brightness = 0.8,
        BGMId = "BGM_Zone3",
    },
}

local ZonesConfig = {}

function ZonesConfig.Get(zoneId: number): Types.ZoneConfig?
    return Zones[zoneId]
end

function ZonesConfig.GetAll(): { [number]: Types.ZoneConfig }
    return Zones
end

function ZonesConfig.CanEnterZone(playerLevel: number, zoneId: number): (boolean, string?)
    local zone = Zones[zoneId]
    if not zone then
        return false, "Ungültige Zone"
    end

    if playerLevel < zone.LevelMin then
        return false, string.format("Erfordert Spieler-Level %d!", zone.LevelMin)
    end

    return true, nil
end

function ZonesConfig.GetZoneForPosition(pos: Types.Vector3Data): Types.ZoneConfig?
    for _, zone in Zones do
        local halfX = zone.Dimensions.X / 2
        local halfZ = zone.Dimensions.Z / 2
        local minX = zone.CenterPosition.X - halfX
        local maxX = zone.CenterPosition.X + halfX
        local minZ = zone.CenterPosition.Z - halfZ
        local maxZ = zone.CenterPosition.Z + halfZ

        if pos.X >= minX and pos.X <= maxX and pos.Z >= minZ and pos.Z <= maxZ then
            return zone
        end
    end
    return nil
end

return ZonesConfig
