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
    PlantMutationBaseChance = 0.001,
    BaseTick = 1,
    MaxGardens = 1,
    UpgradeStats = {
        [1] = {
            Slots = 9, 
            Cols = 3, 
            Spacing = 6,
            HarvestCap = 20,
        },
        [2] = {
            Slots = 12, 
            Cols = 3, 
            Spacing = 6,
            HarvestCap = 20,
        },
        [3] = {
            Slots = 15, 
            Cols = 3, 
            Spacing = 6,
            HarvestCap = 20,
        }
    }
}

-- [ Types ] --
export type UpgradeStats = {
    PlantMutationBaseChance: number,
    BaseTick: number,
    MaxGardens: number,
    [number]: {
        Slots: number,
        Cols: number,
        Spacing: number,
        HarvestCap: number,
    }
}
type ModuleData = {}

export type Module = typeof(GardenConfig) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return GardenConfig :: Module