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

-- [ Functions ] --

-- [ Module Table ] --
local Title = function()
    return Blend.New "Frame" {
        Name = "Title";
        LayoutOrder = 6;
        Position = UDim2.fromOffset(141, 0);
        Size = UDim2.fromOffset(347, 83);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = 7;
        Blend.New "TextLabel" {
            Name = "Title";
            Position = UDim2.fromOffset(130, 13);
            Size = UDim2.fromOffset(180, 51);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal);
            Text = "Inventory";
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 40;
            TextWrapped = true;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(32, 83, 118);
                LineJoinMode = Enum.LineJoinMode.Miter;
                Thickness = 4;
            };
        };
        Blend.New "ImageLabel" {
            Name = "Backpack";
            LayoutOrder = 1;
            Position = UDim2.fromOffset(0, -42);
            Size = UDim2.fromOffset(125, 125);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://130811308690798";
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