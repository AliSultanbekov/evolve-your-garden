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
local Production = require(script._Production)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local PlantHarvestComponent = function(props: Props)
    return AnimatedFrameComponent({
        Name = "PlantStorage";
        Position = UDim2.fromScale(0.5, 0.5);
        AnchorPoint = Vector2.new(0.5, 0.5);
        Size = UDim2.fromOffset(1071, 655);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        IsOpen = props.IsOpen;
        ApplyDeviceScale = true;
        Children = {
            Blend.New "ImageLabel" {
                Name = "Background";
                Position = UDim2.fromOffset(-90, 0);
                Size = UDim2.fromOffset(1162, 768);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ClipsDescendants = true;
                Image = "rbxassetid://138418188524774";
                ScaleType = Enum.ScaleType.Fit;
            };
            Blend.New "Frame" {
                Name = "Title";
                LayoutOrder = 1;
                Position = UDim2.fromOffset(4, 4);
                Size = UDim2.fromOffset(433, 83);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ZIndex = 7;
                Blend.New "TextLabel" {
                    Name = "Title";
                    Position = UDim2.fromOffset(127, 16);
                    Size = UDim2.fromOffset(299, 51);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                    Text = "Plant Harvest";
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    TextSize = 48;
                    TextWrapped = true;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    TextYAlignment = Enum.TextYAlignment.Top;
                    Blend.New "UIStroke" {
                        Color = Color3.fromRGB(43, 73, 112);
                        Thickness = 3;
                    };
                };
                Blend.New "Frame" {
                    Name = "Box";
                    LayoutOrder = 1;
                    Position = UDim2.fromOffset(-28, -90);
                    Size = UDim2.fromOffset(180, 180);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    ZIndex = 2;
                    Blend.New "ImageLabel" {
                        Name = "Union";
                        Position = UDim2.fromOffset(8, 27);
                        Size = UDim2.fromOffset(165, 139);
                        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                        BackgroundTransparency = 1;
                        Image = "rbxassetid://97454369817451";
                        ScaleType = Enum.ScaleType.Fit;
                    };
                    Blend.New "ImageLabel" {
                        Name = "OpenBox";
                        LayoutOrder = 1;
                        Size = UDim2.fromOffset(180, 180);
                        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                        BackgroundTransparency = 1;
                        ClipsDescendants = true;
                        Image = "rbxassetid://97145090938573";
                        ZIndex = 2;
                    };
                };
            };
            Blend.New "CanvasGroup" {
                Name = "Canvas";
                LayoutOrder = 2;
                Position = UDim2.fromOffset(394, 108);
                Size = UDim2.fromOffset(660, 530);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                ZIndex = 3;
                props.Slot:Pipe({
                    Rx.distinct() :: any,
                    Rx.switchMap( function(slot)
                        if not slot then
                            return Rx.of(nil) :: any
                        end

                        return ItemsGridComponent({
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
                            Items = slot.Harvest;
                            Search = ValueObject.new(""):Observe();
                            OnItemPressed = props.OnItemPressed;
                            OnItemHovered = props.OnItemHovered;
                            OnItemUnhovered = props.OnItemUnhovered;
                        });
                    end) :: any
                }) :: any;
            };
            CloseButtonComponent({
                Position = UDim2.fromOffset(993, 10);
                Size = UDim2.fromOffset(68, 71);
                OnClose = props.OnClose;
                ZIndex = 2;
            });
            Capacity({
                Garden = props.Garden,
                Slot = props.Slot,
            });
            GenericButtonComponent({
                Name = "Collect";
                LayoutOrder = 8;
                Position = UDim2.fromOffset(631, 616);
                Size = UDim2.fromOffset(186, 69);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                Image = "rbxassetid://75554473381144";
                ScaleType = Enum.ScaleType.Fit;
                ZIndex = 8;
                OnPressed = function()
                    props.CollectHarvest();
                end;
                Children = {
                    Blend.New "TextLabel" {
                        Name = "Name";
                        Position = UDim2.fromOffset(6, 6);
                        Size = UDim2.fromOffset(174, 54);
                        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                        BackgroundTransparency = 1;
                        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                        Text = "Collect";
                        TextColor3 = Color3.fromRGB(255, 255, 255);
                        TextSize = 29;
                        TextWrapped = true;
                        Blend.New "UIStroke" {
                            Color = Color3.fromRGB(6, 79, 0);
                            Thickness = 3;
                        };
                    };
                }
            });
            Details({
                Slot = props.Slot,
            });
            Production({
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