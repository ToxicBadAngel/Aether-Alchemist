--!strict
--[[
    SkillService.luau
    Aether Alchemist (Element Shapers)
    Server-Singleton für Skill-Tree-Upgrades (UpgradeSkill_RF, Skill-Punkte-Validierung,
    Cap-Schutz MaxLevel 10 und Attribut-Boni für Harvester, Alchemist, Summoner).
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local Types = require("../../Shared/Config/Types")
local Signal = require("../../Shared/Modules/Signal")
local NetworkContracts = require("../../Shared/Remotes/NetworkContracts")
local DataService = require("./DataService")

local VALID_SKILLS: { [string]: boolean } = {
    Harvester = true,
    Alchemist = true,
    Summoner = true,
}

local MAX_SKILL_LEVEL = 10

export type SkillServiceType = {
    SkillUpgraded: Signal.Signal<any, string, number>,

    Init: (self: any) -> (),
    Start: (self: any) -> (),
    UpgradeSkill: (self: any, player: any, skillName: string) -> Types.SkillUpgradeResult,
    GetSkillLevel: (self: any, player: any, skillName: string) -> number,
    GetSkills: (self: any, player: any) -> Types.PlayerSkills?,
}

local SkillService = {
    SkillUpgraded = Signal.new(),

    _initialized = false,
    _started = false,
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("Players") ~= nil
    end)
    return success and result
end

function SkillService:Init()
    if self._initialized then
        return
    end
    self._initialized = true
end

function SkillService:Start()
    if self._started then
        return
    end
    self._started = true

    if not isRobloxEngine() then
        return
    end

    local upgradeSkillRF = NetworkContracts.GetRemoteFunction("UpgradeSkill_RF")
    if upgradeSkillRF then
        upgradeSkillRF.OnServerInvoke = function(player: any, skillName: string)
            return self:UpgradeSkill(player, skillName)
        end
    end
end

function SkillService:UpgradeSkill(player: any, skillName: string): Types.SkillUpgradeResult
    -- 1. Validierung: Skill-Name existiert
    if not VALID_SKILLS[skillName] then
        return { success = false, skill = skillName, newLevel = 0, error = "Ungültiger Skill-Name!" }
    end

    -- 2. Transaktions-Mutex
    local lockAcquired = DataService:AcquireLock(player)
    if not lockAcquired then
        return { success = false, skill = skillName, newLevel = 0, error = "Aktion wird bereits ausgeführt!" }
    end

    local profile = DataService:GetProfile(player)
    if not profile then
        DataService:ReleaseLock(player)
        return { success = false, skill = skillName, newLevel = 0, error = "Profil nicht geladen!" }
    end

    -- 3. Skill-Punkte Prüfung
    if profile.SkillPoints < 1 then
        DataService:ReleaseLock(player)
        return { success = false, skill = skillName, newLevel = 0, error = "Keine Skill-Punkte verfügbar!" }
    end

    -- 4. Cap-Prüfung (Max 10)
    local currentLevel = 0
    if skillName == "Harvester" then
        currentLevel = profile.Skills.Harvester
    elseif skillName == "Alchemist" then
        currentLevel = profile.Skills.Alchemist
    elseif skillName == "Summoner" then
        currentLevel = profile.Skills.Summoner
    end

    if currentLevel >= MAX_SKILL_LEVEL then
        DataService:ReleaseLock(player)
        return { success = false, skill = skillName, newLevel = currentLevel, error = "Skill hat bereits das Maximal-Level erreicht (10)!" }
    end

    -- 5. Upgrade durchführen
    local updatedLevel = currentLevel + 1
    DataService:UpdateProfile(player, function(data)
        data.SkillPoints -= 1
        if skillName == "Harvester" then
            data.Skills.Harvester = updatedLevel
        elseif skillName == "Alchemist" then
            data.Skills.Alchemist = updatedLevel
        elseif skillName == "Summoner" then
            data.Skills.Summoner = updatedLevel
        end
    end)

    -- 6. Mutex freigeben & Signal
    DataService:ReleaseLock(player)
    self.SkillUpgraded:Fire(player, skillName, updatedLevel)

    return {
        success = true,
        skill = skillName,
        newLevel = updatedLevel,
        error = nil,
    }
end

function SkillService:GetSkillLevel(player: any, skillName: string): number
    local profile = DataService:GetProfile(player)
    if not profile then
        return 0
    end

    if skillName == "Harvester" then
        return profile.Skills.Harvester
    elseif skillName == "Alchemist" then
        return profile.Skills.Alchemist
    elseif skillName == "Summoner" then
        return profile.Skills.Summoner
    end

    return 0
end

function SkillService:GetSkills(player: any): Types.PlayerSkills?
    local profile = DataService:GetProfile(player)
    if not profile then
        return nil
    end
    return profile.Skills
end

return SkillService
