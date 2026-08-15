--!strict
--[[
    test_combat_service.luau
    Automatisierter Lune Unit-Test zur Verifikation von CombatService.luau.
]]

local DataService = require("../src/Server/Services/DataService")
local InventoryService = require("../src/Server/Services/InventoryService")
local CauldronService = require("../src/Server/Services/CauldronService")
local CombatService = require("../src/Server/Services/CombatService")

print("🧪 Starte CombatService Verifikation...")

-- 1. Test: Initialisierung
DataService:Init()
DataService:Start()
InventoryService:Init()
InventoryService:Start()
CauldronService:Init()
CauldronService:Start()
CombatService:Init()
CombatService:Start()

local mockPlayer = {
    UserId = 77889900,
    Name = "SlimeHunter",
}

DataService:LoadMockProfile(mockPlayer)

-- 2. Test: Mob Registrierung
local mockMobInstance = { Name = "EarthSlime_01" }
local mobData = CombatService:RegisterMob(mockMobInstance, "EarthSlime", { X = 0, Y = 0, Z = 0 })
assert(mobData.CurrentHp == 50, "EarthSlime muss mit 50 HP starten")
assert(mobData.IsDead == false, "Mob darf nicht initial tot sein")

-- 3. Test: Angriff in Reichweite mit Standard-Waffe (BasicBlade: 10 DMG)
local playerPos = { X = 3, Y = 0, Z = 0 }
local attack1 = CombatService:ProcessAttack(mockPlayer, mockMobInstance, playerPos)
assert(attack1 == true, "Angriff in Reichweite muss erfolgreich sein")
assert(mobData.CurrentHp <= 40, "Mob-HP muss nach Treffer mindestens um 10 DMG sinken")

-- 4. Test: Cooldown-Schutz (Direkter 2. Angriff ohne Wartezeit)
local spamAttack = CombatService:ProcessAttack(mockPlayer, mockMobInstance, playerPos)
assert(spamAttack == false, "Direkter Spam-Angriff vor Ablauf des Cooldowns muss blockiert werden")

-- 5. Test: FireSaber (+50% Bonus gegen Slimes)
InventoryService:UnlockWeapon(mockPlayer, "FireSaber")
InventoryService:EquipWeapon(mockPlayer, "FireSaber")

-- Mob auf 25 HP setzen und simulieren
mobData.CurrentHp = 25

-- 1 Sekunde warten simulieren indem wir _lastAttackTimes zurücksetzen
CombatService._lastAttackTimes[mockPlayer] = 0

local initialXP = DataService:GetProfile(mockPlayer).XP
local attackKill = CombatService:ProcessAttack(mockPlayer, mockMobInstance, playerPos)
assert(attackKill == true, "Tödlicher Angriff muss erfolgreich sein")
assert(mobData.IsDead == true, "Mob muss nach Unterschreiten von 0 HP tot sein")
assert(mobData.CurrentHp == 0, "HP muss auf 0 geklemmt sein")

-- XP & Beute-Gutschrift prüfen
local profile = DataService:GetProfile(mockPlayer)
assert(profile.Stats.TotalMobsDefeated == 1, "Statistik TotalMobsDefeated muss 1 sein")
assert(profile.XP > initialXP, "XP muss nach Mob-Kill gutgeschrieben werden")
assert(InventoryService:GetOreCount(mockPlayer, "EarthTopaz") >= 1, "EarthTopaz muss als Beute im Inventar landen")

-- 6. Test: Begleiter-Aktivierung (FirePhoenix)
InventoryService:UnlockSummon(mockPlayer, "FirePhoenix")
InventoryService:EquipSummon(mockPlayer, "FirePhoenix")

local castSummon1 = CombatService:ProcessSummonCast(mockPlayer)
assert(castSummon1 == true, "Erster Begleiter-Cast muss erfolgreich sein")

local castSummonSpam = CombatService:ProcessSummonCast(mockPlayer)
assert(castSummonSpam == false, "Begleiter-Cast während Cooldown muss blockiert werden")

DataService:UnloadMockProfile(mockPlayer)

print("✅ CombatService zu 100% erfolgreich validiert!")
