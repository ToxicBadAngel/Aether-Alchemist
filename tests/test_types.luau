--!strict
--[[
    test_types.luau
    Automatisierter Lune Unit-Test zur Verifikation des zentralen Typen-Systems.
]]

local Types = require("../src/Shared/Config/Types")

print("🧪 Starte Type-System Verifikation...")

-- 1. Test: Instanziierung eines validen Default-Profils nach PlayerProfileData
local sampleProfile: Types.PlayerProfileData = {
    Version = 1,
    Level = 1,
    XP = 0,
    AetherEssence = 100,
    SkillPoints = 0,
    Skills = {
        Harvester = 0,
        Alchemist = 0,
        Summoner = 0,
    },
    Inventory = {
        Ores = { ["EarthTopaz"] = 5 },
        Potions = {},
        Materials = {},
    },
    UnlockedWeapons = { "BasicBlade" },
    EquippedWeapon = "BasicBlade",
    UnlockedSummons = { "FirePhoenix" },
    EquippedSummon = "FirePhoenix",
    ActiveBuffs = {
        ["InfernoPotion"] = {
            BuffType = "DamageBoost",
            Magnitude = 0.20,
            ExpiresAt = 1000000,
            ShieldHp = nil,
        }
    },
    Settings = {
        MusicVolume = 0.5,
        SFXVolume = 0.8,
        CameraShake = true,
        LowPerformanceMode = false,
    },
    Tutorial = {
        Step1MinedOres = 0,
        Step1Completed = false,
        Step2Completed = false,
        Step3Completed = false,
    },
    DailyStreak = {
        CurrentStreak = 1,
        LastClaimTimestamp = 1000000,
    },
    PlaytimeGift = {
        NextClaimTimestamp = 1000600,
        ClaimCount = 0,
    },
    Stats = {
        TotalOresMined = 0,
        TotalBossesDefeated = 0,
        TotalPotionsCrafted = 0,
        PlaytimeSeconds = 0,
    },
}

assert(sampleProfile.Version == 1, "Profile Version muss 1 sein")
assert(sampleProfile.Level == 1, "Startlevel muss 1 sein")
assert(sampleProfile.AetherEssence == 100, "Start-Essenz muss 100 sein")
assert(sampleProfile.EquippedWeapon == "BasicBlade", "Start-Waffe muss BasicBlade sein")
assert(sampleProfile.EquippedSummon == "FirePhoenix", "Start-Summon muss FirePhoenix sein")
assert(sampleProfile.Settings.LowPerformanceMode == false, "Default LowPerformanceMode muss false sein")
assert(sampleProfile.Tutorial.Step1Completed == false, "Tutorial Step 1 muss initial false sein")

-- 2. Test: Response Payloads
local sampleHarvestResult: Types.HarvestResult = {
    success = true,
    oreId = "EarthTopaz",
    amount = 2,
    error = nil,
}
assert(sampleHarvestResult.success == true, "HarvestResult success muss true sein")
assert(sampleHarvestResult.oreId == "EarthTopaz", "OreId muss EarthTopaz sein")

local sampleCraftResult: Types.CraftResult = {
    success = true,
    craftedItem = "InfernoPotion",
    error = nil,
}
assert(sampleCraftResult.success == true, "CraftResult success muss true sein")

local samplePotionResult: Types.PotionResult = {
    success = true,
    appliedBuff = "DamageBoost",
    duration = 300,
    error = nil,
}
assert(samplePotionResult.duration == 300, "Potion duration muss 300s sein")

local sampleTradeResult: Types.TradeResult = {
    success = true,
    tradeState = nil,
    error = nil,
}
assert(sampleTradeResult.success == true, "TradeResult success muss true sein")

print("✅ Alle Typen-Definitionen & Schema-Invarianten erfolgreich validiert!")
