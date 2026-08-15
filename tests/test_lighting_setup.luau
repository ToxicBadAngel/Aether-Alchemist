--!strict
--[[
    test_lighting_setup.luau
    Automatisierter Lune Unit-Test zur Verifikation von LightingSetup.luau.
]]

local LightingSetup = require("../src/Lighting/LightingSetup")

print("🧪 Starte LightingSetup Verifikation...")

-- 1. Test: Konfiguration abrufen
local config = LightingSetup.GetConfig()
assert(config ~= nil, "LightingConfig darf nicht nil sein")
assert(config.ClockTime == 14.5, "ClockTime muss 14.5 sein")
assert(config.Brightness == 2.2, "Brightness muss 2.2 sein")
assert(config.GlobalShadows == true, "GlobalShadows muss true sein")
assert(config.Bloom.Threshold == 0.8, "Bloom Threshold muss 0.8 sein")
assert(config.SunRays.Intensity == 0.25, "SunRays Intensity muss 0.25 sein")
assert(config.ColorCorrection.Contrast == 0.12, "ColorCorrection Contrast muss 0.12 sein")
assert(config.Atmosphere.Density == 0.25, "Atmosphere Density muss 0.25 sein")

-- 2. Test: Apply ohne Target im Headless-Modus
local resultNil = LightingSetup.Apply(nil)
assert(resultNil == false, "Apply ohne Target im Headless-Modus muss false zurückgeben")

-- 3. Test: Apply mit gemocktem Lighting-Service
local mockLighting: any = {
    ClockTime = 0,
    Brightness = 0,
    GlobalShadows = false,
}

local resultMock = LightingSetup.Apply(mockLighting)
assert(resultMock == true, "Apply mit Target muss true zurückgeben")
assert(mockLighting.ClockTime == 14.5, "Mock ClockTime muss 14.5 sein")
assert(mockLighting.Brightness == 2.2, "Mock Brightness muss 2.2 sein")
assert(mockLighting.GlobalShadows == true, "Mock GlobalShadows muss true sein")

print("✅ LightingSetup zu 100% erfolgreich validiert!")
