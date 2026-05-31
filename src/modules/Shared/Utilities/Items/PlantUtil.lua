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

-- [ Variables ] --

-- [ Module Table ] --
local Plant = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(Plant) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function Plant.AdvanceGrowth(self: Module, item: ItemTypes.PlantItem, time: number)
    item.GrowthTime += time
end

function Plant.ClaimProductionCycles(self: Module, item: ItemTypes.PlantItem): number
    local GrowthTime = item.GrowthTime
    local Genetics = PlantsConfig:GetGenetics(item.Name, item.GeneticNumber)
    local PlantConfig = PlantsConfig.Plants[item.Name]
    local Level = PlantConfig.Level(item.Xp)

    if GrowthTime <= item.LastProduction then
        return 0
    end

    local BaseCycleTime = PlantsConfig.Plants[item.Name].BaseCycleTime
    local ActualCycleTime = BaseCycleTime / ( Genetics.Speed * PlantsConfig:GetLevelTreeStat(Level, "SpeedMultiplier", item.LevelTreeChoices) )
    local Delta = GrowthTime - item.LastProduction
    local Cycles = math.floor(Delta / ActualCycleTime)

    if Cycles > 0 then
        local LeftOver = Delta % ActualCycleTime
        item.LastProduction = GrowthTime - LeftOver
    end

    return Cycles
end

function Plant.Produce(self: Module, plant: ItemTypes.PlantItem): { ItemTypes.RawItem }
    local PlantConfig = PlantsConfig.Plants[plant.Name]
    local Genetics = PlantsConfig:GetGenetics(plant.Name, plant.GeneticNumber)
    local Level = PlantConfig.Level(plant.Xp)

    local Amount = ChanceClass.new(
        PlantConfig.Production.AmountPool,
        Genetics.Yield * PlantsConfig:GetLevelTreeStat(Level, "YieldMultiplier", plant.LevelTreeChoices),
        30
    ):Choose()

    local Items: { ItemTypes.RawItem } = table.create(Amount)
    local BabyChance = Genetics.BabyChance * PlantsConfig:GetLevelTreeStat(Level, "BabyChanceMultiplier", plant.LevelTreeChoices)
    local Quality = Genetics.Quality * PlantsConfig:GetLevelTreeStat(Level, "QualityMultiplier", plant.LevelTreeChoices)

    for _ = 1, Amount do
        local Pool = {
            ["Yes"] = BabyChance,
            ["No"] = 100 - BabyChance,
        }

        local RawItem: ItemTypes.RawItem

        if ChanceClass.new(Pool):Choose() == "Yes" then
            local Baby: ItemTypes.RawPlantItem = {
                Name = plant.Name,
                Category = "Plant",
                GeneticNumber = plant.GeneticNumber,
            }

            RawItem = Baby
        else
            local ItemName = ChanceClass.new(
                PlantConfig.Production.ItemPool,
                Quality,
                10
            ):Choose()

            RawItem = ItemUtil:MakeRawFromName(ItemName)
        end

        table.insert(Items, RawItem)
    end

    return Items
end

function Plant.GetAvaliableMutationSlotCount(self: Module, plant: ItemTypes.PlantItem)
    local TakenCount = #plant.Mutations
    local PlantConfig = PlantsConfig.Plants[plant.Name]
    local Level = PlantConfig.Level(plant.Xp)
    local BaseCount = PlantsConfig:GetLevelTreeStat(Level, "MutationSlot", plant.LevelTreeChoices)

    return math.max(0, BaseCount-TakenCount)
end

function Plant.RollMutation(self: Module, plant: ItemTypes.PlantItem)
    local AvaliableSlots = self:GetAvaliableMutationSlotCount(plant)

    if AvaliableSlots <= 0 then
        return
    end

    local PlantConfig = PlantsConfig.Plants[plant.Name]
    local Level = PlantConfig.Level(plant.Xp)
    local Genetics = PlantsConfig:GetGenetics(plant.Name, plant.GeneticNumber)
    local MutationChance = Genetics.MutationChance * PlantsConfig:GetLevelTreeStat(Level, "MutationChanceMultiplier", plant.LevelTreeChoices)

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