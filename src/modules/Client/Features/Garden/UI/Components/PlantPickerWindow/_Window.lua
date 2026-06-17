--[=[
    @class Window
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")
local ComponentTypes = require("ComponentTypes")
local InventoryTypesClient = require("InventoryTypesClient")
local ReactiveItemTypes = require("ReactiveItemTypes")

-- [ Components ] --
local AnimatedFrameComponent = require("AnimatedFrameComponent")
local CloseButtonComponent = require("CloseButtonComponent")
local ItemsGridComponent = require("ItemsGridComponent")

local SearchBar = require(script.Parent._SeachBar)
local Title = require(script.Parent._Title)
local Background = require(script.Parent._Background)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Window = function(props: Props)
    return AnimatedFrameComponent({
        Name = "PlantPickerWindow";
        Position = UDim2.fromScale(0.5, 0.5);
        AnchorPoint = Vector2.new(0.5, 0.5);
        Size = UDim2.fromOffset(1124, 767);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        IsOpen = props.IsOpen;
        Children = {
            Background() :: any;
            Title();
            SearchBar({
                OnSearch = props.OnSearch
            });
            CloseButtonComponent({
                Position = UDim2.fromOffset(1043+66/2, 58+69/2);
                Size = UDim2.fromOffset(66, 69);
                AnchorPoint = Vector2.new(0.5,0.5);
                BackgroundTransparency = 1;
                OnClose = function()
                    props.OnClose()
                end;
            });
            Blend.New "Frame" {
                Name = "Container";
                LayoutOrder = 4;
                Position = UDim2.fromOffset(26, 140);
                Size = UDim2.fromOffset(1080, 627);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ZIndex = 5;
                ItemsGridComponent({
                    Position = UDim2.fromOffset(15, 13);
                    Size = UDim2.fromOffset(1050, 600);
                    AutomaticCanvasSize = Enum.AutomaticSize.Y;
                    BackgroundTransparency = 1;
                    ZIndex = 2;
                    ScrollBarImageColor3 = Color3.fromRGB(191, 191, 191);
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
                    Items = props.GetItems();
                    Search = props.Search;
                    OnItemPressed = props.OnItemPressed;
                    OnItemHovered = props.OnItemHovered;
                    OnItemUnhovered = props.OnItemUnhovered;
                });
                Blend.New "ImageLabel" {
                    Name = "GridBackground";
                    Position = UDim2.fromOffset(11, 9);
                    Size = UDim2.fromOffset(1058, 608);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    Image = "rbxassetid://117902277887576";
                    ScaleType = Enum.ScaleType.Fit;
                }
            };
        }
    })
end

-- [ Types ] --
type Props = {
    IsOpen: ComponentTypes.Prop<boolean>,
    Search: Observable.Observable<string>,

    OnClose: () -> (),
    GetItems: () -> InventoryTypesClient.Items,
    OnItemPressed: (item: ReactiveItemTypes.ReactiveItem, position: UDim2) -> (),
    OnItemHovered: (item: ReactiveItemTypes.ReactiveItem, position: UDim2) -> (),
    OnItemUnhovered: () -> (),
    OnSearch: (text: string) -> (),
}
type ModuleData = {}

export type Module = typeof(Window) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Window :: Module