--[=[
    @class Capacity

    "Storage 18/30" bar, top-right of the plant harvest window. Flat-frame
    progress bar: dark track, gradient fill whose width follows progress,
    and a stroke outline that hugs the filled part (per the design).
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local GardenTypesClient = require("GardenTypesClient")
local Observable = require("Observable")
local Rx = require("Rx")
local GardenConfig = require("GardenConfig")

-- [ Components ] --
local GenericProgressBarComponent = require("GenericProgressBarComponent")

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
            if data.HarvestCap <= 0 then
                return 0
            end

            return math.clamp((data.HarvestCount / data.HarvestCap), 0, 1)
        end) :: any
    }) :: any

    return Blend.New "Frame" {
        Name = "Capacity";
        LayoutOrder = 3;
        Position = UDim2.fromOffset(568, 17);
        Size = UDim2.fromOffset(311, 57);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = 4;
        GenericProgressBarComponent({
            Position = UDim2.fromOffset(3, 38);
            Size = UDim2.fromOffset(305, 16);
            BarBackgroundPosition = UDim2.fromOffset(0, 0);
            BarBackgroundSize = UDim2.fromScale(1, 1);
            BarBackgroundColor3 = Color3.fromRGB(43, 73, 112);
            BarBackgroundUIStokeColor = Color3.fromRGB(43, 73, 112);
            BarBackgroundUIStokeSize = 0;
            FillPosition = UDim2.fromOffset(0, 0);
            FillSize = UDim2.fromOffset(0, 16);
            FillColorSequence = ColorSequence.new(Color3.fromRGB(114, 249, 132), Color3.fromRGB(33, 190, 30));
            FillGradientRotation = 90;
            FillUICorner = 30;
            FillStrokeColor = Color3.fromRGB(43, 73, 112);
            FillStrokeThickness = 3;
            FillInnerStrokeColorSequence = ColorSequence.new(Color3.fromRGB(180, 248, 184), Color3.fromRGB(90, 211, 93));
            FillInnerStrokeThickness = 3;
            UICorner = 30;
            Progress = Progress;
        });
        Blend.New "TextLabel" {
            Name = "Title";
            LayoutOrder = 3;
            Position = UDim2.fromOffset(3, 2);
            Size = UDim2.fromOffset(107, 26);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
            Text = "Storage";
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 29;
            TextWrapped = true;
            ZIndex = 4;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(43, 73, 112);
                Thickness = 3;
            };
        };
        Blend.New "TextLabel" {
            Name = "Amount";
            LayoutOrder = 4;
            Position = UDim2.fromOffset(235, 2);
            Size = UDim2.fromOffset(73, 26);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
            Text = Blend.Computed(HarvestCount, HarvestCap, function(harvestCount, harvestCap)
                return tostring(harvestCount) .. "/" .. tostring(harvestCap)
            end);
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 29;
            TextWrapped = true;
            ZIndex = 5;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(43, 73, 112);
                Thickness = 3;
            };
        };
    }
end

-- [ Types ] --
type Props = {
    Garden: Observable.Observable<GardenTypesClient.ReactiveGarden?>,
    Slot: Observable.Observable<GardenTypesClient.ReactiveSlot?>,
}
type ModuleData = {}

-- [ Private Functions ] --

-- [ Public Functions ] --

export type Module = typeof(Capacity) & ModuleData

return Capacity :: Module
