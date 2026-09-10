--[=[
    @class Plants

    Plants tab of the encyclopedia: Information header panel + the entry
    grid, both inside one vertically-scrolling canvas. STRUCTURE ONLY —
    tab visibility, real entry data and press handling are left to the
    caller (marked PLACEHOLDER below).
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local PlantsConfig = require("PlantsConfig")
local ItemConfig = require("ItemConfig")
local EncyclopediaTypesClient = require("EncyclopediaTypesClient")
local Rx = require("Rx")
local ComponentTypes = require("ComponentTypes")
local Observable = require("Observable")

-- [ Components ] --
local Information = require(script.Parent._Information)
local PlantCard = require(script.Parent._PlantCard)

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --
local function GetSortedPlants()
    local Plants = {}

    for _, plant in PlantsConfig.Plants do
        table.insert(Plants, plant.Name)
    end

    table.sort(Plants, function(plantAName: string, plantBName: string)
        local PlantAConfig = PlantsConfig.Plants[plantAName]
        local PlantBConfig = PlantsConfig.Plants[plantBName]

        local PlantARarity = PlantAConfig.Rarity
        local PlantBRarity = PlantBConfig.Rarity

        local PlantARarityNumber = ItemConfig.RarityLayoutOrder[PlantARarity]
        local PlantBRarityNumber = ItemConfig.RarityLayoutOrder[PlantBRarity]

        return PlantARarityNumber < PlantBRarityNumber
    end)

    return Plants
end

-- [ Module Table ] --
local Plants = function(props: Props)
    local Plants = GetSortedPlants()
    local PlantCards = {}

    for layoutOrder, plantName in Plants do
        local IsDiscovered = props.GetDiscoveredItem(plantName).DiscoveredTime:Observe():Pipe({
            Rx.map(function(discoveryTime: number?)
                if not discoveryTime then
                    return false
                else
                    return true
                end
            end) :: any
        }) :: any

        table.insert(PlantCards, PlantCard({
            IsDiscovered = IsDiscovered,
            PlantName = plantName,
            LayoutOrder = layoutOrder,
        }))
    end

    return Blend.New "Frame" {
        Name = "Plants";
        LayoutOrder = 1;
        Position = UDim2.fromOffset(15, 14);
        Size = UDim2.fromOffset(1123, 640);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        Visible = Blend.Computed(props.ActiveTab, function(activeTab: string)
            return activeTab == "Plants"
        end);
        ZIndex = 2;
        Blend.New "ImageLabel" {
            Name = "GridBackground";
            Position = UDim2.fromOffset(-3, -2);
            Size = UDim2.fromOffset(1129, 645);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://92882600184454";
            ScaleType = Enum.ScaleType.Fit;
        };
        Blend.New "CanvasGroup" {
            Name = "Canvas";
            LayoutOrder = 1;
            Position = UDim2.fromOffset(0, 1);
            Size = UDim2.fromOffset(1123, 639);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            ZIndex = 2;
            Blend.New "ScrollingFrame" {
                Name = "Grid";
                Size = UDim2.fromScale(1, 1);
                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                CanvasSize = UDim2.new(0, 0, 0, 0);
                ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255);
                ScrollBarImageTransparency = 0.5;
                ScrollBarThickness = 4;
                ScrollingDirection = Enum.ScrollingDirection.Y;
                Blend.New "UIListLayout" {
                    Padding = UDim.new(0, 10);
                    SortOrder = Enum.SortOrder.LayoutOrder;
                };
                Blend.New "UIPadding" {
                    PaddingBottom = UDim.new(0, 10);
                    PaddingLeft = UDim.new(0, 10);
                    PaddingRight = UDim.new(0, 10);
                    PaddingTop = UDim.new(0, 10);
                };
                Information({
                    DiscoveredPlantsCount = props.DiscoveredPlantsCount;
                    SwitchTab = props.SwitchTab;
                });
                Blend.New "Frame" {
                    Name = "Container";
                    LayoutOrder = 1;
                    Size = UDim2.fromOffset(1103, 0);
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    ClipsDescendants = true;
                    ZIndex = 2;
                    Blend.New "UIGridLayout" {
                        CellPadding = UDim2.fromOffset(10, 10);
                        CellSize = UDim2.fromOffset(149, 189);
                        SortOrder = Enum.SortOrder.LayoutOrder;
                    };
                    PlantCards
                };
            };
        };
    }
end

-- [ Types ] --
type Props = {
    ActiveTab: ComponentTypes.Prop<string>,
    DiscoveredPlantsCount: Observable.Observable<number>,
    GetDiscoveredItem: (itemName: string) -> EncyclopediaTypesClient.ReactiveDiscoveredItem,
    SwitchTab: (tabName: string) -> (),
}
type ModuleData = {}

export type Module = typeof(Plants) & ModuleData

return Plants :: Module
