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
        Position = UDim2.fromOffset(13, 42);
        Size = UDim2.fromOffset(370, 83);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = 4;
        Blend.New "TextLabel" {
            Name = "Title";
            Position = UDim2.fromOffset(89, 16);
            Size = UDim2.fromOffset(269, 51);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
            Text = "Plant Picker";
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextScaled = true;
            TextSize = 40;
            TextWrapped = true;
            Blend.New "UITextSizeConstraint" {
                MaxTextSize = 40;
            };
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(43, 73, 112);
                Thickness = 4;
            };
        };
        Blend.New "ImageLabel" {
            Name = "Backpack";
            LayoutOrder = 1;
            Position = UDim2.fromOffset(-13, -42);
            Size = UDim2.fromOffset(125, 125);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://95591766861193";
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 2;
        };
    };
end

-- [ Types ] --
type Props = {
    
}
type ModuleData = {}

export type Module = typeof(Title) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Title :: Module