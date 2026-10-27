--[=[
    @class SlotComponent
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Maid = require("Maid")
local GardenTypesClient = require("GardenTypesClient")
local AssetProvider = require("AssetProvider")
local ReactiveItemTypes = require("ReactiveItemTypes")
local Observable = require("Observable")

-- [ Components ] --
local PlantComponent = require(script.Parent._PlantComponent)

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --
local function SetupSlotModel(
    slotModel: GardenTypesClient.SlotModel, 
    gardenModel: GardenTypesClient.GardenModel,
    slotCFrame: CFrame
)
    slotModel.Parent = gardenModel
    slotModel:PivotTo(slotCFrame)

    return slotModel
end

-- [ Module Table ] --
local SlotComponent = function(props: Props)
    local MaidObject = Maid.new()
    local PlantMaid = MaidObject:Add(Maid.new())

    local SlotModel = MaidObject:Add(
        SetupSlotModel(
            AssetProvider:Get("Objects/Garden/Slot"), 
            props.GardenModel,
            props.SlotCFrame
        )
    )

    MaidObject:Add(function()
        props.OnSlotDestroyed(SlotModel)
    end)

    props.OnSlotCreated(SlotModel)

    MaidObject:Add(props.Slot.Plant:Observe():Subscribe(function(plant: ReactiveItemTypes.ReactivePlantItem?)
        PlantMaid:DoCleaning()

        if not plant then
            return
        end

        PlantMaid:Add(PlantComponent({
            Plant = plant,
            SlotModel = SlotModel,
            IsSlotSelected = props.IsSlotSelected,
            SlotPressed = props.SlotPressed,
            PlantWatered = props.PlantWatered,
        }))
    end))

    return MaidObject
end

-- [ Types ] --
type Props = {
    Slot: GardenTypesClient.ReactiveSlot,
    SlotCFrame: CFrame,
    GardenModel: GardenTypesClient.GardenModel,
    IsSlotSelected: Observable.Observable<boolean>,
    SlotPressed: Observable.Observable<GardenTypesClient.SlotInfo>,
    PlantWatered: Observable.Observable<nil>,

    OnSlotCreated: (slotModel: GardenTypesClient.SlotModel) -> (),
    OnSlotDestroyed: (slotModel: GardenTypesClient.SlotModel) -> (),
}
type ModuleData = {}

export type Module = typeof(SlotComponent) & ModuleData

return SlotComponent :: Module