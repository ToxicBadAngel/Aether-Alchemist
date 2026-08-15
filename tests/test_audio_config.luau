--!strict
--[[
    test_audio_config.luau
    Automatisierter Lune Unit-Test zur Verifikation von AudioConfig.luau.
]]

local AudioConfig = require("../src/Shared/Config/AudioConfig")

print("🧪 Starte AudioConfig Verifikation...")

-- 1. Test: Genau 19 Sounds müssen existieren
local allSounds = AudioConfig.GetAll()
local count = 0
for _, entry in allSounds do
    count += 1
    assert(string.find(entry.AssetId, "rbxassetid://") == 1, string.format("Ungültiges AssetId Format: %s", entry.AssetId))
    assert(entry.Volume >= 0 and entry.Volume <= 1.0, string.format("Lautstärke außerhalb [0, 1]: %f", entry.Volume))
    assert(entry.PitchMin <= entry.PitchMax, "PitchMin darf nicht größer als PitchMax sein")
end
assert(count == 19, string.format("Erwartet 19 Sounds, aber %d gefunden", count))

-- 2. Test: Spezifische SFX-Prüfung
local miningHit = AudioConfig.Get("Mining_Hit")
assert(miningHit ~= nil, "Mining_Hit nicht gefunden")
assert(miningHit.PitchMin == 0.92 and miningHit.PitchMax == 1.08, "Mining_Hit Pitch-Range inkorrekt")
assert(miningHit.SoundGroup == "SFX", "Mining_Hit muss in SoundGroup SFX liegen")

-- 3. Test: UI-Sounds
local uiClick = AudioConfig.Get("UI_Click")
assert(uiClick ~= nil, "UI_Click nicht gefunden")
assert(uiClick.SoundGroup == "UI", "UI_Click muss in SoundGroup UI liegen")

-- 4. Test: BGM-Loops
local bgm1 = AudioConfig.Get("BGM_Zone1")
assert(bgm1 ~= nil, "BGM_Zone1 nicht gefunden")
assert(bgm1.Looped == true, "BGM_Zone1 muss looped sein")
assert(bgm1.SoundGroup == "BGM", "BGM_Zone1 muss in SoundGroup BGM liegen")

-- 5. Test: Pitch-Randomisierung
for _ = 1, 50 do
    local pitch = AudioConfig.GetRandomPitch("Mining_Hit")
    assert(pitch >= 0.92 and pitch <= 1.08, string.format("Random Pitch %f außerhalb [0.92, 1.08]", pitch))
end

-- 6. Test: IsValidSound
assert(AudioConfig.IsValidSound("Boss_Roar") == true, "Boss_Roar muss gültig sein")
assert(AudioConfig.IsValidSound("Explosion") == false, "Explosion darf nicht in Sound-Tabelle sein")

print("✅ AudioConfig zu 100% erfolgreich validiert!")
