--!strict
--[[
    test_glass_button.luau
    Automatisierter Lune Unit-Test zur Verifikation von GlassButton.luau.
]]

local GlassButton = require("../src/StarterGui/AetherUI/Components/GlassButton")

print("🧪 Starte GlassButton Verifikation...")

-- 1. Test: Button-Erstellung mit Gold-Variante
local clickFired = false
local btnResult = GlassButton.Create({
    Name = "CraftButton",
    Text = "Kessel Brauen",
    Variant = "Gold",
    OnClick = function()
        clickFired = true
    end,
})

assert(btnResult ~= nil, "ButtonResult darf nicht nil sein")
assert(btnResult.Button.Name == "CraftButton", "Button-Name inkorrekt")
assert(btnResult.Button.Text == "Kessel Brauen", "Button-Text inkorrekt")
assert(btnResult.Button.Variant == "Gold", "Button-Variante inkorrekt")

-- 2. Test: Klick-Event Signal
btnResult.Clicked:Fire()
assert(clickFired == true, "OnClick Callback muss gefeuert worden sein")

-- 3. Test: Text- & Enabled-Mutatoren
btnResult.SetText("Gekühlt")
assert(btnResult.Button.Text == "Gekühlt", "SetText inkorrekt")

btnResult.SetEnabled(false)
assert(btnResult.Button.Enabled == false, "SetEnabled inkorrekt")

print("✅ GlassButton zu 100% erfolgreich validiert!")
