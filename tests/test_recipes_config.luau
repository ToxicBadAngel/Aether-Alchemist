--!strict
--[[
    test_recipes_config.luau
    Automatisierter Lune Unit-Test zur Verifikation von RecipesConfig.luau.
]]

local RecipesConfig = require("../src/Shared/Config/RecipesConfig")

print("🧪 Starte RecipesConfig Verifikation...")

-- 1. Test: Genau 5 Rezepte müssen existieren
local allRecipes = RecipesConfig.GetAll()
local count = 0
for _ in allRecipes do
    count += 1
end
assert(count == 5, string.format("Erwartet 5 Rezepte, aber %d gefunden", count))

-- 2. Test: InfernoPotion
local inferno = RecipesConfig.Get("InfernoPotion")
assert(inferno ~= nil, "InfernoPotion nicht gefunden")
assert(inferno.Ingredients["FireRuby"] == 2, "InfernoPotion benötigt 2x FireRuby")
assert(inferno.Ingredients["WindEmerald"] == 1, "InfernoPotion benötigt 1x WindEmerald")
assert(inferno.Duration == 300, "InfernoPotion Duration muss 300s sein")
assert(inferno.BuffType == "DamageBoost", "InfernoPotion BuffType muss DamageBoost sein")
assert(inferno.Magnitude == 0.20, "InfernoPotion Magnitude muss 0.20 sein")
assert(inferno.SellPrice == 90, "InfernoPotion SellPrice muss 90 sein (+50% Bonus)")

-- 3. Test: GlacierShield
local shield = RecipesConfig.Get("GlacierShield")
assert(shield ~= nil, "GlacierShield nicht gefunden")
assert(shield.Ingredients["OceanSapphire"] == 2, "GlacierShield benötigt 2x OceanSapphire")
assert(shield.Ingredients["EarthTopaz"] == 1, "GlacierShield benötigt 1x EarthTopaz")
assert(shield.BuffType == "Shield", "GlacierShield BuffType muss Shield sein")
assert(shield.Magnitude == 100, "GlacierShield Magnitude muss 100 HP sein")
assert(shield.SellPrice == 70, "GlacierShield SellPrice muss 70 sein")

-- 4. Test: StormSpeed
local speed = RecipesConfig.Get("StormSpeed")
assert(speed ~= nil, "StormSpeed nicht gefunden")
assert(speed.Ingredients["LightningAmethyst"] == 2, "StormSpeed benötigt 2x LightningAmethyst")
assert(speed.BuffType == "SpeedBoost", "StormSpeed BuffType muss SpeedBoost sein")
assert(speed.Magnitude == 0.30, "StormSpeed Magnitude muss 0.30 sein")
assert(speed.SellPrice == 210, "StormSpeed SellPrice muss 210 sein")

-- 5. Test: AetherElixir & CosmicEssence
local elixir = RecipesConfig.Get("AetherElixir")
assert(elixir ~= nil, "AetherElixir nicht gefunden")
assert(elixir.BuffType == "XpBoost" and elixir.Magnitude == 0.50, "AetherElixir muss +50% XP geben")
assert(elixir.Duration == 600, "AetherElixir muss 600s dauern")
assert(elixir.SellPrice == 360, "AetherElixir SellPrice muss 360 sein")

local cosmic = RecipesConfig.Get("CosmicEssence")
assert(cosmic ~= nil, "CosmicEssence nicht gefunden")
assert(cosmic.BuffType == "CritBoost" and cosmic.Magnitude == 0.15, "CosmicEssence muss +15% Krit geben")
assert(cosmic.SellPrice == 690, "CosmicEssence SellPrice muss 690 sein")

-- 6. Test: CanCraft Validierung
local fullInventory = {
    ["FireRuby"] = 5,
    ["WindEmerald"] = 2,
    ["OceanSapphire"] = 10,
    ["EarthTopaz"] = 10,
}
assert(RecipesConfig.CanCraft("InfernoPotion", fullInventory) == true, "Sollte InfernoPotion craften können")
assert(RecipesConfig.CanCraft("GlacierShield", fullInventory) == true, "Sollte GlacierShield craften können")

local poorInventory = {
    ["FireRuby"] = 1, -- Zu wenig für Inferno (braucht 2)
    ["WindEmerald"] = 2,
}
assert(RecipesConfig.CanCraft("InfernoPotion", poorInventory) == false, "Darf InfernoPotion nicht craften (fehlt 1 FireRuby)")
assert(RecipesConfig.CanCraft("GlacierShield", poorInventory) == false, "Darf GlacierShield nicht craften (fehlt alles)")

-- 7. Test: IsValidRecipe
assert(RecipesConfig.IsValidRecipe("InfernoPotion") == true, "InfernoPotion muss gültig sein")
assert(RecipesConfig.IsValidRecipe("LovePotion") == false, "LovePotion darf nicht existieren")

print("✅ RecipesConfig zu 100% erfolgreich validiert!")
