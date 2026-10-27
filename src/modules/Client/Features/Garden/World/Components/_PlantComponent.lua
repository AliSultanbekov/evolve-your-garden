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
local PlantUtilShared = require("PlantUtilShared")
local VFXClass = require("VFXClass")
local VFXUtil = require("VFXUtil")
local Observable = require("Observable")
local ValueObject = require("ValueObject")
local SpringAnimationPresets = require("SpringAnimationPresets")

-- [ Components ] --
local ModelScaleSpring = require("ModelScaleSpring")

-- [ Constants ] --
local PRESS_SQUASH_SCALE = 0.85
local PRESS_SQUASH_TIME = 0.08

-- [ Variables ] --

-- [ Functions ] --
local function SetupPlantModel(plantModel: Model, slotModel: GardenTypesClient.SlotModel): Model
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
            return PlantUtilShared:GetCurrentGrowthStage(Plant.Name, growthTime)
        end) :: any,
        Rx.distinct() :: any,
    }):Subscribe(function(growthStage: number)
        StageMaid:DoCleaning()

        local PlantModel = StageMaid:Add(SetupPlantModel(AssetProvider:Get("Objects/Plants/" .. Plant.Name .. "/" .. tostring(growthStage)), props.SlotModel))
        local SmokeVFXInfo = VFXUtil:CreateVFXInfo("Plant/Smoke")
        local WateredVFXInfo = VFXUtil:CreateVFXInfo("Plant/Watered")
        local VFXObject = VFXClass.new({
            Container = VFXUtil:BasePartToVFXContainer("VFXContainer", workspace.World.VFX, PlantModel:WaitForChild("BoundingBox") :: any),
            VFXInfos = {
                [SmokeVFXInfo.VFXId] = SmokeVFXInfo,
                [WateredVFXInfo.VFXId] = WateredVFXInfo
            }
        })

        VFXObject:Emit("Id", SmokeVFXInfo.VFXId)

        local ScaleTarget = StageMaid:Add(ValueObject.new(1))

        StageMaid:Add(ModelScaleSpring({
            Model = PlantModel,
            Target = ScaleTarget:Observe(),
            Preset = SpringAnimationPresets.ModelPop,
        }))

        StageMaid:Add(props.PlantWatered:Subscribe(function()
            VFXObject:Emit("Id", WateredVFXInfo.VFXId)
        end))

        StageMaid:Add(props.SlotPressed:Subscribe(function()
            ScaleTarget.Value = PRESS_SQUASH_SCALE

            StageMaid.PressSquash = task.delay(PRESS_SQUASH_TIME, function()
                ScaleTarget.Value = 1
            end)
        end))
        StageMaid:Add(function()
            VFXObject:Emit("Id", SmokeVFXInfo.VFXId)

            task.delay(1, function()
                VFXObject:Destroy()
            end)
        end)
    end))

    return MaidObject
end

-- [ Types ] --
type Props = {
    Plant: ReactiveItemTypes.ReactivePlantItem,
    SlotModel: GardenTypesClient.SlotModel,
    IsSlotSelected: Observable.Observable<boolean>,
    SlotPressed: Observable.Observable<GardenTypesClient.SlotInfo>,
    PlantWatered: Observable.Observable<nil>,
}
type ModuleData = {}

export type Module = typeof(PlantComponent) & ModuleData

return PlantComponent :: Module