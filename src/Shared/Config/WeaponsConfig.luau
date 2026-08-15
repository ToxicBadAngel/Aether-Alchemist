--!strict
--[[
    WeaponsConfig.luau
    Aether Alchemist (Element Shapers)
    Single Source of Truth für alle 5 Waffen-Tiers, Stats, Rezepte und Spezialeffekte.
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local Types = require("./Types")

local Weapons: { [Types.WeaponId]: Types.WeaponConfig } = {
    BasicBlade = {
        Id = "BasicBlade",
        Name = "Anfänger-Klinge",
        Tier = 1,
        Damage = 10,
        AttackRange = 12,
        AttackCooldown = 0.45,
        Description = "Schlichtes eisernes Kurzschwert. Die treue Standard-Waffe jedes angehenden Alchemisten.",
        SpecialEffect = "Keine (Standard-Nahkampf)",
        Ingredients = {},
    },

    FireSaber = {
        Id = "FireSaber",
        Name = "Feuer-Säbel",
        Tier = 2,
        Damage = 25,
        AttackRange = 12,
        AttackCooldown = 0.50,
        Description = "Glühende Klinge aus geschmolzenem Rubin. Entzündet getroffene Gegner mit Brand-DoT.",
        SpecialEffect = "Brand-DoT: 5 Bonusschaden über 2 Sekunden (2 Ticks à 2.5 DMG im 1.0s Intervall)",
        Ingredients = {
            FireRuby = 2,
        },
    },

    OceanTrident = {
        Id = "OceanTrident",
        Name = "Ozean-Dreizack",
        Tier = 3,
        Damage = 45,
        AttackRange = 13,
        AttackCooldown = 0.55,
        Description = "Geschwungener Dreizack aus reinem Ozean-Saphir. Heilt den Träger bei jedem Treffer.",
        SpecialEffect = "Lebensraub: Heilt +5 HP pro Treffer (cappt strikt bei 100 Max-HP)",
        Ingredients = {
            OceanSapphire = 2,
            EarthTopaz = 1,
        },
    },

    StormEdge = {
        Id = "StormEdge",
        Name = "Sturm-Schneide",
        Tier = 4,
        Damage = 75,
        AttackRange = 14,
        AttackCooldown = 0.65,
        Description = "Monumentales Großschwert geladen mit Blitzenergie. Entfesselt verheerende Schockwellen.",
        SpecialEffect = "Blitz-Schockwelle: Bei jedem 3. erfolgreichen Treffer 12-Stud AOE Schockwelle",
        Ingredients = {
            LightningAmethyst = 3,
            ColossusCore = 1,
        },
    },

    VoidShadowBlade = {
        Id = "VoidShadowBlade",
        Name = "Void-Schattenklinge",
        Tier = 5,
        Damage = 110,
        AttackRange = 13,
        AttackCooldown = 0.45,
        Description = "Mythische Klinge aus verdichtetem Void-Glas. Ermöglicht blitzschnelle Schatten-Schritte.",
        SpecialEffect = "Schatten-Blink: 10-Stud Teleport in Blickrichtung + 20% passive Krit-Chance",
        Ingredients = {
            VoidCrystal = 3,
            ColossusHeart = 1,
        },
    },
}

local WeaponsConfig = {}

function WeaponsConfig.Get(weaponId: Types.WeaponId): Types.WeaponConfig?
    return Weapons[weaponId]
end

function WeaponsConfig.GetAll(): { [Types.WeaponId]: Types.WeaponConfig }
    return Weapons
end

function WeaponsConfig.GetByTier(tier: number): Types.WeaponConfig?
    for _, config in Weapons do
        if config.Tier == tier then
            return config
        end
    end
    return nil
end

function WeaponsConfig.IsValidWeapon(weaponId: string): boolean
    return Weapons[weaponId :: Types.WeaponId] ~= nil
end

return WeaponsConfig
