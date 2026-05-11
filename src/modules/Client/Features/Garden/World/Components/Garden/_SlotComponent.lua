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

-- [ Components ] --
local HighlightComponent = require("HighlightComponent")
local PlantComponent = require(script.Parent._PlantComponent)

-- [ Constants ] --

-- [ Variables ] --

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

    MaidObject:Add(HighlightComponent({
        Enabled = MouseServiceClient:ObserveIsHovering(SlotModel),
        Adornee = SlotModel,
        FillColor = Color3.fromRGB(245, 245, 245),
        FillTransparency = 0.8,
        OutlineColor = Color3.fromRGB(255, 255, 255),
        OutlineTransparency = 0.8,
    }))

    MaidObject:Add(MouseServiceClient:ObserveOnClick(SlotModel):Subscribe(function()
        props.OnSlotSelected(SlotID)
    end))

    MaidObject:Add(Slot.Plant:Observe():Subscribe(function(plant: ReactiveItemTypes.ReactivePlantItem?)
        PlantMaid:DoCleaning()

        if not plant then
            return
        end

        PlantMaid:Add(PlantComponent({
            Plant = plant,
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

    OnSlotSelected: (slotId: GardenTypesShared.SlotId) -> (),
}
type ModuleData = {}

export type Module = typeof(SlotComponent) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return SlotComponent :: Module