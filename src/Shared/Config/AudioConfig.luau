--!strict
--[[
    AudioConfig.luau
    Aether Alchemist (Element Shapers)
    Single Source of Truth für alle 19 Roblox Sound-Assets, Lautstärken und Pitch-Variationen.
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local Types = require("./Types")

export type SoundEntry = {
    AssetId: string,
    Volume: number,
    Looped: boolean,
    PitchMin: number,
    PitchMax: number,
    SoundGroup: "Master" | "SFX" | "UI" | "BGM" | "Ambience",
}

local Sounds: { [Types.SoundKey]: SoundEntry } = {
    Mining_Hit = {
        AssetId = "rbxassetid://9114223175",
        Volume = 0.6,
        Looped = false,
        PitchMin = 0.92,
        PitchMax = 1.08,
        SoundGroup = "SFX",
    },
    Mining_Break = {
        AssetId = "rbxassetid://9114223842",
        Volume = 0.8,
        Looped = false,
        PitchMin = 0.95,
        PitchMax = 1.05,
        SoundGroup = "SFX",
    },
    Sword_Swing = {
        AssetId = "rbxassetid://9117967812",
        Volume = 0.5,
        Looped = false,
        PitchMin = 0.92,
        PitchMax = 1.08,
        SoundGroup = "SFX",
    },
    Combat_Hit = {
        AssetId = "rbxassetid://9117968532",
        Volume = 0.7,
        Looped = false,
        PitchMin = 0.92,
        PitchMax = 1.08,
        SoundGroup = "SFX",
    },
    Combat_Crit = {
        AssetId = "rbxassetid://9117969123",
        Volume = 0.9,
        Looped = false,
        PitchMin = 0.98,
        PitchMax = 1.04,
        SoundGroup = "SFX",
    },
    Cauldron_Bubble = {
        AssetId = "rbxassetid://9118021455",
        Volume = 0.4,
        Looped = true,
        PitchMin = 0.95,
        PitchMax = 1.05,
        SoundGroup = "Ambience",
    },
    Craft_Success = {
        AssetId = "rbxassetid://9118022198",
        Volume = 0.85,
        Looped = false,
        PitchMin = 1.00,
        PitchMax = 1.00,
        SoundGroup = "SFX",
    },
    Potion_Drink = {
        AssetId = "rbxassetid://9118022941",
        Volume = 0.6,
        Looped = false,
        PitchMin = 0.95,
        PitchMax = 1.05,
        SoundGroup = "SFX",
    },
    Level_Up = {
        AssetId = "rbxassetid://9118114522",
        Volume = 0.9,
        Looped = false,
        PitchMin = 1.00,
        PitchMax = 1.00,
        SoundGroup = "SFX",
    },
    Player_Hurt = {
        AssetId = "rbxassetid://9118115201",
        Volume = 0.6,
        Looped = false,
        PitchMin = 0.92,
        PitchMax = 1.08,
        SoundGroup = "SFX",
    },
    Player_Death = {
        AssetId = "rbxassetid://9118115910",
        Volume = 0.8,
        Looped = false,
        PitchMin = 1.00,
        PitchMax = 1.00,
        SoundGroup = "SFX",
    },
    Boss_Roar = {
        AssetId = "rbxassetid://9118201244",
        Volume = 1.0,
        Looped = false,
        PitchMin = 0.90,
        PitchMax = 1.02,
        SoundGroup = "SFX",
    },
    Boss_Warning = {
        AssetId = "rbxassetid://9118202019",
        Volume = 0.85,
        Looped = false,
        PitchMin = 1.00,
        PitchMax = 1.00,
        SoundGroup = "SFX",
    },
    UI_Click = {
        AssetId = "rbxassetid://9118255102",
        Volume = 0.4,
        Looped = false,
        PitchMin = 0.98,
        PitchMax = 1.02,
        SoundGroup = "UI",
    },
    UI_Hover = {
        AssetId = "rbxassetid://9118255844",
        Volume = 0.25,
        Looped = false,
        PitchMin = 1.00,
        PitchMax = 1.05,
        SoundGroup = "UI",
    },
    BGM_Zone1 = {
        AssetId = "rbxassetid://1848354536",
        Volume = 0.45,
        Looped = true,
        PitchMin = 1.00,
        PitchMax = 1.00,
        SoundGroup = "BGM",
    },
    BGM_Zone2 = {
        AssetId = "rbxassetid://1848355102",
        Volume = 0.45,
        Looped = true,
        PitchMin = 1.00,
        PitchMax = 1.00,
        SoundGroup = "BGM",
    },
    BGM_Zone3 = {
        AssetId = "rbxassetid://1848355890",
        Volume = 0.45,
        Looped = true,
        PitchMin = 1.00,
        PitchMax = 1.00,
        SoundGroup = "BGM",
    },
    BGM_Boss = {
        AssetId = "rbxassetid://1848356612",
        Volume = 0.55,
        Looped = true,
        PitchMin = 1.00,
        PitchMax = 1.00,
        SoundGroup = "BGM",
    },
}

local AudioConfig = {}

function AudioConfig.Get(soundKey: Types.SoundKey): SoundEntry?
    return Sounds[soundKey]
end

function AudioConfig.GetAll(): { [Types.SoundKey]: SoundEntry }
    return Sounds
end

function AudioConfig.GetRandomPitch(soundKey: Types.SoundKey): number
    local entry = Sounds[soundKey]
    if not entry then
        return 1.0
    end
    if entry.PitchMin == entry.PitchMax then
        return entry.PitchMin
    end
    local minInt = math.floor(entry.PitchMin * 1000)
    local maxInt = math.floor(entry.PitchMax * 1000)
    return math.random(minInt, maxInt) / 1000
end

function AudioConfig.IsValidSound(soundKey: string): boolean
    return Sounds[soundKey :: Types.SoundKey] ~= nil
end

return AudioConfig
