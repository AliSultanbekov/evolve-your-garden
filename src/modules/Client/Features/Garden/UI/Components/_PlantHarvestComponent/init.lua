--[=[
    @class PlantHarvestComponent
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")
local ValueObject = require("ValueObject")
local Rx = require("Rx")

-- [ Components ] --
local AnimatedFrameComponent = require("AnimatedFrameComponent")
local ItemsGridComponent: any = require("ItemsGridComponent")
local GardenTypesClient = require("GardenTypesClient")
local ReactiveItemTypes = require("ReactiveItemTypes")
local CloseButtonComponent = require("CloseButtonComponent")
local GenericButtonComponent = require("GenericButtonComponent")
local Capacity = require(script._Capacity)
local Details = require(script._Details)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local PlantHarvestComponent = function(props: Props)
    return AnimatedFrameComponent({
        Name = "PlantStorage";
        Position = UDim2.fromScale(0.5, 0.5);
        AnchorPoint = Vector2.new(0.5, 0.5);
        Size = UDim2.fromOffset(1008, 618);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        IsOpen = props.IsOpen;
        ApplyDeviceScale = true;
        Children = {
            Blend.New "ImageLabel" {
                Name = "Background";
                Size = UDim2.fromScale(1, 1);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                Image = "rbxassetid://124557205503295";
                ScaleType = Enum.ScaleType.Fit;
            };
            Blend.New "Frame" {
                Name = "Title";
                LayoutOrder = 1;
                Position = UDim2.fromOffset(4, 4);
                Size = UDim2.fromOffset(392, 83);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ZIndex = 2;
                Blend.New "TextLabel" {
                    Name = "Title";
                    Position = UDim2.fromOffset(114, 16);
                    Size = UDim2.fromOffset(265, 51);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                    Text = "Plant Storage";
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    TextSize = 40;
                    Blend.New "UIStroke" {
                        Color = Color3.fromRGB(43, 73, 112);
                        Thickness = 4;
                    };
                };
                Blend.New "ImageLabel" {
                    Name = "Backpack";
                    LayoutOrder = 1;
                    Position = UDim2.fromOffset(-6, -42);
                    Size = UDim2.fromOffset(125, 125);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    ClipsDescendants = true;
                    Image = "rbxassetid://98552678238461";
                    ScaleType = Enum.ScaleType.Fit;
                    ZIndex = 2;
                };
            };
            Blend.New "ImageLabel" {
                Name = "Background2";
                LayoutOrder = 2;
                Position = UDim2.fromOffset(14, 106);
                Size = UDim2.fromOffset(980, 498);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ClipsDescendants = true;
                Image = "rbxassetid://134931817694211";
                ScaleType = Enum.ScaleType.Fit;
                ZIndex = 3;
            };
            props.Slot:Pipe({
                Rx.distinct() :: any,
                Rx.switchMap( function(slot)  
                    if not slot then
                        return Rx.of(nil) :: any
                    end

                    return ItemsGridComponent({
                        Position = UDim2.fromOffset(380, 110);
                        Size = UDim2.fromOffset(610, 490);
                        AutomaticCanvasSize = Enum.AutomaticSize.Y;
                        ScrollingDirection = Enum.ScrollingDirection.Y;
                        BackgroundTransparency = 1;
                        ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255);
                        ScrollBarImageTransparency = 0.5;
                        ScrollBarThickness = 4;
                        ZIndex = 3;
                        UIPaddingSizes = {
                            PaddingTop = UDim.new(0, 10),
                            PaddingBottom = UDim.new(0, 10),
                            PaddingLeft = UDim.new(0, 10),
                            PaddingRight = UDim.new(0, 10),
                        };
                        UIGridLayoutSizes = {
                            CellPadding = UDim2.fromOffset(10, 10),
                            CellSize = UDim2.fromOffset(110, 110),
                            FillDirection = Enum.FillDirection.Horizontal,
                        };
                        Items = slot.Harvest;
                        Search = ValueObject.new(""):Observe();
                        OnItemPressed = props.OnItemPressed;
                        OnItemHovered = props.OnItemHovered;
                        OnItemUnhovered = props.OnItemUnhovered;
                    });
                end) :: any
            }) :: any;
            CloseButtonComponent({
                Position = UDim2.fromOffset(934, 13);
                Size = UDim2.fromOffset(61, 64);
                OnClose = props.OnClose;
                ZIndex = 5;
            });
            Capacity({
                Garden = props.Garden,
                Slot = props.Slot,
            });
            GenericButtonComponent({
                Name = "Collect";
                LayoutOrder = 8;
                Position = UDim2.fromOffset(413, 583);
                Size = UDim2.fromOffset(181, 61);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                Image = "rbxassetid://96496931220643";
                ScaleType = Enum.ScaleType.Fit;
                ZIndex = 9;
                OnPressed = function()
                    props.CollectHarvest();
                end;
                Children = {
                    Blend.New "TextLabel" {
                        Name = "Name";
                        Position = UDim2.fromOffset(6, 6);
                        Size = UDim2.fromOffset(169, 46);
                        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                        BackgroundTransparency = 1;
                        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                        Text = "Collect";
                        TextColor3 = Color3.fromRGB(255, 255, 255);
                        TextSize = 24;
                        Blend.New "UIStroke" {
                            Color = Color3.fromRGB(14, 100, 13);
                            Thickness = 3;
                        };
                    };
                }
            });
            Details({
                Slot = props.Slot,
            })
        }
    })
end

-- [ Types ] --
type Props = {
    IsOpen: Observable.Observable<boolean>,
    Garden: Observable.Observable<GardenTypesClient.ReactiveGarden?>,
    Slot: Observable.Observable<GardenTypesClient.ReactiveSlot?>,
    
    OnClose: () -> (),
    OnItemPressed: (item: ReactiveItemTypes.ReactiveItem, position: UDim2) -> (),
    OnItemHovered: (item: ReactiveItemTypes.ReactiveItem, position: UDim2) -> (),
    OnItemUnhovered: (item: ReactiveItemTypes.ReactiveItem) -> (),
    CollectHarvest: () -> ()
}
type ModuleData = {}

export type Module = typeof(PlantHarvestComponent) & ModuleData

return PlantHarvestComponent :: Module