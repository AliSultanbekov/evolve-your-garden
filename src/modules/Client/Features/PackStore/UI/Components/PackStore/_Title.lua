--[=[
    @class Title
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local Title = function()
    return Blend.New "Frame" {
        Name = "Title";
        LayoutOrder = 5;
        Position = UDim2.fromOffset(111, 0);
        Size = UDim2.fromOffset(371, 124);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = 6;
        Blend.New "TextLabel" {
            Name = "Text";
            Position = UDim2.fromOffset(124, 50);
            Size = UDim2.fromOffset(247, 58);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json");
            Text = "Pack Store";
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 47;
            TextWrapped = true;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(0, 71, 97);
                LineJoinMode = Enum.LineJoinMode.Miter;
                Thickness = 4;
            };
        };
        Blend.New "ImageLabel" {
            Name = "Cart";
            LayoutOrder = 1;
            Size = UDim2.fromOffset(124, 124);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://101096216338013";
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

return Title :: Module