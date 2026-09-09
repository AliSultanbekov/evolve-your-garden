--[=[
    @class Production

    "Next Production: 1m 42s" + progress bar for the slot's plant. Mirrors the
    server's ClaimProductionCycles math: cycle time = BaseCycleTime /
    (genetic speed * level-tree SpeedMultiplier), progress measured from the
    last production claim (or the moment the plant finished growing).
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")
local GardenTypesClient = require("GardenTypesClient")
local Rx = require("Rx")
local ReactiveItemTypes = require("ReactiveItemTypes")
local PlantUtil = require("PlantUtil")
local PlantsConfig = require("PlantsConfig")

-- [ Components ] --
local GenericProgressBarComponent = require("GenericProgressBarComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --
local function FormatRemaining(seconds: number): string
    local Minutes = math.floor(seconds / 60)
    local Secs = math.floor(seconds % 60)

    if Minutes > 0 then
        return string.format("%dm %ds", Minutes, Secs)
    end

    return string.format("%ds", Secs)
end

-- [ Module Table ] --
local Production = function(props: Props)
    local ProductionInfo = props.Slot:Pipe({
        Rx.switchMap(function(slot: GardenTypesClient.ReactiveSlot?)
            if not slot then
                return Rx.of(nil) :: any
            end

            return slot.Plant:Observe():Pipe({
                Rx.switchMap(function(plant: ReactiveItemTypes.ReactivePlantItem?)
                    if not plant then
                        return Rx.of(nil) :: any
                    end

                    return Rx.combineLatest({
                        GrowthTime = plant.GrowthTime:Observe(),
                        LastProduction = plant.LastProduction:Observe(),
                        Xp = plant.Xp:Observe(),
                    }):Pipe({
                        Rx.map(function(data: any)
                            local FinalStageTime = PlantUtil:GetLastGrowthStageTime(plant.Name)

                            if data.GrowthTime < FinalStageTime then
                                return nil
                            end

                            local PlantEntry = PlantsConfig.Plants[plant.Name]
                            local Genetics = PlantUtil:GetGenetics(plant.Name, plant.GeneticNumber)
                            local Level = PlantEntry.Level(data.Xp)
                            local SpeedMultiplier = PlantUtil:GetLevelTreeStat(Level, "SpeedMultiplier", plant.LevelTreeChoices.Value)
                            local CycleTime = PlantEntry.BaseCycleTime / (Genetics.Speed * SpeedMultiplier)

                            local ProductionStart = math.max(data.LastProduction, FinalStageTime)
                            local Elapsed = math.clamp(data.GrowthTime - ProductionStart, 0, CycleTime)

                            return {
                                Progress = Elapsed / CycleTime,
                                Remaining = CycleTime - Elapsed,
                            } :: any
                        end) :: any,
                    }) :: any
                end) :: any,
            }) :: any
        end) :: any,
        Rx.shareReplay(1) :: any,
    }) :: any

    local Progress = ProductionInfo:Pipe({
        Rx.map(function(info: any)
            return if info then info.Progress else 0
        end) :: any,
    }) :: any

    return Blend.New "Frame" {
        Name = "Info";
        LayoutOrder = 4;
        Position = UDim2.fromOffset(17, 489);
        Size = UDim2.fromOffset(361, 149);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = 5;
        Blend.New "Frame" {
            Name = "ProgressBar";
            Position = UDim2.fromOffset(25, 23);
            Size = UDim2.fromOffset(311, 104);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            GenericProgressBarComponent({
                Position = UDim2.fromOffset(3, 86);
                Size = UDim2.fromOffset(305, 16);
                BarBackgroundPosition = UDim2.fromOffset(0, 0);
                BarBackgroundSize = UDim2.fromScale(1, 1);
                BarBackgroundColor3 = Color3.fromRGB(43, 73, 112);
                BarBackgroundUIStokeColor = Color3.fromRGB(43, 73, 112);
                BarBackgroundUIStokeSize = 0;
                FillPosition = UDim2.fromOffset(0, 0);
                FillSize = UDim2.fromOffset(0, 16);
                FillColorSequence = ColorSequence.new(Color3.fromRGB(255, 211, 51), Color3.fromRGB(209, 125, 0));
                FillGradientRotation = 90;
                FillUICorner = 30;
                FillStrokeColor = Color3.fromRGB(43, 73, 112);
                FillStrokeThickness = 3;
                FillInnerStrokeColorSequence = ColorSequence.new(Color3.fromRGB(255, 226, 121), Color3.fromRGB(232, 139, 0));
                FillInnerStrokeThickness = 3;
                UICorner = 30;
                Progress = Progress;
            });
            Blend.New "TextLabel" {
                Name = "Info";
                LayoutOrder = 3;
                Position = UDim2.fromOffset(10, 0);
                Size = UDim2.fromOffset(290, 71);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                Text = Blend.Computed(ProductionInfo, function(info: any)
                    if not info then
                        return ""
                    end

                    return "Next Production: " .. FormatRemaining(info.Remaining)
                end);
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 29;
                TextWrapped = true;
                ZIndex = 4;
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(43, 73, 112);
                    Thickness = 3;
                };
            };
        };
    }
end

-- [ Types ] --
type Props = {
    Slot: Observable.Observable<GardenTypesClient.ReactiveSlot?>,
}
type ModuleData = {}

export type Module = typeof(Production) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Production :: Module
