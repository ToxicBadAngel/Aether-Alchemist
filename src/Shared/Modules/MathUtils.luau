--!strict
--[[
    MathUtils.luau
    Aether Alchemist (Element Shapers)
    Mathematische Formeln, Balancing-Algorithmen und Exploit-Distanz-Validierung.
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

export type Position3D = {
    X: number,
    Y: number,
    Z: number,
}

local MathUtils = {}

-- // 1. XP & Level-Skalierung
function MathUtils.GetRequiredXP(level: number): number
    if level < 1 then
        return 100
    end
    return math.floor(100 * (1.25 ^ (level - 1)))
end

-- // 2. Harvester Mining-Speed (-4% pro Skill-Punkt, max 10 Punkte = -40%)
function MathUtils.CalculateHarvestTime(baseHarvestTime: number, harvesterLevel: number): number
    local clampedLevel = math.clamp(harvesterLevel, 0, 10)
    local multiplier = math.max(0.60, 1.0 - (clampedLevel * 0.04))
    return baseHarvestTime * multiplier
end

-- // 3. Alchemist Essenz-Bonus (+3% pro Skill-Punkt, max 10 Punkte = +30%)
function MathUtils.CalculateEssenceBonus(baseEssence: number, alchemistLevel: number): number
    local clampedLevel = math.clamp(alchemistLevel, 0, 10)
    local multiplier = 1.0 + (clampedLevel * 0.03)
    return math.round(baseEssence * multiplier)
end

-- // 4. Summoner Cooldown-Reduktion (-3% pro Skill-Punkt, max 10 Punkte = -30%)
function MathUtils.CalculateSummonCooldown(baseCooldown: number, summonerLevel: number): number
    local clampedLevel = math.clamp(summonerLevel, 0, 10)
    local multiplier = math.max(0.70, 1.0 - (clampedLevel * 0.03))
    return baseCooldown * multiplier
end

-- // 5. Server-Autorität: Quadratische Distanz-Prüfung (Exploit-Schutz ohne sqrt-Overhead)
function MathUtils.IsWithinDistance(posA: Position3D, posB: Position3D, maxDistance: number): boolean
    local dx = posA.X - posB.X
    local dy = posA.Y - posB.Y
    local dz = posA.Z - posB.Z
    local distSq = (dx * dx) + (dy * dy) + (dz * dz)
    return distSq <= (maxDistance * maxDistance)
end

-- // 6. Exakte 3D-Distanz
function MathUtils.GetDistance(posA: Position3D, posB: Position3D): number
    local dx = posA.X - posB.X
    local dy = posA.Y - posB.Y
    local dz = posA.Z - posB.Z
    return math.sqrt((dx * dx) + (dy * dy) + (dz * dz))
end

-- // 7. UI-Zahlen-Formatierung (1.5k, 2.3M, 1.1B)
function MathUtils.FormatNumber(num: number): string
    if num < 1000 then
        return tostring(math.floor(num))
    elseif num < 1000000 then
        local val = num / 1000
        if val % 1 == 0 then
            return string.format("%dk", val)
        else
            return string.format("%.1fk", val)
        end
    elseif num < 1000000000 then
        local val = num / 1000000
        if val % 1 == 0 then
            return string.format("%dM", val)
        else
            return string.format("%.1fM", val)
        end
    else
        local val = num / 1000000000
        if val % 1 == 0 then
            return string.format("%dB", val)
        else
            return string.format("%.1fB", val)
        end
    end
end

-- // 8. Zeit-Formatierung (MM:SS)
function MathUtils.FormatTime(totalSeconds: number): string
    local seconds = math.max(0, math.floor(totalSeconds))
    local minutes = math.floor(seconds / 60)
    local remainingSecs = seconds % 60
    return string.format("%02d:%02d", minutes, remainingSecs)
end

return MathUtils
