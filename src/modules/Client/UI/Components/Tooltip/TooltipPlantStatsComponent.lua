--[=[
    @class TooltipPlantStatsComponent

    Shared tooltip stats section. Shows Level / Growth / Water bars, but only
    for Plant items. The UI is built once; non-plant items map to nil, which
    hides the section. Values `switchMap` to the current plant, so the bars'
    springs slide between plants instead of being remounted.

    Used by every tooltip that shows plant stats (inventory item, garden item,
    world plant). Take an item Observable via props.
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
local PlantUtilShared = require("PlantUtilShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --
local function FormatMMSS(seconds: number): string
    return string.format("%02d:%02d", math.floor(seconds / 60), math.floor(seconds % 60))
end

local function PlantStats(plant: Observable.Observable<ReactiveItemTypes.ReactivePlantItem?>)
    local Plant = plant:Pipe({
        Rx.where(function(plant: ReactiveItemTypes.ReactivePlantItem?): boolean
            return plant ~= nil
        end) :: any
    }) :: any

    local Stats = Plant:Pipe({
        Rx.switchMap(function(plant: ReactiveItemTypes.ReactivePlantItem)
            return Rx.combineLatest({
                Name = plant.Name,
                Xp = plant.Xp:Observe(),
                GrowthTime = plant.GrowthTime:Observe(),
                Water = plant.Water:Observe(),
                MaxWater = PlantsConfig.Plants[plant.Name].Water.Max
            })
        end) :: any,
        Rx.shareReplay(1) :: any,
    }) :: any

    local LevelInfo = Stats:Pipe({
        Rx.map(function(plantStats: any)
            local Level, CurrentLevelXp, NextLevelXp = PlantsConfig.Plants[plantStats.Name].Level(plantStats.Xp)

            return {
                Level = Level,
                CurrentXp = plantStats.Xp,
                CurrentLevelXp = CurrentLevelXp,
                NextLevelXp = NextLevelXp,
            }
        end) :: any,
        Rx.distinct() :: any,
        Rx.shareReplay(1) :: any,
    }) :: any

    local LevelProgress = LevelInfo:Pipe({
        Rx.map(function(levelInfo: any)
            return math.clamp((levelInfo.CurrentXp - levelInfo.CurrentLevelXp) / (levelInfo.NextLevelXp - levelInfo.CurrentLevelXp), 0, 1)
        end) :: any,
        Rx.distinct(),
        Rx.shareReplay(1)
    }) :: any

    local GrowthInfo = Stats:Pipe({
        Rx.map(function(plantStats: any)
            return {
                GrowthTime = plantStats.GrowthTime,
                FinalStageTime = PlantUtilShared:GetLastGrowthStageTime(plantStats.Name),
            }
        end) :: any,
        Rx.shareReplay(1) :: any,
    }) :: any

    local GrowthProgress = GrowthInfo:Pipe({
        Rx.map(function(growthInfo: any)
            return math.clamp((growthInfo.GrowthTime / growthInfo.FinalStageTime), 0, 1)
        end) :: any,
    }) :: any

    local WaterProgress = Stats:Pipe({
        Rx.map(function(plantStats: any)
            return math.clamp(plantStats.Water / plantStats.MaxWater, 0, 1)
        end) :: any,
        Rx.distinct() :: any,
    }) :: any

    return Blend.New "Frame" {
        Name = "PlantStats";
        Size = UDim2.fromScale(1, 0);
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundTransparency = 1;
        Visible = Blend.Computed(plant, function(plantNonObs: ReactiveItemTypes.ReactivePlantItem?)
            return plantNonObs ~= nil
        end),
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
                Size = UDim2.fromOffset(215, 28);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                IsOpen = true;
                Children = {
                    Blend.New "TextLabel" {
                        Name = "Info";
                        Position = UDim2.fromOffset(0, 1);
                        Size = UDim2.fromOffset(215, 15);
                        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                        BackgroundTransparency = 1;
                        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                        Text = Blend.Computed(LevelInfo, function(levelInfo)
                            return "Level " .. levelInfo.Level
                        end),
                        TextColor3 = Color3.fromRGB(255, 255, 255);
                        TextSize = 17;
                        TextWrapped = true;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        ZIndex = 5;
                        Blend.New "UIStroke" {
                            Color = Color3.fromRGB(109, 72, 0);
                            Thickness = 2;
                        };
                    };
                    GenericProgressBarComponent({
                        Position = UDim2.fromOffset(0, 14);
                        Size = UDim2.fromOffset(215, 12);
                        BarBackgroundPosition = UDim2.fromOffset(0, 0);
                        BarBackgroundSize = UDim2.fromScale(1, 1);
                        BarBackgroundColor3 = Color3.fromRGB(109, 72, 0);
                        BarBackgroundUIStokeColor = Color3.fromRGB(109, 72, 0);
                        BarBackgroundUIStokeSize = 0;
                        FillPosition = UDim2.fromOffset(0, 0);
                        FillSize = UDim2.fromOffset(0, 12);
                        FillColorSequence = ColorSequence.new(Color3.fromRGB(255, 204, 73), Color3.fromRGB(236, 152, 0));
                        FillGradientRotation = 90;
                        FillUICorner = 30;
                        FillStrokeColor = Color3.fromRGB(109, 72, 0);
                        FillStrokeThickness = 2;
                        FillInnerStrokeColorSequence = ColorSequence.new(Color3.fromRGB(255, 219, 125), Color3.fromRGB(255, 174, 27));
                        FillInnerStrokeThickness = 2;
                        UICorner = 30;
                        Progress = LevelProgress;
                    });
                }
            });
            AnimatedFrameComponent({
                Name = "Growth";
                LayoutOrder = 2;
                Size = UDim2.fromOffset(215, 28);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                IsOpen = GrowthInfo:Pipe({
                    Rx.map(function(growthInfo: any)
                        return growthInfo.GrowthTime <= growthInfo.FinalStageTime
                    end) :: any,
                    Rx.distinct() :: any,
                }) :: any,
                Children = {
                    Blend.New "TextLabel" {
                        Name = "Info";
                        Position = UDim2.fromOffset(0, 1);
                        Size = UDim2.fromOffset(215, 15);
                        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                        BackgroundTransparency = 1;
                        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                        Text = Blend.Computed(GrowthInfo, function(growthInfo: any)
                            local Difference = growthInfo.FinalStageTime - growthInfo.GrowthTime
                            return "Fully grown in: " .. FormatMMSS(Difference)
                        end),
                        TextColor3 = Color3.fromRGB(255, 255, 255);
                        TextSize = 17;
                        TextWrapped = true;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        ZIndex = 5;
                        Blend.New "UIStroke" {
                            Color = Color3.fromRGB(17, 103, 19);
                            Thickness = 2;
                        };
                    };
                    GenericProgressBarComponent({
                        Position = UDim2.fromOffset(0, 14);
                        Size = UDim2.fromOffset(215, 12);
                        BarBackgroundPosition = UDim2.fromOffset(0, 0);
                        BarBackgroundSize = UDim2.fromScale(1, 1);
                        BarBackgroundColor3 = Color3.fromRGB(12, 70, 13);
                        BarBackgroundUIStokeColor = Color3.fromRGB(12, 70, 13);
                        BarBackgroundUIStokeSize = 0;
                        FillPosition = UDim2.fromOffset(0, 0);
                        FillSize = UDim2.fromOffset(0, 12);
                        FillColorSequence = ColorSequence.new(Color3.fromRGB(36, 248, 78), Color3.fromRGB(22, 209, 35));
                        FillGradientRotation = 90;
                        FillUICorner = 30;
                        FillStrokeColor = Color3.fromRGB(12, 70, 13);
                        FillStrokeThickness = 2;
                        FillInnerStrokeColorSequence = ColorSequence.new(Color3.fromRGB(72, 253, 108), Color3.fromRGB(60, 255, 73));
                        FillInnerStrokeThickness = 2;
                        UICorner = 30;
                        Progress = GrowthProgress;
                    });
                }
            });
            AnimatedFrameComponent({
                Name = "Water";
                LayoutOrder = 3;
                Size = UDim2.fromOffset(215, 28);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                IsOpen = true;
                Children = {
                    Blend.New "TextLabel" {
                        Name = "Info";
                        Position = UDim2.fromOffset(0, 1);
                        Size = UDim2.fromOffset(215, 15);
                        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                        BackgroundTransparency = 1;
                        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                        Text = Blend.Computed(Stats, function(plantStats: any)
                            return "Water " .. math.floor(plantStats.Water) .. "/" .. plantStats.MaxWater
                        end),
                        TextColor3 = Color3.fromRGB(255, 255, 255);
                        TextSize = 17;
                        TextWrapped = true;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        ZIndex = 5;
                        Blend.New "UIStroke" {
                            Color = Color3.fromRGB(16, 58, 112);
                            Thickness = 2;
                        };
                    };
                    GenericProgressBarComponent({
                        Position = UDim2.fromOffset(0, 14);
                        Size = UDim2.fromOffset(215, 12);
                        BarBackgroundPosition = UDim2.fromOffset(0, 0);
                        BarBackgroundSize = UDim2.fromScale(1, 1);
                        BarBackgroundColor3 = Color3.fromRGB(13, 45, 92);
                        BarBackgroundUIStokeColor = Color3.fromRGB(13, 45, 92);
                        BarBackgroundUIStokeSize = 0;
                        FillPosition = UDim2.fromOffset(0, 0);
                        FillSize = UDim2.fromOffset(0, 12);
                        FillColorSequence = ColorSequence.new(Color3.fromRGB(104, 206, 255), Color3.fromRGB(30, 136, 235));
                        FillGradientRotation = 90;
                        FillUICorner = 30;
                        FillStrokeColor = Color3.fromRGB(13, 45, 92);
                        FillStrokeThickness = 2;
                        FillInnerStrokeColorSequence = ColorSequence.new(Color3.fromRGB(160, 228, 255), Color3.fromRGB(75, 175, 255));
                        FillInnerStrokeThickness = 2;
                        UICorner = 30;
                        Progress = WaterProgress;
                    });
                }
            });
        };
    }
end

-- [ Module Table ] --
local TooltipPlantStatsComponent = function(props: Props)
    local Plant: Observable.Observable<ReactiveItemTypes.ReactivePlantItem?> = props.Item:Pipe({
        Rx.map(function(item: ReactiveItemTypes.ReactiveItem)
            return if item.Category == "Plant" then item else nil
        end) :: any,
        Rx.distinct() :: any,
        Rx.shareReplay(1) :: any,
    }) :: any

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
            SortOrder = Enum.SortOrder.LayoutOrder;
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
        PlantStats(Plant);
    }
end

-- [ Types ] --
type Props = {
    Item: Observable.Observable<ReactiveItemTypes.ReactiveItem>,
}

type ModuleData = {}

export type Module = typeof(TooltipPlantStatsComponent) & ModuleData

return TooltipPlantStatsComponent :: Module
