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
-- One row of UpgradeStats (per garden level).
export type UpgradeStatsEntry = {
    Slots: number,
    Cols: number,
    Spacing: number,
    HarvestCap: number,
}
type ModuleData = {}

export type Module = typeof(GardenConfig) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function GardenConfig.GetUpgradeStats(self: Module, gardenLevel: number)
    return self.UpgradeStats[gardenLevel] or self.UpgradeStats[3]
end

return GardenConfig :: Module