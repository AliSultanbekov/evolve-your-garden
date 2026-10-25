--[=[
    @class PlantUtilServer

    Truth mutation for plants: advances clocks, claims cycles, rolls
    production. Takes plain items because only the server owns them -
    reads shared by the client live in PlantUtilShared.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")
local PlantsConfig = require("PlantsConfig")
local PlantUtilShared = require("PlantUtilShared")
local ChanceClass = require("ChanceClass")
local ItemUtil = require("ItemUtil")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local PlantUtilServer = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(PlantUtilServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function PlantUtilServer.AdvanceGrowth(self: Module, plant: ItemTypes.PlantItem, elapsed: number)
    plant.GrowthTime += elapsed
end

function PlantUtilServer.ClaimProductionCycles(self: Module, plant: ItemTypes.PlantItem): number
    local GrowthTime = plant.GrowthTime
    local FinalStageTime = PlantUtilShared:GetLastGrowthStageTime(plant.Name)
    local ProductionStart = math.max(plant.LastProduction, FinalStageTime)

    if GrowthTime <= ProductionStart then
        return 0
    end

    local ActualCycleTime = PlantUtilShared:GetActualCycleTime(plant.Name, plant.GeneticNumber)
    local UnclaimedTime = GrowthTime - ProductionStart
    local Cycles = math.floor(UnclaimedTime / ActualCycleTime)

    if Cycles > 0 then
        plant.LastProduction = GrowthTime - (UnclaimedTime % ActualCycleTime)
    end

    return Cycles
end

function PlantUtilServer.Produce(self: Module, plant: ItemTypes.PlantItem): { ItemTypes.Item }
    local PlantConfig = PlantsConfig.Plants[plant.Name]
    local Genetics = PlantUtilShared:GetGenetics(plant.Name, plant.GeneticNumber)

    local Amount = ChanceClass.new(
        PlantConfig.Production.AmountPool,
        Genetics.Yield,
        30
    ):Choose()

    local Items: { ItemTypes.Item } = table.create(Amount)

    for _ = 1, Amount do
        local ItemName = ChanceClass.new(
            PlantConfig.Production.ItemPool,
            Genetics.Quality,
            10
        ):Choose()

        table.insert(Items, ItemUtil:ProcessRawItem(ItemUtil:MakeRawFromName(ItemName)))
    end

    plant.Xp += 20

    return Items
end

--[[function PlantUtilServer.GetAvaliableMutationSlotCount(self: Module, plant: ItemTypes.PlantItem)
    local TakenCount = #plant.Mutations

    return math.max(0, PlantsConfig.MaxMutationSlots - TakenCount)
end]]

--[[function PlantUtilServer.RollMutation(self: Module, plant: ItemTypes.PlantItem)
    local AvaliableSlots = self:GetAvaliableMutationSlotCount(plant)

    if AvaliableSlots <= 0 then
        return
    end

    local Genetics = PlantUtilShared:GetGenetics(plant.Name, plant.GeneticNumber)

    local OptionPool = {
        ["Yes"] = GardenConfig.PlantMutationBaseChance,
        ["No"] = 100 - GardenConfig.PlantMutationBaseChance
    }

    if ChanceClass.new(OptionPool, Genetics.MutationChance):Choose() ~= "Yes" then
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
end]]

return PlantUtilServer :: Module
