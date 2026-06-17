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
        LayoutOrder = 3;
        Position = UDim2.fromOffset(4, 4);
        Size = UDim2.fromOffset(413, 88);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = 4;
        Blend.New "TextLabel" {
            Name = "Title";
            Position = UDim2.fromOffset(173, 16);
            Size = UDim2.fromOffset(231, 51);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal);
            Text = "Pack Store";
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 40;
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(97, 61, 34);
                Thickness = 4;
            };
        };
        Blend.New "ImageLabel" {
            Name = "MarketStall";
            LayoutOrder = 1;
            Position = UDim2.fromOffset(-6, -82);
            Size = UDim2.fromOffset(180, 180);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://88507326517378";
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

return Title :: Module