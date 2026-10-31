--[=[
    @class LinkedListClass
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local LinkedListClass = {}
LinkedListClass.__index = LinkedListClass

-- [ Types ] --
export type NodeData<T> = {
    Value: T,
    _Next: Object<T>?,
    _Previous: Object<T>?,
}
export type Object<T> = NodeData<T> & Module
export type Module = typeof(LinkedListClass)

-- [ Private Functions ] --
function LinkedListClass._AssertDetached<T>(self: Object<T>, node: Object<T>)
    if node == self then
        error("[LinkedListClass] Cannot attach a node to itself.")
    end

    if node._Next or node._Previous then
        error("[LinkedListClass] Node is already attached. Detach it first.")
    end
end

-- [ Public Functions ] --
function LinkedListClass.new<T>(value: T?): Object<T>
    local self = setmetatable({} :: any, LinkedListClass) :: Object<T>

    self.Value = value :: any

    return self
end

function LinkedListClass.SetValue<T>(self: Object<T>, value: T)
    self.Value = value
end

function LinkedListClass.AttachAfter<T>(self: Object<T>, node: Object<T>)
    self:_AssertDetached(node)

    local Next = self._Next

    node._Previous = self
    node._Next = Next
    self._Next = node

    if Next then
        Next._Previous = node
    end
end

function LinkedListClass.AttachBefore<T>(self: Object<T>, node: Object<T>)
    self:_AssertDetached(node)

    local Previous = self._Previous

    node._Next = self
    node._Previous = Previous
    self._Previous = node

    if Previous then
        Previous._Next = node
    end
end

function LinkedListClass.Detach<T>(self: Object<T>): Object<T>?
    local Previous = self._Previous
    local Next = self._Next

    if Previous then
        Previous._Next = Next
    end

    if Next then
        Next._Previous = Previous
    end

    self._Previous = nil
    self._Next = nil

    return Next
end

function LinkedListClass.GetNext<T>(self: Object<T>): Object<T>?
    return self._Next
end

function LinkedListClass.GetPrevious<T>(self: Object<T>): Object<T>?
    return self._Previous
end

function LinkedListClass.GetFirst<T>(self: Object<T>): Object<T>
    local First = self

    while First._Previous do
        First = First._Previous
    end

    return First
end

function LinkedListClass.GetLast<T>(self: Object<T>): Object<T>
    local Last = self

    while Last._Next do
        Last = Last._Next
    end

    return Last
end

function LinkedListClass.IterateForward<T>(self: Object<T>)
    return function(first: Object<T>, current: Object<T>?): Object<T>?
        if current == nil then
            return first
        end

        return current._Next
    end, self, nil
end

function LinkedListClass.IterateBackward<T>(self: Object<T>)
    return function(last: Object<T>, current: Object<T>?): Object<T>?
        if current == nil then
            return last
        end

        return current._Previous
    end, self, nil
end

return LinkedListClass :: Module
