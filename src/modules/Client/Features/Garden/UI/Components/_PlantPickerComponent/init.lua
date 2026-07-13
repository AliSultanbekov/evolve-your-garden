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
local ReactiveItemTypes = require("ReactiveItemTypes")

-- [ Components ] --
local AnimatedFrameComponent = require("AnimatedFrameComponent")
local CloseButtonComponent = require("CloseButtonComponent")
local ItemsGridComponent = require("ItemsGridComponent")
local SearchBarComponent = require("SearchBarComponent")

local Title = require(script._Title)
local Background = require(script._Background)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Window = function(props: Props)
    return AnimatedFrameComponent({
        Name = "PlantPickerWindow";
        ApplyDeviceScale = true;
        Position = UDim2.fromScale(0.5, 0.5);
        AnchorPoint = Vector2.new(0.5, 0.5);
        Size = UDim2.fromOffset(1095, 696);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        IsOpen = props.IsOpen;
        Children = {
            Background() :: any;
            Title();
            SearchBarComponent({
                LayoutOrder = 4;
                Position = UDim2.fromOffset(703, 51);
                Size = UDim2.fromOffset(306, 64);
                ZIndex = 5;
                BackgroundImage = "rbxassetid://129977395166820";
                SearchBoxSize = UDim2.fromOffset(306, 64);
                OnSearch = props.OnSearch;
            });
            CloseButtonComponent({
                Position = UDim2.fromOffset(1020, 51);
                Size = UDim2.fromOffset(61, 64);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ZIndex = 2;
                OnClose = function()
                    props.OnClose()
                end;
            });
            Blend.New "Frame" {
                Name = "Container";
                LayoutOrder = 2;
                Position = UDim2.fromOffset(13, 130);
                Size = UDim2.fromOffset(1078, 562);
                BackgroundTransparency = 1;
                ZIndex = 3;
                ItemsGridComponent({
                    Position = UDim2.fromOffset(14, 18);
                    Size = UDim2.fromOffset(1050, 530);
                    AutomaticCanvasSize = Enum.AutomaticSize.Y;
                    BackgroundTransparency = 1;
                    ZIndex = 2;
                    ScrollBarImageColor3 = Color3.fromRGB(191, 191, 191);
                    ScrollBarThickness = 6;
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
                    Position = UDim2.fromOffset(10, 14);
                    Size = UDim2.fromOffset(1058, 538);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    Image = "rbxassetid://125737179056590";
                    ScaleType = Enum.ScaleType.Fit;
                };
            };
        }
    })
end

-- [ Types ] --
type Props = {
    IsOpen: ComponentTypes.Prop<boolean>,
    Search: Observable.Observable<string>,

    OnClose: () -> (),
    GetItems: () -> ReactiveItemTypes.ReactiveItems,
    OnItemPressed: (item: ReactiveItemTypes.ReactiveItem) -> (),
    OnItemHovered: (item: ReactiveItemTypes.ReactiveItem) -> (),
    OnItemUnhovered: (item: ReactiveItemTypes.ReactiveItem) -> (),
    OnSearch: (text: string) -> (),
}
type ModuleData = {}

export type Module = typeof(Window) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Window :: Module