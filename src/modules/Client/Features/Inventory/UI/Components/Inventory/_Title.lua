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
        LayoutOrder = 4;
        Position = UDim2.fromOffset(153, 0);
        Size = UDim2.fromOffset(338, 115);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = 2,
        Blend.New "TextLabel" {
            Name = "Text";
            Position = UDim2.fromOffset(103, 49);
            Size = UDim2.fromOffset(235, 58);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json");
            Text = "Inventory";
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
            Name = "Backpack";
            LayoutOrder = 1;
            Size = UDim2.fromOffset(110, 115);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            Image = "rbxassetid://87648930195244";
            ScaleType = Enum.ScaleType.Fit;
        };
    }
end

-- [ Types ] --
type Props = {
    
}
type ModuleData = {}

export type Module = typeof(Title) & ModuleData

return Title :: Module