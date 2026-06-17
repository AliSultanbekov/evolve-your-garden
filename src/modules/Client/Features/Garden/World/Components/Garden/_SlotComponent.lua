--[=[
    @class Slot
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Maid = require("Maid")
local GardenTypesShared = require("GardenTypesShared")
local GardenTypesClient = require("GardenTypesClient")
local ReactiveItemTypes = require("ReactiveItemTypes")
local AssetProvider = require("AssetProvider")
local Observable = require("Observable")
local Rx = require("Rx")
local ValueObject = require("ValueObject")

-- [ Components ] --
local HighlightComponent = require("HighlightComponent")
local PlantComponent = require(script.Parent._PlantComponent)

-- [ Constants ] --
local HOVER_FILL_COLOR = Color3.new(1, 1, 1)
local HOVER_OUTLINE_COLOR = Color3.new(1, 1, 1)

local SELECTED_FILL_COLOR = Color3.new(1, 0.694118, 0.207843)
local SELECTED_OUTLINE_COLOR = Color3.new(1, 0.694118, 0.207843)

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local SlotComponent = function(props: Props)
    local MaidObject = Maid.new()
    local PlantMaid = MaidObject:Add(Maid.new())
    local MouseServiceClient = props.MouseServiceClient
    local Slot = props.Slot
    local SlotID = Slot.Id

    local function SetupSlot(slotModel: GardenTypesClient.SlotModel)
        slotModel.Name = SlotID
        slotModel:PivotTo(props.SlotCFrame)
        slotModel.Parent = props.GardenModel.Slots

        return slotModel
    end

    local SlotModel = MaidObject:Add(SetupSlot(AssetProvider:Get("Objects/Garden/Slot")))
    
    props.OnSlotCreated(SlotID, SlotModel)

    MaidObject:Add(function()
        props.OnSlotDestroyed(SlotID)
    end)

    MaidObject:Add(MouseServiceClient:ObserveIsHovering(SlotModel):Subscribe(function(isHovering: boolean)
        if isHovering then
            props.OnSlotHovered(SlotID)
        else
            props.OnSlotUnhovered(SlotID)
        end
    end))

    local HighlightEnabled = ValueObject.new(false)
    local HighlightFillColor = ValueObject.new(HOVER_FILL_COLOR)
    local HighlightOutlineColor = ValueObject.new(HOVER_OUTLINE_COLOR)

    MaidObject:Add(Rx.combineLatest({
        IsHovering = MouseServiceClient:ObserveIsHovering(SlotModel),
        SelectedSlot = props.SelectedSlot
    }):Subscribe(function(data)
        local IsSelected = data.SelectedSlot == SlotID

        HighlightEnabled.Value = IsSelected or data.IsHovering
        HighlightFillColor.Value = if IsSelected then SELECTED_FILL_COLOR else HOVER_FILL_COLOR
        HighlightOutlineColor.Value = if IsSelected then SELECTED_OUTLINE_COLOR else HOVER_OUTLINE_COLOR
    end))

    MaidObject:Add(HighlightComponent({
        Enabled = HighlightEnabled:Observe();
        Adornee = SlotModel;
        FillColor = HighlightFillColor:Observe();
        FillTransparency = 0.8;
        OutlineColor = HighlightOutlineColor:Observe();
        OutlineTransparency = 0.8;
    }):Subscribe())

    MaidObject:Add(MouseServiceClient:ObserveOnClick(SlotModel):Subscribe(function()
        props.OnSlotSelected(SlotID)
    end))

    MaidObject:Add(Slot.Plant:Observe():Subscribe(function(plant: ReactiveItemTypes.ReactivePlantItem?)
        PlantMaid:DoCleaning()

        if not plant then
            return
        end

        PlantMaid:Add(PlantComponent({
            Plant = plant;
            SlotModel = SlotModel
        }))
    end))

    return MaidObject
end

-- [ Types ] --
type Props = {
    MouseServiceClient: typeof(require("MouseServiceClient")),

    Garden: GardenTypesClient.ReactiveGarden,
    GardenModel: GardenTypesClient.GardenModel,
    Slot: GardenTypesClient.ReactiveSlot,
    SlotCFrame: CFrame,
    SelectedSlot: Observable.Observable<GardenTypesShared.SlotId?>,

    OnSlotHovered: (slotId: GardenTypesShared.SlotId) -> (),
    OnSlotUnhovered: (slotId: GardenTypesShared.SlotId) -> (),
    OnSlotSelected: (slotId: GardenTypesShared.SlotId) -> (),
    OnSlotCreated: (slotId: GardenTypesShared.SlotId, slotModel: GardenTypesClient.SlotModel) -> (),
    OnSlotDestroyed: (slotId: GardenTypesShared.SlotId) -> (),
}
type ModuleData = {}

export type Module = typeof(SlotComponent) & ModuleData

return SlotComponent :: Module