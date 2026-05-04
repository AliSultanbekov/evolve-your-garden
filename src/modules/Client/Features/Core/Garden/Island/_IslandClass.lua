--[=[
    @class IslandClass
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local IslandClass = {}
IslandClass.__index = IslandClass

-- [ Types ] --
export type ObjectData = {
    
}
export type Object = typeof(setmetatable({} :: ObjectData, IslandClass))
export type Module = typeof(IslandClass)

-- [ Private Functions ] --

-- [ Public Functions ] --
function IslandClass.new(owner: Player, ): Object
    local self = setmetatable({} :: any, IslandClass) :: Object

    return self
end

return IslandClass :: Module