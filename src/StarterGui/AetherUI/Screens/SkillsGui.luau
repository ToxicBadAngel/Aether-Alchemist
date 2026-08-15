--!strict
--[[
    SkillsGui.luau
    Aether Alchemist (Element Shapers)
    Modales Skill-Tree- und Talentfenster (3 Pfade: Harvester, Alchemist, Summoner,
    Level-Cap 10, Talentpunkt-Vergabe via AllocateSkill_RF und Skill_Unlock Sound).
    Entspricht 100% UITheme.luau & INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local Types = require("../../../Shared/Config/Types")
local UITheme = require("../../../Shared/Modules/UITheme")
local ModalWrapper = require("../Components/ModalWrapper")
local GlassButton = require("../Components/GlassButton")
local GlassPanel = require("../Components/GlassPanel")
local DataController = require("../../../Client/Controllers/DataController")
local UIController = require("../../../Client/Controllers/UIController")
local AudioController = require("../../../Client/Controllers/AudioController")
local NetworkContracts = require("../../../Shared/Remotes/NetworkContracts")

export type SkillsGuiResult = {
    Modal: any,
    CanAllocate: (self: any, skillName: Types.SkillType) -> boolean,
    AllocatePoint: (self: any, skillName: Types.SkillType) -> boolean,
    Refresh: (self: any) -> (),
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("UserInputService") ~= nil
    end)
    return success and result
end

local SkillsGui = {}

function SkillsGui.Create(parentGui: any?): SkillsGuiResult
    local modal = ModalWrapper.Create({
        Name = "SkillsGui",
        Title = "Talent-Bäume",
        Size = if isRobloxEngine() then UDim2.fromOffset(560, 420) else nil,
        Parent = parentGui,
    })

    UIController:RegisterScreen("Skills", function(visible)
        if visible then
            modal:Show()
        else
            modal:Hide()
        end
    end, modal.ScreenGui)

    local guiResult: SkillsGuiResult = {
        Modal = modal,
        CanAllocate = function(_self: any, skillName: Types.SkillType): boolean
            local profile = DataController:GetProfile()
            if not profile then
                return false
            end
            if profile.SkillPoints <= 0 then
                return false
            end
            local currentLvl = profile.Skills[skillName] or 0
            return currentLvl < 10
        end,

        AllocatePoint = function(self: any, skillName: Types.SkillType): boolean
            if not self:CanAllocate(skillName) then
                return false
            end

            AudioController:PlaySound("Skill_Unlock")
            if isRobloxEngine() then
                local allocateRF = NetworkContracts.GetRemoteFunction("AllocateSkill_RF")
                if allocateRF then
                    allocateRF:InvokeServer(skillName)
                end
            end
            return true
        end,

        Refresh = function(_self: any) end,
    }

    if not isRobloxEngine() then
        DataController.ProfileChanged:Connect(function()
            guiResult:Refresh()
        end)
        return guiResult
    end

    local contentFrame = modal.Content

    -- 1. Header: Verfügbare Talentpunkte
    local pointsLabel = Instance.new("TextLabel")
    pointsLabel.Name = "PointsLabel"
    pointsLabel.Size = UDim2.new(1, 0, 0, 24)
    pointsLabel.Position = UDim2.fromOffset(0, 0)
    pointsLabel.BackgroundTransparency = 1
    pointsLabel.Font = Enum.Font.GothamBold
    pointsLabel.TextSize = 14
    pointsLabel.TextColor3 = Color3.fromRGB(UITheme.Colors.AntiqueGold.R, UITheme.Colors.AntiqueGold.G, UITheme.Colors.AntiqueGold.B)
    pointsLabel.TextXAlignment = Enum.TextXAlignment.Left
    pointsLabel.Text = "Verfügbare Talentpunkte: 0"
    pointsLabel.Parent = contentFrame

    -- 2. 3 Spalten für die Talent-Pfade
    local cardsContainer = Instance.new("Frame")
    cardsContainer.Name = "CardsContainer"
    cardsContainer.Size = UDim2.new(1, 0, 1, -36)
    cardsContainer.Position = UDim2.fromOffset(0, 36)
    cardsContainer.BackgroundTransparency = 1
    cardsContainer.Parent = contentFrame

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 12)
    layout.Parent = cardsContainer

    local skillData: { { Key: Types.SkillType, Name: string, Desc: string, PerLevel: string, Variant: string } } = {
        {
            Key = "Harvester",
            Name = "Ernter",
            Desc = "Erhöht die Abbau-Geschwindigkeit für alle Erzkristalle.",
            PerLevel = "-4% Abbauzeit / Punkt (max -40%)",
            Variant = "Cyan",
        },
        {
            Key = "Alchemist",
            Name = "Alchemist",
            Desc = "Steigert den Essenz-Gewinn beim Verkauf von Erzen und Tränken.",
            PerLevel = "+3% Verkaufserlös / Punkt (max +30%)",
            Variant = "Gold",
        },
        {
            Key = "Summoner",
            Name = "Beschwörer",
            Desc = "Verkürzt die Abklingzeit aktiver Begleiter-Fähigkeiten.",
            PerLevel = "-3% Cooldown / Punkt (max -30%)",
            Variant = "Cyan",
        },
    }

    local levelLabels: { [Types.SkillType]: any } = {}
    local allocateButtons: { [Types.SkillType]: any } = {}

    for _, def in skillData do
        local card = GlassPanel.Create({
            Name = def.Key .. "Card",
            Size = UDim2.fromScale(0.31, 1),
            CornerRadius = UITheme.Radii.Card,
            Parent = cardsContainer,
        })

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, -12, 0, 24)
        nameLbl.Position = UDim2.fromOffset(6, 8)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextSize = 14
        nameLbl.TextColor3 = Color3.fromRGB(UITheme.Colors.TextPrimary.R, UITheme.Colors.TextPrimary.G, UITheme.Colors.TextPrimary.B)
        nameLbl.Text = def.Name
        nameLbl.Parent = card.Frame

        local lvlLbl = Instance.new("TextLabel")
        lvlLbl.Size = UDim2.new(1, -12, 0, 20)
        lvlLbl.Position = UDim2.fromOffset(6, 34)
        lvlLbl.BackgroundTransparency = 1
        lvlLbl.Font = Enum.Font.GothamBold
        lvlLbl.TextSize = 13
        lvlLbl.TextColor3 = Color3.fromRGB(UITheme.Colors.AntiqueGold.R, UITheme.Colors.AntiqueGold.G, UITheme.Colors.AntiqueGold.B)
        lvlLbl.Text = "Stufe: 0 / 10"
        lvlLbl.Parent = card.Frame
        levelLabels[def.Key] = lvlLbl

        local descLbl = Instance.new("TextLabel")
        descLbl.Size = UDim2.new(1, -12, 0, 70)
        descLbl.Position = UDim2.fromOffset(6, 60)
        descLbl.BackgroundTransparency = 1
        descLbl.Font = Enum.Font.GothamMedium
        descLbl.TextSize = 11
        descLbl.TextColor3 = Color3.fromRGB(UITheme.Colors.TextSecondary.R, UITheme.Colors.TextSecondary.G, UITheme.Colors.TextSecondary.B)
        descLbl.TextWrapped = true
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.TextYAlignment = Enum.TextYAlignment.Top
        descLbl.Text = def.Desc .. "\n\n" .. def.PerLevel
        descLbl.Parent = card.Frame

        local btnResult = GlassButton.Create({
            Name = def.Key .. "AllocateBtn",
            Text = "+ Investieren",
            Size = UDim2.new(1, -16, 0, 36),
            Position = UDim2.new(0.5, 0, 1, -20),
            AnchorPoint = Vector2.new(0.5, 1),
            Variant = def.Variant :: any,
            OnClick = function()
                guiResult:AllocatePoint(def.Key)
            end,
            Parent = card.Frame,
        })
        allocateButtons[def.Key] = btnResult
    end

    local function renderSkills()
        local profile = DataController:GetProfile()
        if not profile then
            return
        end

        pointsLabel.Text = string.format("Verfügbare Talentpunkte: %d", profile.SkillPoints)

        for _, def in skillData do
            local currentLvl = profile.Skills[def.Key] or 0
            local lvlLabel = levelLabels[def.Key]
            if lvlLabel then
                if currentLvl >= 10 then
                    lvlLabel.Text = "Stufe: 10 / 10 (MAX)"
                    lvlLabel.TextColor3 = Color3.fromRGB(UITheme.Colors.SuccessGreen.R, UITheme.Colors.SuccessGreen.G, UITheme.Colors.SuccessGreen.B)
                else
                    lvlLabel.Text = string.format("Stufe: %d / 10", currentLvl)
                    lvlLabel.TextColor3 = Color3.fromRGB(UITheme.Colors.AntiqueGold.R, UITheme.Colors.AntiqueGold.G, UITheme.Colors.AntiqueGold.B)
                end
            end

            local btn = allocateButtons[def.Key]
            if btn then
                local canAlloc = profile.SkillPoints > 0 and currentLvl < 10
                btn.SetEnabled(canAlloc)
                if currentLvl >= 10 then
                    btn.SetText("Meister")
                else
                    btn.SetText("+ Investieren")
                end
            end
        end
    end

    guiResult.Refresh = renderSkills

    DataController.ProfileChanged:Connect(function()
        renderSkills()
    end)

    renderSkills()
    return guiResult
end

return SkillsGui
