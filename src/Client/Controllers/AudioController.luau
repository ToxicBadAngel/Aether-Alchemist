--!strict
--[[
    AudioController.luau
    Aether Alchemist (Element Shapers)
    Client-Singleton für Audio-Wiedergabe (3D Positional Audio, Pitch-Randomisierung
    0.92 .. 1.08 gegen akustische Ermüdung, BGM-Crossfades und SoundGroups).
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local Types = require("../../Shared/Config/Types")
local AudioConfig = require("../../Shared/Config/AudioConfig")
local Signal = require("../../Shared/Modules/Signal")
local DataController = require("./DataController")

export type AudioControllerType = {
    SoundPlayed: Signal.Signal<string, any?>,
    BGMChanged: Signal.Signal<string>,

    Init: (self: any) -> (),
    Start: (self: any) -> (),
    PlaySound: (self: any, soundKey: Types.SoundKey, parentPart: any?, customPitch: number?) -> any,
    PlayBGM: (self: any, bgmKey: Types.SoundKey, fadeDuration: number?) -> (),
    StopBGM: (self: any) -> (),
    SetMasterVolume: (self: any, volume: number) -> (),
    SetSFXVolume: (self: any, volume: number) -> (),
    SetMusicVolume: (self: any, volume: number) -> (),
    CalculatePitch: (self: any, soundKey: Types.SoundKey) -> number,
}

local AudioController = {
    SoundPlayed = Signal.new(),
    BGMChanged = Signal.new(),

    _currentBGM = nil :: any,
    _currentBGMKey = "" :: string,
    _soundGroups = {} :: { [string]: any },
    _masterVolume = 1.0,
    _sfxVolume = 0.8,
    _musicVolume = 0.5,
    _initialized = false,
    _started = false,
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("SoundService") ~= nil
    end)
    return success and result
end

function AudioController:Init()
    if self._initialized then
        return
    end
    self._initialized = true

    if not isRobloxEngine() then
        return
    end

    local SoundService = game:GetService("SoundService")
    local groupNames = { "Master", "SFX", "UI", "BGM", "Ambience" }

    for _, name in groupNames do
        local existing = SoundService:FindFirstChild(name)
        if not existing then
            local newGroup = Instance.new("SoundGroup")
            newGroup.Name = name
            newGroup.Parent = SoundService
            self._soundGroups[name] = newGroup
        else
            self._soundGroups[name] = existing
        end
    end
end

function AudioController:Start()
    if self._started then
        return
    end
    self._started = true

    -- Lautstärke-Einstellungen mit Profil synchronisieren
    local profile = DataController:GetProfile()
    if profile then
        self._sfxVolume = profile.Settings.SFXVolume
        self._musicVolume = profile.Settings.MusicVolume
    end

    DataController.ProfileChanged:Connect(function(newProfile)
        if newProfile and newProfile.Settings then
            self:SetSFXVolume(newProfile.Settings.SFXVolume)
            self:SetMusicVolume(newProfile.Settings.MusicVolume)
        end
    end)
end

function AudioController:CalculatePitch(soundKey: Types.SoundKey): number
    local config = AudioConfig.Get(soundKey)
    if not config then
        return 1.0
    end

    local minInt = math.round(config.PitchMin * 100)
    local maxInt = math.round(config.PitchMax * 100)

    if minInt >= maxInt then
        return config.PitchMin
    end

    return math.random(minInt, maxInt) / 100
end

function AudioController:PlaySound(soundKey: Types.SoundKey, parentPart: any?, customPitch: number?): any
    local config = AudioConfig.Get(soundKey)
    if not config then
        return nil
    end

    local pitch = customPitch or self:CalculatePitch(soundKey)
    local volume = config.Volume * self._sfxVolume * self._masterVolume

    self.SoundPlayed:Fire(soundKey, parentPart)

    if not isRobloxEngine() then
        return {
            SoundKey = soundKey,
            Pitch = pitch,
            Volume = volume,
            Parent = parentPart,
        }
    end

    local sound = Instance.new("Sound")
    sound.SoundId = config.AssetId
    sound.Volume = volume
    sound.PlaybackSpeed = pitch
    sound.Looped = config.Looped

    local targetParent = parentPart
    if not targetParent or typeof(targetParent) ~= "Instance" then
        targetParent = game:GetService("SoundService")
    end

    sound.Parent = targetParent

    local group = self._soundGroups[config.SoundGroup]
    if group then
        sound.SoundGroup = group
    end

    sound:Play()

    if not config.Looped then
        sound.Ended:Once(function()
            sound:Destroy()
        end)
    end

    return sound
end

function AudioController:PlayBGM(bgmKey: Types.SoundKey, fadeDuration: number?)
    local config = AudioConfig.Get(bgmKey)
    if not config or self._currentBGMKey == bgmKey then
        return
    end

    self._currentBGMKey = bgmKey
    self.BGMChanged:Fire(bgmKey)

    if not isRobloxEngine() then
        return
    end

    local SoundService = game:GetService("SoundService")
    local TweenService = game:GetService("TweenService")
    local duration = fadeDuration or 1.5
    local targetVolume = config.Volume * self._musicVolume * self._masterVolume

    local oldBGM = self._currentBGM

    local newBGM = Instance.new("Sound")
    newBGM.SoundId = config.AssetId
    newBGM.Volume = 0
    newBGM.Looped = true
    newBGM.SoundGroup = self._soundGroups["BGM"]
    newBGM.Parent = SoundService
    newBGM:Play()

    self._currentBGM = newBGM

    -- Fade In neuer Track
    local fadeInTween = TweenService:Create(newBGM, TweenInfo.new(duration), { Volume = targetVolume })
    fadeInTween:Play()

    -- Fade Out alter Track
    if oldBGM then
        local fadeOutTween = TweenService:Create(oldBGM, TweenInfo.new(duration), { Volume = 0 })
        fadeOutTween:Play()
        fadeOutTween.Completed:Once(function()
            oldBGM:Stop()
            oldBGM:Destroy()
        end)
    end
end

function AudioController:StopBGM()
    if self._currentBGM and isRobloxEngine() then
        self._currentBGM:Stop()
        self._currentBGM:Destroy()
        self._currentBGM = nil
        self._currentBGMKey = ""
    end
end

function AudioController:SetMasterVolume(volume: number)
    self._masterVolume = math.clamp(volume, 0, 1)
end

function AudioController:SetSFXVolume(volume: number)
    self._sfxVolume = math.clamp(volume, 0, 1)
    if isRobloxEngine() and self._soundGroups["SFX"] then
        self._soundGroups["SFX"].Volume = self._sfxVolume
    end
end

function AudioController:SetMusicVolume(volume: number)
    self._musicVolume = math.clamp(volume, 0, 1)
    if self._currentBGM and isRobloxEngine() then
        self._currentBGM.Volume = self._musicVolume * self._masterVolume
    end
end

return AudioController
