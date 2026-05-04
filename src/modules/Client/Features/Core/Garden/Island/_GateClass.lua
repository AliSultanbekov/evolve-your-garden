--[=[
    @class GateClass
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GateClass = {}
GateClass.__index = GateClass

-- [ Types ] --
export type ObjectData = {
    
}
export type Object = typeof(setmetatable({} :: ObjectData, GateClass))
export type Module = typeof(GateClass)

-- [ Private Functions ] --

-- [ Public Functions ] --
function GateClass.new(): Object
    local self = setmetatable({} :: any, GateClass) :: Object

    return self
end

return GateClass :: Module