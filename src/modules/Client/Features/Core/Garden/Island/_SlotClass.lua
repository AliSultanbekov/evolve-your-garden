--[=[
    @class SlotClass
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local SlotClass = {}
SlotClass.__index = SlotClass

-- [ Types ] --
export type ObjectData = {
    
}
export type Object = typeof(setmetatable({} :: ObjectData, SlotClass))
export type Module = typeof(SlotClass)

-- [ Private Functions ] --

-- [ Public Functions ] --
function SlotClass.new(): Object
    local self = setmetatable({} :: any, SlotClass) :: Object

    return self
end

return SlotClass :: Module