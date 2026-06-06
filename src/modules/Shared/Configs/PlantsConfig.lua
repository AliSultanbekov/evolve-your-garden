--[=[
    @class PlantConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --
local ACCUM_OPS = {
    ["+"] = { Default = 0, Apply = function(a: number, b: number) return a + b end },
    ["*"] = { Default = 1, Apply = function(a: number, b: number) return a * b end },
}

local STAT_ACCUM_SIGN: { [string]: "+" | "*" } = {
    MutationSlot             = "+",
    YieldMultiplier          = "*",
    SpeedMultiplier          = "*",
    BabyChanceMultiplier     = "*",
    QualityMultiplier        = "*",
    MutationChanceMultiplier = "*",
}

local GENETIC_OFFSETS = {
    Speed = 1,
    BabyChance = 2,
    Quality = 3,
    Yield = 4,
    MutationChance = 5,
}

local DEFAULT_AMOUNT_POOL = {
    [1] = 50,
    [2] = 25,
    [3] = 10,
    [4] = 5,
}

local DEFAULT_GENETICS_CONFIG = {
    Speed = NumberRange.new(1.0, 1.2),
    BabyChance = NumberRange.new(0.001, 0.01),
    Yield = NumberRange.new(0, 2),
    Quality = NumberRange.new(0, 2),
    MutationChance = NumberRange.new(0, 2),
}

local DEFAULT_LEVEL = function(xp: number): number
    local level = 1
    local cumulative = 0
    while level < 25 do
        cumulative += math.floor(50 * level ^ 1.5)
        if cumulative > xp then
            break
        end
        level += 1
    end
    return level
end

-- [ Variables ] --

-- [ Module Table ] --
local PlantConfig = {}

-- [ Private Functions ] --
function PlantConfig._ScaleGenetic(self: Module, range: NumberRange, t: number): number
    return range.Min + (range.Max - range.Min) * t
end

function PlantConfig._Init(self: Module)
    self.Plants = {
        ["Snow Blossom"] = {
            Name = "Snow Blossom",
            Rarity = "Celestial",
            Icon = "rbxassetid://175279732",
            BaseCycleTime = 5,
            Level = DEFAULT_LEVEL,
            Genetics = DEFAULT_GENETICS_CONFIG,
            Production = {
                AmountPool = DEFAULT_AMOUNT_POOL,
                ItemPool = {
                    ["Snow Blossom Fruit"] = 100
                }
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
function PlantConfig.GetGenetics(self: Module, plantName: string, geneticNumber: number): Genetics
    local GeneticsConfig = self.Plants[plantName].Genetics

    return {
        Speed = self:_ScaleGenetic(GeneticsConfig.Speed, Random.new(geneticNumber + GENETIC_OFFSETS.Speed):NextNumber()),
        BabyChance = self:_ScaleGenetic(GeneticsConfig.BabyChance, Random.new(geneticNumber + GENETIC_OFFSETS.BabyChance):NextNumber()),
        Yield = self:_ScaleGenetic(GeneticsConfig.Yield, Random.new(geneticNumber + GENETIC_OFFSETS.Yield):NextNumber()),
        Quality = self:_ScaleGenetic(GeneticsConfig.Quality, Random.new(geneticNumber + GENETIC_OFFSETS.Quality):NextNumber()),
        MutationChance = self:_ScaleGenetic(GeneticsConfig.MutationChance, Random.new(geneticNumber + GENETIC_OFFSETS.MutationChance):NextNumber()),
    }
end

function PlantConfig.GetLevelTreeStat(self: Module, plantLevel: number, stat: LevelTreeStat, choices: LevelTreeChoices): number
    local Result = nil
    local Op = nil

    for milestone, milestoneData in self.LevelTreeRewards do
        if milestone > plantLevel then
            continue
        end

        local ChoiceIndex = choices[milestone]
        if not ChoiceIndex then
            continue
        end

        local Choice = milestoneData.Choices[ChoiceIndex]
        if not Choice or Choice.Stat ~= stat then
            continue
        end

        if not Op then
            Op = ACCUM_OPS[Choice.AccumSign]
            Result = Op.Default
        end

        Result = Op.Apply(Result, Choice.Value)
    end

    if Result ~= nil then
        return Result
    end

    local sign = STAT_ACCUM_SIGN[stat]
    return if sign then ACCUM_OPS[sign].Default else 0
end

-- [ Types ] --
type Genetics = {
    Speed: number,
    BabyChance: number,
    Yield: number,
    Quality: number,
    MutationChance: number,
}

type GeneticsConfig = {
    Speed: NumberRange,
    BabyChance: NumberRange,
    Yield: NumberRange,
    Quality: NumberRange,
    MutationChance: NumberRange,
}

type PlantEntry = {
    Name: string,
    Rarity: string,
    Icon: string,
    BaseCycleTime: number,
    Level: (xp: number) -> number,
    Genetics: GeneticsConfig,
    Production: {
        AmountPool: { [number]: number },
        ItemPool: { [string]: number },
    },
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
    Plants: { [string]: PlantEntry },
    Mutations: { [string]: MutationEntry },
    LevelTreeRewards: { [number]: LevelTreeMilestone },
}

export type Module = typeof(PlantConfig) & ModuleData

(PlantConfig :: any):_Init()

return PlantConfig :: Module
