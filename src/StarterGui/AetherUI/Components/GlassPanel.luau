--!strict
--[[
    GlassPanel.luau
    Aether Alchemist (Element Shapers)
    Wiederverwendbare Glassmorphism-Container-Komponente (Frame, UICorner 14px/10px,
    UIStroke 1.2px transluzent, UIGradient Obsidian-Slate).
    Entspricht 100% UITheme.luau & INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local UITheme = require("../../../Shared/Modules/UITheme")

export type GlassPanelProps = {
    Name: string?,
    Size: any?,
    Position: any?,
    AnchorPoint: any?,
    CornerRadius: number?,
    BackgroundTransparency: number?,
    BorderColor: any?,
    Title: string?,
    Parent: any?,
}

export type GlassPanelResult = {
    Frame: any,
    Content: any,
    TitleLabel: any?,
    CloseButton: any?,
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("GuiService") ~= nil
    end)
    return success and result
end

local GlassPanel = {}

function GlassPanel.Create(props: GlassPanelProps): GlassPanelResult
    local panelName = props.Name or "GlassPanel"
    local cornerRadius = props.CornerRadius or UITheme.Radii.Panel
    local bgTransparency = props.BackgroundTransparency or UITheme.Transparencies.PanelBackground

    if not isRobloxEngine() then
        -- Headless Lune Mock-Struktur
        local mockFrame = {
            Name = panelName,
            CornerRadius = cornerRadius,
            BackgroundTransparency = bgTransparency,
            Title = props.Title,
            Parent = props.Parent,
            Visible = true,
        }
        return {
            Frame = mockFrame,
            Content = {},
            TitleLabel = if props.Title then { Text = props.Title } else nil,
            CloseButton = nil,
        }
    end

    -- 1. Haupt-Frame
    local frame = Instance.new("Frame")
    frame.Name = panelName
    frame.Size = props.Size or UDim2.fromOffset(480, 360)
    frame.Position = props.Position or UDim2.fromScale(0.5, 0.5)
    frame.AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(
        UITheme.Colors.ObsidianSlate.R,
        UITheme.Colors.ObsidianSlate.G,
        UITheme.Colors.ObsidianSlate.B
    )
    frame.BackgroundTransparency = bgTransparency
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true

    -- 2. UICorner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius)
    corner.Parent = frame

    -- 3. UIStroke (Transluzenter Rand)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.2
    stroke.Transparency = UITheme.Transparencies.StrokeGlass
    stroke.Color = props.BorderColor or Color3.fromRGB(
        UITheme.Colors.AetherCyan.R,
        UITheme.Colors.AetherCyan.G,
        UITheme.Colors.AetherCyan.B
    )
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = frame

    -- 4. UIGradient (Obsidian-Farbverlauf)
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 90
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(UITheme.Colors.CardBackground.R, UITheme.Colors.CardBackground.G, UITheme.Colors.CardBackground.B)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(UITheme.Colors.ObsidianSlate.R, UITheme.Colors.ObsidianSlate.G, UITheme.Colors.ObsidianSlate.B)),
    })
    gradient.Transparency = NumberSequence.new(0.0)
    gradient.Parent = frame

    -- 5. Header / Titel
    local titleLabel = nil
    local contentTop = 16

    if props.Title then
        contentTop = 48
        local title = Instance.new("TextLabel")
        title.Name = "PanelTitle"
        title.Size = UDim2.new(1, -32, 0, 32)
        title.Position = UDim2.fromOffset(16, 12)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamBold
        title.TextSize = 20
        title.TextColor3 = Color3.fromRGB(
            UITheme.Colors.AntiqueGold.R,
            UITheme.Colors.AntiqueGold.G,
            UITheme.Colors.AntiqueGold.B
        )
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Text = props.Title
        title.Parent = frame
        titleLabel = title
    end

    -- 6. Content Container Frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -32, 1, -(contentTop + 16))
    contentFrame.Position = UDim2.fromOffset(16, contentTop)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = frame

    if props.Parent then
        frame.Parent = props.Parent
    end

    return {
        Frame = frame,
        Content = contentFrame,
        TitleLabel = titleLabel,
        CloseButton = nil,
    }
end

return GlassPanel
