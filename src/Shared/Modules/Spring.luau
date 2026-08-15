--!strict
--[[
    Spring.luau
    Aether Alchemist (Element Shapers)
    Haptische Feder-Physik (Damped Harmonic Oscillator) für UI Micro-Animations,
    Damage-Number Pops und Kamera-Schütteln.
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

export type Spring = {
    Position: number,
    Velocity: number,
    Target: number,
    Stiffness: number,
    Damping: number,
    Mass: number,

    SetTarget: (self: Spring, target: number) -> (),
    Impulse: (self: Spring, velocity: number) -> (),
    Reset: (self: Spring, value: number) -> (),
    Update: (self: Spring, dt: number) -> number,
    IsAtRest: (self: Spring, tolerance: number?) -> boolean,
}

local SpringImpl = {}
SpringImpl.__index = SpringImpl

function SpringImpl.new(initialValue: number?, stiffness: number?, damping: number?): Spring
    local self = setmetatable({}, SpringImpl)

    self.Position = initialValue or 0
    self.Velocity = 0
    self.Target = initialValue or 0
    self.Stiffness = stiffness or 280
    self.Damping = damping or 18
    self.Mass = 1

    return (self :: any) :: Spring
end

function SpringImpl:SetTarget(target: number)
    self.Target = target
end

function SpringImpl:Impulse(velocity: number)
    self.Velocity += velocity
end

function SpringImpl:Reset(value: number)
    self.Position = value
    self.Velocity = 0
    self.Target = value
end

function SpringImpl:Update(dt: number): number
    if dt <= 0 then
        return self.Position
    end

    -- Sub-Stepping für numerische Stabilität (verhindert Überschwingungs-Explosionen bei Lag-Spikes)
    local maxSubDt = 0.016
    local steps = math.clamp(math.ceil(dt / maxSubDt), 1, 10)
    local subDt = dt / steps

    for _ = 1, steps do
        local displacement = self.Position - self.Target
        local force = (-self.Stiffness * displacement) - (self.Damping * self.Velocity)
        local acceleration = force / self.Mass

        self.Velocity += acceleration * subDt
        self.Position += self.Velocity * subDt
    end

    return self.Position
end

function SpringImpl:IsAtRest(tolerance: number?): boolean
    local tol = tolerance or 0.001
    local displacement = math.abs(self.Position - self.Target)
    local velocity = math.abs(self.Velocity)
    return displacement < tol and velocity < tol
end

return SpringImpl
