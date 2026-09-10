--[=[
    @class QuestCard

    Single quest entry of the Rewards tab: quest icon + title, reward icon
    strip, progress bar and Claim button. STRUCTURE ONLY — every dynamic
    value below is a static placeholder marked PLACEHOLDER; design the
    props contract and wire the observables yourself.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local ValueObject = require("ValueObject")

-- [ Components ] --
local GenericButtonComponent = require("GenericButtonComponent")
local GenericProgressBarComponent = require("GenericProgressBarComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local QuestCard = function(props: Props)
    -- PLACEHOLDER: sample reward icon strip; build from the quest's reward data
    local RewardIcons = {}

    for index = 1, 5 do
        table.insert(RewardIcons, Blend.New "ImageLabel" {
            Name = "RewardIcon";
            LayoutOrder = index;
            Size = UDim2.fromOffset(55, 55);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://84208852588697";
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = index;
        })
    end

    return Blend.New "Frame" {
        Name = "QuestCard";
        LayoutOrder = props.LayoutOrder;
        Size = UDim2.fromOffset(361, 254);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        Blend.New "ImageLabel" {
            Name = "Background";
            Size = UDim2.fromScale(1, 1);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://90597864729469";
            ScaleType = Enum.ScaleType.Fit;
        };
        Blend.New "ImageLabel" {
            Name = "RewardsBackground";
            LayoutOrder = 1;
            Position = UDim2.fromOffset(11, 123);
            Size = UDim2.fromOffset(339, 79);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://116579572873271";
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 2;
        };
        Blend.New "Frame" {
            Name = "ProgressBar";
            LayoutOrder = 2;
            Position = UDim2.fromOffset(11, 210);
            Size = UDim2.fromOffset(339, 33);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ZIndex = 3;
            GenericProgressBarComponent({
                Position = UDim2.fromOffset(2, 19);
                Size = UDim2.fromOffset(337, 12);
                BarBackgroundPosition = UDim2.fromOffset(0, 0);
                BarBackgroundSize = UDim2.fromScale(1, 1);
                BarBackgroundColor3 = Color3.fromRGB(43, 73, 112);
                BarBackgroundUIStokeColor = Color3.fromRGB(43, 73, 112);
                BarBackgroundUIStokeSize = 0;
                FillPosition = UDim2.fromOffset(0, 0);
                FillSize = UDim2.fromOffset(0, 12);
                FillColorSequence = ColorSequence.new(Color3.fromRGB(114, 249, 132), Color3.fromRGB(33, 190, 30));
                FillGradientRotation = 90;
                FillUICorner = 30;
                FillStrokeColor = Color3.fromRGB(43, 73, 112);
                FillStrokeThickness = 2;
                UICorner = 30;
                Progress = ValueObject.new(0.64):Observe(); -- PLACEHOLDER: quest progress observable
            });
            Blend.New "TextLabel" {
                Name = "Value";
                LayoutOrder = 3;
                Position = UDim2.fromOffset(309, 0);
                Size = UDim2.fromOffset(30, 16);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                Text = "0%"; -- PLACEHOLDER: quest progress percent
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 19;
                TextWrapped = true;
                ZIndex = 4;
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(43, 73, 112);
                    Thickness = 2;
                };
            };
        };
        Blend.New "CanvasGroup" {
            Name = "Canvas";
            LayoutOrder = 3;
            Position = UDim2.fromOffset(13, 125);
            Size = UDim2.fromOffset(335, 75);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            ZIndex = 4;
            Blend.New "ScrollingFrame" {
                Name = "Rewards";
                Size = UDim2.fromOffset(335, 75);
                AutomaticCanvasSize = Enum.AutomaticSize.X;
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                CanvasSize = UDim2.new(0, 0, 0, 0);
                ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255);
                ScrollBarImageTransparency = 0.5;
                ScrollBarThickness = 4;
                ScrollingDirection = Enum.ScrollingDirection.X;
                Blend.New "UIListLayout" {
                    FillDirection = Enum.FillDirection.Horizontal;
                    Padding = UDim.new(0, 10);
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    VerticalAlignment = Enum.VerticalAlignment.Center;
                };
                Blend.New "UIPadding" {
                    PaddingBottom = UDim.new(0, 10);
                    PaddingLeft = UDim.new(0, 10);
                    PaddingRight = UDim.new(0, 10);
                    PaddingTop = UDim.new(0, 10);
                };
                RewardIcons;
            };
        };
        GenericButtonComponent({
            Name = "Claim";
            LayoutOrder = 4;
            Position = UDim2.fromOffset(134, 207);
            Size = UDim2.fromOffset(94, 39);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ZIndex = 5;
            OnPressed = function()
                print("[Encyclopedia] Claim pressed") -- PLACEHOLDER: claim quest reward
            end;
            Children = {
                Blend.New "ImageLabel" {
                    Name = "Background";
                    Size = UDim2.fromScale(1, 1);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    ClipsDescendants = true;
                    Image = "rbxassetid://82692781038536";
                    ScaleType = Enum.ScaleType.Fit;
                };
                Blend.New "TextLabel" {
                    Name = "Title";
                    LayoutOrder = 1;
                    Position = UDim2.fromOffset(4, 4);
                    Size = UDim2.fromOffset(86, 29);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                    Text = "Claim";
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    TextSize = 19;
                    TextWrapped = true;
                    ZIndex = 2;
                    Blend.New "UIStroke" {
                        Color = Color3.fromRGB(27, 92, 30);
                        Thickness = 2;
                    };
                };
            };
        });
        Blend.New "TextLabel" {
            Name = "RewardsLabel";
            LayoutOrder = 5;
            Position = UDim2.fromOffset(11, 103);
            Size = UDim2.fromOffset(83, 16);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
            Text = "Rewards:";
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 19;
            TextWrapped = true;
            ZIndex = 6;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(43, 73, 112);
                Thickness = 2;
            };
        };
        Blend.New "Frame" {
            Name = "Info";
            LayoutOrder = 6;
            Position = UDim2.fromOffset(6, 6);
            Size = UDim2.fromOffset(349, 79);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ZIndex = 7;
            Blend.New "ImageLabel" {
                Name = "Icon";
                Size = UDim2.fromOffset(79, 79);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ClipsDescendants = true;
                Image = "rbxassetid://134233703548866"; -- PLACEHOLDER: quest icon
                ScaleType = Enum.ScaleType.Fit;
            };
            Blend.New "TextLabel" {
                Name = "Title";
                LayoutOrder = 1;
                Position = UDim2.fromOffset(79, 0);
                Size = UDim2.fromOffset(270, 79);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                Text = "Discover 20 Plants"; -- PLACEHOLDER: quest title
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 24;
                TextWrapped = true;
                ZIndex = 2;
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
    LayoutOrder: number?,
}
type ModuleData = {}

export type Module = typeof(QuestCard) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return QuestCard :: Module
