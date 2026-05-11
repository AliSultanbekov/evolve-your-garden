--[=[
    @class GardenConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GardenConfig = {
    MaxGardens = 1,
    UpgradeStats = {
        [1] = {
            Slots = 9, Cols = 3, Spacing = 5
        },
        [2] = {
            Slots = 12, Cols = 3, Spacing = 5
        },
        [3] = {
            Slots = 15, Cols = 3, Spacing = 5
        }
    }
} :: {
    GrowthCycle: number,
    MaxGardens: number,
    UpgradeStats: {
        [number]: {
            Slots: number,
            Cols: number,
            Spacing: number
        }
    }
}

-- [ Types ] --
export type UpgradeStats = {
    [number]: {
        Slots: number,
        Cols: number,
        Spacing: number
    }
}
type ModuleData = {}

export type Module = typeof(GardenConfig) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return GardenConfig :: Module