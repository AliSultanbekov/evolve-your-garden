--[=[
    @class PortalConfigClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local PortalConfigClient = {}

-- [ Private Functions ] --
function PortalConfigClient._Init(self: Module)
    self.Range = 8
end

-- [ Public Functions ] --

-- [ Types ] --
type ModuleData = {
    Range: number
}

export type Module = typeof(PortalConfigClient) & ModuleData

(PortalConfigClient :: any):_Init()

return PortalConfigClient :: Module