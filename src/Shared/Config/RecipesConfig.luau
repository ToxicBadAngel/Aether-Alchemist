--!strict
--[[
    RecipesConfig.luau
    Aether Alchemist (Element Shapers)
    Single Source of Truth für alle 5 Kessel-Rezepte, Buffs und Verkaufswerte.
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local Types = require("./Types")

local Recipes: { [Types.PotionId]: Types.RecipeConfig } = {
    InfernoPotion = {
        Id = "InfernoPotion",
        Name = "Inferno-Trank",
        Ingredients = {
            FireRuby = 2,
            WindEmerald = 1,
        },
        Duration = 300,
        BuffType = "DamageBoost",
        Magnitude = 0.20,
        SellPrice = 90,
        Description = "Verleiht dem Alchemisten die zerstörerische Kraft des Feuers (+20% Schaden für 5 Min).",
    },

    GlacierShield = {
        Id = "GlacierShield",
        Name = "Gletscher-Schutz",
        Ingredients = {
            OceanSapphire = 2,
            EarthTopaz = 1,
        },
        Duration = 0,
        BuffType = "Shield",
        Magnitude = 100,
        SellPrice = 70,
        Description = "Eisiger Schutzwall, der bis zu 100 eingehenden Schaden absorbiert.",
    },

    StormSpeed = {
        Id = "StormSpeed",
        Name = "Sturm-Tempo",
        Ingredients = {
            LightningAmethyst = 2,
            WindEmerald = 1,
        },
        Duration = 300,
        BuffType = "SpeedBoost",
        Magnitude = 0.30,
        SellPrice = 210,
        Description = "Elektrisiert die Schritte des Alchemisten (+30% Tempo für 5 Min).",
    },

    AetherElixir = {
        Id = "AetherElixir",
        Name = "Aether-Elixier",
        Ingredients = {
            FireRuby = 1,
            OceanSapphire = 1,
            VoidCrystal = 1,
        },
        Duration = 600,
        BuffType = "XpBoost",
        Magnitude = 0.50,
        SellPrice = 360,
        Description = "Flüssiges Aether-Wissen, das alle erhaltenen Erfahrungspunkte um +50% steigert (10 Min).",
    },

    CosmicEssence = {
        Id = "CosmicEssence",
        Name = "Kosmische Essenz",
        Ingredients = {
            VoidCrystal = 2,
            LightningAmethyst = 1,
        },
        Duration = 300,
        BuffType = "CritBoost",
        Magnitude = 0.15,
        SellPrice = 690,
        Description = "Mächtige kosmische Essenz, die die Chance auf kritische Treffer um +15% erhöht (5 Min).",
    },
}

local RecipesConfig = {}

function RecipesConfig.Get(recipeId: Types.PotionId): Types.RecipeConfig?
    return Recipes[recipeId]
end

function RecipesConfig.GetAll(): { [Types.PotionId]: Types.RecipeConfig }
    return Recipes
end

function RecipesConfig.IsValidRecipe(recipeId: string): boolean
    return Recipes[recipeId :: Types.PotionId] ~= nil
end

function RecipesConfig.CanCraft(recipeId: Types.PotionId, inventoryOres: { [string]: number }): boolean
    local recipe = Recipes[recipeId]
    if not recipe then
        return false
    end

    for oreId, requiredAmount in recipe.Ingredients do
        local currentAmount = inventoryOres[oreId] or 0
        if currentAmount < requiredAmount then
            return false
        end
    end

    return true
end

return RecipesConfig
