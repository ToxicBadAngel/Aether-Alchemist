--!strict
--[[
    UIController.luau
    Aether Alchemist (Element Shapers)
    Client-Singleton für modales Fenster-Management & Screen-Routing (Exklusives Öffnen,
    Hotkeys B/C/M/K/Escape, Audio-Kopplung und Screen-Lifecycle).
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local Signal = require("../../Shared/Modules/Signal")
local AudioController = require("./AudioController")

export type ScreenEntry = {
    Name: string,
    IsOpen: boolean,
    ScreenInstance: any?,
    SetVisible: (visible: boolean) -> (),
}

export type UIControllerType = {
    ScreenOpened: Signal.Signal<string>,
    ScreenClosed: Signal.Signal<string>,

    Init: (self: any) -> (),
    Start: (self: any) -> (),
    RegisterScreen: (self: any, screenName: string, setVisibleCallback: (visible: boolean) -> (), screenInstance: any?) -> (),
    OpenScreen: (self: any, screenName: string) -> boolean,
    CloseScreen: (self: any, screenName: string) -> boolean,
    ToggleScreen: (self: any, screenName: string) -> boolean,
    CloseAllModals: (self: any) -> (),
    GetActiveScreen: (self: any) -> string?,
    IsScreenOpen: (self: any, screenName: string) -> boolean,
}

local UIController = {
    ScreenOpened = Signal.new(),
    ScreenClosed = Signal.new(),

    _screens = {} :: { [string]: ScreenEntry },
    _activeModal = nil :: string?,
    _initialized = false,
    _started = false,
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("UserInputService") ~= nil
    end)
    return success and result
end

function UIController:Init()
    if self._initialized then
        return
    end
    self._initialized = true
end

function UIController:Start()
    if self._started then
        return
    end
    self._started = true

    if not isRobloxEngine() then
        return
    end

    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(input: any, gameProcessed: boolean)
        if gameProcessed then
            return
        end

        local keyCode = input.KeyCode
        if keyCode == Enum.KeyCode.B then
            self:ToggleScreen("Inventory")
        elseif keyCode == Enum.KeyCode.C then
            self:ToggleScreen("Cauldron")
        elseif keyCode == Enum.KeyCode.M then
            self:ToggleScreen("Merchant")
        elseif keyCode == Enum.KeyCode.K then
            self:ToggleScreen("Skills")
        elseif keyCode == Enum.KeyCode.Escape then
            self:CloseAllModals()
        end
    end)
end

function UIController:RegisterScreen(
    screenName: string,
    setVisibleCallback: (visible: boolean) -> (),
    screenInstance: any?
)
    self._screens[screenName] = {
        Name = screenName,
        IsOpen = false,
        ScreenInstance = screenInstance,
        SetVisible = setVisibleCallback,
    }
end

function UIController:OpenScreen(screenName: string): boolean
    local entry = self._screens[screenName]
    if not entry then
        return false
    end

    if entry.IsOpen then
        return true -- Bereits geöffnet
    end

    -- Andere geöffnete Modale automatisch schließen (Exklusivitäts-Garantie)
    if self._activeModal and self._activeModal ~= screenName then
        self:CloseScreen(self._activeModal)
    end

    entry.IsOpen = true
    self._activeModal = screenName
    entry.SetVisible(true)

    AudioController:PlaySound("UI_Click")
    self.ScreenOpened:Fire(screenName)

    return true
end

function UIController:CloseScreen(screenName: string): boolean
    local entry = self._screens[screenName]
    if not entry or not entry.IsOpen then
        return false
    end

    entry.IsOpen = false
    if self._activeModal == screenName then
        self._activeModal = nil
    end

    entry.SetVisible(false)

    AudioController:PlaySound("UI_Click")
    self.ScreenClosed:Fire(screenName)

    return true
end

function UIController:ToggleScreen(screenName: string): boolean
    local entry = self._screens[screenName]
    if not entry then
        return false
    end

    if entry.IsOpen then
        return self:CloseScreen(screenName)
    else
        return self:OpenScreen(screenName)
    end
end

function UIController:CloseAllModals()
    if self._activeModal then
        self:CloseScreen(self._activeModal)
    end
end

function UIController:GetActiveScreen(): string?
    return self._activeModal
end

function UIController:IsScreenOpen(screenName: string): boolean
    local entry = self._screens[screenName]
    return if entry then entry.IsOpen else false
end

return UIController
