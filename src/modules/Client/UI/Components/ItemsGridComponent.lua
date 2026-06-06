--[=[
    @class ItemsGrid
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local ReactiveItemTypes = require("ReactiveItemTypes")
local ObservableMap = require("ObservableMap")
local ItemTypes = require("ItemTypes")
local RxBrioUtils = require("RxBrioUtils")
local Observable = require("Observable")
local Rx = require("Rx")

-- [ Components ] --
local ItemCardComponent = require("ItemCardComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local ItemsGridComponent = function(props: Props)
    local Items = props.Items
    local ItemCards = Items:ObserveValuesBrio():Pipe({
        RxBrioUtils.map(function(item: ReactiveItemTypes.ReactiveItem)
            return ItemCardComponent({
                Visible = (props.Search :: any):Pipe({
                    Rx.map(function(search: string)
                        if search == "" then return true end
                        return string.find(item.Name:lower(), search:lower(), 1, true) ~= nil
                    end)
                });
                Item = item,
                OnItemPressed = props.OnItemPressed,
                OnItemHovered = props.OnItemHovered,
                OnItemUnhovered = props.OnItemUnhovered,
            })
        end) :: any
    })

    return Blend.New "ScrollingFrame" {
        Size = props.Size;
        Position = props.Position;
        AnchorPoint = props.AnchorPoint;
        ZIndex = props.ZIndex;
        BackgroundTransparency = props.BackgroundTransparency,
        AutomaticCanvasSize = props.AutomaticCanvasSize;
        [Blend.Children] = {
            Blend.New "UIPadding" {
                PaddingTop = props.UIPaddingSizes.PaddingTop;
                PaddingBottom = props.UIPaddingSizes.PaddingBottom;
                PaddingLeft = props.UIPaddingSizes.PaddingLeft;
                PaddingRight = props.UIPaddingSizes.PaddingRight;
            };
            Blend.New "UIGridLayout" {
                CellPadding = props.UIGridLayoutSizes.CellPadding;
                CellSize = props.UIGridLayoutSizes.CellSize;
            };
            ItemCards :: any;
        }
    }
end

-- [ Types ] --
type Props = {
    Size: UDim2?,
    Position: UDim2?,
    AnchorPoint: Vector2?,
    ZIndex: number?,
    BackgroundTransparency: number?,
    AutomaticCanvasSize: Enum.AutomaticSize?,
    UIPaddingSizes: {
        PaddingTop: UDim,
        PaddingBottom: UDim,
        PaddingLeft: UDim,
        PaddingRight: UDim,
    },
    UIGridLayoutSizes: {
        CellPadding: UDim2;
        CellSize: UDim2;
    },

    Items: ObservableMap.ObservableMap<ItemTypes.ItemId, ReactiveItemTypes.ReactiveItem>,
    Search: Observable.Observable<string>,
    OnItemPressed: (item: ReactiveItemTypes.ReactiveItem, position: UDim2) -> (),
    OnItemHovered: (item: ReactiveItemTypes.ReactiveItem, position: UDim2) -> (),
    OnItemUnhovered: () -> (),
}
type ModuleData = {}

export type Module = typeof(ItemsGridComponent) & ModuleData

return ItemsGridComponent :: Module