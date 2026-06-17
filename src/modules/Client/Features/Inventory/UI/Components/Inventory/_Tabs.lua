--[=[
    @class Tabs
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local InventoryTypesClient = require("InventoryTypesClient")
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
            Position = UDim2.fromOffset(10, 14);
            Size = UDim2.fromOffset(1058, 538);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            Image = "rbxassetid://133446100786000";
            ScaleType = Enum.ScaleType.Fit;
        };
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
            Items = props.GetItems(tabName);
            Search = props.Search;
            OnItemPressed = props.OnItemPressed;
            OnItemHovered = props.OnItemHovered;
            OnItemUnhovered = props.OnItemUnhovered;
        })
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
        Position = UDim2.fromOffset(141, 88);
        Size = UDim2.fromOffset(1078, 562);
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
    GetItems: (filter: string?) -> InventoryTypesClient.Items,
    OnItemPressed: (item: ReactiveItemTypes.ReactiveItem, position: UDim2) -> (),
    OnItemHovered: (item: ReactiveItemTypes.ReactiveItem, position: UDim2) -> (),
    OnItemUnhovered: () -> (),
}
type ModuleData = {}

export type Module = typeof(Tabs) & ModuleData

return Tabs :: Module
