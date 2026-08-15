--!strict
--[[
    test_spring.luau
    Automatisierter Lune Unit-Test zur Verifikation der Feder-Physik in Spring.luau.
]]

local Spring = require("../src/Shared/Modules/Spring")

print("🧪 Starte Spring Physik Verifikation...")

-- 1. Test: Initialisierung
local spring = Spring.new(1.0, 280, 18)
assert(spring.Position == 1.0, "Startposition muss 1.0 sein")
assert(spring.Target == 1.0, "Start-Target muss 1.0 sein")
assert(spring.Velocity == 0, "Start-Velocity muss 0 sein")
assert(spring:IsAtRest() == true, "Feder muss initial in Ruhe sein")

-- 2. Test: Zielwert-Änderung (Hover 1.04x) & Konvergenz
spring:SetTarget(1.04)
assert(spring:IsAtRest() == false, "Feder darf nach Target-Änderung nicht in Ruhe sein")

-- 60 Frames à 16.6ms simulieren (ca. 1 Sekunde)
for _ = 1, 60 do
    spring:Update(0.016)
end

assert(spring:IsAtRest(0.001) == true, "Feder muss nach 1 Sekunde konvergiert sein")
assert(math.abs(spring.Position - 1.04) < 0.001, string.format("Position %f weicht von Target 1.04 ab", spring.Position))

-- 3. Test: Impuls (Klick / Damage Pop)
spring:Reset(1.0)
spring:Impulse(5.0)
assert(spring.Velocity == 5.0, "Impuls muss Velocity erhöhen")
assert(spring:IsAtRest() == false, "Nach Impuls muss Bewegung vorliegen")

-- 4. Test: Reset
spring:Reset(0.5)
assert(spring.Position == 0.5 and spring.Target == 0.5 and spring.Velocity == 0, "Reset muss alle Werte sofort setzen")
assert(spring:IsAtRest() == true, "Nach Reset muss Ruhe eintreten")

-- 5. Test: Lag-Spike Stabilität (dt = 0.5s)
spring:SetTarget(10.0)
local posAfterLag = spring:Update(0.5)
assert(not (posAfterLag ~= posAfterLag), "Feder-Berechnung darf kein NaN erzeugen")
assert(math.abs(posAfterLag) < 1000, "Sub-Stepping muss vor Schwingungs-Explosion schützen")

print("✅ Spring Feder-Physik zu 100% erfolgreich validiert!")
