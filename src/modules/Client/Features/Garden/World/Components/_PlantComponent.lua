--[=[
    @class Plant
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Maid = require("Maid")
local GardenTypesClient = require("GardenTypesClient")
local ReactiveItemTypes = require("ReactiveItemTypes")
local AssetProvider = require("AssetProvider")
local Rx = require("Rx")
local PlantUtil = require("PlantUtil")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --
local function SetupPlantModel(plantModel: Model, slotModel: GardenTypesClient.SlotModel)
    plantModel.Parent = slotModel
    plantModel:PivotTo(slotModel.PlantSpawnPoint.WorldCFrame * CFrame.Angles(0, math.rad(math.random(0,360)), 0))

    return plantModel
end

-- [ Module Table ] --
local PlantComponent = function(props: Props)
    local MaidObject = Maid.new()
    local Plant = props.Plant
    local StageMaid = MaidObject:Add(Maid.new())
    
    MaidObject:Add(props.Plant.GrowthTime:Observe():Pipe({
        Rx.map(function(growthTime: number)
            return PlantUtil:GetCurrentGrowthStage(Plant.Name, growthTime)
        end) :: any,
        Rx.distinct() :: any,
    }):Subscribe(function(growthStage: number)
        StageMaid:DoCleaning()

        StageMaid:Add(SetupPlantModel(AssetProvider:Get("Objects/Plants/" .. Plant.Name .. "/" .. tostring(growthStage)), props.SlotModel))
    end))

    return MaidObject
end

-- [ Types ] --
type Props = {
    Plant: ReactiveItemTypes.ReactivePlantItem,
    SlotModel: GardenTypesClient.SlotModel,
}
type ModuleData = {}

export type Module = typeof(PlantComponent) & ModuleData

return PlantComponent :: Module