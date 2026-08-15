--!strict
--[[
    UITheme.luau
    Aether Alchemist (Element Shapers)
    Zentrale Design-Tokens für das moderne 4-Layer Glassmorphism UI-System.
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1) & GEMINI.md Anti-Slop Standard.
]]

export type UIThemeColors = {
    -- Hintergründe
    ObsidianSlate: { R: number, G: number, B: number },
    CardBackground: { R: number, G: number, B: number },
    SurfaceElevated: { R: number, G: number, B: number },

    -- Akzente
    AntiqueGold: { R: number, G: number, B: number },
    AntiqueGoldGlow: { R: number, G: number, B: number },
    AetherCyan: { R: number, G: number, B: number },
    AetherCyanGlow: { R: number, G: number, B: number },
    CrimsonRed: { R: number, G: number, B: number },
    SuccessGreen: { R: number, G: number, B: number },

    -- Typografie
    TextPrimary: { R: number, G: number, B: number },
    TextSecondary: { R: number, G: number, B: number },
    TextMuted: { R: number, G: number, B: number },

    -- Elementar-Farben
    Earth: { R: number, G: number, B: number },
    Fire: { R: number, G: number, B: number },
    Ocean: { R: number, G: number, B: number },
    Wind: { R: number, G: number, B: number },
    Lightning: { R: number, G: number, B: number },
    Void: { R: number, G: number, B: number },
}

local Colors: UIThemeColors = {
    ObsidianSlate = { R = 15, G = 23, B = 42 },
    CardBackground = { R = 30, G = 41, B = 59 },
    SurfaceElevated = { R = 51, G = 65, B = 85 },

    AntiqueGold = { R = 212, G = 175, B = 55 },
    AntiqueGoldGlow = { R = 251, G = 191, B = 36 },
    AetherCyan = { R = 56, G = 189, B = 248 },
    AetherCyanGlow = { R = 125, G = 211, B = 252 },
    CrimsonRed = { R = 239, G = 68, B = 68 },
    SuccessGreen = { R = 34, G = 197, B = 94 },

    TextPrimary = { R = 248, G = 250, B = 252 },
    TextSecondary = { R = 148, G = 163, B = 184 },
    TextMuted = { R = 100, G = 116, B = 139 },

    Earth = { R = 245, G = 158, B = 11 },
    Fire = { R = 239, G = 68, B = 68 },
    Ocean = { R = 59, G = 130, B = 246 },
    Wind = { R = 16, G = 185, B = 129 },
    Lightning = { R = 168, G = 85, B = 247 },
    Void = { R = 217, G = 70, B = 239 },
}

local Transparencies = {
    PanelBackground = 0.15,
    CardBackground = 0.25,
    StrokeGlass = 0.60,
    StrokeHighlight = 0.20,
}

local Radii = {
    Panel = 14,
    Card = 10,
    Button = 8,
    Small = 6,
}

local Animations = {
    ButtonHoverScale = 1.04,
    ButtonClickScale = 0.95,
    SpringStiffness = 280,
    SpringDamping = 18,
    TweenFast = 0.15,
    TweenNormal = 0.25,
    TweenSlow = 0.40,
}

local Fonts = {
    Title = "GothamBold",
    Body = "GothamMedium",
    Numbers = "GothamBold",
}

local UITheme = {
    Colors = Colors,
    Transparencies = Transparencies,
    Radii = Radii,
    Animations = Animations,
    Fonts = Fonts,
}

function UITheme.GetColor(colorName: keyof<UIThemeColors>): { R: number, G: number, B: number }
    return Colors[colorName]
end

return UITheme
