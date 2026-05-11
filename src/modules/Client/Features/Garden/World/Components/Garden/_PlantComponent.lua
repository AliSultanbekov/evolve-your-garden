--[=[
    @class PlantComponent
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Maid = require("Maid")
local GardenTypesClient = require("GardenTypesClient")
local ReactiveItemTypes = require("ReactiveItemTypes")
local AssetProvider = require("AssetProvider")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local PlantComponent = function(props: Props)
    local MaidObject = Maid.new()
    local Plant = props.Plant
    local SlotModel = props.SlotModel

    local function SetupPlantModel(plantModel: Model)
        plantModel.Name = Plant.Name
        plantModel.Parent = SlotModel
        plantModel:PivotTo(SlotModel.PlantSpawnPoint.WorldCFrame)

        return plantModel
    end

    local _PlantModel = MaidObject:Add(SetupPlantModel(AssetProvider:Get("Objects/Items/Snow Blossom")))

    return MaidObject
end

-- [ Types ] --
type Props = {
    Plant: ReactiveItemTypes.ReactivePlantItem,
    SlotModel: GardenTypesClient.SlotModel,
}
type ModuleData = {}

export type Module = typeof(PlantComponent) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return PlantComponent :: Module