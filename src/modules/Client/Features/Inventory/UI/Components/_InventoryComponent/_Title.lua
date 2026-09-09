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
        LayoutOrder = 3;
        Position = UDim2.fromOffset(4, 4);
        Size = UDim2.fromOffset(433, 83);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = 4;
        Blend.New "TextLabel" {
            Name = "Title";
            Position = UDim2.fromOffset(121, 16);
            Size = UDim2.fromOffset(225, 51);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
            Text = "Inventory";
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
        Blend.New "Frame" {
            Name = "Book";
            LayoutOrder = 1;
            Position = UDim2.fromOffset(-14, -62);
            Size = UDim2.fromOffset(154, 154);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ZIndex = 2;
            Blend.New "ImageLabel" {
                Name = "Union";
                Position = UDim2.fromOffset(16, 9);
                Size = UDim2.fromOffset(123, 135);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                Image = "rbxassetid://76874802233725";
                ScaleType = Enum.ScaleType.Fit;
            };
            Blend.New "ImageLabel" {
                Name = "book 1";
                LayoutOrder = 1;
                Size = UDim2.fromOffset(154, 154);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                ClipsDescendants = true;
                Image = "rbxassetid://134588367207436";
                ZIndex = 2;
            };
        };
    }
end

-- [ Types ] --
type Props = {
    
}
type ModuleData = {}

export type Module = typeof(Title) & ModuleData

return Title :: Module