--!strict
--[[
    ModalWrapper.luau
    Aether Alchemist (Element Shapers)
    Standardisierter ScreenGui-Modal-Wrapper (DisplayOrder = 10, ResetOnSpawn = false,
    Backdrop-Dimming, GlassPanel-Einbindung, "✕" Schließen-Button und Spring-Animationen).
    Entspricht 100% UITheme.luau & GEMINI.md Section 7.3.
]]

local UITheme = require("../../../Shared/Modules/UITheme")
local Signal = require("../../../Shared/Modules/Signal")
local GlassPanel = require("./GlassPanel")
local GlassButton = require("./GlassButton")

export type ModalWrapperProps = {
    Name: string,
    Title: string,
    Size: any?,
    OnClose: (() -> ())?,
    Parent: any?,
}

export type ModalWrapperResult = {
    ScreenGui: any,
    Panel: any,
    Content: any,
    CloseButton: any,
    Show: (self: any) -> (),
    Hide: (self: any) -> (),
    Toggle: (self: any) -> (),
    IsOpen: (self: any) -> boolean,
    Opened: Signal.Signal<()>,
    Closed: Signal.Signal<()>,
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("TweenService") ~= nil
    end)
    return success and result
end

local ModalWrapper = {}

function ModalWrapper.Create(props: ModalWrapperProps): ModalWrapperResult
    local modalName = props.Name
    local modalTitle = props.Title

    local openedSignal = Signal.new()
    local closedSignal = Signal.new()

    if not isRobloxEngine() then
        -- Headless Lune Mock
        local isOpen = false
        local wrapper: any = {}

        wrapper = {
            ScreenGui = { Name = modalName, DisplayOrder = 10, ResetOnSpawn = false, Enabled = false },
            Panel = { Name = modalName .. "Panel", Title = modalTitle },
            Content = {},
            CloseButton = {},
            Opened = openedSignal,
            Closed = closedSignal,

            Show = function(_self: any)
                isOpen = true
                wrapper.ScreenGui.Enabled = true
                openedSignal:Fire()
            end,

            Hide = function(_self: any)
                isOpen = false
                wrapper.ScreenGui.Enabled = false
                closedSignal:Fire()
                if props.OnClose then
                    props.OnClose()
                end
            end,

            Toggle = function(self: any)
                if isOpen then
                    self:Hide()
                else
                    self:Show()
                end
            end,

            IsOpen = function(_self: any): boolean
                return isOpen
            end,
        }

        return wrapper
    end

    local TweenService = game:GetService("TweenService")
    local modalSize = props.Size or UDim2.fromOffset(520, 420)

    -- 1. ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = modalName
    screenGui.DisplayOrder = 10
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Enabled = false

    -- 2. Backdrop Overlay (abgedunkelter Hintergrund mit Klick-Schließen)
    local backdrop = Instance.new("TextButton")
    backdrop.Name = "Backdrop"
    backdrop.Size = UDim2.fromScale(1, 1)
    backdrop.Position = UDim2.fromScale(0, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 1 -- Startet transparent
    backdrop.Text = ""
    backdrop.AutoButtonColor = false
    backdrop.BorderSizePixel = 0
    backdrop.Parent = screenGui

    -- 3. GlassPanel Container
    local panelResult = GlassPanel.Create({
        Name = modalName .. "Panel",
        Title = modalTitle,
        Size = modalSize,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        CornerRadius = UITheme.Radii.Panel,
        Parent = screenGui,
    })

    local panelFrame = panelResult.Frame
    panelFrame.Position = UDim2.fromScale(0.5, 0.55) -- Leicht nach unten versetzt für Einblend-Tween
    panelFrame.Visible = false

    -- 4. Schließen-Button "✕" im Header oben rechts
    local closeBtnResult = GlassButton.Create({
        Name = "CloseButton",
        Text = "✕",
        Size = UDim2.fromOffset(32, 32),
        Position = UDim2.new(1, -24, 0, 24),
        AnchorPoint = Vector2.new(1, 0.5),
        Variant = "Red",
        Parent = panelFrame,
    })

    local isCurrentlyOpen = false
    local animTweenInfo = TweenInfo.new(UITheme.Animations.TweenNormal, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local hideTweenInfo = TweenInfo.new(UITheme.Animations.TweenFast, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

    local wrapper: any = {}

    wrapper = {
        ScreenGui = screenGui,
        Panel = panelFrame,
        Content = panelResult.Content,
        CloseButton = closeBtnResult.Button,
        Opened = openedSignal,
        Closed = closedSignal,

        Show = function(_self: any)
            if isCurrentlyOpen then
                return
            end
            isCurrentlyOpen = true
            screenGui.Enabled = true
            panelFrame.Visible = true

            -- Animationen starten
            TweenService:Create(backdrop, TweenInfo.new(UITheme.Animations.TweenNormal), { BackgroundTransparency = 0.55 }):Play()
            TweenService:Create(panelFrame, animTweenInfo, {
                Position = UDim2.fromScale(0.5, 0.5),
            }):Play()

            openedSignal:Fire()
        end,

        Hide = function(_self: any)
            if not isCurrentlyOpen then
                return
            end
            isCurrentlyOpen = false

            local backdropTween = TweenService:Create(backdrop, hideTweenInfo, { BackgroundTransparency = 1 })
            local panelTween = TweenService:Create(panelFrame, hideTweenInfo, {
                Position = UDim2.fromScale(0.5, 0.55),
            })

            backdropTween:Play()
            panelTween:Play()

            panelTween.Completed:Once(function()
                if not isCurrentlyOpen then
                    screenGui.Enabled = false
                    panelFrame.Visible = false
                end
            end)

            closedSignal:Fire()
            if props.OnClose then
                props.OnClose()
            end
        end,

        Toggle = function(self: any)
            if isCurrentlyOpen then
                self:Hide()
            else
                self:Show()
            end
        end,

        IsOpen = function(_self: any): boolean
            return isCurrentlyOpen
        end,
    }

    closeBtnResult.Clicked:Connect(function()
        wrapper:Hide()
    end)

    backdrop.Activated:Connect(function()
        wrapper:Hide()
    end)

    if props.Parent then
        screenGui.Parent = props.Parent
    end

    return wrapper
end

return ModalWrapper
