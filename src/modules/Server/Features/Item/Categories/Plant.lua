--[=[
    @class Plant
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")
local PlantsConfig = require("PlantsConfig")
local ChanceClass = require("ChanceClass")
local ItemUtil = require("ItemUtil")

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

    if GrowthTime <= item.LastProduction then
        return 0
    end

    local Delta = GrowthTime - item.LastProduction
    local Cycles = math.floor(Delta / Genetics.ProductionTime)

    if Cycles > 0 then
        local LeftOver = Delta % Genetics.ProductionTime
        item.LastProduction = GrowthTime - LeftOver
    end

    return Cycles
end

function Plant.Produce(self: Module, item: ItemTypes.PlantItem): { ItemTypes.RawItem }
    local PlantConfig = PlantsConfig[item.Name]
    local Genetics = PlantsConfig:GetGenetics(item.Name, item.GeneticNumber)

    local Amount = ChanceClass.new(
        PlantConfig.Production.AmountPool,
        Genetics.Luck.AmountProductionLuck,
        30
    ):Choose()

    local Items: { ItemTypes.RawItem } = table.create(Amount)

    for _ = 1, Amount do
        local Pool = {
            ["Yes"] = Genetics.BabyChance,
            ["No"] = 100 - Genetics.BabyChance,
        }

        local RawItem: ItemTypes.RawItem

        if ChanceClass.new(Pool):Choose() == "Yes" then
            local Baby: ItemTypes.RawPlantItem = {
                Name = item.Name,
                Category = "Plant",
                GeneticNumber = item.GeneticNumber,
            }

            RawItem = Baby
        else
            local ItemName = ChanceClass.new(
                PlantConfig.Production.ItemPool,
                Genetics.Luck.ItemProductionLuck,
                10
            ):Choose()

            RawItem = ItemUtil:MakeRawFromName(ItemName)
        end

        table.insert(Items, RawItem)
    end

    return Items
end

return Plant :: Module