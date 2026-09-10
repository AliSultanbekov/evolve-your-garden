--[=[
    @class Information

    Header panel of the Plants tab: "24 / 80 Discovered" counter, blue
    discovery progress bar and the Rewards shortcut button. STRUCTURE ONLY —
    every dynamic value below is a static placeholder marked PLACEHOLDER;
    design the props contract and wire the observables yourself.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")
local Rx = require("Rx")
local PlantsConfig = require("PlantsConfig")

-- [ Components ] --
local GenericButtonComponent = require("GenericButtonComponent")
local GenericProgressBarComponent = require("GenericProgressBarComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Information = function(props: Props)
    return Blend.New "Frame" {
        Name = "Information";
        Size = UDim2.fromOffset(1104, 160);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        Blend.New "ImageLabel" {
            Name = "Background";
            Size = UDim2.fromOffset(1103, 160);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            Image = "rbxassetid://115137286262316";
        };
        Blend.New "TextLabel" {
            Name = "DiscoveredInfo";
            LayoutOrder = 1;
            Position = UDim2.fromOffset(469, 23);
            Size = UDim2.fromOffset(166, 50);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
            Text = "24 / 80";
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 38;
            TextWrapped = true;
            ZIndex = 2;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(43, 73, 112);
                Thickness = 3;
            };
        };
        Blend.New "TextLabel" {
            Name = "Text";
            LayoutOrder = 2;
            Position = UDim2.fromOffset(476, 65);
            Size = UDim2.fromOffset(151, 30);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
            Text = "Discovered";
            TextColor3 = Color3.fromRGB(166, 234, 255);
            TextSize = 29;
            TextWrapped = true;
            ZIndex = 3;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(43, 73, 112);
                Thickness = 3;
            };
        };
        GenericButtonComponent({
            Name = "Rewards";
            LayoutOrder = 3;
            Position = UDim2.fromOffset(954, 104);
            Size = UDim2.fromOffset(141, 49);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ZIndex = 4;
            OnPressed = function()
                print("[Encyclopedia] Rewards pressed") -- PLACEHOLDER: switch to Rewards tab
            end;
            Children = {
                Blend.New "ImageLabel" {
                    Name = "Rewards";
                    Size = UDim2.fromScale(1, 1);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    Image = "rbxassetid://86659464577617";
                    ScaleType = Enum.ScaleType.Fit;
                };
                Blend.New "ImageLabel" {
                    Name = "Background";
                    LayoutOrder = 1;
                    Size = UDim2.fromScale(1, 1);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    ClipsDescendants = true;
                    Image = "rbxassetid://121654905642768";
                    ScaleType = Enum.ScaleType.Fit;
                    ZIndex = 2;
                };
                Blend.New "ImageLabel" {
                    Name = "Trophy";
                    LayoutOrder = 2;
                    Position = UDim2.fromOffset(-30, -18);
                    Size = UDim2.fromOffset(81, 81);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    ClipsDescendants = true;
                    Image = "rbxassetid://104668620127858";
                    ScaleType = Enum.ScaleType.Fit;
                    ZIndex = 3;
                };
                Blend.New "TextLabel" {
                    Name = "Title";
                    LayoutOrder = 3;
                    Position = UDim2.fromOffset(6, 6);
                    Size = UDim2.fromOffset(129, 34);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                    Text = "Rewards";
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    TextSize = 19;
                    TextWrapped = true;
                    ZIndex = 4;
                    Blend.New "UIStroke" {
                        Color = Color3.fromRGB(126, 88, 34);
                        Thickness = 2;
                    };
                };
            };
        });
        GenericProgressBarComponent({
            Position = UDim2.fromOffset(392, 114);
            Size = UDim2.fromOffset(320, 14);
            BarBackgroundPosition = UDim2.fromOffset(0, 0);
            BarBackgroundSize = UDim2.fromScale(1, 1);
            BarBackgroundColor3 = Color3.fromRGB(43, 73, 112);
            BarBackgroundUIStokeColor = Color3.fromRGB(43, 73, 112);
            BarBackgroundUIStokeSize = 0;
            FillPosition = UDim2.fromOffset(0, 0);
            FillSize = UDim2.fromOffset(0, 14);
            FillColorSequence = ColorSequence.new(Color3.fromRGB(150, 215, 255), Color3.fromRGB(0, 159, 255));
            FillGradientRotation = 90;
            FillUICorner = 30;
            FillStrokeColor = Color3.fromRGB(43, 73, 112);
            FillStrokeThickness = 3;
            UICorner = 30;
            Progress = props.DiscoveredPlantsCount:Pipe({
                Rx.map(function(discoveredPlantsCount: number)
                    return PlantsConfig.PlantsCount / discoveredPlantsCount
                end) :: any
            }) :: any
        });
    }
end

-- [ Types ] --
type Props = {
    DiscoveredPlantsCount: Observable.Observable<number>,
}

type ModuleData = {}

export type Module = typeof(Information) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Information :: Module
