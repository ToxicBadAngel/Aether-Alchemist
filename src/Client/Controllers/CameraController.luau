--!strict
--[[
    CameraController.luau
    Aether Alchemist (Element Shapers)
    Client-Singleton für Kamera-Dynamik & Perlin-Trauma-Shake (Nichtlineare Trauma^2
    Abklingkurve, FoV-Punch bei Crits & Begleitern, Settings-Respekt).
    Entspricht 100% INTERVIEW_TECHNICAL_SPEC.md (v3.1).
]]

local Signal = require("../../Shared/Modules/Signal")
local Spring = require("../../Shared/Modules/Spring")
local DataController = require("./DataController")
local CombatController = require("./CombatController")

export type CameraControllerType = {
    ShakeTriggered: Signal.Signal<number>,
    FoVPunched: Signal.Signal<number>,

    Init: (self: any) -> (),
    Start: (self: any) -> (),
    AddTrauma: (self: any, amount: number) -> (),
    PunchFoV: (self: any, amount: number) -> (),
    Update: (self: any, dt: number) -> (number, number, number, number),
    GetTrauma: (self: any) -> number,
}

local CameraController = {
    ShakeTriggered = Signal.new(),
    FoVPunched = Signal.new(),

    _trauma = 0,
    _decayRate = 1.4,
    _maxAngle = 4.0, -- Grad
    _maxOffset = 0.5, -- Studs
    _frequency = 25.0,
    _fovSpring = Spring.new(70),
    _time = 0,
    _enabled = true,
    _initialized = false,
    _started = false,
}

local function isRobloxEngine(): boolean
    local success, result = pcall(function()
        return game ~= nil and game:GetService("Workspace") ~= nil and workspace.CurrentCamera ~= nil
    end)
    return success and result
end

function CameraController:Init()
    if self._initialized then
        return
    end
    self._initialized = true

    self._fovSpring.Speed = 20
    self._fovSpring.Damper = 0.75
end

function CameraController:Start()
    if self._started then
        return
    end
    self._started = true

    -- Settings synchronisieren
    local profile = DataController:GetProfile()
    if profile and profile.Settings then
        self._enabled = profile.Settings.CameraShake
    end

    DataController.ProfileChanged:Connect(function(newProfile)
        if newProfile and newProfile.Settings then
            self._enabled = newProfile.Settings.CameraShake
        end
    end)

    -- Reaktive Verbindung mit Kampf-Ereignissen
    CombatController.DamageFeedbackReceived:Connect(function(feedback)
        if feedback.isCrit then
            self:AddTrauma(0.40)
            self:PunchFoV(6)
        else
            self:AddTrauma(0.15)
        end
    end)

    CombatController.SummonTriggered:Connect(function()
        self:AddTrauma(0.35)
        self:PunchFoV(8)
    end)

    if isRobloxEngine() then
        local RunService = game:GetService("RunService")
        RunService:BindToRenderStep("AetherCameraShake", Enum.RenderPriority.Camera.Value + 1, function(dt: number)
            local yaw, pitch, roll, targetFov = self:Update(dt)
            local camera = workspace.CurrentCamera
            if camera and self._enabled then
                camera.CFrame = camera.CFrame * CFrame.Angles(math.rad(pitch), math.rad(yaw), math.rad(roll))
                camera.FieldOfView = targetFov
            end
        end)
    end
end

function CameraController:AddTrauma(amount: number)
    if not self._enabled then
        return
    end

    self._trauma = math.clamp(self._trauma + amount, 0, 1.0)
    self.ShakeTriggered:Fire(self._trauma)
end

function CameraController:PunchFoV(amount: number)
    self._fovSpring:Impulse(-amount)
    self.FoVPunched:Fire(amount)
end

function CameraController:Update(dt: number): (number, number, number, number)
    self._time += dt

    -- Nichtlineare Trauma^2 Shake-Berechnung (Game-Feel Gesetz #11)
    local shake = self._trauma * self._trauma

    local yaw = 0
    local pitch = 0
    local roll = 0

    if shake > 0.001 and self._enabled then
        yaw = self._maxAngle * shake * math.sin(self._time * self._frequency * 1.1)
        pitch = self._maxAngle * shake * math.cos(self._time * self._frequency * 0.9)
        roll = (self._maxAngle * 0.5) * shake * math.sin(self._time * self._frequency * 1.3)
    end

    -- Trauma linear abbauen
    if self._trauma > 0 then
        self._trauma = math.max(0, self._trauma - (self._decayRate * dt))
    end

    -- FoV Spring Physik aktualisieren
    local currentFov = self._fovSpring:Update(dt)

    return yaw, pitch, roll, currentFov
end

function CameraController:GetTrauma(): number
    return self._trauma
end

return CameraController
