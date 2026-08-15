--!strict
--[[
    ProfileTemplate.luau
    Aether Alchemist (Element Shapers)
    Single Source of Truth für das initiale Spieler-Profil (ProfileService Schema v1).
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local Types = require("./Types")

local DEFAULT_PROFILE: Types.PlayerProfileData = {
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
        Ores = {
            EarthTopaz = 5,
        },
        Potions = {},
        Materials = {},
    },

    UnlockedWeapons = { "BasicBlade" },
    EquippedWeapon = "BasicBlade",

    UnlockedSummons = { "FirePhoenix" },
    EquippedSummon = "FirePhoenix",

    ActiveBuffs = {},

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
        LastClaimTimestamp = 0,
    },

    PlaytimeGift = {
        NextClaimTimestamp = 0,
        ClaimCount = 0,
    },

    Stats = {
        TotalOresMined = 0,
        TotalBossesDefeated = 0,
        TotalPotionsCrafted = 0,
        PlaytimeSeconds = 0,
    },
}

local function deepCopy<T>(target: T): T
    if typeof(target) ~= "table" then
        return target
    end

    local copy = {}
    for key, value in (target :: any) do
        if typeof(value) == "table" then
            copy[key] = deepCopy(value)
        else
            copy[key] = value
        end
    end

    return (copy :: any) :: T
end

local ProfileTemplate = {}

function ProfileTemplate.GetDefault(): Types.PlayerProfileData
    return deepCopy(DEFAULT_PROFILE)
end

function ProfileTemplate.Reconcile(target: { [string]: any }, template: { [string]: any }?): { [string]: any }
    local baseTemplate = template or (DEFAULT_PROFILE :: any)

    for key, defaultValue in baseTemplate do
        if target[key] == nil then
            if typeof(defaultValue) == "table" then
                target[key] = deepCopy(defaultValue)
            else
                target[key] = defaultValue
            end
        elseif typeof(defaultValue) == "table" and typeof(target[key]) == "table" then
            ProfileTemplate.Reconcile(target[key], defaultValue)
        end
    end

    return target
end

return ProfileTemplate
