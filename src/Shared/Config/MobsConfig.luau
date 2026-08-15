--!strict
--[[
    MobsConfig.luau
    Aether Alchemist (Element Shapers)
    Single Source of Truth für alle Monster- und Boss-Arten, Stats und Drop-Tabellen.
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local Types = require("./Types")

local Mobs: { [Types.MobId]: Types.MobConfig } = {
    EarthSlime = {
        Id = "EarthSlime",
        Name = "Erd-Schleim",
        Zone = 1,
        MaxHp = 50,
        Damage = 8,
        AggroRadius = 16,
        LeashRadius = 35,
        RespawnTime = 8,
        XP = 15,
        EssenceReward = 8,
        GuaranteedDrops = {
            EarthTopaz = 1,
        },
        ChanceDrops = {},
    },

    CrystalCrab = {
        Id = "CrystalCrab",
        Name = "Kristall-Krabbe",
        Zone = 2,
        MaxHp = 180,
        Damage = 22,
        AggroRadius = 20,
        LeashRadius = 40,
        RespawnTime = 15,
        XP = 45,
        EssenceReward = 25,
        GuaranteedDrops = {
            WindEmerald = 1,
        },
        ChanceDrops = {
            {
                ItemId = "LightningAmethyst",
                Chance = 0.15,
                MinAmount = 1,
                MaxAmount = 1,
            },
        },
    },

    CrystalCrabElite = {
        Id = "CrystalCrabElite",
        Name = "Elite Kristall-Krabbe",
        Zone = 2,
        MaxHp = 380,
        Damage = 40,
        AggroRadius = 22,
        LeashRadius = 45,
        RespawnTime = 30,
        XP = 110,
        EssenceReward = 60,
        GuaranteedDrops = {
            LightningAmethyst = 1,
        },
        ChanceDrops = {
            {
                ItemId = "LightningAmethyst",
                Chance = 0.50,
                MinAmount = 1,
                MaxAmount = 2,
            },
        },
    },

    VoidStalker = {
        Id = "VoidStalker",
        Name = "Void-Pirscher",
        Zone = 3,
        MaxHp = 420,
        Damage = 50,
        AggroRadius = 24,
        LeashRadius = 50,
        RespawnTime = 20,
        XP = 120,
        EssenceReward = 70,
        GuaranteedDrops = {
            VoidCrystal = 1,
        },
        ChanceDrops = {
            {
                ItemId = "VoidCrystal",
                Chance = 0.25,
                MinAmount = 1,
                MaxAmount = 1,
            },
        },
    },

    CrystalColossus = {
        Id = "CrystalColossus",
        Name = "Kristall-Koloss (Boss)",
        Zone = 2,
        MaxHp = 2500,
        Damage = 65,
        AggroRadius = 45,
        LeashRadius = 80,
        RespawnTime = 120,
        XP = 600,
        EssenceReward = 350,
        GuaranteedDrops = {
            LightningAmethyst = 3,
            ColossusCore = 1,
        },
        ChanceDrops = {
            {
                ItemId = "ColossusHeart",
                Chance = 0.20,
                MinAmount = 1,
                MaxAmount = 1,
            },
        },
    },

    MiniColossus = {
        Id = "MiniColossus",
        Name = "Mini-Koloss (Scherge)",
        Zone = 2,
        MaxHp = 200,
        Damage = 20,
        AggroRadius = 25,
        LeashRadius = 50,
        RespawnTime = 0,
        XP = 30,
        EssenceReward = 15,
        GuaranteedDrops = {},
        ChanceDrops = {},
    },
}

local MobsConfig = {}

function MobsConfig.Get(mobId: Types.MobId): Types.MobConfig?
    return Mobs[mobId]
end

function MobsConfig.GetAll(): { [Types.MobId]: Types.MobConfig }
    return Mobs
end

function MobsConfig.GetMobsForZone(zoneId: number): { Types.MobConfig }
    local result: { Types.MobConfig } = {}
    for _, config in Mobs do
        if config.Zone == zoneId then
            table.insert(result, config)
        end
    end
    return result
end

function MobsConfig.IsValidMob(mobId: string): boolean
    return Mobs[mobId :: Types.MobId] ~= nil
end

return MobsConfig
