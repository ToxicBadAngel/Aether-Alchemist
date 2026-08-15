--!strict
--[[
    test_zones_config.luau
    Automatisierter Lune Unit-Test zur Verifikation von ZonesConfig.luau.
]]

local ZonesConfig = require("../src/Shared/Config/ZonesConfig")

print("🧪 Starte ZonesConfig Verifikation...")

-- 1. Test: Genau 3 Zonen müssen existieren
local allZones = ZonesConfig.GetAll()
local count = 0
for _ in allZones do
    count += 1
end
assert(count == 3, string.format("Erwartet 3 Zonen, aber %d gefunden", count))

-- 2. Test: Zone 1 (Aether-Wald)
local zone1 = ZonesConfig.Get(1)
assert(zone1 ~= nil, "Zone 1 nicht gefunden")
assert(zone1.LevelMin == 1 and zone1.LevelMax == 4, "Zone 1 Level-Range muss 1..4 sein")
assert(zone1.ClockTime == 14.5 and zone1.Brightness == 2.2, "Zone 1 Beleuchtung inkorrekt")
assert(zone1.BGMId == "BGM_Zone1", "Zone 1 BGM muss BGM_Zone1 sein")

-- 3. Test: Zone 2 (Kristall-Höhle)
local zone2 = ZonesConfig.Get(2)
assert(zone2 ~= nil, "Zone 2 nicht gefunden")
assert(zone2.LevelMin == 5 and zone2.LevelMax == 9, "Zone 2 Level-Range muss 5..9 sein")
assert(zone2.ClockTime == 17.8 and zone2.Brightness == 1.2, "Zone 2 Beleuchtung inkorrekt")
assert(zone2.BGMId == "BGM_Zone2", "Zone 2 BGM muss BGM_Zone2 sein")

-- 4. Test: Zone 3 (Void-Riss)
local zone3 = ZonesConfig.Get(3)
assert(zone3 ~= nil, "Zone 3 nicht gefunden")
assert(zone3.LevelMin == 10 and zone3.LevelMax == 20, "Zone 3 Level-Range muss 10..20 sein")
assert(zone3.ClockTime == 21.0 and zone3.Brightness == 0.8, "Zone 3 Beleuchtung inkorrekt")
assert(zone3.BGMId == "BGM_Zone3", "Zone 3 BGM muss BGM_Zone3 sein")

-- 5. Test: Level-Gate Validierung
local canEnter1, _ = ZonesConfig.CanEnterZone(1, 1)
assert(canEnter1 == true, "Lvl 1 Spieler muss Zone 1 betreten können")

local canEnter2Blocked, err2 = ZonesConfig.CanEnterZone(1, 2)
assert(canEnter2Blocked == false, "Lvl 1 Spieler darf Zone 2 nicht betreten")
assert(err2 ~= nil, "Fehlermeldung für Level-Sperre muss vorhanden sein")

local canEnter2Allowed, _ = ZonesConfig.CanEnterZone(5, 2)
assert(canEnter2Allowed == true, "Lvl 5 Spieler muss Zone 2 betreten können")

local canEnter3Blocked, _ = ZonesConfig.CanEnterZone(5, 3)
assert(canEnter3Blocked == false, "Lvl 5 Spieler darf Zone 3 nicht betreten")

local canEnter3Allowed, _ = ZonesConfig.CanEnterZone(10, 3)
assert(canEnter3Allowed == true, "Lvl 10 Spieler muss Zone 3 betreten können")

-- 6. Test: Positions-Lookup
local inZone1 = ZonesConfig.GetZoneForPosition({ X = 0, Y = 0, Z = 0 })
assert(inZone1 ~= nil and inZone1.Id == 1, "Position (0,0,0) muss in Zone 1 liegen")

local inZone2 = ZonesConfig.GetZoneForPosition({ X = 300, Y = 0, Z = 0 })
assert(inZone2 ~= nil and inZone2.Id == 2, "Position (300,0,0) muss in Zone 2 liegen")

local inZone3 = ZonesConfig.GetZoneForPosition({ X = 650, Y = 0, Z = 0 })
assert(inZone3 ~= nil and inZone3.Id == 3, "Position (650,0,0) muss in Zone 3 liegen")

local inVoid = ZonesConfig.GetZoneForPosition({ X = 5000, Y = 0, Z = 0 })
assert(inVoid == nil, "Position (5000,0,0) darf keiner Zone angehören")

print("✅ ZonesConfig zu 100% erfolgreich validiert!")
