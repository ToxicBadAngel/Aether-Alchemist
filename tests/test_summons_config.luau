--!strict
--[[
    test_summons_config.luau
    Automatisierter Lune Unit-Test zur Verifikation von SummonsConfig.luau.
]]

local SummonsConfig = require("../src/Shared/Config/SummonsConfig")

print("🧪 Starte SummonsConfig Verifikation...")

-- 1. Test: Genau 3 Summons müssen existieren
local allSummons = SummonsConfig.GetAll()
local count = 0
for _ in allSummons do
    count += 1
end
assert(count == 3, string.format("Erwartet 3 Summons, aber %d gefunden", count))

-- 2. Test: Feuer-Phönix
local phoenix = SummonsConfig.Get("FirePhoenix")
assert(phoenix ~= nil, "FirePhoenix nicht gefunden")
assert(phoenix.Cooldown == 10, "FirePhoenix Cooldown muss 10s sein")
assert(phoenix.Keybind == "E", "FirePhoenix Keybind muss 'E' sein")
assert(phoenix.Damage == 40, "FirePhoenix Damage muss 40 sein")

-- 3. Test: Eis-Golem
local golem = SummonsConfig.Get("IceGolem")
assert(golem ~= nil, "IceGolem nicht gefunden")
assert(golem.Cooldown == 15, "IceGolem Cooldown muss 15s sein")
assert(golem.ShieldAmount == 50, "IceGolem ShieldAmount muss 50 sein")
assert(golem.SlowDuration == 3.0, "IceGolem SlowDuration muss 3.0s sein")

-- 4. Test: Void-Phantom
local phantom = SummonsConfig.Get("VoidPhantom")
assert(phantom ~= nil, "VoidPhantom nicht gefunden")
assert(phantom.Cooldown == 12, "VoidPhantom Cooldown muss 12s sein")
assert(phantom.TeleportDistance == 15, "VoidPhantom TeleportDistance muss 15 Studs sein")

-- 5. Test: IsValidSummon
assert(SummonsConfig.IsValidSummon("FirePhoenix") == true, "FirePhoenix muss gültig sein")
assert(SummonsConfig.IsValidSummon("Dragon") == false, "Dragon darf nicht existieren")

print("✅ SummonsConfig zu 100% erfolgreich validiert!")
