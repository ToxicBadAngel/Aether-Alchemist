--!strict
--[[
    LightingSetup.luau
    Aether Alchemist (Element Shapers)
    Beleuchtungs- und Post-Processing-Setup (Future Lighting, Atmosphere, Bloom,
    ColorCorrection, SunRays). Entspricht 100% GEMINI.md Abschnitt 4.
]]

export type RGBColor = {
    R: number,
    G: number,
    B: number,
}

export type LightingConfig = {
    ClockTime: number,
    Brightness: number,
    GlobalShadows: boolean,
    OutdoorAmbient: RGBColor,
    Bloom: {
        Size: number,
        Threshold: number,
        Intensity: number,
    },
    SunRays: {
        Intensity: number,
        Spread: number,
    },
    ColorCorrection: {
        Contrast: number,
        Saturation: number,
        Brightness: number,
    },
    Atmosphere: {
        Density: number,
        Haze: number,
        Glare: number,
        Color: RGBColor,
        Decay: RGBColor,
    },
}

local CONFIG: LightingConfig = {
    ClockTime = 14.5,
    Brightness = 2.2,
    GlobalShadows = true,
    OutdoorAmbient = { R = 120, G = 130, B = 150 },
    Bloom = {
        Size = 24,
        Threshold = 0.8,
        Intensity = 0.6,
    },
    SunRays = {
        Intensity = 0.25,
        Spread = 0.8,
    },
    ColorCorrection = {
        Contrast = 0.12,
        Saturation = 0.2,
        Brightness = 0.02,
    },
    Atmosphere = {
        Density = 0.25,
        Haze = 1.5,
        Glare = 0.3,
        Color = { R = 199, G = 218, B = 255 },
        Decay = { R = 106, G = 132, B = 175 },
    },
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("Lighting") ~= nil
    end)
    return success and result
end

local LightingSetup = {}

function LightingSetup.GetConfig(): LightingConfig
    return CONFIG
end

function LightingSetup.Apply(lightingService: any?): boolean
    local targetLighting = lightingService

    if not targetLighting and isRobloxEngine() then
        targetLighting = game:GetService("Lighting")
    end

    if not targetLighting then
        return false
    end

    targetLighting.ClockTime = CONFIG.ClockTime
    targetLighting.Brightness = CONFIG.Brightness
    targetLighting.GlobalShadows = CONFIG.GlobalShadows

    if isRobloxEngine() then
        targetLighting.Technology = Enum.Technology.Future
        targetLighting.OutdoorAmbient = Color3.fromRGB(CONFIG.OutdoorAmbient.R, CONFIG.OutdoorAmbient.G, CONFIG.OutdoorAmbient.B)

        local bloom = targetLighting:FindFirstChildOfClass("BloomEffect")
        if not bloom then
            bloom = Instance.new("BloomEffect")
            bloom.Name = "AetherBloom"
            bloom.Parent = targetLighting
        end
        bloom.Size = CONFIG.Bloom.Size
        bloom.Threshold = CONFIG.Bloom.Threshold
        bloom.Intensity = CONFIG.Bloom.Intensity

        local sunRays = targetLighting:FindFirstChildOfClass("SunRaysEffect")
        if not sunRays then
            sunRays = Instance.new("SunRaysEffect")
            sunRays.Name = "AetherSunRays"
            sunRays.Parent = targetLighting
        end
        sunRays.Intensity = CONFIG.SunRays.Intensity
        sunRays.Spread = CONFIG.SunRays.Spread

        local cc = targetLighting:FindFirstChildOfClass("ColorCorrectionEffect")
        if not cc then
            cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "AetherColorCorrection"
            cc.Parent = targetLighting
        end
        cc.Contrast = CONFIG.ColorCorrection.Contrast
        cc.Saturation = CONFIG.ColorCorrection.Saturation
        cc.Brightness = CONFIG.ColorCorrection.Brightness

        local atmosphere = targetLighting:FindFirstChildOfClass("Atmosphere")
        if not atmosphere then
            atmosphere = Instance.new("Atmosphere")
            atmosphere.Name = "AetherAtmosphere"
            atmosphere.Parent = targetLighting
        end
        atmosphere.Density = CONFIG.Atmosphere.Density
        atmosphere.Haze = CONFIG.Atmosphere.Haze
        atmosphere.Glare = CONFIG.Atmosphere.Glare
        atmosphere.Color = Color3.fromRGB(CONFIG.Atmosphere.Color.R, CONFIG.Atmosphere.Color.G, CONFIG.Atmosphere.Color.B)
        atmosphere.Decay = Color3.fromRGB(CONFIG.Atmosphere.Decay.R, CONFIG.Atmosphere.Decay.G, CONFIG.Atmosphere.Decay.B)
    end

    return true
end

return LightingSetup
