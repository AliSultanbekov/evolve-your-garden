--[=[
    @class Map
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Map = {}
Map.__index = Map

-- [ Types ] --
export type ObjectData<K, V> = {
    _Map: { [K]: V },
    _Size: number,
}
export type Object<K, V> = typeof(setmetatable({} :: ObjectData<K, V>, Map))
export type Module = typeof(Map)

-- [ Private Functions ] --

-- [ Public Functions ] --
function Map.new<K,V>(): Object<K, V>
    local self = setmetatable({} :: any, Map) :: Object<K, V>

    self._Map = {}
    self._Size = 0

    return self
end

function Map.Put<K, V>(self: Object<K, V>, key: K, value: V)
    if value == nil then
        return
    end
    self._Map[key] = value
    self._Size += 1
end

function Map.Remove<K, V>(self: Object<K, V>, key: K)
    if not self._Map[key] then
        return
    end

    self._Map[key] = nil
    self._Size -= 1
end

function Map.Get<K, V>(self: Object<K, V>, key: K): V
    return self._Map[key]
end

function Map.Size<K, V>(self: Object<K, V>)
    return self._Size
end

return Map :: Module