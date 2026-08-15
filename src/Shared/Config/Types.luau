--!strict
--[[
    Types.luau
    Aether Alchemist (Element Shapers)
    Zentrales, verbindliches Typ-System für das gesamte Spiel.
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1 Production-Ready).
]]

export type Rarity = "Common" | "Rare" | "Epic" | "Mythic"
export type Element = "Earth" | "Fire" | "Ocean" | "Wind" | "Lightning" | "Void"
export type RGBColor = { R: number, G: number, B: number }

-- // 1. Erze & Bergbau
export type OreId =
    "EarthTopaz"
    | "FireRuby"
    | "OceanSapphire"
    | "WindEmerald"
    | "LightningAmethyst"
    | "VoidCrystal"

export type OreConfig = {
    Id: OreId,
    Name: string,
    Element: Element,
    Rarity: Rarity,
    Zone: number,
    SellPrice: number,
    BaseHarvestTime: number,
    DropMin: number,
    DropMax: number,
    ExtraDropChance: number?,
    RespawnTime: number,
    PointLightColor: RGBColor,
    PointLightRange: number,
    PointLightBrightness: number,
}

-- // 2. Waffen & Kampf
export type WeaponId =
    "BasicBlade"
    | "FireSaber"
    | "OceanTrident"
    | "StormEdge"
    | "VoidShadowBlade"

export type WeaponConfig = {
    Id: WeaponId,
    Name: string,
    Tier: number,
    Damage: number,
    AttackRange: number,
    AttackCooldown: number,
    Description: string,
    SpecialEffect: string,
    Ingredients: { [string]: number },
}

-- // 3. Tränke, Rezepte & Buffs
export type PotionId =
    "InfernoPotion"
    | "GlacierShield"
    | "StormSpeed"
    | "AetherElixir"
    | "CosmicEssence"

export type BuffType = "DamageBoost" | "SpeedBoost" | "Shield" | "CritBoost" | "XpBoost"

export type ActiveBuff = {
    BuffType: BuffType,
    Magnitude: number,
    ExpiresAt: number,
    ShieldHp: number?,
}

export type RecipeConfig = {
    Id: PotionId,
    Name: string,
    Ingredients: { [string]: number },
    Duration: number,
    BuffType: BuffType,
    Magnitude: number,
    SellPrice: number,
    Description: string,
}

-- // 4. Begleiter (Elementar-Wesen / 2nd Ability)
export type SummonId = "FirePhoenix" | "IceGolem" | "VoidPhantom"

export type SummonConfig = {
    Id: SummonId,
    Name: string,
    Cooldown: number,
    Keybind: string,
    AbilityName: string,
    AbilityDescription: string,
    Damage: number?,
    ShieldAmount: number?,
    SlowDuration: number?,
    TeleportDistance: number?,
}

-- // 5. Mobs & Bosse
export type MobId =
    "EarthSlime"
    | "CrystalCrab"
    | "CrystalCrabElite"
    | "VoidStalker"
    | "CrystalColossus"
    | "MiniColossus"

export type MobChanceDrop = {
    ItemId: string,
    Chance: number,
    MinAmount: number,
    MaxAmount: number,
}

export type MobConfig = {
    Id: MobId,
    Name: string,
    Zone: number,
    MaxHp: number,
    Damage: number,
    AggroRadius: number,
    LeashRadius: number,
    RespawnTime: number,
    XP: number,
    EssenceReward: number,
    GuaranteedDrops: { [string]: number },
    ChanceDrops: { MobChanceDrop },
}

-- // 6. Zonen & Welt
export type ZoneId = number
export type Vector3Data = { X: number, Y: number, Z: number }

export type ZoneConfig = {
    Id: ZoneId,
    Name: string,
    LevelMin: number,
    LevelMax: number,
    CenterPosition: Vector3Data,
    Dimensions: Vector3Data,
    BarrierPosition: Vector3Data?,
    ClockTime: number,
    Brightness: number,
    BGMId: string,
}

-- // 7. Audio & SFX
export type SoundKey =
    "Mining_Hit"
    | "Mining_Break"
    | "Sword_Swing"
    | "Combat_Hit"
    | "Combat_Crit"
    | "Cauldron_Bubble"
    | "Craft_Success"
    | "Potion_Drink"
    | "Level_Up"
    | "Player_Hurt"
    | "Player_Death"
    | "Boss_Roar"
    | "Boss_Warning"
    | "UI_Click"
    | "UI_Hover"
    | "BGM_Zone1"
    | "BGM_Zone2"
    | "BGM_Zone3"
    | "BGM_Boss"

export type SoundConfig = {
    AssetId: string,
    Volume: number,
    Looped: boolean,
    PitchMin: number,
    PitchMax: number,
}

-- // 8. Spieler-Profil & DataStore (ProfileService)
export type PlayerSkills = {
    Harvester: number,
    Alchemist: number,
    Summoner: number,
}

export type PlayerInventory = {
    Ores: { [string]: number },
    Potions: { [string]: number },
    Materials: { [string]: number },
}

export type PlayerSettings = {
    MusicVolume: number,
    SFXVolume: number,
    CameraShake: boolean,
    LowPerformanceMode: boolean,
}

export type PlayerTutorial = {
    Step1MinedOres: number,
    Step1Completed: boolean,
    Step2Completed: boolean,
    Step3Completed: boolean,
}

export type PlayerDailyStreak = {
    CurrentStreak: number,
    LastClaimTimestamp: number,
}

export type PlayerPlaytimeGift = {
    NextClaimTimestamp: number,
    ClaimCount: number,
}

export type PlayerStats = {
    TotalOresMined: number,
    TotalMobsDefeated: number,
    TotalBossesDefeated: number,
    TotalPotionsCrafted: number,
    PlaytimeSeconds: number,
}

export type PlayerProfileData = {
    Version: number,
    Level: number,
    XP: number,
    AetherEssence: number,
    SkillPoints: number,
    Skills: PlayerSkills,
    Inventory: PlayerInventory,
    UnlockedWeapons: { string },
    EquippedWeapon: string,
    UnlockedSummons: { string },
    EquippedSummon: string,
    ActiveBuffs: { [string]: ActiveBuff },
    Settings: PlayerSettings,
    Tutorial: PlayerTutorial,
    DailyStreak: PlayerDailyStreak,
    PlaytimeGift: PlayerPlaytimeGift,
    Stats: PlayerStats,
}

-- // 9. Netzwerk-Payloads & Remotes
export type GenericResult = {
    success: boolean,
    error: string?,
}

export type HarvestResult = {
    success: boolean,
    oreId: string?,
    amount: number?,
    error: string?,
}

export type CraftResult = {
    success: boolean,
    craftedItem: string?,
    error: string?,
}

export type PotionResult = {
    success: boolean,
    appliedBuff: string?,
    duration: number?,
    error: string?,
}

export type SellResult = {
    success: boolean,
    earnedEssence: number,
    error: string?,
}

export type EquipResult = {
    success: boolean,
    equipped: string,
    error: string?,
}

export type SkillUpgradeResult = {
    success: boolean,
    newLevel: number,
    remainingPoints: number,
    error: string?,
}

export type ResetSkillsResult = {
    success: boolean,
    refundedPoints: number,
    error: string?,
}

export type TradeResult = {
    success: boolean,
    tradeState: any?,
    error: string?,
}

export type CombatFeedbackData = {
    targetModel: any?,
    damage: number,
    isCrit: boolean,
    isHeal: boolean,
}

local Types = {}
return Types
