--!strict
--[[
    ClientBootstrapper.client.luau
    Aether Alchemist (Element Shapers)
    Haupteinstiegspunkt für den Client (StarterPlayerScripts.Client).
    Orchestriert den strikten 2-Phasen-Lifecycle (Init -> Start) aller
    Client-Controller und initialisiert die UI-Screens (HUD, Inventory, Cauldron, Merchant, Skills).
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local DataController = require("./Controllers/DataController")
local AudioController = require("./Controllers/AudioController")
local MiningController = require("./Controllers/MiningController")
local CombatController = require("./Controllers/CombatController")
local CameraController = require("./Controllers/CameraController")
local UIController = require("./Controllers/UIController")
local AutoQAController = require("./Controllers/AutoQAController")

local HUDGui = require("../StarterGui/AetherUI/Screens/HUDGui")
local InventoryGui = require("../StarterGui/AetherUI/Screens/InventoryGui")
local CauldronGui = require("../StarterGui/AetherUI/Screens/CauldronGui")
local MerchantGui = require("../StarterGui/AetherUI/Screens/MerchantGui")
local SkillsGui = require("../StarterGui/AetherUI/Screens/SkillsGui")

local CONTROLLERS = {
    { Name = "DataController", Controller = DataController },
    { Name = "AudioController", Controller = AudioController },
    { Name = "MiningController", Controller = MiningController },
    { Name = "CombatController", Controller = CombatController },
    { Name = "CameraController", Controller = CameraController },
    { Name = "UIController", Controller = UIController },
    { Name = "AutoQAController", Controller = AutoQAController },
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("Players") ~= nil and game:GetService("Players").LocalPlayer ~= nil
    end)
    return success and result
end

local ClientBootstrapper = {}

function ClientBootstrapper.Bootstrap()
    -- Phase 1: Controller Initialisierung (Init)
    for _, entry in CONTROLLERS do
        if typeof(entry.Controller.Init) == "function" then
            entry.Controller:Init()
        end
    end

    -- Phase 2: UI-Screens erzeugen
    local playerGui: any = nil
    if isRobloxEngine() then
        local localPlayer = game:GetService("Players").LocalPlayer
        playerGui = localPlayer:WaitForChild("PlayerGui")
    end

    HUDGui.Create(playerGui)
    InventoryGui.Create(playerGui)
    CauldronGui.Create(playerGui)
    MerchantGui.Create(playerGui)
    SkillsGui.Create(playerGui)

    -- Phase 3: Controller Starten (Start)
    for _, entry in CONTROLLERS do
        if typeof(entry.Controller.Start) == "function" then
            entry.Controller:Start()
        end
    end

    -- Phase 4: ProximityPrompt Interaktionen binden (Kessel & Händler)
    if isRobloxEngine() then
        local proximityPromptService = game:GetService("ProximityPromptService")
        proximityPromptService.PromptTriggered:Connect(function(prompt, player)
            if player ~= game:GetService("Players").LocalPlayer then
                return
            end
            if prompt.Name == "CauldronPrompt" then
                UIController:OpenScreen("Cauldron")
            elseif prompt.Name == "MerchantPrompt" then
                UIController:OpenScreen("Merchant")
            end
        end)
    end

    print("✨ [Aether Alchemist Client] Alle 7 Controller & alle 5 UI-Screens erfolgreich gestartet!")
    return true
end

if isRobloxEngine() then
    ClientBootstrapper.Bootstrap()
end

return ClientBootstrapper
