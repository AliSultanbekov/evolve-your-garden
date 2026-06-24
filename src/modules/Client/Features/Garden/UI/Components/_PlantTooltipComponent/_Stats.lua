--[=[
    @class Stats

    Tooltip stats section (Level / Growth bars). Currently a non-functional,
    hidden placeholder - not wired to any reactive data and not mounted in
    the tooltip window yet.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local Stats = function(_props: Props)
    return Blend.New "Frame" {
        Name = "Stats";
        LayoutOrder = 1;
        Position = UDim2.fromOffset(0, 81);
        Size = UDim2.fromScale(1, 0);
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        Visible = false;
        ZIndex = 2;
        Blend.New "UIListLayout" {
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            Padding = UDim.new(0, 10);
            SortOrder = Enum.SortOrder.Name;
            VerticalAlignment = Enum.VerticalAlignment.Center;
        };
        Blend.New "UIPadding" {
            PaddingBottom = UDim.new(0, 10);
            PaddingTop = UDim.new(0, 10);
        };
        Blend.New "Frame" {
            Name = "Level";
            Position = UDim2.fromOffset(30, 17);
            Size = UDim2.fromOffset(189, 28);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            Blend.New "Frame" {
                Name = "BarBackground";
                Position = UDim2.fromOffset(2, 11);
                Size = UDim2.fromOffset(185, 15);
                BackgroundColor3 = Color3.fromRGB(101, 66, 15);
                BorderColor3 = Color3.fromRGB(27, 42, 53);
                Blend.New "UICorner" {
                    CornerRadius = UDim.new(0, 10);
                };
                Blend.New "UIStroke" {
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                    Color = Color3.fromRGB(135, 90, 22);
                    Thickness = 2;
                };
            };
            Blend.New "Frame" {
                Name = "Bar";
                LayoutOrder = 1;
                Position = UDim2.fromOffset(2, 11);
                Size = UDim2.fromOffset(185, 15);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ClipsDescendants = true;
                ZIndex = 2;
                Blend.New "ImageLabel" {
                    Name = "Image";
                    Size = UDim2.fromScale(1, 1);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    Image = "rbxassetid://102543012338502";
                    ScaleType = Enum.ScaleType.Slice;
                    SliceCenter = Rect.new(Vector2.new(15, 15), Vector2.new(355, 15));
                };
            };
            Blend.New "TextLabel" {
                Name = "Name";
                LayoutOrder = 2;
                Position = UDim2.fromOffset(18, 1);
                Size = UDim2.fromOffset(75, 12);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                Text = "Level 2";
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 13;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 3;
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(135, 90, 22);
                    LineJoinMode = Enum.LineJoinMode.Miter;
                    Thickness = 2;
                };
            };
            Blend.New "TextLabel" {
                Name = "Value";
                LayoutOrder = 3;
                Position = UDim2.fromOffset(124, 2);
                Size = UDim2.fromOffset(60, 11);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                Text = "120/200";
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 13;
                ZIndex = 4;
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(135, 90, 22);
                    LineJoinMode = Enum.LineJoinMode.Miter;
                    Thickness = 2;
                };
            };
        };
        Blend.New "Frame" {
            Name = "Growth";
            LayoutOrder = 1;
            Position = UDim2.fromOffset(30, 63);
            Size = UDim2.fromOffset(189, 28);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ZIndex = 2;
            Blend.New "Frame" {
                Name = "BarBackground";
                Position = UDim2.fromOffset(2, 11);
                Size = UDim2.fromOffset(185, 15);
                BackgroundColor3 = Color3.fromRGB(15, 85, 31);
                BorderColor3 = Color3.fromRGB(27, 42, 53);
                Blend.New "UICorner" {
                    CornerRadius = UDim.new(0, 10);
                };
                Blend.New "UIStroke" {
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                    Color = Color3.fromRGB(14, 115, 38);
                    Thickness = 2;
                };
            };
            Blend.New "Frame" {
                Name = "Bar";
                LayoutOrder = 1;
                Position = UDim2.fromOffset(2, 11);
                Size = UDim2.fromOffset(185, 15);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ClipsDescendants = true;
                ZIndex = 2;
                Blend.New "ImageLabel" {
                    Name = "Image";
                    Size = UDim2.fromScale(1, 1);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    Image = "rbxassetid://87643659234500";
                    ScaleType = Enum.ScaleType.Slice;
                    SliceCenter = Rect.new(Vector2.new(15, 15), Vector2.new(355, 15));
                };
            };
            Blend.New "TextLabel" {
                Name = "Name";
                LayoutOrder = 2;
                Position = UDim2.fromOffset(18, 1);
                Size = UDim2.fromOffset(75, 13);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                Text = "Growth";
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 13;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 3;
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(14, 115, 38);
                    LineJoinMode = Enum.LineJoinMode.Miter;
                    Thickness = 2;
                };
            };
            Blend.New "TextLabel" {
                Name = "Value";
                LayoutOrder = 3;
                Position = UDim2.fromOffset(108, 1);
                Size = UDim2.fromOffset(74, 13);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                Text = "Grown 60%";
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 13;
                ZIndex = 4;
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(14, 115, 38);
                    LineJoinMode = Enum.LineJoinMode.Miter;
                    Thickness = 2;
                };
            };
        };
    }
end

-- [ Types ] --
type Props = {}
type ModuleData = {}

export type Module = typeof(Stats) & ModuleData

return Stats :: Module
