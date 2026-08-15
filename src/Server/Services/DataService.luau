--!strict
--[[
    DataService.luau
    Aether Alchemist (Element Shapers)
    Server-Singleton für Spielerdaten-Persistenz via ProfileService (Session-Locking,
    Transaktions-Mutex, Level-Up-Kalkulation und Netzwerk-Synchronisation).
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local Types = require("../../Shared/Config/Types")
local ProfileTemplate = require("../../Shared/Config/ProfileTemplate")
local Signal = require("../../Shared/Modules/Signal")
local MathUtils = require("../../Shared/Modules/MathUtils")
local NetworkContracts = require("../../Shared/Remotes/NetworkContracts")

export type DataServiceType = {
    ProfileLoaded: Signal.Signal<any, Types.PlayerProfileData>,
    ProfileUpdated: Signal.Signal<any, Types.PlayerProfileData>,
    PlayerLeveledUp: Signal.Signal<any, number, number>,

    Init: (self: any) -> (),
    Start: (self: any) -> (),
    GetProfile: (self: any, player: any) -> Types.PlayerProfileData?,
    UpdateProfile: (self: any, player: any, updateFn: (data: Types.PlayerProfileData) -> ()) -> boolean,
    AddEssence: (self: any, player: any, amount: number) -> number,
    RemoveEssence: (self: any, player: any, amount: number) -> boolean,
    AddXP: (self: any, player: any, amount: number) -> (number, boolean),
    AcquireLock: (self: any, player: any) -> boolean,
    ReleaseLock: (self: any, player: any) -> (),
    SyncProfile: (self: any, player: any) -> (),
    LoadMockProfile: (self: any, player: any, initialData: Types.PlayerProfileData?) -> Types.PlayerProfileData,
    UnloadMockProfile: (self: any, player: any) -> (),
}

local DataService = {
    ProfileLoaded = Signal.new(),
    ProfileUpdated = Signal.new(),
    PlayerLeveledUp = Signal.new(),

    _profiles = {} :: { [any]: any },
    _playerLocks = {} :: { [any]: boolean },
    _profileStore = nil :: any,
    _initialized = false,
    _started = false,
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("Players") ~= nil
    end)
    return success and result
end

function DataService:Init()
    if self._initialized then
        return
    end
    self._initialized = true

    if not isRobloxEngine() then
        return
    end

    local ServerScriptService = game:GetService("ServerScriptService")
    local ServerPackages = ServerScriptService:FindFirstChild("ServerPackages")
    if ServerPackages then
        local profileServiceModule = ServerPackages:FindFirstChild("ProfileService") or ServerPackages:FindFirstChild("profileservice")
        if profileServiceModule then
            local ProfileService = require(profileServiceModule :: any)
            self._profileStore = (ProfileService :: any).GetProfileStore(
                "AetherAlchemist_PlayerData_v1",
                ProfileTemplate.GetDefault()
            )
        end
    end
end

function DataService:Start()
    if self._started then
        return
    end
    self._started = true

    if not isRobloxEngine() then
        return
    end

    local Players = game:GetService("Players")

    local function onPlayerAdded(player: any)
        if not self._profileStore then
            return
        end

        local profileKey = string.format("Player_%d", player.UserId)
        local profile = self._profileStore:LoadProfileAsync(profileKey)

        if profile ~= nil then
            profile:AddUserId(player.UserId)
            profile:Reconcile()
            profile:ListenToRelease(function()
                self._profiles[player] = nil
                self._playerLocks[player] = nil
                player:Kick("Dein Spielstand wurde auf einem anderen Server geladen.")
            end)

            if player:IsDescendantOf(Players) then
                self._profiles[player] = profile
                self:SyncProfile(player)
                self.ProfileLoaded:Fire(player, profile.Data)
            else
                profile:Release()
            end
        else
            player:Kick("Konnte Spieldaten nicht laden. Bitte trete erneut bei.")
        end
    end

    local function onPlayerRemoving(player: any)
        local profile = self._profiles[player]
        if profile ~= nil then
            profile:Release()
            self._profiles[player] = nil
            self._playerLocks[player] = nil
        end
    end

    for _, player in Players:GetPlayers() do
        task.spawn(onPlayerAdded, player)
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)
end

function DataService:GetProfile(player: any): Types.PlayerProfileData?
    local profile = self._profiles[player]
    if profile then
        return profile.Data
    end
    return nil
end

function DataService:AcquireLock(player: any): boolean
    if self._playerLocks[player] == true then
        return false -- Mutex gesperrt (aktive Transaktion läuft bereits)
    end
    self._playerLocks[player] = true
    return true
end

function DataService:ReleaseLock(player: any)
    self._playerLocks[player] = nil
end

function DataService:UpdateProfile(player: any, updateFn: (data: Types.PlayerProfileData) -> ()): boolean
    local profile = self._profiles[player]
    if not profile or not profile.Data then
        return false
    end

    updateFn(profile.Data)
    self.ProfileUpdated:Fire(player, profile.Data)
    self:SyncProfile(player)
    return true
end

function DataService:AddEssence(player: any, amount: number): number
    if amount <= 0 then
        local data = self:GetProfile(player)
        return if data then data.AetherEssence else 0
    end

    local newBalance = 0
    self:UpdateProfile(player, function(data)
        data.AetherEssence += amount
        newBalance = data.AetherEssence
    end)

    return newBalance
end

function DataService:RemoveEssence(player: any, amount: number): boolean
    if amount <= 0 then
        return false
    end

    local profile = self:GetProfile(player)
    if not profile or profile.AetherEssence < amount then
        return false
    end

    self:UpdateProfile(player, function(data)
        data.AetherEssence -= amount
    end)

    return true
end

function DataService:AddXP(player: any, amount: number): (number, boolean)
    if amount <= 0 then
        local data = self:GetProfile(player)
        return if data then data.Level else 1, false
    end

    local currentLevel = 1
    local didLevelUp = false

    self:UpdateProfile(player, function(data)
        data.XP += amount
        local requiredXP = MathUtils.GetRequiredXP(data.Level)

        while data.XP >= requiredXP and data.Level < 20 do
            data.XP -= requiredXP
            data.Level += 1
            data.SkillPoints += 1
            didLevelUp = true
            currentLevel = data.Level
            requiredXP = MathUtils.GetRequiredXP(data.Level)
        end
    end)

    if didLevelUp then
        self.PlayerLeveledUp:Fire(player, currentLevel, amount)
    end

    return currentLevel, didLevelUp
end

function DataService:SyncProfile(player: any)
    if not isRobloxEngine() then
        return
    end

    local profileData = self:GetProfile(player)
    if profileData then
        local syncRemote = NetworkContracts.GetRemoteEvent("ProfileSync_RE")
        if syncRemote then
            syncRemote:FireClient(player, profileData)
        end
    end
end

-- // Headless Testing Support
function DataService:LoadMockProfile(player: any, initialData: Types.PlayerProfileData?): Types.PlayerProfileData
    local data = initialData or ProfileTemplate.GetDefault()
    self._profiles[player] = {
        Data = data,
        Release = function()
            self._profiles[player] = nil
        end,
    }
    self.ProfileLoaded:Fire(player, data)
    return data
end

function DataService:UnloadMockProfile(player: any)
    self._profiles[player] = nil
    self._playerLocks[player] = nil
end

return DataService
