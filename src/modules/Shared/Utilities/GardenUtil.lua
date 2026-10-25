--[=[
    @class GardenUtil
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local GardenConfig = require("GardenConfig")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GardenUtil = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(GardenUtil) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function GardenUtil.TickCheck(self: Module, elapsed: number)
    if elapsed < GardenConfig.BaseTick then
        return false
    end

    return true
end

return GardenUtil :: Module