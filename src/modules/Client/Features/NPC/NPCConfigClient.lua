--[=[
    @class NPCConfigClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local NPCConfigClient = {}

-- [ Private Functions ] --
function NPCConfigClient._Init(self: Module)
    self.Range = 8
end

-- [ Public Functions ] --

-- [ Types ] --
type ModuleData = {
    Range: number,
}

export type Module = typeof(NPCConfigClient) & ModuleData

(NPCConfigClient :: any):_Init()

return NPCConfigClient :: Module