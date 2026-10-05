--[=[
    @class StatsConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local StatsConfig = {}

-- [ Private Functions ] --
function StatsConfig._Init(self: Module)
    self.Stats = { "StartTime" }
end

-- [ Public Functions ] --

-- [ Types ] --
type ModuleData = {
    Stats: { string },
}

export type Module = typeof(StatsConfig) & ModuleData

(StatsConfig :: any):_Init()

return StatsConfig :: Module