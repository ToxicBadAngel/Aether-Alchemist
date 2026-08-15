--!strict
--[[
    CauldronGui.luau
    Aether Alchemist (Element Shapers)
    Modales Alchemie-Kessel-Braufenster (Rezept-Auswahl GlacierShield/InfernoPotion/StormSpeed etc.,
    Zutaten-Check, 0s Instant-Crafting via BrewPotion_RF und Cauldron_Bubble Sound).
    Entspricht 100% UITheme.luau & INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local Types = require("../../../Shared/Config/Types")
local UITheme = require("../../../Shared/Modules/UITheme")
local RecipesConfig = require("../../../Shared/Config/RecipesConfig")
local OresConfig = require("../../../Shared/Config/OresConfig")
local ModalWrapper = require("../Components/ModalWrapper")
local GlassButton = require("../Components/GlassButton")
local GlassPanel = require("../Components/GlassPanel")
local DataController = require("../../../Client/Controllers/DataController")
local UIController = require("../../../Client/Controllers/UIController")
local AudioController = require("../../../Client/Controllers/AudioController")
local NetworkContracts = require("../../../Shared/Remotes/NetworkContracts")

export type CauldronGuiResult = {
    Modal: any,
    SelectedRecipe: Types.PotionId,
    SelectRecipe: (self: any, recipeId: Types.PotionId) -> (),
    CanCraftSelected: (self: any) -> boolean,
    CraftSelected: (self: any) -> boolean,
    Refresh: (self: any) -> (),
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("UserInputService") ~= nil
    end)
    return success and result
end

local CauldronGui = {}

function CauldronGui.Create(parentGui: any?): CauldronGuiResult
    local selectedRecipe: Types.PotionId = "GlacierShield"

    local modal = ModalWrapper.Create({
        Name = "CauldronGui",
        Title = "Alchemie-Kessel",
        Size = if isRobloxEngine() then UDim2.fromOffset(560, 420) else nil,
        Parent = parentGui,
    })

    UIController:RegisterScreen("Cauldron", function(visible)
        if visible then
            modal:Show()
        else
            modal:Hide()
        end
    end, modal.ScreenGui)

    local guiResult: CauldronGuiResult = {
        Modal = modal,
        SelectedRecipe = selectedRecipe,
        SelectRecipe = function(self: any, recipeId: Types.PotionId)
            self.SelectedRecipe = recipeId
            selectedRecipe = recipeId
            self:Refresh()
        end,
        CanCraftSelected = function(self: any): boolean
            local config = RecipesConfig.Get(self.SelectedRecipe)
            if not config then
                return false
            end
            for oreId, requiredAmount in config.Ingredients do
                local have = DataController:GetOreCount(oreId)
                if have < requiredAmount then
                    return false
                end
            end
            return true
        end,
        CraftSelected = function(self: any): boolean
            if not self:CanCraftSelected() then
                return false
            end
            AudioController:PlaySound("Cauldron_Bubble")
            if isRobloxEngine() then
                local brewRF = NetworkContracts.GetRemoteFunction("BrewPotion_RF")
                if brewRF then
                    brewRF:InvokeServer(self.SelectedRecipe)
                end
            end
            return true
        end,
        Refresh = function(_self: any) end,
    }

    if not isRobloxEngine() then
        DataController.InventoryChanged:Connect(function()
            guiResult:Refresh()
        end)
        return guiResult
    end

    local contentFrame = modal.Content

    -- 1. Linke Spalte: Rezept-Liste
    local leftCol = Instance.new("Frame")
    leftCol.Name = "RecipeList"
    leftCol.Size = UDim2.fromScale(0.38, 1)
    leftCol.Position = UDim2.fromOffset(0, 0)
    leftCol.BackgroundTransparency = 1
    leftCol.Parent = contentFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.Parent = leftCol

    local allRecipes = RecipesConfig.GetAll()

    -- 2. Rechte Spalte: Rezept-Details & Crafting-Aktion
    local rightCol = GlassPanel.Create({
        Name = "RecipeDetails",
        Size = UDim2.fromScale(0.60, 1),
        Position = UDim2.fromScale(0.40, 0),
        CornerRadius = UITheme.Radii.Card,
        Parent = contentFrame,
    })

    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "DescLabel"
    descLabel.Size = UDim2.new(1, -16, 0, 48)
    descLabel.Position = UDim2.fromOffset(8, 8)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.GothamMedium
    descLabel.TextSize = 12
    descLabel.TextColor3 = Color3.fromRGB(UITheme.Colors.TextSecondary.R, UITheme.Colors.TextSecondary.G, UITheme.Colors.TextSecondary.B)
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = rightCol.Frame

    local ingredientsFrame = Instance.new("Frame")
    ingredientsFrame.Name = "Ingredients"
    ingredientsFrame.Size = UDim2.new(1, -16, 0, 120)
    ingredientsFrame.Position = UDim2.fromOffset(8, 64)
    ingredientsFrame.BackgroundTransparency = 1
    ingredientsFrame.Parent = rightCol.Frame

    local ingLayout = Instance.new("UIListLayout")
    ingLayout.Padding = UDim.new(0, 6)
    ingLayout.Parent = ingredientsFrame

    local craftBtnResult = GlassButton.Create({
        Name = "BrewButton",
        Text = "Brauen (0s)",
        Size = UDim2.fromOffset(160, 40),
        Position = UDim2.new(0.5, 0, 1, -24),
        AnchorPoint = Vector2.new(0.5, 1),
        Variant = "Gold",
        OnClick = function()
            guiResult:CraftSelected()
        end,
        Parent = rightCol.Frame,
    })

    local function renderDetails()
        local config = RecipesConfig.Get(selectedRecipe)
        if not config then
            return
        end

        descLabel.Text = string.format("%s: %s (Dauer: %ds)", config.Name, config.Description, config.Duration)

        for _, child in ingredientsFrame:GetChildren() do
            if child:IsA("TextLabel") then
                child:Destroy()
            end
        end

        local canCraft = true
        for oreId, required in config.Ingredients do
            local oreCfg = OresConfig.Get(oreId)
            local oreName = if oreCfg then oreCfg.Name else oreId
            local have = DataController:GetOreCount(oreId)

            if have < required then
                canCraft = false
            end

            local ingLabel = Instance.new("TextLabel")
            ingLabel.Size = UDim2.new(1, 0, 0, 22)
            ingLabel.BackgroundTransparency = 1
            ingLabel.Font = Enum.Font.GothamMedium
            ingLabel.TextSize = 12
            ingLabel.TextXAlignment = Enum.TextXAlignment.Left
            ingLabel.Text = string.format("• %s: %d / %d", oreName, have, required)
            ingLabel.TextColor3 = if have >= required
                then Color3.fromRGB(UITheme.Colors.SuccessGreen.R, UITheme.Colors.SuccessGreen.G, UITheme.Colors.SuccessGreen.B)
                else Color3.fromRGB(UITheme.Colors.CrimsonRed.R, UITheme.Colors.CrimsonRed.G, UITheme.Colors.CrimsonRed.B)
            ingLabel.Parent = ingredientsFrame
        end

        craftBtnResult.SetEnabled(canCraft)
    end

    for recipeId, config in allRecipes do
        GlassButton.Create({
            Name = recipeId .. "Btn",
            Text = config.Name,
            Size = UDim2.new(1, 0, 0, 36),
            Variant = if recipeId == selectedRecipe then "Gold" else "Cyan",
            OnClick = function()
                guiResult:SelectRecipe(recipeId)
            end,
            Parent = leftCol,
        })
    end

    guiResult.Refresh = renderDetails

    DataController.InventoryChanged:Connect(function()
        renderDetails()
    end)

    renderDetails()
    return guiResult
end

return CauldronGui
