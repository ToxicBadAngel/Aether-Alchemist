--!strict
--[[
    test_ui_theme.luau
    Automatisierter Lune Unit-Test zur Verifikation von UITheme.luau Tokens.
]]

local UITheme = require("../src/Shared/Modules/UITheme")

print("🧪 Starte UITheme Verifikation...")

-- 1. Test: Alle Farben validieren
for colorName, rgb in UITheme.Colors do
    assert(rgb.R >= 0 and rgb.R <= 255, string.format("Farbe %s R-Wert ungültig: %f", colorName, rgb.R))
    assert(rgb.G >= 0 and rgb.G <= 255, string.format("Farbe %s G-Wert ungültig: %f", colorName, rgb.G))
    assert(rgb.B >= 0 and rgb.B <= 255, string.format("Farbe %s B-Wert ungültig: %f", colorName, rgb.B))
end

-- 2. Test: Spezifische Markenfarben
local gold = UITheme.GetColor("AntiqueGold")
assert(gold.R == 212 and gold.G == 175 and gold.B == 55, "AntiqueGold RGB Werte inkorrekt")

local cyan = UITheme.GetColor("AetherCyan")
assert(cyan.R == 56 and cyan.G == 189 and cyan.B == 248, "AetherCyan RGB Werte inkorrekt")

local slate = UITheme.GetColor("ObsidianSlate")
assert(slate.R == 15 and slate.G == 23 and slate.B == 42, "ObsidianSlate RGB Werte inkorrekt")

-- 3. Test: Transparenzen
assert(UITheme.Transparencies.PanelBackground == 0.15, "Panel Glass Transparenz muss 0.15 sein")
assert(UITheme.Transparencies.CardBackground == 0.25, "Card Glass Transparenz muss 0.25 sein")

-- 4. Test: Eckenradien (Anti-Slop Standard)
assert(UITheme.Radii.Panel == 14, "Panel Radius muss 14px sein")
assert(UITheme.Radii.Card == 10, "Card Radius muss 10px sein")
assert(UITheme.Radii.Button == 8, "Button Radius muss 8px sein")

-- 5. Test: Micro-Animation Tokens
assert(UITheme.Animations.ButtonHoverScale == 1.04, "Hover Scale muss 1.04x sein")
assert(UITheme.Animations.ButtonClickScale == 0.95, "Click Scale muss 0.95x sein")

-- 6. Test: Typografie
assert(UITheme.Fonts.Title == "GothamBold", "Title Font muss GothamBold sein")
assert(UITheme.Fonts.Body == "GothamMedium", "Body Font muss GothamMedium sein")

print("✅ UITheme zu 100% erfolgreich validiert!")
