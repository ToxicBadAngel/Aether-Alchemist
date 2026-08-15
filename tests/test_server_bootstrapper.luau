--!strict
--[[
    test_server_bootstrapper.luau
    Automatisierter Lune Unit-Test zur Verifikation von ServerBootstrapper.server.luau.
]]

local ServerBootstrapper = require("../src/Server/ServerBootstrapper.server")
local DataService = require("../src/Server/Services/DataService")
local InventoryService = require("../src/Server/Services/InventoryService")

print("🧪 Starte ServerBootstrapper Verifikation...")

-- 1. Test: Bootstrapping des gesamten Server-Stacks
local bootstrapResult = ServerBootstrapper.Bootstrap()
assert(bootstrapResult == true, "Server-Bootstrapping muss erfolgreich true zurückgeben")

-- 2. Test: Integrität der hochgefahrenen Services
local mockPlayer = {
    UserId = 99991111,
    Name = "BootstrappedHero",
}

local profile = DataService:LoadMockProfile(mockPlayer)
assert(profile ~= nil, "DataService muss nach Bootstrapping einsatzbereit sein")

local addSuccess = InventoryService:AddOre(mockPlayer, "EarthTopaz", 10)
assert(addSuccess == true, "InventoryService muss nach Bootstrapping einsatzbereit sein")
assert(InventoryService:GetOreCount(mockPlayer, "EarthTopaz") == 15, "Inventar-Zustand muss 15 EarthTopaz sein")

DataService:UnloadMockProfile(mockPlayer)

print("✅ ServerBootstrapper zu 100% erfolgreich validiert!")
