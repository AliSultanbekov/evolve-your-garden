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

-- [ Module Table ] --
local Title = function()
    return Blend.New "Frame" {
        Name = "Title";
        LayoutOrder = 3;
        Size = UDim2.fromOffset(397, 130);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = 4;
        Blend.New "TextLabel" {
            Name = "Text";
            Position = UDim2.fromOffset(118, 62);
            Size = UDim2.fromOffset(279, 58);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json");
            Text = "Plant Picker";
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextScaled = true;
            TextSize = 47;
            TextWrapped = true;
            Blend.New "UITextSizeConstraint" {
                MaxTextSize = 47;
            };
            Blend.New "UIStroke" {
                Color = Color3.fromRGB(0, 71, 97);
                LineJoinMode = Enum.LineJoinMode.Miter;
                Thickness = 4;
            };
        };
        Blend.New "ImageLabel" {
            Name = "Image";
            Size = UDim2.fromOffset(130, 130);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            Image = "rbxassetid://124953141206252";
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