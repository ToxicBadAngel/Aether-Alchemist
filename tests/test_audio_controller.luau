--!strict
--[[
    test_audio_controller.luau
    Automatisierter Lune Unit-Test zur Verifikation von AudioController.luau.
]]

local ProfileTemplate = require("../src/Shared/Config/ProfileTemplate")
local DataController = require("../src/Client/Controllers/DataController")
local AudioController = require("../src/Client/Controllers/AudioController")

print("🧪 Starte AudioController Verifikation...")

-- 1. Test: Initialisierung & Profil setzen
DataController:Init()
DataController:Start()
AudioController:Init()
AudioController:Start()

DataController:SetLocalProfile(ProfileTemplate.GetDefault())

-- 2. Test: Pitch-Randomisierung (Anti-Acoustic Fatigue Gesetz #11)
local pitchMining = AudioController:CalculatePitch("Mining_Hit")
assert(pitchMining >= 0.92 and pitchMining <= 1.08, string.format("Mining Pitch %f liegt außerhalb [0.92, 1.08]", pitchMining))

local pitchLevelUp = AudioController:CalculatePitch("Level_Up")
assert(pitchLevelUp == 1.0, "Level-Up Sound muss exakt 1.0 Pitch besitzen")

-- 3. Test: PlaySound & Signal-Reaktion
local playedKey = ""
local playedPart: any = nil
AudioController.SoundPlayed:Connect(function(sKey, part)
    playedKey = sKey
    playedPart = part
end)

local mockPart = { Name = "OrePart" }
local soundObj = AudioController:PlaySound("Mining_Hit", mockPart)
assert(soundObj ~= nil, "Sound-Objekt darf nicht nil sein")
assert(playedKey == "Mining_Hit", "SoundPlayed Signal muss Mining_Hit melden")
assert(playedPart == mockPart, "SoundPlayed Part muss übergeben worden sein")
assert(soundObj.Pitch >= 0.92 and soundObj.Pitch <= 1.08, "Sound Pitch inkorrekt")

-- 4. Test: PlayBGM & Signal-Reaktion
local currentBGM = ""
AudioController.BGMChanged:Connect(function(bgmKey)
    currentBGM = bgmKey
end)

AudioController:PlayBGM("BGM_Zone1")
assert(currentBGM == "BGM_Zone1", "BGMChanged Signal muss BGM_Zone1 melden")

-- 5. Test: Lautstärke-Steuerung
AudioController:SetMasterVolume(0.8)
AudioController:SetSFXVolume(0.6)
AudioController:SetMusicVolume(0.4)

local adjustedSound = AudioController:PlaySound("UI_Click")
assert(adjustedSound ~= nil, "Adjusted Sound nil")
-- UI_Click: BaseVolume = 0.4 -> 0.4 * 0.6 * 0.8 = 0.192
assert(math.abs(adjustedSound.Volume - 0.192) < 0.001, string.format("Erwartete Lautstärke 0.192, aber %f erhalten", adjustedSound.Volume))

print("✅ AudioController zu 100% erfolgreich validiert!")
