--[=[
    @class Plant
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")
local PlantsConfig = require("PlantsConfig")
local ChanceClass = require("ChanceClass")
local ItemUtil = require("ItemUtil")
local GardenConfig = require("GardenConfig")

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

-- [ Variables ] --

-- [ Module Table ] --
local Plant = {}

-- [ Types ] --
type Genetics = {
    Speed: number,
    BabyChance: number,
    Yield: number,
    Quality: number,
    MutationChance: number,
}

type ModuleData = {}

export type Module = typeof(Plant) & ModuleData

-- [ Private Functions ] --
function Plant._ScaleGenetic(self: Module, range: NumberRange, t: number): number
    return range.Min + (range.Max - range.Min) * t
end

-- [ Public Functions ] --
function Plant.GetLastGrowthStageTime(self: Module, plantName: string): number
    local PlantConfig = PlantsConfig.Plants[plantName]
    local Stages = #PlantConfig.GrowthStages

    return PlantConfig.GrowthStages[Stages]
end

function Plant.GetCurrentGrowthStage(self: Module, plantName: string, growthTime: number)
    local PlantConfig = PlantsConfig.Plants[plantName]
    local Stages = #PlantConfig.GrowthStages
    local CurrentStage = 0

    for i = 1, Stages do
        if PlantConfig.GrowthStages[i] <= growthTime then
            CurrentStage = i
        else
            break
        end
    end

    return CurrentStage
end

function Plant.IsPlantFullyGrown(self: Module, plantName: string, growthTime: number)
    local PlantConfig = PlantsConfig.Plants[plantName]
    local FinalStage = #PlantConfig.GrowthStages
    local FinalStageTime = PlantConfig.GrowthStages[FinalStage]

    return FinalStageTime <= growthTime
end

function Plant.GetGenetics(self: Module, plantName: string, geneticNumber: number): Genetics
    local GeneticsConfig = PlantsConfig.Plants[plantName].Genetics

    return {
        Speed = self:_ScaleGenetic(GeneticsConfig.Speed, Random.new(geneticNumber + GENETIC_OFFSETS.Speed):NextNumber()),
        BabyChance = self:_ScaleGenetic(GeneticsConfig.BabyChance, Random.new(geneticNumber + GENETIC_OFFSETS.BabyChance):NextNumber()),
        Yield = self:_ScaleGenetic(GeneticsConfig.Yield, Random.new(geneticNumber + GENETIC_OFFSETS.Yield):NextNumber()),
        Quality = self:_ScaleGenetic(GeneticsConfig.Quality, Random.new(geneticNumber + GENETIC_OFFSETS.Quality):NextNumber()),
        MutationChance = self:_ScaleGenetic(GeneticsConfig.MutationChance, Random.new(geneticNumber + GENETIC_OFFSETS.MutationChance):NextNumber()),
    }
end

function Plant.GetLevelTreeStat(self: Module, plantLevel: number, stat: PlantsConfig.LevelTreeStat, choices: PlantsConfig.LevelTreeChoices): number
    local Result = nil
    local Op = nil

    for milestone, milestoneData in PlantsConfig.LevelTreeRewards do
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

function Plant.AdvanceGrowth(self: Module, item: ItemTypes.PlantItem, time: number)
    item.GrowthTime += time
end

function Plant.ClaimProductionCycles(self: Module, item: ItemTypes.PlantItem): number
    local GrowthTime = item.GrowthTime
    local Genetics = self:GetGenetics(item.Name, item.GeneticNumber)
    local PlantConfig = PlantsConfig.Plants[item.Name]
    local Level = PlantConfig.Level(item.Xp)
    local FinalStageTime = self:GetLastGrowthStageTime(item.Name)
    local ProductionStart = math.max(item.LastProduction, FinalStageTime)

    if GrowthTime <= ProductionStart then
        return 0
    end

    local BaseCycleTime = PlantConfig.BaseCycleTime
    local ActualCycleTime = BaseCycleTime / ( Genetics.Speed * self:GetLevelTreeStat(Level, "SpeedMultiplier", item.LevelTreeChoices) )
    local Delta = GrowthTime - ProductionStart
    local Cycles = math.floor(Delta / ActualCycleTime)

    if Cycles > 0 then
        local LeftOver = Delta % ActualCycleTime
        item.LastProduction = GrowthTime - LeftOver
    end

    return Cycles
end

function Plant.Produce(self: Module, plant: ItemTypes.PlantItem): { ItemTypes.Item }
    local PlantConfig = PlantsConfig.Plants[plant.Name]
    local Genetics = self:GetGenetics(plant.Name, plant.GeneticNumber)
    local Level = PlantConfig.Level(plant.Xp)

    local Amount = ChanceClass.new(
        PlantConfig.Production.AmountPool,
        Genetics.Yield * self:GetLevelTreeStat(Level, "YieldMultiplier", plant.LevelTreeChoices),
        30
    ):Choose()

    local Items: { ItemTypes.Item } = table.create(Amount)
    local BabyChance = Genetics.BabyChance * self:GetLevelTreeStat(Level, "BabyChanceMultiplier", plant.LevelTreeChoices)
    local Quality = Genetics.Quality * self:GetLevelTreeStat(Level, "QualityMultiplier", plant.LevelTreeChoices)

    for _ = 1, Amount do
        local Pool = {
            ["Yes"] = BabyChance,
            ["No"] = 100 - BabyChance,
        }

        local Item: ItemTypes.Item

        if ChanceClass.new(Pool):Choose() == "Yes" then
            local Baby = ItemUtil:ProcessRawItem({
                Name = plant.Name,
                Category = "Plant",
                GeneticNumber = plant.GeneticNumber,
            })

            Item = Baby
        else
            local ItemName = ChanceClass.new(
                PlantConfig.Production.ItemPool,
                Quality,
                10
            ):Choose()

            Item = ItemUtil:ProcessRawItem(ItemUtil:MakeRawFromName(ItemName))
        end

        table.insert(Items, Item)
    end

    return Items
end

function Plant.GetAvaliableMutationSlotCount(self: Module, plant: ItemTypes.PlantItem)
    local TakenCount = #plant.Mutations
    local PlantConfig = PlantsConfig.Plants[plant.Name]
    local Level = PlantConfig.Level(plant.Xp)
    local BaseCount = self:GetLevelTreeStat(Level, "MutationSlot", plant.LevelTreeChoices)

    return math.max(0, BaseCount-TakenCount)
end

function Plant.RollMutation(self: Module, plant: ItemTypes.PlantItem)
    local AvaliableSlots = self:GetAvaliableMutationSlotCount(plant)

    if AvaliableSlots <= 0 then
        return
    end

    local PlantConfig = PlantsConfig.Plants[plant.Name]
    local Level = PlantConfig.Level(plant.Xp)
    local Genetics = self:GetGenetics(plant.Name, plant.GeneticNumber)
    local MutationChance = Genetics.MutationChance * self:GetLevelTreeStat(Level, "MutationChanceMultiplier", plant.LevelTreeChoices)

    local OptionPool = {
        ["Yes"] = GardenConfig.PlantMutationBaseChance,
        ["No"] = 100 - GardenConfig.PlantMutationBaseChance
    }

    if ChanceClass.new(OptionPool, MutationChance):Choose() ~= "Yes" then
        return
    end

    local MutationPool = {}

    for _, mutationData in pairs(PlantsConfig.Mutations) do
        if mutationData.CanRoll() then
            MutationPool[mutationData.Name] = mutationData.Chance()
        end
    end

    if not next(MutationPool) then
        return
    end

    local Mutation = ChanceClass.new(MutationPool):Choose()

    table.insert(plant.Mutations, Mutation)

    return Mutation
end

function Plant.AddXp(self: Module, plant: ItemTypes.PlantItem, amount: number)
    plant.Xp += amount
end

return Plant :: Module