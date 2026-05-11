--[=[
    @class GardenConstants
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GardenConstants = {
    MaxGardens = 8
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(GardenConstants) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return GardenConstants :: Module