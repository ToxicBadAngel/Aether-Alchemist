--!strict
--[[
    SummonsConfig.luau
    Aether Alchemist (Element Shapers)
    Single Source of Truth für alle 3 Begleiter-Wesen, Cooldowns und Spezialfähigkeiten.
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local Types = require("./Types")

local Summons: { [Types.SummonId]: Types.SummonConfig } = {
    FirePhoenix = {
        Id = "FirePhoenix",
        Name = "Feuer-Phönix",
        Cooldown = 10,
        Keybind = "E",
        AbilityName = "Flammenstoß",
        AbilityDescription = "Feuert einen zielgerichteten Feuerstrahl ab, der 40 Feuerschaden verursacht.",
        Damage = 40,
        ShieldAmount = nil,
        SlowDuration = nil,
        TeleportDistance = nil,
    },

    IceGolem = {
        Id = "IceGolem",
        Name = "Eis-Golem",
        Cooldown = 15,
        Keybind = "E",
        AbilityName = "Eis-Barriere",
        AbilityDescription = "Errichtet einen frostigen Schild um den Spieler, der 50 Schaden absorbiert und nahe Gegner verlangsamt.",
        Damage = nil,
        ShieldAmount = 50,
        SlowDuration = 3.0,
        TeleportDistance = nil,
    },

    VoidPhantom = {
        Id = "VoidPhantom",
        Name = "Void-Phantom",
        Cooldown = 12,
        Keybind = "E",
        AbilityName = "Void-Teleport",
        AbilityDescription = "Teleportiert den Spieler 15 Studs in Blickrichtung und macht ihn für 0.5s immun.",
        Damage = nil,
        ShieldAmount = nil,
        SlowDuration = nil,
        TeleportDistance = 15,
    },
}

local SummonsConfig = {}

function SummonsConfig.Get(summonId: Types.SummonId): Types.SummonConfig?
    return Summons[summonId]
end

function SummonsConfig.GetAll(): { [Types.SummonId]: Types.SummonConfig }
    return Summons
end

function SummonsConfig.IsValidSummon(summonId: string): boolean
    return Summons[summonId :: Types.SummonId] ~= nil
end

return SummonsConfig
