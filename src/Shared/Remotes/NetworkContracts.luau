--!strict
--[[
    NetworkContracts.luau
    Aether Alchemist (Element Shapers)
    Zentrales Remotes-Verzeichnis aller RemoteEvents & RemoteFunctions.
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

export type RemoteFunctionName =
    "HarvestOre_RF"
    | "CraftPotion_RF"
    | "DrinkPotion_RF"
    | "SellOre_RF"
    | "EquipWeapon_RF"
    | "EquipSummon_RF"
    | "UpgradeSkill_RF"
    | "ResetSkills_RF"
    | "ClaimDailyStreak_RF"
    | "ClaimPlaytimeGift_RF"
    | "RequestTrade_RF"

export type RemoteEventName =
    "AttackSwing_RE"
    | "SummonAbility_RE"
    | "CombatFeedback_RE"
    | "ProfileSync_RE"
    | "BroadcastAnnouncement_RE"
    | "TutorialProgress_RE"
    | "PlaySound_RE"

local REMOTE_FUNCTIONS: { RemoteFunctionName } = {
    "HarvestOre_RF",
    "CraftPotion_RF",
    "DrinkPotion_RF",
    "SellOre_RF",
    "EquipWeapon_RF",
    "EquipSummon_RF",
    "UpgradeSkill_RF",
    "ResetSkills_RF",
    "ClaimDailyStreak_RF",
    "ClaimPlaytimeGift_RF",
    "RequestTrade_RF",
}

local REMOTE_EVENTS: { RemoteEventName } = {
    "AttackSwing_RE",
    "SummonAbility_RE",
    "CombatFeedback_RE",
    "ProfileSync_RE",
    "BroadcastAnnouncement_RE",
    "TutorialProgress_RE",
    "PlaySound_RE",
}

local NetworkContracts = {
    RemoteFunctions = REMOTE_FUNCTIONS,
    RemoteEvents = REMOTE_EVENTS,
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("ReplicatedStorage") ~= nil
    end)
    return success and result
end

-- // Server-seitige Initialisierung aller Remotes
function NetworkContracts.InitServer()
    if not isRobloxEngine() then
        return
    end

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local folder = ReplicatedStorage:FindFirstChild("Remotes")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "Remotes"
        folder.Parent = ReplicatedStorage
    end

    for _, fnName in REMOTE_FUNCTIONS do
        if not folder:FindFirstChild(fnName) then
            local rf = Instance.new("RemoteFunction")
            rf.Name = fnName
            rf.Parent = folder
        end
    end

    for _, evName in REMOTE_EVENTS do
        if not folder:FindFirstChild(evName) then
            local re = Instance.new("RemoteEvent")
            re.Name = evName
            re.Parent = folder
        end
    end
end

-- // Client & Server Zugriffs-Methoden
function NetworkContracts.GetRemoteFunction(name: RemoteFunctionName): any
    if not isRobloxEngine() then
        return nil
    end
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local folder = ReplicatedStorage:WaitForChild("Remotes", 10)
    if folder then
        return folder:WaitForChild(name, 10)
    end
    return nil
end

function NetworkContracts.GetRemoteEvent(name: RemoteEventName): any
    if not isRobloxEngine() then
        return nil
    end
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local folder = ReplicatedStorage:WaitForChild("Remotes", 10)
    if folder then
        return folder:WaitForChild(name, 10)
    end
    return nil
end

function NetworkContracts.IsValidRemoteFunction(name: string): boolean
    for _, fnName in REMOTE_FUNCTIONS do
        if fnName == name then
            return true
        end
    end
    return false
end

function NetworkContracts.IsValidRemoteEvent(name: string): boolean
    for _, evName in REMOTE_EVENTS do
        if evName == name then
            return true
        end
    end
    return false
end

return NetworkContracts
