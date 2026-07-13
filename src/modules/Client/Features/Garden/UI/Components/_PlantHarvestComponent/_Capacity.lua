--[=[
    @class Capacity
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local GenericProgressBarComponent = require("GenericProgressBarComponent")
local GardenTypesClient = require("GardenTypesClient")
local Observable = require("Observable")
local Rx = require("Rx")
local GardenConfig = require("GardenConfig")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Capacity = function(props: Props)
    local GardenLevel = props.Garden:Pipe({
        Rx.switchMap(function(garden: GardenTypesClient.ReactiveGarden?)
            if not garden then
                return Rx.of(0) :: any
            end

            return garden.Level:Observe():Pipe({
                Rx.map(function(level: number?)
                    if not level then
                        return 0
                    end
                    
                    return level
                end) :: any
            }) :: any
        end) :: any
    }) :: any

    local HarvestCount = props.Slot:Pipe({
        Rx.switchMap(function(slot: GardenTypesClient.ReactiveSlot?)
            if not slot then
                return Rx.of(0) :: any
            end

            return slot.Harvest:ObserveCount()
        end) :: any
    })
    local HarvestCap = GardenLevel:Pipe({
        Rx.map(function(gardenLevel: number)      
            if gardenLevel <= 0 then
                return 0
            end
            
            return GardenConfig.UpgradeStats[gardenLevel].HarvestCap or 0
        end) :: any
    })
    local Progress = Rx.combineLatest({
        HarvestCount = HarvestCount,
        HarvestCap = HarvestCap
    }):Pipe({
        Rx.map(function(data: any)
            return math.clamp((data.HarvestCount / data.HarvestCap), 0, 1)
        end) :: any
    }) :: any

    return Blend.New "Frame" {
        Name = "Capacity";
        LayoutOrder = 6;
        Position = UDim2.fromOffset(28, 477);
        Size = UDim2.fromOffset(352, 113);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = 7;
        Blend.New "ImageLabel" {
            Name = "Background";
            Size = UDim2.fromOffset(355, 116);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://70860649823021";
            ScaleType = Enum.ScaleType.Fit;
        };
        GenericProgressBarComponent({
            Position = UDim2.fromOffset(14, 68);
            Size = UDim2.fromOffset(231, 26);
            FillImage = "rbxassetid://118444637732111";
            FillColorSequence = ColorSequence.new(Color3.fromRGB(54, 240, 44), Color3.fromRGB(33, 195, 33));
            InnerStrokeImage = "rbxassetid://108722683933611";
            InnerStrokeColorSequence = ColorSequence.new(Color3.fromRGB(119, 255, 135), Color3.fromRGB(73, 225, 91));
            BarBackgroundPosition = UDim2.fromOffset(3, 3);
            BarBackgroundSize = UDim2.fromOffset(225, 20);
            BarBackgroundUIStokeSize = 3,
            BarBackgroundUIStokeColor = Color3.fromRGB(37, 89, 34);
            BarBackgroundColor3 = Color3.fromRGB(41, 110, 37);
            FillSize = UDim2.fromOffset(-4, 20);
            FillPosition = UDim2.fromOffset(3, 3);
            InnerStrokeSize = UDim2.fromOffset(-4, 20);
            InnerStrokePosition = UDim2.fromOffset(3, 3);
            SliceCenter = Rect.new(20, 20, 338, 20);
            UICorner = 10;
            Progress = Progress;
        });
        Blend.New "TextLabel" {
            Name = "Name";
            LayoutOrder = 2;
            Position = UDim2.fromOffset(69, 18);
            Size = UDim2.fromOffset(173, 30);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
            Text = "Storage Capacity";
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 20;
            ZIndex = 3;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(43, 73, 112);
                Thickness = 3;
            };
        };
        Blend.New "Frame" {
            Name = "CapacityLabel";
            LayoutOrder = 3;
            Position = UDim2.fromOffset(262, 58);
            Size = UDim2.fromOffset(81, 46);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ZIndex = 4;
            Blend.New "ImageLabel" {
                Name = "Background2";
                Size = UDim2.fromScale(1, 1);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ClipsDescendants = true;
                Image = "rbxassetid://92050553302162";
                ScaleType = Enum.ScaleType.Fit;
            };
            Blend.New "TextLabel" {
                Name = "Value";
                LayoutOrder = 1;
                Position = UDim2.fromOffset(8, 10);
                Size = UDim2.fromOffset(65, 26);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                Text = Blend.Computed(HarvestCount, HarvestCap, function(harvestCount, harvestCap)
                    return tostring(harvestCount) .. "/" .. tostring(harvestCap)
                end);
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 20;
                ZIndex = 2;
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(43, 73, 112);
                    Thickness = 3;
                };
            };
        };
        Blend.New "ImageLabel" {
            Name = "Box";
            LayoutOrder = 4;
            Position = UDim2.fromOffset(14, 8);
            Size = UDim2.fromOffset(56, 50);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://124314546485212";
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 5;
        };
    }
end

-- [ Types ] --
type Props = {
    Garden: Observable.Observable<GardenTypesClient.ReactiveGarden?>,
    Slot: Observable.Observable<GardenTypesClient.ReactiveSlot?>,
}
type ModuleData = {}

export type Module = typeof(Capacity) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Capacity :: Module