--[=[
    @class Tabs
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")
local ReactiveItemTypes = require("ReactiveItemTypes")
local MerchantTypesClient = require("MerchantTypesClient")

-- [ Components ] --
local ItemsGridComponent = require("ItemsGridComponent")
local BuySlot = require(script.Parent._BuySlot)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Tabs = function(props: Props)
    local BuySlots = Blend.ComputedPairs(props.BuySlots, function(_, slot: MerchantTypesClient.ReactiveSlot)
        return BuySlot({
            Slot = slot,
            Buy = props.Buy,
        })
    end)
    
    return Blend.New "Frame" {
        Name = "Tabs";
        LayoutOrder = 4;
        Position = UDim2.fromOffset(4, 95);
        Size = UDim2.fromOffset(1077, 556);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = 4;
        Blend.New "Frame" {
            Name = "Sell";
            Visible = Blend.Computed(props.ActiveTab, function(activeTab: string)
                if activeTab == "Sell" then
                    return true
                end

                return false
            end);
            LayoutOrder = 1;
            Size = UDim2.fromOffset(1077, 556);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            ZIndex = 2;
            Blend.New "ImageLabel" {
                Name = "Background";
                Position = UDim2.fromOffset(10, 10);
                Size = UDim2.fromOffset(1056, 536);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                Image = "rbxassetid://130311441656394";
            };
            Blend.New "CanvasGroup" {
                Name = "Canvas";
                Position = UDim2.fromOffset(13, 13);
                Size = UDim2.fromOffset(1050, 530);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                ZIndex = 2;
                ItemsGridComponent({
                    Size = UDim2.fromScale(1, 1);
                    AutomaticCanvasSize = Enum.AutomaticSize.Y;
                    ScrollingDirection = Enum.ScrollingDirection.Y;
                    BackgroundTransparency = 1;
                    ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255);
                    ScrollBarImageTransparency = 0.5;
                    ScrollBarThickness = 4;
                    UIPaddingSizes = {
                        PaddingTop = UDim.new(0, 10),
                        PaddingBottom = UDim.new(0, 10),
                        PaddingLeft = UDim.new(0, 10),
                        PaddingRight = UDim.new(0, 10),
                    };
                    UIGridLayoutSizes = {
                        CellPadding = UDim2.fromOffset(10, 10),
                        CellSize = UDim2.fromOffset(120, 120),
                        FillDirection = Enum.FillDirection.Horizontal,
                    };
                    Items = props.Items,
                    Search = props.Search;
                    OnItemPressed = props.ItemPressed;
                    OnItemHovered = props.ItemHovered;
                    OnItemUnhovered = props.ItemUnhovered;
                })
            };
        };
        Blend.New "Frame" {
            Name = "Buy";
            Visible = Blend.Computed(props.ActiveTab, function(activeTab: string)
                if activeTab == "Buy" then
                    return true
                end

                return false
            end);
            LayoutOrder = 2;
            Size = UDim2.fromOffset(1077, 556);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            ZIndex = 3;
            Blend.New "ImageLabel" {
                Name = "Background";
                Position = UDim2.fromOffset(10, 10);
                Size = UDim2.fromOffset(1056, 536);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                Image = "rbxassetid://130311441656394";
            };
            Blend.New "CanvasGroup" {
                Name = "Canvas";
                Position = UDim2.fromOffset(13, 13);
                Size = UDim2.fromOffset(1050, 530);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                ZIndex = 2;
                Blend.New "ScrollingFrame" {
                    Name = "Grid";
                    Size = UDim2.fromScale(1, 1);
                    AutomaticCanvasSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    CanvasSize = UDim2.new(0, 0, 0, 0);
                    ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255);
                    ScrollBarImageTransparency = 0.5;
                    ScrollBarThickness = 4;
                    ScrollingDirection = Enum.ScrollingDirection.Y;
                    Blend.New "UIGridLayout" {
                        CellPadding = UDim2.fromOffset(10, 10);
                        CellSize = UDim2.fromOffset(198, 250);
                        SortOrder = Enum.SortOrder.LayoutOrder;
                    };
                    Blend.New "UIPadding" {
                        PaddingBottom = UDim.new(0, 10);
                        PaddingLeft = UDim.new(0, 10);
                        PaddingRight = UDim.new(0, 10);
                        PaddingTop = UDim.new(0, 10);
                    };
                    BuySlots;
                };
            };
        };
    }
end

-- [ Types ] --
type Props = {
    ActiveTab: Observable.Observable<string>,
    Items: ReactiveItemTypes.ReactiveItems,
    Search: Observable.Observable<string>,
    BuySlots: MerchantTypesClient.ReactiveSlots,
    LastRefresh: Observable.Observable<number?>,

    Buy: (slotId: string) -> (),
    ItemPressed: (item: ReactiveItemTypes.ReactiveItem, position: UDim2) -> (),
    ItemHovered: (item: ReactiveItemTypes.ReactiveItem) -> (),
    ItemUnhovered: (item: ReactiveItemTypes.ReactiveItem) -> (),
}
type ModuleData = {}

export type Module = typeof(Tabs) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Tabs :: Module