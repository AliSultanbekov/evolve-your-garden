--[=[
    @class GardenConfigClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GardenConfigClient = {}

-- [ Private Functions ] --
function GardenConfigClient._Init(self: Module)
    self.InteractionRange = 20
end

-- [ Public Functions ] --

-- [ Types ] --
type ModuleData = {
    InteractionRange: number,
}

export type Module = typeof(GardenConfigClient) & ModuleData

(GardenConfigClient :: any):_Init()

return GardenConfigClient :: Module