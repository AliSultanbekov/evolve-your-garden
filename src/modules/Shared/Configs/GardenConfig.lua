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
local GardenConfig = {}

-- [ Private Functions ] --
function GardenConfig._Init(self: Module)
    self.PlantMutationBaseChance = 0.001
    self.BaseTick = 1
    self.MaxGardens = 1
    self.HarvestCap = 20
    self.UpgradeStats = {
        [1] = {
            Slots = 9,
            Cols = 3,
            Spacing = 6,
        },
        [2] = {
            Slots = 12,
            Cols = 3,
            Spacing = 6,
        },
        [3] = {
            Slots = 15,
            Cols = 3,
            Spacing = 6,
        }
    }
end

-- [ Public Functions ] --
function GardenConfig.GetUpgradeStats(self: Module, gardenLevel: number)
    return self.UpgradeStats[gardenLevel] or self.UpgradeStats[3]
end

-- [ Types ] --
-- One row of UpgradeStats (per garden level).
export type UpgradeStatsEntry = {
    Slots: number,
    Cols: number,
    Spacing: number,
}

type ModuleData = {
    PlantMutationBaseChance: number,
    BaseTick: number,
    MaxGardens: number,
    HarvestCap: number,
    UpgradeStats: { [number]: UpgradeStatsEntry },
}

export type Module = typeof(GardenConfig) & ModuleData

(GardenConfig :: any):_Init()

return GardenConfig :: Module
