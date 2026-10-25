--[=[
    @class ToolbarComponent

    The bottom-center hotbar: one Slot per ToolbarConfig.SlotOrder entry.
    Pure view - state comes in through props from ToolbarServiceClient.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local ToolbarConfig = require("ToolbarConfig")
local ToolbarTypesShared = require("ToolbarTypesShared")
local ReactiveItemTypes = require("ReactiveItemTypes")
local Observable = require("Observable")

-- [ Components ] --
local AnimatedFrameComponent = require("AnimatedFrameComponent")
local Slot = require(script._Slot)

-- [ Constants ] --
local SLOT_SIZE = 100
local SLOT_GAP = 5
local FRAME_PADDING = 5

-- [ Variables ] --

-- [ Module Table ] --
local ToolbarComponent = function(props: Props)
    local Slots = {}

    for layoutOrder, slotId in ToolbarConfig.SlotOrder do
        table.insert(Slots, Slot({
            SlotId = slotId,
            LayoutOrder = layoutOrder,
            Size = SLOT_SIZE,
            ObserveItem = function()
                return props.ObserveItemFromSlotId(slotId)
            end,
            ObserveEquippedSlotId = props.ObserveEquippedSlotId,
            IsInventoryOpen = props.IsInventoryOpen,
            InventorySelectedItem = props.InventorySelectedItem,
            OnPressed = props.OnSlotPressed,
        }))
    end

    return AnimatedFrameComponent({
        Name = "Toolbar";
        AnchorPoint = Vector2.new(0.5, 1);
        Position = UDim2.new(0.5, 0, 1, -10);
        Size = UDim2.fromOffset(
            ToolbarConfig.SlotCount * SLOT_SIZE + (ToolbarConfig.SlotCount - 1) * SLOT_GAP + 2 * FRAME_PADDING,
            SLOT_SIZE
        );
        BackgroundTransparency = 1;
        ApplyDeviceScale = true;
        IsOpen = props.IsOpen;
        Children = {
            Blend.New "UIPadding" {
                PaddingBottom = UDim.new(0, 5);
                PaddingLeft = UDim.new(0, 5);
                PaddingRight = UDim.new(0, 5);
                PaddingTop = UDim.new(0, 5);
            };
            Blend.New "UIListLayout" {
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                VerticalAlignment = Enum.VerticalAlignment.Center;
                Padding = UDim.new(0, SLOT_GAP);
                SortOrder = Enum.SortOrder.LayoutOrder;
            };
            Slots :: any;
        };
    })
end

-- [ Types ] --
type Props = {
    IsOpen: Observable.Observable<boolean>,
    IsInventoryOpen: Observable.Observable<boolean>,
    InventorySelectedItem: Observable.Observable<ReactiveItemTypes.ReactiveItem?>,
    ObserveItemFromSlotId: (slotId: ToolbarTypesShared.SlotId) -> Observable.Observable<ReactiveItemTypes.ReactiveItem?>,
    ObserveEquippedSlotId: Observable.Observable<ToolbarTypesShared.SlotId?>,
    OnSlotPressed: (slotId: ToolbarTypesShared.SlotId) -> (),
}
type ModuleData = {}

export type Module = typeof(ToolbarComponent) & ModuleData

return ToolbarComponent :: Module
