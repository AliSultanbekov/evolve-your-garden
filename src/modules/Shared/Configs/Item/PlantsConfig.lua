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
    BabyChance = NumberRange.new(0.0001, 0.01),
    Yield = NumberRange.new(0, 2),
    Quality = NumberRange.new(0, 2),
    MutationChance = NumberRange.new(0, 2),
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
    self.PlantsCount = 5
    self.Plants = {
        ["Snow Blossom"] = {
            Name = "Snow Blossom",
            Rarity = "Common",
            Icon = "",
            BaseCycleTime = 5,
            Level = DEFAULT_LEVEL,
            Genetics = table.clone(DEFAULT_GENETICS_CONFIG),
            Production = {
                AmountPool = table.clone(DEFAULT_AMOUNT_POOL),
                ItemPool = {
                    ["Snow Blossom Fruit"] = 100
                }
            },
            GrowthStages = {
                [1] = 0,
                [2] = 60,
                [3] = 120,
                [4] = 180
            }
        },
        ["Daisy"] = {
            Name = "Daisy",
            Rarity = "Uncommon",
            Icon = "rbxassetid://136682835000115",
            BaseCycleTime = 5,
            Level = DEFAULT_LEVEL,
            Genetics = table.clone(DEFAULT_GENETICS_CONFIG),
            Production = {
                AmountPool = table.clone(DEFAULT_AMOUNT_POOL),
                ItemPool = {
                    ["Snow Blossom Fruit"] = 100
                }
            },
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
            BaseCycleTime = 5,
            Level = DEFAULT_LEVEL,
            Genetics = table.clone(DEFAULT_GENETICS_CONFIG),
            Production = {
                AmountPool = table.clone(DEFAULT_AMOUNT_POOL),
                ItemPool = {
                    ["Snow Blossom Fruit"] = 100
                }
            },
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
            BaseCycleTime = 5,
            Level = DEFAULT_LEVEL,
            Genetics = table.clone(DEFAULT_GENETICS_CONFIG),
            Production = {
                AmountPool = table.clone(DEFAULT_AMOUNT_POOL),
                ItemPool = {
                    ["Snow Blossom Fruit"] = 100
                }
            },
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

    self.LevelTreeRewards = {
        [5] = {
            Choices = {
                [1] = { Stat = "MutationSlot", Value = 1, AccumSign = "+"},
                [2] = { Stat = "YieldMultiplier", Value = 1.2, AccumSign = "*"},
            }
        },
        [10] = {
            Choices = {
                [1] = { Stat = "MutationSlot", Value = 1, AccumSign = "+" },
                [2] = { Stat = "SpeedMultiplier", Value = 1.15, AccumSign = "*" },
            }
        },
        [15] = {
            Choices = {
                [1] = { Stat = "MutationSlot", Value = 1,   AccumSign = "+" },
                [2] = { Stat = "BabyChanceMultiplier", Value = 1.5, AccumSign = "*" },
            }
        },
        [20] = {
            Choices = {
                [1] = { Stat = "MutationSlot", Value = 1, AccumSign = "+" },
                [2] = { Stat = "QualityMultiplier", Value = 1.3, AccumSign = "*" },
            }
        },
        [25] = {
            Choices = {
                [1] = { Stat = "MutationSlot", Value = 1, AccumSign = "+" },
                [2] = { Stat = "MutationChanceMultiplier", Value = 1.5, AccumSign = "*" },
            }
        },
    }
end

-- [ Public Functions ] --

-- [ Types ] --
type GeneticsConfig = {
    Speed: NumberRange,
    BabyChance: NumberRange,
    Yield: NumberRange,
    Quality: NumberRange,
    MutationChance: NumberRange,
}

type PlantEntry = {
    Name: string,
    Rarity: ItemTypes.Rarity,
    Icon: string,
    BaseCycleTime: number,
    Level: (xp: number) -> (number, number, number),
    Genetics: GeneticsConfig,
    Production: {
        AmountPool: { [number]: number },
        ItemPool: { [string]: number },
    },
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

export type LevelTreeStat = "MutationSlot" | "YieldMultiplier" | "SpeedMultiplier" | "BabyChanceMultiplier" | "QualityMultiplier" | "MutationChanceMultiplier"
export type LevelTreeChoices = { [number]: number }

type LevelTreeChoice = {
    Stat: LevelTreeStat,
    Value: number,
    AccumSign: "+" | "*",
}

type LevelTreeMilestone = {
    Choices: { [number]: LevelTreeChoice },
}

type ModuleData = {
    PlantsCount: number,
    Plants: { [string]: PlantEntry },
    Mutations: { [string]: MutationEntry },
    LevelTreeRewards: { [number]: LevelTreeMilestone },
}

export type Module = typeof(PlantConfig) & ModuleData

(PlantConfig :: any):_Init()

return PlantConfig :: Module
