--[=[
    @class GardenConfig
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GardenConfig = {
    MaxGardens = 1,
    UpgradeStats = {
        [0] = {
            Slots = 9,
        },
        [1] = {
            Slots = 12,
        },
        [2] = {
            Slots = 15,
        }
    }
} :: {
    GrowthCycle: number,
    MaxGardens: number,
    UpgradeStats: {
        Slot: number
    }
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(GardenConfig) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return GardenConfig :: Module