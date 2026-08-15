--!strict
--[[
    InventoryGui.luau
    Aether Alchemist (Element Shapers)
    Modales Inventar- & Ausrüstungsfenster (Basiert auf ModalWrapper, 4 Tabs: Erze,
    Tränke, Waffen, Begleiter, Card-Grid, Ausrüst-Buttons, reaktive Datenbindung).
    Entspricht 100% UITheme.luau & INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local UITheme = require("../../../Shared/Modules/UITheme")
local OresConfig = require("../../../Shared/Config/OresConfig")
local RecipesConfig = require("../../../Shared/Config/RecipesConfig")
local WeaponsConfig = require("../../../Shared/Config/WeaponsConfig")
local SummonsConfig = require("../../../Shared/Config/SummonsConfig")
local ModalWrapper = require("../Components/ModalWrapper")
local GlassButton = require("../Components/GlassButton")
local GlassPanel = require("../Components/GlassPanel")
local DataController = require("../../../Client/Controllers/DataController")
local UIController = require("../../../Client/Controllers/UIController")
local AudioController = require("../../../Client/Controllers/AudioController")
local NetworkContracts = require("../../../Shared/Remotes/NetworkContracts")

export type InventoryTab = "Erze" | "Tränke" | "Waffen" | "Begleiter"

export type InventoryGuiResult = {
    Modal: any,
    CurrentTab: InventoryTab,
    SetTab: (self: any, tab: InventoryTab) -> (),
    Refresh: (self: any) -> (),
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("UserInputService") ~= nil
    end)
    return success and result
end

local InventoryGui = {}

function InventoryGui.Create(parentGui: any?): InventoryGuiResult
    local currentTab: InventoryTab = "Erze"

    -- 1. Modal Wrapper erzeugen
    local modal = ModalWrapper.Create({
        Name = "InventoryGui",
        Title = "Inventar & Ausrüstung",
        Size = if isRobloxEngine() then UDim2.fromOffset(560, 440) else nil,
        Parent = parentGui,
    })

    -- Bei UIController für Hotkey [B] und Exklusivitäts-Management registrieren
    UIController:RegisterScreen("Inventory", function(visible)
        if visible then
            modal:Show()
        else
            modal:Hide()
        end
    end, modal.ScreenGui)

    local guiResult: InventoryGuiResult = {
        Modal = modal,
        CurrentTab = currentTab,
        SetTab = function(self: any, tab: InventoryTab)
            self.CurrentTab = tab
            currentTab = tab
            self:Refresh()
        end,
        Refresh = function(_self: any) end,
    }

    if not isRobloxEngine() then
        -- Headless Lune Mock-Implementierung
        guiResult.Refresh = function(_self: any)
            -- Simuliert sauberes Refreshing der Tab-Inhalte
            local profile = DataController:GetProfile()
            if not profile then
                return
            end
        end

        DataController.InventoryChanged:Connect(function()
            guiResult:Refresh()
        end)
        DataController.WeaponChanged:Connect(function()
            guiResult:Refresh()
        end)
        DataController.SummonChanged:Connect(function()
            guiResult:Refresh()
        end)

        return guiResult
    end

    local contentFrame = modal.Content

    -- 2. Tab Bar Oben
    local tabBar = Instance.new("Frame")
    tabBar.Name = "TabBar"
    tabBar.Size = UDim2.new(1, 0, 0, 36)
    tabBar.Position = UDim2.fromOffset(0, 0)
    tabBar.BackgroundTransparency = 1
    tabBar.Parent = contentFrame

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 8)
    tabLayout.Parent = tabBar

    -- 3. Scrollbarer Content Container für Item-Cards
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ItemsScroll"
    scrollFrame.Size = UDim2.new(1, 0, 1, -48)
    scrollFrame.Position = UDim2.fromOffset(0, 48)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(UITheme.Colors.AetherCyan.R, UITheme.Colors.AetherCyan.G, UITheme.Colors.AetherCyan.B)
    scrollFrame.Parent = contentFrame

    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.fromOffset(120, 130)
    gridLayout.CellPadding = UDim2.fromOffset(10, 10)
    gridLayout.Parent = scrollFrame

    local tabs: { InventoryTab } = { "Erze", "Tränke", "Waffen", "Begleiter" }
    local tabButtons: { [InventoryTab]: any } = {}

    local function renderItems()
        -- Vorherige Cards aufräumen
        for _, child in scrollFrame:GetChildren() do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end

        local profile = DataController:GetProfile()
        if not profile then
            return
        end

        if currentTab == "Erze" then
            for oreId, config in OresConfig.GetAll() do
                local count = profile.Inventory.Ores[oreId] or 0
                if count > 0 then
                    local card = GlassPanel.Create({
                        Name = oreId .. "Card",
                        Size = UDim2.fromOffset(120, 130),
                        CornerRadius = UITheme.Radii.Card,
                        Parent = scrollFrame,
                    })

                    local nameLbl = Instance.new("TextLabel")
                    nameLbl.Size = UDim2.new(1, -8, 0, 24)
                    nameLbl.Position = UDim2.fromOffset(4, 6)
                    nameLbl.BackgroundTransparency = 1
                    nameLbl.Font = Enum.Font.GothamBold
                    nameLbl.TextSize = 12
                    nameLbl.TextColor3 = Color3.fromRGB(UITheme.Colors.TextPrimary.R, UITheme.Colors.TextPrimary.G, UITheme.Colors.TextPrimary.B)
                    nameLbl.Text = config.Name
                    nameLbl.Parent = card.Frame

                    local countLbl = Instance.new("TextLabel")
                    countLbl.Size = UDim2.new(1, -8, 0, 20)
                    countLbl.Position = UDim2.new(0, 4, 1, -26)
                    countLbl.BackgroundTransparency = 1
                    countLbl.Font = Enum.Font.GothamBold
                    countLbl.TextSize = 14
                    countLbl.TextColor3 = Color3.fromRGB(UITheme.Colors.AntiqueGold.R, UITheme.Colors.AntiqueGold.G, UITheme.Colors.AntiqueGold.B)
                    countLbl.Text = "x" .. tostring(count)
                    countLbl.Parent = card.Frame
                end
            end
        elseif currentTab == "Tränke" then
            for potionId, config in RecipesConfig.GetAll() do
                local count = profile.Inventory.Potions[potionId] or 0
                if count > 0 then
                    local card = GlassPanel.Create({
                        Name = potionId .. "Card",
                        Size = UDim2.fromOffset(120, 130),
                        CornerRadius = UITheme.Radii.Card,
                        Parent = scrollFrame,
                    })

                    local nameLbl = Instance.new("TextLabel")
                    nameLbl.Size = UDim2.new(1, -8, 0, 20)
                    nameLbl.Position = UDim2.fromOffset(4, 6)
                    nameLbl.BackgroundTransparency = 1
                    nameLbl.Font = Enum.Font.GothamBold
                    nameLbl.TextSize = 11
                    nameLbl.TextColor3 = Color3.fromRGB(UITheme.Colors.TextPrimary.R, UITheme.Colors.TextPrimary.G, UITheme.Colors.TextPrimary.B)
                    nameLbl.Text = config.Name
                    nameLbl.Parent = card.Frame

                    GlassButton.Create({
                        Name = "UseBtn",
                        Text = "Trinken",
                        Size = UDim2.fromOffset(90, 28),
                        Position = UDim2.new(0.5, 0, 1, -18),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Variant = "Green",
                        OnClick = function()
                            local usePotionRE = NetworkContracts.GetRemoteEvent("UsePotion_RE")
                            if usePotionRE then
                                usePotionRE:FireServer(potionId)
                                AudioController:PlaySound("Potion_Drink")
                            end
                        end,
                        Parent = card.Frame,
                    })
                end
            end
        elseif currentTab == "Waffen" then
            for _, weaponId in profile.UnlockedWeapons do
                local config = WeaponsConfig.Get(weaponId :: any)
                if config then
                    local isEquipped = profile.EquippedWeapon == weaponId
                    local card = GlassPanel.Create({
                        Name = weaponId .. "Card",
                        Size = UDim2.fromOffset(120, 130),
                        CornerRadius = UITheme.Radii.Card,
                        Parent = scrollFrame,
                    })

                    local nameLbl = Instance.new("TextLabel")
                    nameLbl.Size = UDim2.new(1, -8, 0, 20)
                    nameLbl.Position = UDim2.fromOffset(4, 6)
                    nameLbl.BackgroundTransparency = 1
                    nameLbl.Font = Enum.Font.GothamBold
                    nameLbl.TextSize = 11
                    nameLbl.TextColor3 = Color3.fromRGB(UITheme.Colors.TextPrimary.R, UITheme.Colors.TextPrimary.G, UITheme.Colors.TextPrimary.B)
                    nameLbl.Text = config.Name
                    nameLbl.Parent = card.Frame

                    GlassButton.Create({
                        Name = "EquipBtn",
                        Text = if isEquipped then "Aktiv" else "Ausrüsten",
                        Size = UDim2.fromOffset(90, 28),
                        Position = UDim2.new(0.5, 0, 1, -18),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Variant = if isEquipped then "Gold" else "Cyan",
                        OnClick = function()
                            if not isEquipped then
                                local equipRE = NetworkContracts.GetRemoteEvent("EquipWeapon_RE")
                                if equipRE then
                                    equipRE:FireServer(weaponId)
                                    AudioController:PlaySound("UI_Click")
                                end
                            end
                        end,
                        Parent = card.Frame,
                    })
                end
            end
        elseif currentTab == "Begleiter" then
            for _, summonId in profile.UnlockedSummons do
                local config = SummonsConfig.Get(summonId :: any)
                if config then
                    local isEquipped = profile.EquippedSummon == summonId
                    local card = GlassPanel.Create({
                        Name = summonId .. "Card",
                        Size = UDim2.fromOffset(120, 130),
                        CornerRadius = UITheme.Radii.Card,
                        Parent = scrollFrame,
                    })

                    local nameLbl = Instance.new("TextLabel")
                    nameLbl.Size = UDim2.new(1, -8, 0, 20)
                    nameLbl.Position = UDim2.fromOffset(4, 6)
                    nameLbl.BackgroundTransparency = 1
                    nameLbl.Font = Enum.Font.GothamBold
                    nameLbl.TextSize = 11
                    nameLbl.TextColor3 = Color3.fromRGB(UITheme.Colors.TextPrimary.R, UITheme.Colors.TextPrimary.G, UITheme.Colors.TextPrimary.B)
                    nameLbl.Text = config.Name
                    nameLbl.Parent = card.Frame

                    GlassButton.Create({
                        Name = "EquipSummonBtn",
                        Text = if isEquipped then "Aktiv" else "Ausrüsten",
                        Size = UDim2.fromOffset(90, 28),
                        Position = UDim2.new(0.5, 0, 1, -18),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Variant = if isEquipped then "Gold" else "Cyan",
                        OnClick = function()
                            if not isEquipped then
                                local equipSummonRE = NetworkContracts.GetRemoteEvent("EquipSummon_RE")
                                if equipSummonRE then
                                    equipSummonRE:FireServer(summonId)
                                    AudioController:PlaySound("UI_Click")
                                end
                            end
                        end,
                        Parent = card.Frame,
                    })
                end
            end
        end
    end

    for _, tabName in tabs do
        local btnResult = GlassButton.Create({
            Name = tabName .. "TabButton",
            Text = tabName,
            Size = UDim2.fromOffset(100, 32),
            Variant = if tabName == currentTab then "Cyan" else "Gold",
            OnClick = function()
                guiResult:SetTab(tabName)
            end,
            Parent = tabBar,
        })
        tabButtons[tabName] = btnResult
    end

    guiResult.Refresh = renderItems

    -- Reaktive Verbindung
    DataController.InventoryChanged:Connect(function()
        renderItems()
    end)
    DataController.WeaponChanged:Connect(function()
        renderItems()
    end)
    DataController.SummonChanged:Connect(function()
        renderItems()
    end)

    renderItems()
    return guiResult
end

return InventoryGui
