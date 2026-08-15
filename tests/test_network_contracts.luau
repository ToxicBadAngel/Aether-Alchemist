--!strict
--[[
    test_network_contracts.luau
    Automatisierter Lune Unit-Test zur Verifikation von NetworkContracts.luau.
]]

local NetworkContracts = require("../src/Shared/Remotes/NetworkContracts")

print("🧪 Starte NetworkContracts Verifikation...")

-- 1. Test: Genau 11 RemoteFunctions
local rfCount = #NetworkContracts.RemoteFunctions
assert(rfCount == 11, string.format("Erwartet 11 RemoteFunctions, aber %d gefunden", rfCount))

-- 2. Test: Genau 7 RemoteEvents
local reCount = #NetworkContracts.RemoteEvents
assert(reCount == 7, string.format("Erwartet 7 RemoteEvents, aber %d gefunden", reCount))

-- 3. Test: Spezifische Remote-Namen
assert(NetworkContracts.IsValidRemoteFunction("HarvestOre_RF") == true, "HarvestOre_RF muss gültig sein")
assert(NetworkContracts.IsValidRemoteFunction("CraftPotion_RF") == true, "CraftPotion_RF muss gültig sein")
assert(NetworkContracts.IsValidRemoteFunction("SellOre_RF") == true, "SellOre_RF muss gültig sein")
assert(NetworkContracts.IsValidRemoteFunction("HackServer_RF") == false, "HackServer_RF darf nicht existieren")

assert(NetworkContracts.IsValidRemoteEvent("CombatFeedback_RE") == true, "CombatFeedback_RE muss gültig sein")
assert(NetworkContracts.IsValidRemoteEvent("ProfileSync_RE") == true, "ProfileSync_RE muss gültig sein")
assert(NetworkContracts.IsValidRemoteEvent("BroadcastAnnouncement_RE") == true, "BroadcastAnnouncement_RE muss gültig sein")
assert(NetworkContracts.IsValidRemoteEvent("FakeEvent_RE") == false, "FakeEvent_RE darf nicht existieren")

print("✅ NetworkContracts zu 100% erfolgreich validiert!")
