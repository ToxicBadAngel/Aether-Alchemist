--!strict
--[[
    test_mob_service.luau
    Automatisierter Lune Unit-Test zur Verifikation von MobService.luau.
]]

local DataService = require("../src/Server/Services/DataService")
local InventoryService = require("../src/Server/Services/InventoryService")
local CauldronService = require("../src/Server/Services/CauldronService")
local CombatService = require("../src/Server/Services/CombatService")
local MobService = require("../src/Server/Services/MobService")

print("🧪 Starte MobService Verifikation...")

-- 1. Test: Initialisierung
DataService:Init()
DataService:Start()
InventoryService:Init()
InventoryService:Start()
CauldronService:Init()
CauldronService:Start()
CombatService:Init()
CombatService:Start()
MobService:Init()
MobService:Start()

local mockPlayer = {
    UserId = 12121212,
    Name = "TargetHero",
}

DataService:LoadMockProfile(mockPlayer)

-- 2. Test: Spawner Registrierung & Spawning
local spawner = MobService:RegisterSpawner("Spawner_Slimes_Zone1", "EarthSlime", { X = 0, Y = 0, Z = 0 }, 2, 5)
assert(spawner.MaxCount == 2, "MaxCount des Spawners inkorrekt")

local mobEntity = MobService:SpawnMob("Spawner_Slimes_Zone1")
assert(mobEntity ~= nil, "Mob konnte nicht gespawnt werden")
assert(mobEntity.MobId == "EarthSlime", "MobId muss EarthSlime sein")
assert(mobEntity.State == "Idle", "Startzustand muss Idle sein")

local combatMob = CombatService:GetMob(mobEntity.Instance)
assert(combatMob ~= nil, "Mob muss automatisch im CombatService registriert sein")
assert(combatMob.CurrentHp == 50, "Slime muss 50 HP besitzen")

-- 3. Test: State Machine - Aggro & Verfolgung
-- Spieler weit weg (50 Studs) -> Kein Aggro
local farPlayers = { [mockPlayer] = { X = 50, Y = 0, Z = 50 } }
MobService:UpdateAI(0.1, farPlayers)
assert(mobEntity.State == "Idle" or mobEntity.State == "Patrol", "Weit entfernter Spieler darf kein Aggro auslösen")

-- Spieler betritt Aggro-Radius (8 Studs) -> Chase
local nearPlayers = { [mockPlayer] = { X = 8, Y = 0, Z = 0 } }
MobService:UpdateAI(0.1, nearPlayers)
assert(mobEntity.State == "Chase", "Mob muss bei 8 Studs Distanz in Chase wechseln")
assert(mobEntity.TargetPlayer == mockPlayer, "TargetPlayer muss gesetzt sein")

-- Mob nähert sich auf 3 Studs -> Attack
local closePlayers = { [mockPlayer] = { X = 3, Y = 0, Z = 0 } }
-- Position des Mobs dicht heranbewegen
mobEntity.CurrentPosition = { X = 3.5, Y = 0, Z = 0 }
MobService:UpdateAI(0.1, closePlayers)
assert(mobEntity.State == "Attack", "Mob muss bei <= 4 Studs Distanz in Attack wechseln")

-- 4. Test: Leash-Bruch & Reset (Spieler zieht Mob über Leash-Radius hinaus)
-- Mob ist bei 40 Studs (LeashRadius für Slime ist 35)
mobEntity.CurrentPosition = { X = 40, Y = 0, Z = 0 }
MobService:UpdateAI(0.1, farPlayers)
assert(mobEntity.State == "Reset", "Mob muss bei Überschreiten des Leash-Radius in Reset wechseln")
assert(mobEntity.TargetPlayer == nil, "TargetPlayer muss beim Reset gelöscht werden")

-- Reset abschließen (Mob erreicht Home)
mobEntity.CurrentPosition = { X = 0.5, Y = 0, Z = 0 }
mobEntity.HomePosition = { X = 0, Y = 0, Z = 0 }
MobService:UpdateAI(0.1, farPlayers)
assert(mobEntity.State == "Idle", "Nach Erreichen der Home-Position muss Mob wieder Idle sein")
assert(combatMob.CurrentHp == 50, "Mob muss nach Reset wieder 100% HP besitzen")

DataService:UnloadMockProfile(mockPlayer)

print("✅ MobService zu 100% erfolgreich validiert!")
