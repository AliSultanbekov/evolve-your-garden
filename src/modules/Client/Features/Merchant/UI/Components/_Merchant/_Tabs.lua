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
local RefreshTime = require(script.Parent._RefreshTime)

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
        Position = UDim2.fromOffset(0, 92);
        Size = UDim2.fromOffset(1078, 558);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = 5;
        Blend.New "ImageLabel" {
            Name = "GridBackground";
            Position = UDim2.fromOffset(10, 10);
            Size = UDim2.fromOffset(1058, 538);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            Image = "rbxassetid://126492638317587";
            ScaleType = Enum.ScaleType.Fit;
        };
        Blend.New "Frame" {
            Name = "Sell";
            Visible = Blend.Computed(props.ActiveTab, function(activeTab: string)
                if activeTab == "Sell" then
                    return true
                end

                return false
            end);
            LayoutOrder = 1;
            Size = UDim2.fromOffset(1078, 558);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            ZIndex = 2;
            ItemsGridComponent({
                Position = UDim2.fromOffset(14, 18);
                Size = UDim2.fromOffset(1050, 530);
                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                ScrollingDirection = Enum.ScrollingDirection.Y;
                BackgroundTransparency = 1;
                ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255);
                ScrollBarImageTransparency = 0.5;
                ScrollBarThickness = 4;
                ZIndex = 2;
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
                OnItemPressed = function(item: ReactiveItemTypes.ReactiveItem)
                    -- Sell the whole stack; the server validates sellability/amount.
                    local Stackable = item :: ReactiveItemTypes.ReactiveStackableItem

                    props.Sell(item.Id, Stackable.Amount.Value)
                end;
                OnItemHovered = function()

                end;
                OnItemUnhovered = function()

                end;
            })
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
            Size = UDim2.fromOffset(1078, 558);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            ZIndex = 3;
            Blend.New "CanvasGroup" {
                Name = "Canvas";
                Position = UDim2.fromOffset(14, 14);
                Size = UDim2.fromOffset(1050, 530);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                Blend.New "ScrollingFrame" {
                    Name = "Grid";
                    Size = UDim2.fromOffset(1050, 530);
                    AutomaticCanvasSize = Enum.AutomaticSize.X;
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    CanvasSize = UDim2.new(0, 0, 0, 0);
                    ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255);
                    ScrollBarImageTransparency = 0.5;
                    ScrollBarThickness = 4;
                    ScrollingDirection = Enum.ScrollingDirection.X;
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
            RefreshTime({
                Position = UDim2.new(0.5, 0, 0, 480);
                AnchorPoint = Vector2.new(0.5, 0);
                Size = UDim2.fromOffset(400, 40);
                ZIndex = 2;
                LastRefresh = props.LastRefresh;
            });
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
    Sell: (itemId: string, amount: number) -> (),
}
type ModuleData = {}

export type Module = typeof(Tabs) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Tabs :: Module