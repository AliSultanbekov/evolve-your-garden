--[=[
    @class Title
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Title = function()
    return Blend.New "Frame" {
        Name = "Title";
        LayoutOrder = 3;
        Position = UDim2.fromOffset(4, 4);
        Size = UDim2.fromOffset(434, 83);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = 4;
        Blend.New "TextLabel" {
            Name = "Title";
            Position = UDim2.fromOffset(122, 16);
            Size = UDim2.fromOffset(295, 51);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
            Text = "Encyclopedia";
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 48;
            TextWrapped = true;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextYAlignment = Enum.TextYAlignment.Top;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(43, 73, 112);
                Thickness = 3;
            };
        };
        Blend.New "ImageLabel" {
            Name = "Book";
            LayoutOrder = 1;
            Position = UDim2.fromOffset(-15, -69);
            Size = UDim2.fromOffset(155, 156);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://77502748803508";
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 2;
        };
    }
end

-- [ Types ] --
type Props = {
    
}
type ModuleData = {}

export type Module = typeof(Title) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Title :: Module