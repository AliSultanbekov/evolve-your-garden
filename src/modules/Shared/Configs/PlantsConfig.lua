--[=[
    @class PlantConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --
local GENETIC_OFFSETS = {
    ProductionTime = 1,
    BabyChance = 2,
    ItemProductionLuck = 3,
    AmountProductionLuck = 4,
    MutationLuck = 5,
}

local DEFAULT_AMOUNT_POOL = {
    [1] = 50,
    [2] = 25,
    [3] = 10,
    [4] = 5,
}

--Brutal black pill
local DEFAULT_GENETICS_CONFIG = {
    ProductionTime = NumberRange.new(5, 5.5),
    BabyChance = NumberRange.new(0.001, 0.01),
    Luck = {
        ItemProductionLuck = NumberRange.new(0, 2),
        AmountProductionLuck = NumberRange.new(0, 2),
        MutationLuck = NumberRange.new(0, 2),
    }
}

-- [ Variables ] --

-- [ Module Table ] --
local PlantConfig = {
    Plants = {
        ["Snow Blossom"] = {
            Name = "Snow Blossom",
            Rarity = "Common",
            Icon = "rbxassetid://175279732",
            Genetics = DEFAULT_GENETICS_CONFIG,
            Production = {
                AmountPool = DEFAULT_AMOUNT_POOL,
                ItemPool = {
                    ["Snow Blossom Fruit"] = 100
                }
            }
        }
    }
}

-- [ Types ] --
type Genetics = {
    ProductionTime: number,
    BabyChance: number,
    Luck: {
        ItemProductionLuck: number,
        AmountProductionLuck: number,
        MutationLuck: number,
    }
}

type GeneticsConfig = {
    ProductionTime: NumberRange,
    BabyChance: NumberRange,
    Luck: {
        ItemProductionLuck: NumberRange,
        AmountProductionLuck: NumberRange,
        MutationLuck: NumberRange,
    }
}

type ModuleData = {
    Plants: {
        [string]: {
            Name: string,
            Rarity: string,
            Icon: string,
            Genetics: GeneticsConfig,
            Production: {
                AmountPool: { [number]: number },
                ItemPool: { [string]: number },
            }
        }
    }
}

export type Module = typeof(PlantConfig) & ModuleData

-- [ Private Functions ] --
function PlantConfig._ScaleGenetic(self: Module, range: NumberRange, t: number): number
    return range.Min + (range.Max - range.Min) * t
end

-- [ Public Functions ] --
function PlantConfig.GetGenetics(self: Module, plantName: string, geneticNumber: number): Genetics
    local GeneticsConfig = self.Plants[plantName].Genetics

    return {
        ProductionTime = self:_ScaleGenetic(GeneticsConfig.ProductionTime, Random.new(geneticNumber + GENETIC_OFFSETS.ProductionTime):NextNumber()),
        BabyChance = self:_ScaleGenetic(GeneticsConfig.BabyChance, Random.new(geneticNumber + GENETIC_OFFSETS.BabyChance):NextNumber()),
        Luck = {
            ItemProductionLuck = self:_ScaleGenetic(GeneticsConfig.Luck.ItemProductionLuck, Random.new(geneticNumber + GENETIC_OFFSETS.ItemProductionLuck):NextNumber()),
            AmountProductionLuck = self:_ScaleGenetic(GeneticsConfig.Luck.AmountProductionLuck, Random.new(geneticNumber + GENETIC_OFFSETS.AmountProductionLuck):NextNumber()),
            MutationLuck = self:_ScaleGenetic(GeneticsConfig.Luck.MutationLuck, Random.new(geneticNumber + GENETIC_OFFSETS.MutationLuck):NextNumber()),
        },
    }
end

return PlantConfig :: Module