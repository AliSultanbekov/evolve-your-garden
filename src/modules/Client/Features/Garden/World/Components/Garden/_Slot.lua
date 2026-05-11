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

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local SlotComponent = function(props: Props)
    local MaidObject = Maid.new()
    local MouseServiceClient = props.MouseServiceClient
    local Garden = props.Garden
    local Slot = props.Slot
    local SlotID = Slot.Id

    local function SetupSlot(slotModel: GardenTypesClient.SlotModel)
        slotModel.Name = SlotID
        slotModel:PivotTo(props.SlotCFrame)
        slotModel.Parent = workspace.World.Gardens[Garden.GardenId]

        return slotModel
    end

    local SlotModel = MaidObject:Add(SetupSlot(AssetProvider:Get("Objects/Garden/Slot")))

    local Highlight = Instance.new("Highlight")
    Highlight.Adornee = SlotModel
    Highlight.FillColor = Color3.fromRGB(255, 220, 100)
    Highlight.OutlineColor = Color3.fromRGB(255, 200, 0)
    Highlight.FillTransparency = 0.5
    Highlight.Enabled = false
    Highlight.Parent = SlotModel
    MaidObject:Add(Highlight)
    
    MaidObject:Add(MouseServiceClient:ObserveIsHovering(SlotModel):Subscribe(function(hovering: boolean)
        Highlight.Enabled = hovering
    end))

    MaidObject:Add(MouseServiceClient:ObserveOnClick(SlotModel):Subscribe(function()
        props.OnSlotSelected(SlotID)
    end))

    MaidObject:Add(Slot.Plant:Observe():Subscribe(function(plant: ReactiveItemTypes.ReactivePlantItem?)
        
    end))

    return MaidObject
end

-- [ Types ] --
type Props = {
    MouseServiceClient: typeof(require("MouseServiceClient")),

    Garden: GardenTypesClient.ReactiveGarden,
    Slot: GardenTypesClient.ReactiveSlot,
    SlotCFrame: CFrame,

    OnSlotSelected: (slotId: GardenTypesShared.SlotId) -> (),
}
type ModuleData = {}

export type Module = typeof(SlotComponent) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return SlotComponent :: Module