--[=[
    @class Rewards

    Rewards tab of the encyclopedia: vertically-scrolling grid of quest
    cards. STRUCTURE ONLY — real quest cards, progress and claim handling
    are left to the caller (marked PLACEHOLDER below).
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local ComponentTypes = require("ComponentTypes")

-- [ Components ] --
local QuestCard = require(script.Parent._QuestCard)

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Rewards = function(props: Props)
    return Blend.New "Frame" {
        Name = "Rewards";
        LayoutOrder = 2;
        Size = UDim2.fromOffset(1153, 668);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        Visible = Blend.Computed(props.ActiveTab, function(activeTab: string)
            return activeTab == "Rewards"
        end);
        ZIndex = 2;
        Blend.New "ImageLabel" {
            Name = "GridBackground";
            Position = UDim2.fromOffset(12, 11);
            Size = UDim2.fromOffset(1130, 646);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://117819154375744";
            ScaleType = Enum.ScaleType.Fit;
        };
        Blend.New "CanvasGroup" {
            Name = "Canvas";
            LayoutOrder = 1;
            Position = UDim2.fromOffset(15, 14);
            Size = UDim2.fromOffset(1122, 640);
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
                Blend.New "UIGridLayout" {
                    CellPadding = UDim2.fromOffset(10, 10);
                    CellSize = UDim2.fromOffset(361, 254);
                    SortOrder = Enum.SortOrder.LayoutOrder;
                };
                Blend.New "UIPadding" {
                    PaddingBottom = UDim.new(0, 10);
                    PaddingLeft = UDim.new(0, 10);
                    PaddingRight = UDim.new(0, 10);
                    PaddingTop = UDim.new(0, 10);
                };
                QuestCard({ LayoutOrder = 1 }); -- PLACEHOLDER: sample card; build real cards from quest data
            };
        };
    }
end

-- [ Types ] --
type Props = {
    ActiveTab: ComponentTypes.Prop<string>,
}
type ModuleData = {}

export type Module = typeof(Rewards) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Rewards :: Module
