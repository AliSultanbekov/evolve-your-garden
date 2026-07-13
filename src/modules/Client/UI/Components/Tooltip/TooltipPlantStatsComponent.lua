--[=[
    @class TooltipPlantStatsComponent

    Shared tooltip stats section. Shows Level / Growth bars, but only for Plant
    items. The whole plant-stats subtree is gated at the top: the component
    `switchMap`s on the item and only mounts `PlantStats(plant)` when the item is
    a Plant, passing the concrete plant down. Inside `PlantStats` the plant is
    therefore guaranteed non-nil and always a Plant, so there are no
    per-observable category/nil guards.

    Used by every tooltip that shows plant stats (inventory item, garden item,
    world plant). Take an item Observable via props; non-plant items render nothing.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")
local ReactiveItemTypes = require("ReactiveItemTypes")
local AnimatedFrameComponent = require("AnimatedFrameComponent")
local GenericProgressBarComponent = require("GenericProgressBarComponent")
local Rx = require("Rx")
local PlantsConfig = require("PlantsConfig")
local PlantUtil = require("PlantUtil")

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --
local function FormatMMSS(seconds: number): string
    return string.format("%02d:%02d", math.floor(seconds / 60), math.floor(seconds % 60))
end

-- Built only for Plant items (gated below), so `plant` is always a concrete,
-- non-nil ReactivePlantItem here. No ShouldShow / nil guards needed.
local function PlantStats(plant: ReactiveItemTypes.ReactivePlantItem)
    local LevelInfo = plant.Xp:Observe():Pipe({
        Rx.map(function(xp: number)
            local Level, CurrentLevelXp, NextLevelXp = PlantsConfig.Plants[plant.Name].Level(xp)

            return {
                Level = Level,
                CurrentXp = xp,
                CurrentLevelXp = CurrentLevelXp,
                NextLevelXp = NextLevelXp,
            }
        end) :: any,
        Rx.distinct() :: any,
        Rx.shareReplay(1) :: any,
    }) :: any

    local LevelProgress = LevelInfo:Pipe({
        Rx.map(function(levelInfo: any)
            return math.clamp((levelInfo.CurrentXp -levelInfo.CurrentLevelXp) / (levelInfo.NextLevelXp - levelInfo.CurrentLevelXp), 0.08, 1)
        end) :: any,
        Rx.distinct(),
        Rx.shareReplay(1)
    }) :: any

    local GrowthInfo = plant.GrowthTime:Observe():Pipe({
        Rx.map(function(growthTime: number)
            return {
                GrowthTime = growthTime,
                FinalStageTime = PlantUtil:GetLastGrowthStageTime(plant.Name),
            }
        end) :: any,
        Rx.shareReplay(1) :: any,
    }) :: any

    local GrowthProgress = GrowthInfo:Pipe({
        Rx.map(function(growthInfo: any)
            return math.clamp((growthInfo.GrowthTime / growthInfo.FinalStageTime), 0.08, 1)
        end) :: any,
    }) :: any

    return Blend.New "Frame" {
        Name = "PlantStats";
        Size = UDim2.fromScale(1, 0);
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundTransparency = 1;
        Blend.New "UIListLayout" {
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            Padding = UDim.new(0, 10);
            SortOrder = Enum.SortOrder.LayoutOrder;
            VerticalAlignment = Enum.VerticalAlignment.Center;
        };
        [Blend.Children] = {
            AnimatedFrameComponent({
                Name = "Level";
                LayoutOrder = 1;
                Size = UDim2.fromOffset(189, 27);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                IsOpen = true;
                Children = {
                    GenericProgressBarComponent({
                        Position = UDim2.fromOffset(0, 8);
                        Size = UDim2.fromOffset(189, 19);
                        BarBackgroundPosition = UDim2.fromOffset(2, 2);
                        BarBackgroundSize = UDim2.fromOffset(185, 15);
                        BarBackgroundColor3 = Color3.fromRGB(121, 78, 18);
                        BarBackgroundUIStokeColor = Color3.fromRGB(103, 69, 17);
                        BarBackgroundUIStokeSize = 2;
                        UICorner = 10;
                        FillImage = "rbxassetid://92565082291017";
                        FillColorSequence = ColorSequence.new(Color3.fromRGB(255, 200, 2), Color3.fromRGB(255, 158, 1));
                        FillPosition = UDim2.fromOffset(2, 2);
                        FillSize = UDim2.fromOffset(-4, 15);
                        InnerStrokeImage = "rbxassetid://111508696383639";
                        InnerStrokeColorSequence = ColorSequence.new(Color3.fromRGB(255, 237, 44), Color3.fromRGB(255, 200, 73));
                        InnerStrokePosition = UDim2.fromOffset(2, 2);
                        InnerStrokeSize = UDim2.fromOffset(185, 15);
                        SliceCenter = Rect.new(15, 15, 355, 15);
                        Progress = LevelProgress;
                    });
                    Blend.New "TextLabel" {
                        Name = "Info";
                        LayoutOrder = 1;
                        Position = UDim2.fromOffset(2, 3);
                        Size = UDim2.fromOffset(185, 9);
                        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                        BackgroundTransparency = 1;
                        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                        Text = Blend.Computed(LevelInfo, function(levelInfo)
                            return "Level " .. levelInfo.Level
                        end),
                        TextColor3 = Color3.fromRGB(255, 255, 255);
                        TextXAlignment = Enum.TextXAlignment.Left;
                        ZIndex = 2;
                        Blend.New "UIStroke" {
                            Color = Color3.fromRGB(135, 90, 22);
                            Thickness = 2;
                        };
                    };
                }
            });
            AnimatedFrameComponent({
                Name = "Growth";
                LayoutOrder = 2;
                Size = UDim2.fromOffset(189, 27);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                IsOpen = GrowthInfo:Pipe({
                    Rx.map(function(growthInfo: any)
                        return growthInfo.GrowthTime <= growthInfo.FinalStageTime
                    end) :: any,
                    Rx.distinct() :: any,
                }) :: any,
                Children = {
                    GenericProgressBarComponent({
                        Position = UDim2.fromOffset(0, 8);
                        Size = UDim2.fromOffset(189, 19);
                        BarBackgroundPosition = UDim2.fromOffset(2, 2);
                        BarBackgroundSize = UDim2.fromOffset(185, 15);
                        BarBackgroundColor3 = Color3.fromRGB(12, 70, 13);
                        BarBackgroundUIStokeColor = Color3.fromRGB(17, 103, 19);
                        BarBackgroundUIStokeSize = 2;
                        UICorner = 10;
                        FillImage = "rbxassetid://92565082291017";
                        FillColorSequence = ColorSequence.new(Color3.fromRGB(36, 248, 78), Color3.fromRGB(22, 209, 35));
                        FillPosition = UDim2.fromOffset(2, 2);
                        FillSize = UDim2.fromOffset(-4, 15);
                        InnerStrokeImage = "rbxassetid://111508696383639";
                        InnerStrokeColorSequence = ColorSequence.new(Color3.fromRGB(72, 253, 108), Color3.fromRGB(60, 255, 73));
                        InnerStrokePosition = UDim2.fromOffset(2, 2);
                        InnerStrokeSize = UDim2.fromOffset(185, 15);
                        SliceCenter = Rect.new(15, 15, 355, 15);
                        Progress = GrowthProgress;
                    });
                    Blend.New "TextLabel" {
                        Name = "Info";
                        LayoutOrder = 1;
                        Position = UDim2.fromOffset(2, 3);
                        Size = UDim2.fromOffset(185, 9);
                        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                        BackgroundTransparency = 1;
                        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                        Text = Blend.Computed(GrowthInfo, function(growthInfo: any)
                            local Difference = growthInfo.FinalStageTime - growthInfo.GrowthTime
                            return "Fully grown in: " .. FormatMMSS(Difference)
                        end),
                        TextColor3 = Color3.fromRGB(255, 255, 255);
                        TextXAlignment = Enum.TextXAlignment.Left;
                        ZIndex = 2;
                        Blend.New "UIStroke" {
                            Color = Color3.fromRGB(17, 103, 19);
                            Thickness = 2;
                        };
                    };
                }
            });
        };
    }
end

-- [ Module Table ] --
local TooltipPlantStatsComponent = function(props: Props)
    return Blend.New "Frame" {
        Name = "Stats";
        LayoutOrder = 1;
        Position = UDim2.fromOffset(0, 81);
        Size = UDim2.fromScale(1, 0);
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = 2;
        Blend.New "UIListLayout" {
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            Padding = UDim.new(0, 10);
            SortOrder = Enum.SortOrder.Name;
            VerticalAlignment = Enum.VerticalAlignment.Center;
        };
        Blend.New "UIPadding" {
            PaddingTop = Blend.Computed(props.Item, function(item)
                return UDim.new(0, if item.Category == "Plant" then 10 else 0)
            end),
            PaddingBottom = Blend.Computed(props.Item, function(item)
                return UDim.new(0, if item.Category == "Plant" then 10 else 0)
            end),
        };
        props.Item:Pipe({
            Rx.distinct() :: any,
            Rx.switchMap(function(item: ReactiveItemTypes.ReactiveItem)
                if item.Category ~= "Plant" then
                    return Rx.of(nil) :: any
                end

                return PlantStats(item :: ReactiveItemTypes.ReactivePlantItem) :: any
            end) :: any,
        }) :: any;
    }
end

-- [ Types ] --
type Props = {
    Item: Observable.Observable<ReactiveItemTypes.ReactiveItem>,
}

type ModuleData = {}

export type Module = typeof(TooltipPlantStatsComponent) & ModuleData

return TooltipPlantStatsComponent :: Module
