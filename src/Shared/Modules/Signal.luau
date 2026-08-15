--!strict
--[[
    Signal.luau
    Aether Alchemist (Element Shapers)
    Leichtgewichtiger, typsicherer Event-Emitter für lose System-Entkopplung (Gesetz #8).
    Schützt vor System-Bricking durch isolierte Event-Streams zwischen Services.
]]

export type Connection = {
    Connected: boolean,
    Disconnect: (self: Connection) -> (),
    Destroy: (self: Connection) -> (),
}

export type Signal<T...> = {
    Connect: (self: Signal<T...>, handler: (T...) -> ()) -> Connection,
    Once: (self: Signal<T...>, handler: (T...) -> ()) -> Connection,
    Fire: (self: Signal<T...>, T...) -> (),
    Destroy: (self: Signal<T...>) -> (),
}

type Node = {
    Handler: (...any) -> (),
    Next: Node?,
    Prev: Node?,
    Connected: boolean,
}

local ConnectionImpl = {}
ConnectionImpl.__index = ConnectionImpl

function ConnectionImpl.new(node: Node, signal: any): Connection
    local self = setmetatable({
        Connected = true,
        _node = node,
        _signal = signal,
    }, ConnectionImpl)
    return (self :: any) :: Connection
end

function ConnectionImpl:Disconnect()
    if not self.Connected then
        return
    end
    self.Connected = false
    self._node.Connected = false

    local node = self._node
    local prev = node.Prev
    local next = node.Next

    if prev then
        prev.Next = next
    else
        self._signal._head = next
    end

    if next then
        next.Prev = prev
    end
end

function ConnectionImpl:Destroy()
    self:Disconnect()
end

local SignalImpl = {}
SignalImpl.__index = SignalImpl

function SignalImpl.new<T...>(): Signal<T...>
    local self = setmetatable({
        _head = nil :: Node?,
        _isFiring = false,
    }, SignalImpl)
    return (self :: any) :: Signal<T...>
end

function SignalImpl:Connect(handler: (...any) -> ()): Connection
    local node: Node = {
        Handler = handler,
        Next = self._head,
        Prev = nil,
        Connected = true,
    }

    if self._head then
        self._head.Prev = node
    end
    self._head = node

    return ConnectionImpl.new(node, self)
end

function SignalImpl:Once(handler: (...any) -> ()): Connection
    local connection: Connection? = nil
    connection = self:Connect(function(...)
        if connection then
            connection:Disconnect()
        end
        handler(...)
    end)
    return connection :: Connection
end

function SignalImpl:Fire(...)
    local current = self._head
    while current do
        local next = current.Next
        if current.Connected then
            current.Handler(...)
        end
        current = next
    end
end

function SignalImpl:Destroy()
    local current = self._head
    while current do
        current.Connected = false
        current = current.Next
    end
    self._head = nil
end

return SignalImpl
