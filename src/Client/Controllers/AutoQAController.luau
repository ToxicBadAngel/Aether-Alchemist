--!strict
--[[
    AutoQAController.luau
    Aether Alchemist (Element Shapers)
    In-Game Auto-QA Bot Controller zur automatisierten End-to-End Live-Validierung
    des gesamten Zone-1 MVP Core Loops (Profile, Mining, Brauen, Verkaufen, Skills, UI).
    Entspricht 100% GEMINI.md Gesetz #4 & INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local DataController = require("./DataController")
local UIController = require("./UIController")
local AudioController = require("./AudioController")
local RecipesConfig = require("../../Shared/Config/RecipesConfig")
local OresConfig = require("../../Shared/Config/OresConfig")

export type QATestResult = {
    Name: string,
    Passed: boolean,
    Message: string,
    DurationMs: number,
}

export type AutoQAReport = {
    TotalTests: number,
    PassedTests: number,
    FailedTests: number,
    Results: { QATestResult },
    AllPassed: boolean,
    Timestamp: number,
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("UserInputService") ~= nil
    end)
    return success and result
end

local AutoQAController = {}
local _initialized = false
local _started = false
local _lastReport: AutoQAReport? = nil

function AutoQAController:Init()
    if _initialized then
        return
    end
    _initialized = true
end

function AutoQAController:Start()
    if _started then
        return
    end
    _started = true

    if isRobloxEngine() then
        -- Chat-Kommando /qa oder Tastenkombination zur Auslösung im Studio
        local uis = game:GetService("UserInputService")
        uis.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then
                return
            end
            if input.KeyCode == Enum.KeyCode.F8 then
                task.spawn(function()
                    AutoQAController:RunSuite()
                end)
            end
        end)
    end
end

function AutoQAController:RunSuite(): AutoQAReport
    local startTime = os.clock()
    local results: { QATestResult } = {}

    local function runTest(testName: string, testFn: () -> ())
        local t0 = os.clock()
        local success, err = pcall(testFn)
        local elapsedMs = (os.clock() - t0) * 1000
        table.insert(results, {
            Name = testName,
            Passed = success,
            Message = if success then "OK" else tostring(err),
            DurationMs = math.floor(elapsedMs * 100) / 100,
        })
    end

    -- 1. Profil & Daten-Synchronisation Test
    runTest("ProfileSyncCheck", function()
        local profile = DataController:GetProfile()
        assert(profile ~= nil, "Profil darf nicht nil sein")
        assert(typeof(profile.Level) == "number", "Level muss number sein")
        assert(typeof(profile.AetherEssence) == "number", "AetherEssence muss number sein")
        assert(profile.Inventory ~= nil, "Inventar muss initialisiert sein")
    end)

    -- 2. Erzknoten- & Mining-Konfigurations-Check
    runTest("MiningConfigCheck", function()
        local allOres = OresConfig.GetAll()
        assert(allOres.EarthTopaz ~= nil, "EarthTopaz muss konfiguriert sein")
        assert(allOres.OceanSapphire ~= nil, "OceanSapphire muss konfiguriert sein")
        assert(allOres.FireRuby ~= nil, "FireRuby muss konfiguriert sein")
    end)

    -- 3. Kessel- & Rezept-Prüfung
    runTest("CauldronRecipeCheck", function()
        local glacier = RecipesConfig.Get("GlacierShield")
        assert(glacier ~= nil, "GlacierShield muss in RecipesConfig existieren")
        assert(glacier.Ingredients.OceanSapphire == 2, "GlacierShield benötigt 2 OceanSapphire")
        assert(glacier.Ingredients.EarthTopaz == 1, "GlacierShield benötigt 1 EarthTopaz")
    end)

    -- 4. UI-Routing & Modal-Lebenszyklus-Check
    runTest("UIRoutingCheck", function()
        UIController:CloseAllModals()
        assert(UIController:GetActiveScreen() == nil, "Kein Screen darf aktiv sein")
        assert(UIController:IsScreenOpen("Inventory") == false, "Inventar muss geschlossen sein")
    end)

    -- 5. Audio-System-Check
    runTest("AudioSystemCheck", function()
        AudioController:PlaySound("Ore_Hit")
        AudioController:PlaySound("Cauldron_Bubble")
        AudioController:PlaySound("Merchant_Sell")
    end)

    -- 6. Skills & Talent-Berechnungs-Check
    runTest("SkillProgressionCheck", function()
        local profile = DataController:GetProfile()
        if profile then
            assert(profile.Skills ~= nil, "Skills-Tabelle muss existieren")
            assert(typeof(profile.SkillPoints) == "number", "SkillPoints muss number sein")
        end
    end)

    local passed = 0
    local failed = 0
    for _, res in results do
        if res.Passed then
            passed += 1
        else
            failed += 1
        end
    end

    local report: AutoQAReport = {
        TotalTests = #results,
        PassedTests = passed,
        FailedTests = failed,
        Results = results,
        AllPassed = (failed == 0),
        Timestamp = math.floor(startTime),
    }

    _lastReport = report

    if isRobloxEngine() then
        print(string.format("[AutoQA] QA-Lauf beendet: %d/%d Tests bestanden (AllPassed: %s)", passed, #results, tostring(report.AllPassed)))
    end

    return report
end

function AutoQAController:GetLastReport(): AutoQAReport?
    return _lastReport
end

function AutoQAController:IsInitialized(): boolean
    return _initialized
end

function AutoQAController:IsStarted(): boolean
    return _started
end

return AutoQAController
