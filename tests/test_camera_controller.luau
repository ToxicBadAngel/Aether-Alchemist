--!strict
--[[
    test_camera_controller.luau
    Automatisierter Lune Unit-Test zur Verifikation von CameraController.luau.
]]

local ProfileTemplate = require("../src/Shared/Config/ProfileTemplate")
local DataController = require("../src/Client/Controllers/DataController")
local CombatController = require("../src/Client/Controllers/CombatController")
local CameraController = require("../src/Client/Controllers/CameraController")

print("🧪 Starte CameraController Verifikation...")

-- 1. Test: Initialisierung & Profil setzen
DataController:Init()
DataController:Start()
CombatController:Init()
CombatController:Start()
CameraController:Init()
CameraController:Start()

DataController:SetLocalProfile(ProfileTemplate.GetDefault())

assert(CameraController:GetTrauma() == 0, "Trauma muss initial 0 sein")

-- 2. Test: Trauma Hinzufügen & Signal
local triggeredTrauma = 0
CameraController.ShakeTriggered:Connect(function(trauma)
    triggeredTrauma = trauma
end)

CameraController:AddTrauma(0.50)
assert(CameraController:GetTrauma() == 0.50, "Trauma muss auf 0.50 gesetzt sein")
assert(triggeredTrauma == 0.50, "ShakeTriggered Signal muss 0.50 melden")

-- 3. Test: Shake-Berechnung & Abklingkurve (Update)
local yaw, pitch, _roll, fov = CameraController:Update(0.1)
assert(yaw ~= 0 or pitch ~= 0, "Bei Trauma > 0 müssen Shake-Winkel berechnet werden")
assert(fov >= 60 and fov <= 80, "FoV muss im realistischen Bereich liegen")
assert(CameraController:GetTrauma() < 0.50, "Trauma muss nach 0.1s dt abgeklungen sein")

-- 4. Test: FoV-Punch & Feder-Erholung
local punchedAmount = 0
CameraController.FoVPunched:Connect(function(amount)
    punchedAmount = amount
end)

CameraController:PunchFoV(8)
assert(punchedAmount == 8, "FoVPunched Signal muss 8 melden")

-- FoV-Erholung über mehrere Ticks simulieren
for _ = 1, 20 do
    CameraController:Update(0.05)
end
local _y, _p, _r, recoveredFov = CameraController:Update(0.05)
assert(math.abs(recoveredFov - 70) < 1.0, string.format("FoV muss sich auf 70 erholt haben, aktuell: %f", recoveredFov))

-- 5. Test: Automatische Reaktion auf Kritische Treffer
local previousTrauma = CameraController:GetTrauma()
CombatController.DamageFeedbackReceived:Fire({
    targetModel = nil,
    damage = 50,
    isCrit = true,
    isHeal = false,
})

assert(CameraController:GetTrauma() > previousTrauma, "Kritischer Treffer muss Trauma erhöhen")

print("✅ CameraController zu 100% erfolgreich validiert!")
