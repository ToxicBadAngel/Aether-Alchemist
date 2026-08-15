--!strict
--[[
    GlassButton.luau
    Aether Alchemist (Element Shapers)
    Der 4-Layer GlassButton Standard (TextButton, UICorner 8px, UIStroke 1.2px,
    UIGradient, haptische Micro-Animations 1.04x Hover / 0.95x Click).
    Entspricht 100% UITheme.luau & GEMINI.md Anti-Slop Standard.
]]

local UITheme = require("../../../Shared/Modules/UITheme")
local Signal = require("../../../Shared/Modules/Signal")

export type GlassButtonVariant = "Gold" | "Cyan" | "Red" | "Green"

export type GlassButtonProps = {
    Name: string?,
    Text: string?,
    Size: any?,
    Position: any?,
    AnchorPoint: any?,
    Variant: GlassButtonVariant?,
    OnClick: (() -> ())?,
    Parent: any?,
}

export type GlassButtonResult = {
    Button: any,
    Stroke: any?,
    Gradient: any?,
    Clicked: Signal.Signal<()>,
    SetEnabled: (enabled: boolean) -> (),
    SetText: (text: string) -> (),
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("TweenService") ~= nil
    end)
    return success and result
end

local GlassButton = {}

function GlassButton.Create(props: GlassButtonProps): GlassButtonResult
    local btnName = props.Name or "GlassButton"
    local btnText = props.Text or "Button"
    local variant = props.Variant or "Cyan"
    local clickedSignal = Signal.new()

    if not isRobloxEngine() then
        -- Headless Lune Mock-Struktur
        local mockButton = {
            Name = btnName,
            Text = btnText,
            Variant = variant,
            Enabled = true,
            Visible = true,
        }

        local result: GlassButtonResult = {
            Button = mockButton,
            Stroke = {},
            Gradient = {},
            Clicked = clickedSignal,
            SetEnabled = function(enabled: boolean)
                mockButton.Enabled = enabled
            end,
            SetText = function(text: string)
                mockButton.Text = text
            end,
        }

        if props.OnClick then
            clickedSignal:Connect(props.OnClick)
        end

        return result
    end

    local TweenService = game:GetService("TweenService")

    -- Akzent-Farben auswählen
    local strokeColor = Color3.fromRGB(UITheme.Colors.AetherCyan.R, UITheme.Colors.AetherCyan.G, UITheme.Colors.AetherCyan.B)
    local strokeGlow = Color3.fromRGB(UITheme.Colors.AetherCyanGlow.R, UITheme.Colors.AetherCyanGlow.G, UITheme.Colors.AetherCyanGlow.B)

    if variant == "Gold" then
        strokeColor = Color3.fromRGB(UITheme.Colors.AntiqueGold.R, UITheme.Colors.AntiqueGold.G, UITheme.Colors.AntiqueGold.B)
        strokeGlow = Color3.fromRGB(UITheme.Colors.AntiqueGoldGlow.R, UITheme.Colors.AntiqueGoldGlow.G, UITheme.Colors.AntiqueGoldGlow.B)
    elseif variant == "Red" then
        strokeColor = Color3.fromRGB(UITheme.Colors.CrimsonRed.R, UITheme.Colors.CrimsonRed.G, UITheme.Colors.CrimsonRed.B)
        strokeGlow = Color3.fromRGB(248, 113, 113)
    elseif variant == "Green" then
        strokeColor = Color3.fromRGB(UITheme.Colors.SuccessGreen.R, UITheme.Colors.SuccessGreen.G, UITheme.Colors.SuccessGreen.B)
        strokeGlow = Color3.fromRGB(74, 222, 128)
    end

    -- 1. Layer 1: TextButton
    local button = Instance.new("TextButton")
    button.Name = btnName
    button.Size = props.Size or UDim2.fromOffset(160, 44)
    button.Position = props.Position or UDim2.fromScale(0.5, 0.5)
    button.AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5)
    button.BackgroundColor3 = Color3.fromRGB(
        UITheme.Colors.CardBackground.R,
        UITheme.Colors.CardBackground.G,
        UITheme.Colors.CardBackground.B
    )
    button.BackgroundTransparency = UITheme.Transparencies.CardBackground
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Font = Enum.Font.GothamBold
    button.TextSize = 15
    button.TextColor3 = Color3.fromRGB(
        UITheme.Colors.TextPrimary.R,
        UITheme.Colors.TextPrimary.G,
        UITheme.Colors.TextPrimary.B
    )
    button.Text = btnText

    -- 2. Layer 2: UICorner (8px Button Radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, UITheme.Radii.Button)
    corner.Parent = button

    -- 3. Layer 3: UIStroke
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.2
    stroke.Transparency = UITheme.Transparencies.StrokeGlass
    stroke.Color = strokeColor
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = button

    -- 4. Layer 4: UIGradient
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 90
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(UITheme.Colors.SurfaceElevated.R, UITheme.Colors.SurfaceElevated.G, UITheme.Colors.SurfaceElevated.B)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(UITheme.Colors.CardBackground.R, UITheme.Colors.CardBackground.G, UITheme.Colors.CardBackground.B)),
    })
    gradient.Transparency = NumberSequence.new(0.0)
    gradient.Parent = button

    -- Haptische Micro-Animations (1.04x Hover / 0.95x Click)
    local originalSize = button.Size
    local hoverTweenInfo = TweenInfo.new(UITheme.Animations.TweenFast, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    button.MouseEnter:Connect(function()
        TweenService:Create(stroke, hoverTweenInfo, {
            Color = strokeGlow,
            Transparency = UITheme.Transparencies.StrokeHighlight,
        }):Play()
        TweenService:Create(button, hoverTweenInfo, {
            Size = UDim2.fromOffset(math.round(originalSize.X.Offset * UITheme.Animations.ButtonHoverScale), math.round(originalSize.Y.Offset * UITheme.Animations.ButtonHoverScale)),
        }):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(stroke, hoverTweenInfo, {
            Color = strokeColor,
            Transparency = UITheme.Transparencies.StrokeGlass,
        }):Play()
        TweenService:Create(button, hoverTweenInfo, {
            Size = originalSize,
        }):Play()
    end)

    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, hoverTweenInfo, {
            Size = UDim2.fromOffset(math.round(originalSize.X.Offset * UITheme.Animations.ButtonClickScale), math.round(originalSize.Y.Offset * UITheme.Animations.ButtonClickScale)),
        }):Play()
    end)

    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, hoverTweenInfo, {
            Size = originalSize,
        }):Play()
    end)

    button.Activated:Connect(function()
        clickedSignal:Fire()
    end)

    if props.OnClick then
        clickedSignal:Connect(props.OnClick)
    end

    if props.Parent then
        button.Parent = props.Parent
    end

    return {
        Button = button,
        Stroke = stroke,
        Gradient = gradient,
        Clicked = clickedSignal,
        SetEnabled = function(enabled: boolean)
            button.Active = enabled
            button.AutoButtonColor = false
            button.TextTransparency = if enabled then 0 else 0.5
            stroke.Transparency = if enabled then UITheme.Transparencies.StrokeGlass else 0.9
        end,
        SetText = function(text: string)
            button.Text = text
        end,
    }
end

return GlassButton
