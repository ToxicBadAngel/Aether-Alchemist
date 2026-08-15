--!strict
--[[
    HUDGui.luau
    Aether Alchemist (Element Shapers)
    Permanentes Haupt-HUD (DisplayOrder = 1, ResetOnSpawn = false, Essenz-Counter,
    Level & XP-Bar, Zonen-Kompass, 4 Schnellzugriff-Buttons via GlassButton).
    Entspricht 100% UITheme.luau & INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local UITheme = require("../../../Shared/Modules/UITheme")
local MathUtils = require("../../../Shared/Modules/MathUtils")
local GlassButton = require("../Components/GlassButton")
local GlassPanel = require("../Components/GlassPanel")
local DataController = require("../../../Client/Controllers/DataController")
local UIController = require("../../../Client/Controllers/UIController")

export type HUDGuiResult = {
    ScreenGui: any,
    EssenceLabel: any,
    LevelLabel: any,
    ExpBarFill: any,
    ZoneLabel: any,
    UpdateEssence: (self: any, essence: number) -> (),
    UpdateLevel: (self: any, level: number, currentExp: number, maxExp: number) -> (),
    UpdateZone: (self: any, zoneName: string) -> (),
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("TweenService") ~= nil
    end)
    return success and result
end

local HUDGui = {}

function HUDGui.Create(parentGui: any?): HUDGuiResult
    if not isRobloxEngine() then
        -- Headless Lune Mock-Struktur
        local mockResult: HUDGuiResult = {
            ScreenGui = { Name = "HUDGui", DisplayOrder = 1, ResetOnSpawn = false, Enabled = true },
            EssenceLabel = { Text = "0" },
            LevelLabel = { Text = "Lv. 1" },
            ExpBarFill = { Size = { X = 0, Y = 1 } },
            ZoneLabel = { Text = "Zone 1: Smaragd-Hain" },

            UpdateEssence = function(self: any, essence: number)
                self.EssenceLabel.Text = tostring(essence)
            end,

            UpdateLevel = function(self: any, level: number, curExp: number, maxExp: number)
                self.LevelLabel.Text = string.format("Lv. %d", level)
                local expPct = if maxExp and maxExp > 0 then curExp / maxExp else 0
                self.ExpBarFill.Size = { X = expPct, Y = 1 }
            end,

            UpdateZone = function(self: any, zoneName: string)
                self.ZoneLabel.Text = zoneName
            end,
        }

        -- Reaktive Bindung an DataController
        DataController.EssenceChanged:Connect(function(ess)
            mockResult:UpdateEssence(ess)
        end)

        DataController.LevelChanged:Connect(function(lvl, curExp, maxExp)
            mockResult:UpdateLevel(lvl, curExp, maxExp)
        end)

        local profile = DataController:GetProfile()
        if profile then
            mockResult:UpdateEssence(profile.AetherEssence)
            local reqXP = MathUtils.GetRequiredXP(profile.Level)
            mockResult:UpdateLevel(profile.Level, profile.XP, reqXP)
        end

        return mockResult
    end

    local TweenService = game:GetService("TweenService")

    -- 1. ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HUDGui"
    screenGui.DisplayOrder = 1
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- 2. Oben Links: Level & XP Bar
    local levelPanelResult = GlassPanel.Create({
        Name = "LevelContainer",
        Size = UDim2.fromOffset(200, 52),
        Position = UDim2.fromOffset(20, 20),
        AnchorPoint = Vector2.new(0, 0),
        CornerRadius = UITheme.Radii.Card,
        Parent = screenGui,
    })

    local levelLabel = Instance.new("TextLabel")
    levelLabel.Name = "LevelText"
    levelLabel.Size = UDim2.new(1, -16, 0, 20)
    levelLabel.Position = UDim2.fromOffset(8, 6)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Font = Enum.Font.GothamBold
    levelLabel.TextSize = 14
    levelLabel.TextColor3 = Color3.fromRGB(UITheme.Colors.TextPrimary.R, UITheme.Colors.TextPrimary.G, UITheme.Colors.TextPrimary.B)
    levelLabel.TextXAlignment = Enum.TextXAlignment.Left
    levelLabel.Text = "Lv. 1"
    levelLabel.Parent = levelPanelResult.Frame

    local expBg = Instance.new("Frame")
    expBg.Name = "ExpBg"
    expBg.Size = UDim2.new(1, -16, 0, 8)
    expBg.Position = UDim2.fromOffset(8, 30)
    expBg.BackgroundColor3 = Color3.fromRGB(UITheme.Colors.SurfaceElevated.R, UITheme.Colors.SurfaceElevated.G, UITheme.Colors.SurfaceElevated.B)
    expBg.BorderSizePixel = 0
    expBg.Parent = levelPanelResult.Frame

    local expBgCorner = Instance.new("UICorner")
    expBgCorner.CornerRadius = UDim.new(0, 4)
    expBgCorner.Parent = expBg

    local expFill = Instance.new("Frame")
    expFill.Name = "ExpFill"
    expFill.Size = UDim2.fromScale(0, 1)
    expFill.BackgroundColor3 = Color3.fromRGB(UITheme.Colors.AetherCyan.R, UITheme.Colors.AetherCyan.G, UITheme.Colors.AetherCyan.B)
    expFill.BorderSizePixel = 0
    expFill.Parent = expBg

    local expFillCorner = Instance.new("UICorner")
    expFillCorner.CornerRadius = UDim.new(0, 4)
    expFillCorner.Parent = expFill

    -- 3. Oben Rechts: Essenz-Counter (Gold-Glanz)
    local essencePanelResult = GlassPanel.Create({
        Name = "EssenceContainer",
        Size = UDim2.fromOffset(160, 44),
        Position = UDim2.new(1, -20, 0, 20),
        AnchorPoint = Vector2.new(1, 0),
        CornerRadius = UITheme.Radii.Card,
        Parent = screenGui,
    })

    local essenceIcon = Instance.new("TextLabel")
    essenceIcon.Name = "EssenceIcon"
    essenceIcon.Size = UDim2.fromOffset(24, 24)
    essenceIcon.Position = UDim2.fromOffset(12, 10)
    essenceIcon.BackgroundTransparency = 1
    essenceIcon.Font = Enum.Font.GothamBold
    essenceIcon.TextSize = 16
    essenceIcon.TextColor3 = Color3.fromRGB(UITheme.Colors.AntiqueGold.R, UITheme.Colors.AntiqueGold.G, UITheme.Colors.AntiqueGold.B)
    essenceIcon.Text = "✧"
    essenceIcon.Parent = essencePanelResult.Frame

    local essenceLabel = Instance.new("TextLabel")
    essenceLabel.Name = "EssenceAmount"
    essenceLabel.Size = UDim2.new(1, -44, 1, 0)
    essenceLabel.Position = UDim2.fromOffset(36, 0)
    essenceLabel.BackgroundTransparency = 1
    essenceLabel.Font = Enum.Font.GothamBold
    essenceLabel.TextSize = 16
    essenceLabel.TextColor3 = Color3.fromRGB(UITheme.Colors.AntiqueGold.R, UITheme.Colors.AntiqueGold.G, UITheme.Colors.AntiqueGold.B)
    essenceLabel.TextXAlignment = Enum.TextXAlignment.Left
    essenceLabel.Text = "100"
    essenceLabel.Parent = essencePanelResult.Frame

    -- 4. Oben Mitte: Zonen-Anzeige
    local zoneLabel = Instance.new("TextLabel")
    zoneLabel.Name = "ZoneLabel"
    zoneLabel.Size = UDim2.fromOffset(300, 28)
    zoneLabel.Position = UDim2.new(0.5, 0, 0, 20)
    zoneLabel.AnchorPoint = Vector2.new(0.5, 0)
    zoneLabel.BackgroundTransparency = 1
    zoneLabel.Font = Enum.Font.GothamBold
    zoneLabel.TextSize = 16
    zoneLabel.TextColor3 = Color3.fromRGB(UITheme.Colors.TextSecondary.R, UITheme.Colors.TextSecondary.G, UITheme.Colors.TextSecondary.B)
    zoneLabel.Text = "Zone 1: Smaragd-Hain"
    zoneLabel.Parent = screenGui

    -- 5. Unten Mitte: Schnellzugriff Action-Bar (4 GlassButtons)
    local bottomBar = Instance.new("Frame")
    bottomBar.Name = "ActionBar"
    bottomBar.Size = UDim2.fromOffset(460, 56)
    bottomBar.Position = UDim2.new(0.5, 0, 1, -24)
    bottomBar.AnchorPoint = Vector2.new(0.5, 1)
    bottomBar.BackgroundTransparency = 1
    bottomBar.Parent = screenGui

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Padding = UDim.new(0, 12)
    layout.Parent = bottomBar

    local actionButtons = {
        { Key = "B", Name = "Inventar", Variant = "Cyan", Screen = "Inventory" },
        { Key = "C", Name = "Kessel", Variant = "Gold", Screen = "Cauldron" },
        { Key = "M", Name = "Händler", Variant = "Green", Screen = "Merchant" },
        { Key = "K", Name = "Skills", Variant = "Cyan", Screen = "Skills" },
    }

    for _, btnData in actionButtons do
        GlassButton.Create({
            Name = btnData.Screen .. "HUDButton",
            Text = string.format("[%s] %s", btnData.Key, btnData.Name),
            Size = UDim2.fromOffset(100, 44),
            Variant = btnData.Variant :: any,
            OnClick = function()
                UIController:ToggleScreen(btnData.Screen)
            end,
            Parent = bottomBar,
        })
    end

    local result: HUDGuiResult = {
        ScreenGui = screenGui,
        EssenceLabel = essenceLabel,
        LevelLabel = levelLabel,
        ExpBarFill = expFill,
        ZoneLabel = zoneLabel,

        UpdateEssence = function(_self: any, essence: number)
            essenceLabel.Text = tostring(essence)
        end,

        UpdateLevel = function(_self: any, level: number, curExp: number, maxExp: number)
            levelLabel.Text = string.format("Lv. %d", level)
            local pct = if maxExp and maxExp > 0 then math.clamp(curExp / maxExp, 0, 1) else 0
            TweenService:Create(expFill, TweenInfo.new(0.3), { Size = UDim2.fromScale(pct, 1) }):Play()
        end,

        UpdateZone = function(_self: any, zoneName: string)
            zoneLabel.Text = zoneName
        end,
    }

    -- Reaktive Verbindung
    DataController.EssenceChanged:Connect(function(ess)
        result:UpdateEssence(ess)
    end)

    DataController.LevelChanged:Connect(function(lvl, curExp, maxExp)
        result:UpdateLevel(lvl, curExp, maxExp)
    end)

    local profile = DataController:GetProfile()
    if profile then
        result:UpdateEssence(profile.AetherEssence)
        local reqXP = MathUtils.GetRequiredXP(profile.Level)
        result:UpdateLevel(profile.Level, profile.XP, reqXP)
    end

    if parentGui then
        screenGui.Parent = parentGui
    end

    return result
end

return HUDGui
