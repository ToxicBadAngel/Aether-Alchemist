--!strict
--[[
    ClientBootstrapper.client.luau
    Aether Alchemist (Element Shapers)
    Haupteinstiegspunkt für den Client (StarterPlayerScripts.Client).
    Orchestriert den strikten 2-Phasen-Lifecycle (Init -> Start) aller
    Client-Controller.
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local DataController = require("./Controllers/DataController")
local AudioController = require("./Controllers/AudioController")
local MiningController = require("./Controllers/MiningController")
local CombatController = require("./Controllers/CombatController")
local CameraController = require("./Controllers/CameraController")
local UIController = require("./Controllers/UIController")

local CONTROLLERS = {
    { Name = "DataController", Controller = DataController },
    { Name = "AudioController", Controller = AudioController },
    { Name = "MiningController", Controller = MiningController },
    { Name = "CombatController", Controller = CombatController },
    { Name = "CameraController", Controller = CameraController },
    { Name = "UIController", Controller = UIController },
}

local ClientBootstrapper = {}

function ClientBootstrapper.Bootstrap()
    -- Phase 1: Controller Initialisierung (Init)
    for _, entry in CONTROLLERS do
        if typeof(entry.Controller.Init) == "function" then
            entry.Controller:Init()
        end
    end

    -- Phase 2: Controller Starten (Start)
    for _, entry in CONTROLLERS do
        if typeof(entry.Controller.Start) == "function" then
            entry.Controller:Start()
        end
    end

    print("✨ [Aether Alchemist Client] Alle 6 Client-Controller erfolgreich initialisiert & gestartet!")
    return true
end

-- Automatische Ausführung im Roblox-Client-Kontext
local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("Players") ~= nil and game:GetService("Players").LocalPlayer ~= nil
    end)
    return success and result
end

if isRobloxEngine() then
    ClientBootstrapper.Bootstrap()
end

return ClientBootstrapper
