--!strict
--[[
    test_signal.luau
    Automatisierter Lune Unit-Test zur Verifikation des Signal Event-Emitters.
]]

local Signal = require("../src/Shared/Modules/Signal")

print("🧪 Starte Signal Verifikation...")

-- 1. Test: Einfache Übertragung & Parameter
local signal = Signal.new()
local receivedVal = 0
local receivedText = ""

local conn = signal:Connect(function(val: number, text: string)
    receivedVal = val
    receivedText = text
end)

signal:Fire(42, "Aether")
assert(receivedVal == 42, "Signal Zahl nicht empfangen")
assert(receivedText == "Aether", "Signal Text nicht empfangen")

-- 2. Test: Disconnect
conn:Disconnect()
assert(conn.Connected == false, "Connection muss getrennt sein")

signal:Fire(99, "Ignored")
assert(receivedVal == 42, "Nach Disconnect darf kein Event mehr empfangen werden")

-- 3. Test: Once()
local onceCount = 0
signal:Once(function(amount: number)
    onceCount += amount
end)

signal:Fire(10)
signal:Fire(10)
signal:Fire(10)
assert(onceCount == 10, string.format("Once() darf nur 1x feuern, feuerte %d", onceCount))

-- 4. Test: Mehrere Listener & Self-Disconnect während Fire()
local fireOrder = {}
local selfConn: any = nil

signal:Connect(function()
    table.insert(fireOrder, 1)
end)

selfConn = signal:Connect(function()
    table.insert(fireOrder, 2)
    selfConn:Disconnect()
end)

signal:Connect(function()
    table.insert(fireOrder, 3)
end)

signal:Fire()
assert(#fireOrder == 3, "Alle 3 Listener müssen beim ersten Fire ausgeführt werden")

-- Zweites Feuern: Listener 2 darf nicht mehr laufen
fireOrder = {}
signal:Fire()
assert(#fireOrder == 2, "Nach Self-Disconnect dürfen nur noch 2 Listener laufen")

-- 5. Test: Destroy()
signal:Destroy()
fireOrder = {}
signal:Fire()
assert(#fireOrder == 0, "Nach Destroy() dürfen keine Listener mehr laufen")

print("✅ Signal Event-Emitter zu 100% erfolgreich validiert!")
