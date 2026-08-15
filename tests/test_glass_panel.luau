--!strict
--[[
    test_glass_panel.luau
    Automatisierter Lune Unit-Test zur Verifikation von GlassPanel.luau.
]]

local UITheme = require("../src/Shared/Modules/UITheme")
local GlassPanel = require("../src/StarterGui/AetherUI/Components/GlassPanel")

print("🧪 Starte GlassPanel Verifikation...")

-- 1. Test: Panel-Erstellung mit Standard-Props
local panelResult = GlassPanel.Create({
    Name = "InventoryPanel",
    Title = "Inventar & Beutel",
    CornerRadius = UITheme.Radii.Panel,
})

assert(panelResult ~= nil, "PanelResult darf nicht nil sein")
assert(panelResult.Frame ~= nil, "Frame muss existieren")
assert(panelResult.Frame.Name == "InventoryPanel", "Panel-Name inkorrekt")
assert(panelResult.Frame.CornerRadius == 14, "CornerRadius muss 14px betragen")
assert(panelResult.TitleLabel ~= nil and panelResult.TitleLabel.Text == "Inventar & Beutel", "Titel inkorrekt")

-- 2. Test: Card Panel ohne Titel
local cardResult = GlassPanel.Create({
    Name = "ItemCard",
    CornerRadius = UITheme.Radii.Card,
})

assert(cardResult.Frame.CornerRadius == 10, "Card CornerRadius muss 10px betragen")
assert(cardResult.TitleLabel == nil, "Card ohne Titel darf kein TitleLabel haben")

print("✅ GlassPanel zu 100% erfolgreich validiert!")
