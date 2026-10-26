--[=[
    @class PlantConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")

-- [ Constants ] --
local DEFAULT_AMOUNT_POOL = {
    [1] = 50,
    [2] = 25,
    [3] = 10,
    [4] = 5,
}

local DEFAULT_GENETICS_CONFIG = {
    Speed = NumberRange.new(0.8, 1.2),
    Yield = NumberRange.new(0, 2),
    Quality = NumberRange.new(0, 2),
    MutationChance = NumberRange.new(0, 2),
}

local DEFAULT_WATER_CONFIG = {
    Max = 100,
    UsagePerCycle = 5,
}

local DEFAULT_LEVEL = function(xp: number): (number, number, number) -- currentlevel, currentlevelxp, nextlevelxp
    local level = 1
    local cumulative = 0
    while level < 25 do
        cumulative += math.floor(50 * level ^ 1.5)
        if cumulative > xp then
            break
        end
        level += 1
    end
    
    return level, math.floor(50 * (level-1) ^ 1.5), cumulative
end

-- [ Variables ] --

-- [ Module Table ] --
local PlantConfig = {}

-- [ Private Functions ] --
function PlantConfig._Init(self: Module)
    self.PlantsCount = 3
    self.GeneticOffsets = {
        Speed = 1,
        Quality = 3,
        Yield = 4,
        MutationChance = 5,
    }
    self.MaxMutationSlots = 1
    self.Plants = {
        ["Daisy"] = {
            Name = "Daisy",
            Rarity = "Uncommon",
            Icon = "rbxassetid://136682835000115",
            Tags = {},
            Level = DEFAULT_LEVEL,
            Genetics = table.clone(DEFAULT_GENETICS_CONFIG),
            Production = {
                CycleTime = 5,
                AmountPool = table.clone(DEFAULT_AMOUNT_POOL),
                ItemPool = {
                    ["Fruit"] = 100
                }
            },
            Water = table.clone(DEFAULT_WATER_CONFIG),
            GrowthStages = {
                [1] = 0,
                [2] = 60,
                [3] = 120,
            }
        },
        ["Buttercup"] = {
            Name = "Buttercup",
            Rarity = "Uncommon",
            Icon = "rbxassetid://94575197746146",
            Tags = {},
            Level = DEFAULT_LEVEL,
            Genetics = table.clone(DEFAULT_GENETICS_CONFIG),
            Production = {
                CycleTime = 5,
                AmountPool = table.clone(DEFAULT_AMOUNT_POOL),
                ItemPool = {
                    ["Fruit"] = 100
                }
            },
            Water = table.clone(DEFAULT_WATER_CONFIG),
            GrowthStages = {
                [1] = 0,
                [2] = 60,
                [3] = 120,
                [4] = 240,
            }
        },
        ["Tomato"] = {
            Name = "Tomato",
            Rarity = "Uncommon",
            Icon = "rbxassetid://115827142175801",
            Tags = {},
            Level = DEFAULT_LEVEL,
            Genetics = table.clone(DEFAULT_GENETICS_CONFIG),
            Production = {
                CycleTime = 5,
                AmountPool = table.clone(DEFAULT_AMOUNT_POOL),
                ItemPool = {
                    ["Fruit"] = 100
                }
            },
            Water = table.clone(DEFAULT_WATER_CONFIG),
            GrowthStages = {
                [1] = 0,
            }
        }
    }

    self.Mutations = {
        ["Juicy"] = {
            Name = "Juicy",
            Desc = "+15% fruit yield",
            Chance = function(context: any): number
                return 20
            end,
            CanRoll = function(context: any): boolean
                return true
            end,
        },
        ["Hardy"] = {
            Name = "Hardy",
            Desc = "+10% growth speed",
            Chance = function(context: any): number
                return 20
            end,
            CanRoll = function(context: any): boolean
                return true
            end,
        },
        ["Golden"] = {
            Name = "Golden",
            Desc = "+75% sell value",
            Chance = function(context: any): number
                return 20
            end,
            CanRoll = function(context: any): boolean
                return true
            end,
        },
        ["Crystalline"] = {
            Name = "Crystalline",
            Desc = "Produces rare crystal",
            Chance = function(context: any): number
                return 20
            end,
            CanRoll = function(context: any): boolean
                return true
            end,
        },
        ["Ancient"] = {
            Name = "Ancient",
            Desc = "+200% baby chance",
            Chance = function(context: any): number
                return 20
            end,
            CanRoll = function(context: any): boolean
                return true
            end,
        },
        ["Void"] = {
            Name = "Void",
            Desc = "Produces void materials",
            Chance = function(context: any): number
                return 20
            end,
            CanRoll = function(context: any): boolean
                return true
            end,
        },
    }
end

-- [ Public Functions ] --

-- [ Types ] --
type GeneticsConfig = {
    Speed: NumberRange,
    Yield: NumberRange,
    Quality: NumberRange,
    MutationChance: NumberRange,
}

type WaterConfig = {
    Max: number,
    UsagePerCycle: number,
}

type PlantEntry = {
    Name: string,
    Rarity: ItemTypes.Rarity,
    Icon: string,
    Tags: { [string]: boolean },
    Level: (xp: number) -> (number, number, number),
    Genetics: GeneticsConfig,
    Production: {
        CycleTime: number,
        AmountPool: { [number]: number },
        ItemPool: { [string]: number },
    },
    Water: WaterConfig,
    GrowthStages: {
        [number]: number
    }
}

type MutationEntry = {
    Name: string,
    Desc: string,
    Chance: (context: any) -> number,
    CanRoll: (context: any) -> boolean,
}

type ModuleData = {
    PlantsCount: number,
    GeneticOffsets: {
        Speed: number,
        Quality: number,
        Yield: number,
        MutationChance: number,
    },
    MaxMutationSlots: number,
    Plants: { [string]: PlantEntry },
    Mutations: { [string]: MutationEntry },
}

export type Module = typeof(PlantConfig) & ModuleData

(PlantConfig :: any):_Init()

return PlantConfig :: Module
