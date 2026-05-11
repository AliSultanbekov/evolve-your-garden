--[=[
    @class Array
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Array = {}
Array.__index = Array

-- [ Types ] --
export type ObjectData<V> = {
    _Array: { V },
    _Size: number,
}
export type Object<V> = typeof(setmetatable({} :: ObjectData<V>, Array))
export type Module = typeof(Array)

-- [ Private Functions ] --

-- [ Public Functions ] --
function Array.new<V>(): Object<V>
    local self = setmetatable({} :: any, Array) :: Object<V>

    self._Array = {}
    self._Size = 0

    return self
end

function Array.Insert<V>(self: Object<V>, value: V, index: number?)
    if value == nil then
        return
    end

    if index then
        table.insert(self._Array, index, value)
    else
        table.insert(self._Array, value)
    end

    self._Size += 1
end

function Array.Remove<V>(self: Object<V>, index: number?)
    if index then
        table.remove(self._Array, index)
    else
        table.remove(self._Array)
    end

    self._Size -= 1
end

function Array.Get<V>(self: Object<V>, index: number)
    return self._Array[index]
end

function Array.Size<V>(self: Object<V>)
    return self._Size
end

return Array :: Module