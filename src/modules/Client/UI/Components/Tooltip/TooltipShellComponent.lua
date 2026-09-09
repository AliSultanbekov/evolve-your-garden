--[=[
    @class TooltipShellComponent

    The shared shell every item/plant tooltip is built from: derives
    DisplayItem (non-nil stream) and IsOpen from a nilable item observable,
    renders the animated 256-wide frame with Background, Top header and the
    plant stats section. `Content` injects extra elements (e.g. action
    buttons) between the header and the stats; each child positions itself
    via its own LayoutOrder.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")
local ReactiveItemTypes = require("ReactiveItemTypes")
local Rx = require("Rx")

-- [ Components ] --
local AnimatedFrameComponent = require("AnimatedFrameComponent")
local TooltipBackgroundComponent = require("TooltipBackgroundComponent")
local TooltipTopComponent = require("TooltipTopComponent")
local TooltipPlantStatsComponent = require("TooltipPlantStatsComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local TooltipShellComponent = function(props: Props)
    local DisplayItem: Observable.Observable<ReactiveItemTypes.ReactiveItem> = props.Item:Pipe({
        Rx.where(function(item) return item ~= nil end) :: any,
    }) :: any

    local IsOpen: Observable.Observable<boolean> = props.Item:Pipe({
        Rx.map(function(item)
            return item ~= nil
        end) :: any
    }) :: any

    local ContainerChildren: { any } = {
        Blend.New "UIListLayout" {
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        };
        Blend.New "UIPadding" {
            PaddingBottom = UDim.new(0, props.PaddingBottom or 3)
        };
        TooltipTopComponent({
            Item = DisplayItem,
            AnimateEffects = IsOpen,
            Image = props.TopImage,
            RaysImage = props.RaysImage,
        });
        TooltipPlantStatsComponent({
            Item = DisplayItem :: any,
        });
    }

    if props.Content then
        local Children = props.Content(DisplayItem, IsOpen)

        for _, child in Children do
            table.insert(ContainerChildren, child)
        end
    end

    return AnimatedFrameComponent({
        Name = "Tooltip";
        ApplyDeviceScale = true;
        Position = props.Position;
        AnchorPoint = props.AnchorPoint or Vector2.new(0, 0.5);
        Size = UDim2.fromOffset(256, 0);
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundTransparency = 1;
        IsOpen = IsOpen;
        ZIndex = 100,
        Children = {
            TooltipBackgroundComponent();
            Blend.New "Frame" {
                Name = "Container";
                Position = UDim2.fromScale(0.5, 0);
                AnchorPoint = Vector2.new(0.5, 0);
                Size = UDim2.fromScale(1, 0);
                AutomaticSize = Enum.AutomaticSize.Y;
                BackgroundTransparency = 1;
                [Blend.Children] = ContainerChildren;
            }
        }
    })
end

-- [ Types ] --
type Props = {
    Item: Observable.Observable<ReactiveItemTypes.ReactiveItem?>,
    Position: Observable.Observable<UDim2>,
    AnchorPoint: Vector2?,
    PaddingBottom: number?,
    TopImage: string?,
    RaysImage: string?,
    Content: ((displayItem: Observable.Observable<ReactiveItemTypes.ReactiveItem>, isOpen: Observable.Observable<boolean>) -> { any })?,
}
type ModuleData = {}

export type Module = typeof(TooltipShellComponent) & ModuleData

return TooltipShellComponent :: Module
