--!strict
--[[
    ServerBootstrapper.server.luau
    Aether Alchemist (Element Shapers)
    Haupteinstiegspunkt für den Server (ServerScriptService.Server).
    Initialisiert Netzwerk-Remotes und orchestriert den strikten 2-Phasen-Lifecycle
    (Init -> Start) aller 8 Server-Services.
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local NetworkContracts = require("../Shared/Remotes/NetworkContracts")
local DataService = require("./Services/DataService")
local InventoryService = require("./Services/InventoryService")
local HarvestService = require("./Services/HarvestService")
local CauldronService = require("./Services/CauldronService")
local MerchantService = require("./Services/MerchantService")
local SkillService = require("./Services/SkillService")
local CombatService = require("./Services/CombatService")
local MobService = require("./Services/MobService")

local SERVICES = {
    { Name = "DataService", Service = DataService },
    { Name = "InventoryService", Service = InventoryService },
    { Name = "HarvestService", Service = HarvestService },
    { Name = "CauldronService", Service = CauldronService },
    { Name = "MerchantService", Service = MerchantService },
    { Name = "SkillService", Service = SkillService },
    { Name = "CombatService", Service = CombatService },
    { Name = "MobService", Service = MobService },
}

local ServerBootstrapper = {}

function ServerBootstrapper.Bootstrap()
    -- Phase 0: Netzwerk-Remotes registrieren
    NetworkContracts.InitServer()

    -- Phase 1: Services Initialisierung (Init)
    for _, entry in SERVICES do
        if typeof(entry.Service.Init) == "function" then
            entry.Service:Init()
        end
    end

    -- Phase 2: Services Starten (Start)
    for _, entry in SERVICES do
        if typeof(entry.Service.Start) == "function" then
            entry.Service:Start()
        end
    end

    print("🛡️ [Aether Alchemist Server] Alle 8 Server-Services erfolgreich initialisiert & gestartet!")
    return true
end

-- Automatische Ausführung im Roblox-Server-Kontext
local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("Players") ~= nil
    end)
    return success and result
end

if isRobloxEngine() then
    ServerBootstrapper.Bootstrap()
end

return ServerBootstrapper
