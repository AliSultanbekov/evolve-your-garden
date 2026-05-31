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

-- [ Components ] --
local ItemsGridComponent = require("ItemsGridComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Tabs = function(props: Props)
    return Blend.New "Frame" {
        Name = "Tabs";
        Position = UDim2.fromOffset(17, 127);
        Size = UDim2.fromOffset(1080, 627);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        Blend.New "Frame" {
            Name = "Garden";
            Size = UDim2.fromOffset(1080, 627);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ZIndex = -1;
            Visible = Blend.Computed(props.ActiveTab, function(activeTab: string)
                return activeTab == "Garden"
            end);
            Blend.New "ImageLabel" {
                Name = "GridBackground";
                Position = UDim2.fromOffset(11, 9);
                Size = UDim2.fromOffset(1058, 538);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                Image = "rbxassetid://122393690825747";
                ScaleType = Enum.ScaleType.Fit;
            };
            ItemsGridComponent({
                Position = UDim2.fromOffset(15, 13);
                Size = UDim2.fromOffset(1050, 530);
                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                BackgroundTransparency = 1;
                UIPaddingSizes = {
                    PaddingTop = UDim.new(0, 10),
                    PaddingBottom = UDim.new(0, 10),
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                };
                UIGridLayoutSizes = {
                    CellPadding = UDim2.fromOffset(10, 10),
                    CellSize = UDim2.fromOffset(120, 120)
                };
                Items = props.GetItems("Garden");
                Search = props.Search;
                OnItemPressed = props.OnItemPressed;
                OnItemHovered = props.OnItemHovered;
                OnItemUnhovered = props.OnItemUnhovered;
            })
        };
    }
end

-- [ Types ] --
type Props = {
    ActiveTab: Observable.Observable<string>,
    Search: Observable.Observable<string>,
    GetItems: (filter: string?) -> InventoryTypesClient.Items,
    OnItemPressed: (item: ReactiveItemTypes.ReactiveItem, position: UDim2) -> (),
    OnItemHovered: (item: ReactiveItemTypes.ReactiveItem, position: UDim2) -> (),
    OnItemUnhovered: () -> (),
}
type ModuleData = {}

export type Module = typeof(Tabs) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Tabs :: Module