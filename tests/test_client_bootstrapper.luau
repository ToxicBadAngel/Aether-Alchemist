--!strict
--[[
    test_client_bootstrapper.luau
    Automatisierter Lune Unit-Test zur Verifikation von ClientBootstrapper.client.luau.
]]

local ProfileTemplate = require("../src/Shared/Config/ProfileTemplate")
local ClientBootstrapper = require("../src/Client/ClientBootstrapper.client")
local DataController = require("../src/Client/Controllers/DataController")
local UIController = require("../src/Client/Controllers/UIController")

print("🧪 Starte ClientBootstrapper Verifikation...")

-- 1. Test: Bootstrapping des gesamten Client-Stacks
local bootstrapResult = ClientBootstrapper.Bootstrap()
assert(bootstrapResult == true, "Client-Bootstrapping muss erfolgreich true zurückgeben")

-- 2. Test: Integrität der hochgefahrenen Controller
DataController:SetLocalProfile(ProfileTemplate.GetDefault())
assert(DataController:GetProfile() ~= nil, "DataController muss nach Bootstrapping einsatzbereit sein")
assert(DataController:GetEssence() == 100, "Start-Essenz muss 100 sein")

UIController:RegisterScreen("Inventory", function(_vis) end)
local openSuccess = UIController:OpenScreen("Inventory")
assert(openSuccess == true, "UIController muss nach Bootstrapping einsatzbereit sein")

print("✅ ClientBootstrapper zu 100% erfolgreich validiert!")
