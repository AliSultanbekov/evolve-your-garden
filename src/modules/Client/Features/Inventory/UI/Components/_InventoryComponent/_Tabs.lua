--[=[
    @class Tabs
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local ReactiveItemTypes = require("ReactiveItemTypes")
local Observable = require("Observable")
local ComponentTypes = require("ComponentTypes")
local InventoryConfigClient = require("InventoryConfigClient")

-- [ Components ] --
local ItemsGridComponent = require("ItemsGridComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --
local function TabContent(tabName: string, props: Props)
    return Blend.New "Frame" {
        Name = tabName;
        Size = UDim2.fromScale(1, 1);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        Visible = Blend.Computed(props.ActiveTab, function(activeTab: string)
            return activeTab == tabName
        end);
        
        Blend.New "ImageLabel" {
            Name = "GridBackground";
            Position = UDim2.fromOffset(10, 10);
            Size = UDim2.fromOffset(1058, 536);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            Image = "rbxassetid://102015862917082";
            ScaleType = Enum.ScaleType.Fit;
        };
        Blend.New "CanvasGroup" {
            Name = "Canvas";
            Position = UDim2.fromOffset(13, 13);
            Size = UDim2.fromOffset(1052, 530);
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
                Items = props.GetItems(tabName);
                Search = props.Search;
                OnItemPressed = props.OnItemPressed;
                OnItemHovered = props.OnItemHovered;
                OnItemUnhovered = props.OnItemUnhovered;
            })
        }
    }
end

-- [ Module Table ] --
local Tabs = function(props: Props)
    local Children = {}

    for tabName, _ in InventoryConfigClient.TabsConfig do
        table.insert(Children, TabContent(tabName, props))
    end

    return Blend.New "Frame" {
        Name = "Tab";
        LayoutOrder = 5;
        Position = UDim2.fromOffset(4, 95);
        Size = UDim2.fromOffset(1078, 558);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = 6;
        Children
    }
end

-- [ Types ] --
type Props = {
    ActiveTab: ComponentTypes.Prop<string>,
    Search: Observable.Observable<string>,
    GetItems: (filter: string?) -> ReactiveItemTypes.ReactiveItems,
    OnItemPressed: (item: ReactiveItemTypes.ReactiveItem) -> (),
    OnItemHovered: (item: ReactiveItemTypes.ReactiveItem) -> (),
    OnItemUnhovered: (item: ReactiveItemTypes.ReactiveItem) -> (),
}
type ModuleData = {}

export type Module = typeof(Tabs) & ModuleData

return Tabs :: Module
