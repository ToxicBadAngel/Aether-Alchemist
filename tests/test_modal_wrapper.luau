--!strict
--[[
    test_modal_wrapper.luau
    Automatisierter Lune Unit-Test zur Verifikation von ModalWrapper.luau.
]]

local ModalWrapper = require("../src/StarterGui/AetherUI/Components/ModalWrapper")

print("🧪 Starte ModalWrapper Verifikation...")

local closedCallbackFired = false
local modal = ModalWrapper.Create({
    Name = "CauldronModal",
    Title = "Alchemie-Kessel",
    OnClose = function()
        closedCallbackFired = true
    end,
})

assert(modal ~= nil, "Modal darf nicht nil sein")
assert(modal.ScreenGui.DisplayOrder == 10, "DisplayOrder muss 10 sein (Modal-Standard)")
assert(modal.ScreenGui.ResetOnSpawn == false, "ResetOnSpawn muss false sein")
assert(modal:IsOpen() == false, "Modal muss initial geschlossen sein")

-- 1. Test: Öffnen (Show)
local openedFired = false
modal.Opened:Connect(function()
    openedFired = true
end)

modal:Show()
assert(modal:IsOpen() == true, "Nach Show() muss IsOpen() true sein")
assert(modal.ScreenGui.Enabled == true, "ScreenGui.Enabled muss true sein")
assert(openedFired == true, "Opened Signal muss gefeuert haben")

-- 2. Test: Schließen (Hide)
local closedFired = false
modal.Closed:Connect(function()
    closedFired = true
end)

modal:Hide()
assert(modal:IsOpen() == false, "Nach Hide() muss IsOpen() false sein")
assert(modal.ScreenGui.Enabled == false, "ScreenGui.Enabled muss false sein")
assert(closedFired == true, "Closed Signal muss gefeuert haben")
assert(closedCallbackFired == true, "OnClose Callback muss ausgeführt worden sein")

-- 3. Test: Toggle
modal:Toggle()
assert(modal:IsOpen() == true, "Toggle auf geschlossenem Modal muss es öffnen")
modal:Toggle()
assert(modal:IsOpen() == false, "Toggle auf geöffnetem Modal muss es schließen")

print("✅ ModalWrapper zu 100% erfolgreich validiert!")
