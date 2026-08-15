--!strict
--[[
    test_build_zone1.luau
    Automatisierter Lune Unit-Test zur Verifikation von BuildZone1.luau.
]]

local BuildZone1 = require("../src/Workspace/MapGen/BuildZone1")

print("🧪 Starte BuildZone1 Verifikation...")

-- 1. Test: Layout-Konfiguration
local layout = BuildZone1.GetLayout()
assert(layout ~= nil, "Layout darf nicht nil sein")
assert(layout.Name == "Aether-Lichtung (Zone 1)", "Name muss Aether-Lichtung (Zone 1) sein")
assert(#layout.OreNodes == 10, string.format("Es müssen genau 10 Erzknoten sein, aber %d gefunden", #layout.OreNodes))
assert(#layout.MobSpawns == 4, string.format("Es müssen genau 4 Mobspawns sein, aber %d gefunden", #layout.MobSpawns))

-- 2. Test: Erz-Zusammensetzung (5 Topas, 3 Saphir, 2 Rubin)
local oreCounts: { [string]: number } = {}
for _, node in layout.OreNodes do
    oreCounts[node.OreId] = (oreCounts[node.OreId] or 0) + 1
end

assert(oreCounts["EarthTopaz"] == 5, string.format("Erwartet 5 EarthTopaz, aber %d", oreCounts["EarthTopaz"] or 0))
assert(oreCounts["OceanSapphire"] == 3, string.format("Erwartet 3 OceanSapphire, aber %d", oreCounts["OceanSapphire"] or 0))
assert(oreCounts["FireRuby"] == 2, string.format("Erwartet 2 FireRuby, aber %d", oreCounts["FireRuby"] or 0))

-- 3. Test: Mob-Zusammensetzung (4 Slimes)
for _, spawn in layout.MobSpawns do
    assert(spawn.MobId == "Slime", "In Zone 1 dürfen nur Slimes spawnen")
end

-- 4. Test: Build-Ergebnis
local buildResult = BuildZone1.Build(nil)
assert(buildResult ~= nil, "BuildResult darf nicht nil sein")
assert(buildResult.OreNodesCount == 10, "OreNodesCount muss 10 sein")
assert(buildResult.MobSpawnsCount == 4, "MobSpawnsCount muss 4 sein")
assert(buildResult.HasCauldron == true, "HasCauldron muss true sein")
assert(buildResult.HasMerchant == true, "HasMerchant muss true sein")
assert(buildResult.HasSpawnLocation == true, "HasSpawnLocation muss true sein")

print("✅ BuildZone1 zu 100% erfolgreich validiert!")
