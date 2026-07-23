--[=[
    @class ItemsGrid
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local ReactiveItemTypes = require("ReactiveItemTypes")
local Observable = require("Observable")
local ComponentTypes = require("ComponentTypes")
local Rx = require("Rx")
local BackingPool = require("BackingPool")
local Maid = require("Maid")
local Brio = require("Brio")

-- [ Components ] --
local ItemCardComponent = require("ItemCardComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local ItemsGridComponent = function(props: Props)
    local MaidObject = Maid.new()
    local Items = props.Items

    local Order = Rx.combineLatest({
        Keys = Items:ObserveKeyList(),
        Search = props.Search
    }):Pipe({
        Rx.map(function(data)
            local Order = {}

            for _, id in data.Keys do
                local Item = Items:Get(id)

                if not Item then
                    continue
                end

                local Matches = data.Search == "" or string.find(Item.Name:lower(), data.Search:lower(), 1, true)

                if Matches then
                    table.insert(Order, id)
                end
            end

            table.sort(Order)
            return Order
        end) :: any,
        Rx.shareReplay(1) :: any,
    })
    return Blend.New "CanvasGroup" {
        Name = "Canvas";
        Position = props.Position;
        Size = props.Size;
        BackgroundTransparency = 1;
        ZIndex = props.ZIndex;
        Blend.New "ScrollingFrame" {
            Name = "Grid";
            Size = UDim2.fromScale(1, 1);
            ScrollBarImageColor3 = props.ScrollBarImageColor3;
            ScrollBarImageTransparency = props.ScrollBarImageTransparency;
            ScrollBarThickness = props.ScrollBarThickness;
            ScrollingDirection = props.ScrollingDirection;
            BackgroundTransparency = 1,
            AutomaticCanvasSize = props.AutomaticCanvasSize;
            [Blend.Instance] = function(instance)
                local BackingPoolObj = MaidObject:Add(BackingPool.new({
                    Parent = instance
                }))
    
                MaidObject:Add(Items:ObserveCount():Subscribe(function(count: number)
                    BackingPoolObj:Ensure(count)
                end))
    
                MaidObject:Add(Items:ObserveValuesBrio():Subscribe(function(brio: Brio.Brio<ReactiveItemTypes.ReactiveItem>)
                    local ItemMaid, Item = brio:ToMaidAndValue()
    
                    local Backing = (Order :: any):Pipe({
                        Rx.map(function(order)
                            return table.find(order, Item.Id)
                        end),
                        Rx.distinct() :: any,
                        Rx.map(function(index)
                            return BackingPoolObj:GetBacking(index)
                        end) :: any
                    })
                    
                    ItemMaid:Add(ItemCardComponent({
                        Item = Item;
                        Parent = Backing;
                        OnItemPressed = props.OnItemPressed,
                        OnItemHovered = props.OnItemHovered,
                        OnItemUnhovered = props.OnItemUnhovered,
                    }):Subscribe(function()  end))
                end))
            end,
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
                    FillDirection = props.UIGridLayoutSizes.FillDirection;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                };
            },
            [Blend.OnEvent "Destroying"] = function()
                MaidObject:DoCleaning()
            end
        }
    }
end

-- [ Types ] --
type Props = {
    Size: ComponentTypes.Prop<UDim2>?,
    Position: ComponentTypes.Prop<UDim2>?,
    AnchorPoint: ComponentTypes.Prop<Vector2>?,
    ZIndex: ComponentTypes.Prop<number>?,
    AutomaticCanvasSize: ComponentTypes.Prop<Enum.AutomaticSize>?,
    ScrollingDirection: ComponentTypes.Prop<Enum.ScrollingDirection>?,
    ScrollBarImageColor3: ComponentTypes.Prop<Color3>?,
    ScrollBarImageTransparency: ComponentTypes.Prop<number>?,
    ScrollBarThickness: ComponentTypes.Prop<number>?,
    UIPaddingSizes: {
        PaddingTop: UDim,
        PaddingBottom: UDim,
        PaddingLeft: UDim,
        PaddingRight: UDim,
    },
    UIGridLayoutSizes: {
        CellPadding: UDim2;
        CellSize: UDim2;
        FillDirection: Enum.FillDirection?;
    },
    Items: ReactiveItemTypes.ReactiveItems,
    Search: Observable.Observable<string>,
    OnItemPressed: (item: ReactiveItemTypes.ReactiveItem, position: UDim2) -> (),
    OnItemHovered: (item: ReactiveItemTypes.ReactiveItem, position: UDim2) -> (),
    OnItemUnhovered: (item: ReactiveItemTypes.ReactiveItem) -> (),
}
type ItemsGridComponentModuleData = {}

export type Module = typeof(ItemsGridComponent) & ItemsGridComponentModuleData

return ItemsGridComponent :: Module