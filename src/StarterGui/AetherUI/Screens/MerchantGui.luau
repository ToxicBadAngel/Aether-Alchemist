--!strict
--[[
    MerchantGui.luau
    Aether Alchemist (Element Shapers)
    Modales Händler-Verkaufsfenster (Erze & Tränke verkaufen, Alchemist-Talent-Bonus,
    Alles-Verkaufen Funktion, SellItem_RF / SellAll_RF Aufrufe und Merchant_Sell Sound).
    Entspricht 100% UITheme.luau & INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local UITheme = require("../../../Shared/Modules/UITheme")
local MathUtils = require("../../../Shared/Modules/MathUtils")
local OresConfig = require("../../../Shared/Config/OresConfig")
local RecipesConfig = require("../../../Shared/Config/RecipesConfig")
local ModalWrapper = require("../Components/ModalWrapper")
local GlassButton = require("../Components/GlassButton")
local GlassPanel = require("../Components/GlassPanel")
local DataController = require("../../../Client/Controllers/DataController")
local UIController = require("../../../Client/Controllers/UIController")
local AudioController = require("../../../Client/Controllers/AudioController")
local NetworkContracts = require("../../../Shared/Remotes/NetworkContracts")

export type MerchantGuiResult = {
    Modal: any,
    CalculateTotalValue: (self: any) -> number,
    SellSingleItem: (self: any, itemType: string, itemId: string, amount: number) -> boolean,
    SellAll: (self: any) -> boolean,
    Refresh: (self: any) -> (),
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("UserInputService") ~= nil
    end)
    return success and result
end

local MerchantGui = {}

function MerchantGui.Create(parentGui: any?): MerchantGuiResult
    local modal = ModalWrapper.Create({
        Name = "MerchantGui",
        Title = "Aether-Händler",
        Size = if isRobloxEngine() then UDim2.fromOffset(560, 440) else nil,
        Parent = parentGui,
    })

    UIController:RegisterScreen("Merchant", function(visible)
        if visible then
            modal:Show()
        else
            modal:Hide()
        end
    end, modal.ScreenGui)

    local guiResult: MerchantGuiResult = {
        Modal = modal,
        CalculateTotalValue = function(_self: any): number
            local profile = DataController:GetProfile()
            if not profile then
                return 0
            end

            local alchemistLevel = profile.Skills.Alchemist
            local total = 0

            for oreId, count in profile.Inventory.Ores do
                if count > 0 then
                    local oreCfg = OresConfig.Get(oreId :: any)
                    if oreCfg then
                        local unitPrice = MathUtils.CalculateEssenceBonus(oreCfg.SellPrice, alchemistLevel)
                        total += unitPrice * count
                    end
                end
            end

            for potionId, count in profile.Inventory.Potions do
                if count > 0 then
                    local potCfg = RecipesConfig.Get(potionId :: any)
                    if potCfg then
                        local unitPrice = MathUtils.CalculateEssenceBonus(potCfg.SellPrice, alchemistLevel)
                        total += unitPrice * count
                    end
                end
            end

            return total
        end,

        SellSingleItem = function(_self: any, itemType: string, itemId: string, amount: number): boolean
            local profile = DataController:GetProfile()
            if not profile then
                return false
            end

            local have = if itemType == "Ore"
                then profile.Inventory.Ores[itemId] or 0
                else profile.Inventory.Potions[itemId] or 0

            if have < amount or amount <= 0 then
                return false
            end

            AudioController:PlaySound("Merchant_Sell")
            if isRobloxEngine() then
                local sellRF = NetworkContracts.GetRemoteFunction("SellItem_RF")
                if sellRF then
                    sellRF:InvokeServer(itemType, itemId, amount)
                end
            end
            return true
        end,

        SellAll = function(self: any): boolean
            local totalVal = self:CalculateTotalValue()
            if totalVal <= 0 then
                return false
            end

            AudioController:PlaySound("Merchant_Sell")
            if isRobloxEngine() then
                local sellAllRF = NetworkContracts.GetRemoteFunction("SellAll_RF")
                if sellAllRF then
                    sellAllRF:InvokeServer()
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

    -- 1. Header: Bonus-Anzeige
    local bonusLabel = Instance.new("TextLabel")
    bonusLabel.Name = "BonusLabel"
    bonusLabel.Size = UDim2.new(1, 0, 0, 24)
    bonusLabel.Position = UDim2.fromOffset(0, 0)
    bonusLabel.BackgroundTransparency = 1
    bonusLabel.Font = Enum.Font.GothamBold
    bonusLabel.TextSize = 13
    bonusLabel.TextColor3 = Color3.fromRGB(UITheme.Colors.AntiqueGold.R, UITheme.Colors.AntiqueGold.G, UITheme.Colors.AntiqueGold.B)
    bonusLabel.TextXAlignment = Enum.TextXAlignment.Left
    bonusLabel.Text = "Alchemisten-Handelsbonus: +0%"
    bonusLabel.Parent = contentFrame

    -- 2. Scrollbarer Content für verkaufbare Gegenstände
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "MerchantScroll"
    scrollFrame.Size = UDim2.new(1, 0, 1, -84)
    scrollFrame.Position = UDim2.fromOffset(0, 28)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(UITheme.Colors.AntiqueGold.R, UITheme.Colors.AntiqueGold.G, UITheme.Colors.AntiqueGold.B)
    scrollFrame.Parent = contentFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.Parent = scrollFrame

    -- 3. Footer Bar mit 'Alles Verkaufen'
    local footerBar = Instance.new("Frame")
    footerBar.Name = "FooterBar"
    footerBar.Size = UDim2.new(1, 0, 0, 48)
    footerBar.Position = UDim2.new(0, 0, 1, -48)
    footerBar.BackgroundTransparency = 1
    footerBar.Parent = contentFrame

    local totalValLabel = Instance.new("TextLabel")
    totalValLabel.Name = "TotalValue"
    totalValLabel.Size = UDim2.fromScale(0.5, 1)
    totalValLabel.Position = UDim2.fromOffset(0, 0)
    totalValLabel.BackgroundTransparency = 1
    totalValLabel.Font = Enum.Font.GothamBold
    totalValLabel.TextSize = 15
    totalValLabel.TextColor3 = Color3.fromRGB(UITheme.Colors.AntiqueGold.R, UITheme.Colors.AntiqueGold.G, UITheme.Colors.AntiqueGold.B)
    totalValLabel.TextXAlignment = Enum.TextXAlignment.Left
    totalValLabel.Text = "Gesamterlös: 0 Essenz"
    totalValLabel.Parent = footerBar

    local sellAllBtn = GlassButton.Create({
        Name = "SellAllBtn",
        Text = "Alles Verkaufen",
        Size = UDim2.fromOffset(160, 38),
        Position = UDim2.fromScale(1, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        Variant = "Gold",
        OnClick = function()
            guiResult:SellAll()
        end,
        Parent = footerBar,
    })

    local function renderMerchant()
        local profile = DataController:GetProfile()
        if not profile then
            return
        end

        local alchemistLvl = profile.Skills.Alchemist
        bonusLabel.Text = string.format("Alchemisten-Handelsbonus: +%d%%", alchemistLvl * 3)

        local totalValue = guiResult:CalculateTotalValue()
        totalValLabel.Text = string.format("Gesamterlös: %d Essenz", totalValue)
        sellAllBtn.SetEnabled(totalValue > 0)

        for _, child in scrollFrame:GetChildren() do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end

        -- Erze rendern
        for oreId, count in profile.Inventory.Ores do
            if count > 0 then
                local config = OresConfig.Get(oreId :: any)
                if config then
                    local unitPrice = MathUtils.CalculateEssenceBonus(config.SellPrice, alchemistLvl)
                    local card = GlassPanel.Create({
                        Name = oreId .. "SellCard",
                        Size = UDim2.new(1, 0, 0, 48),
                        CornerRadius = UITheme.Radii.Card,
                        Parent = scrollFrame,
                    })

                    local infoLbl = Instance.new("TextLabel")
                    infoLbl.Size = UDim2.fromScale(0.6, 1)
                    infoLbl.Position = UDim2.fromOffset(12, 0)
                    infoLbl.BackgroundTransparency = 1
                    infoLbl.Font = Enum.Font.GothamMedium
                    infoLbl.TextSize = 13
                    infoLbl.TextColor3 = Color3.fromRGB(UITheme.Colors.TextPrimary.R, UITheme.Colors.TextPrimary.G, UITheme.Colors.TextPrimary.B)
                    infoLbl.TextXAlignment = Enum.TextXAlignment.Left
                    infoLbl.Text = string.format("%s (x%d) — %d Essenz/Stk", config.Name, count, unitPrice)
                    infoLbl.Parent = card.Frame

                    GlassButton.Create({
                        Name = "Sell1Btn",
                        Text = "Verkaufen",
                        Size = UDim2.fromOffset(90, 32),
                        Position = UDim2.new(1, -12, 0.5, 0),
                        AnchorPoint = Vector2.new(1, 0.5),
                        Variant = "Green",
                        OnClick = function()
                            guiResult:SellSingleItem("Ore", oreId, 1)
                        end,
                        Parent = card.Frame,
                    })
                end
            end
        end
    end

    guiResult.Refresh = renderMerchant

    DataController.InventoryChanged:Connect(function()
        renderMerchant()
    end)

    renderMerchant()
    return guiResult
end

return MerchantGui
