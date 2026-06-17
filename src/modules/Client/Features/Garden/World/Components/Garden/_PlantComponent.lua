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
local ValueObject = require("ValueObject")
local Rx = require("Rx")
local PlantsConfig = require("PlantsConfig")
local VFXClass = require("VFXClass")
local VFXContainer = require("VFXContainer")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local PlantComponent = function(props: Props)
    local MaidObject = Maid.new()
    local Plant = props.Plant
    local GrowthStage = ValueObject.new(0)

    MaidObject:Add(Plant.GrowthTime:Observe():Subscribe(function(growthTime: number)
        GrowthStage.Value = PlantsConfig:GetCurrentGrowthStage(Plant.Name, growthTime)
    end))

    local StageMaid = MaidObject:Add(Maid.new())
    local IsFirstStage = true

    MaidObject:Add(GrowthStage:Observe():Subscribe(function(growthStage: number)
        StageMaid:DoCleaning()

        local IsGrowthChange = not IsFirstStage
        IsFirstStage = false

        local PlantModel = StageMaid:Add(AssetProvider:Get("Objects/Plants/" .. Plant.Name .. "/" .. tostring(growthStage))) :: Model
        PlantModel.Parent = workspace
        PlantModel:PivotTo(props.SlotModel.PlantSpawnPoint.WorldCFrame)

        if IsGrowthChange then
            local VFXObject = StageMaid:Add(VFXClass.new({"VFX/PlantStage"}, props.SlotModel.PlantSpawnPoint))

            VFXObject:SetEnabled(true)

            StageMaid:Add(task.delay(3, function()
                VFXObject:SetEnabled(false)
            end))
        end
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