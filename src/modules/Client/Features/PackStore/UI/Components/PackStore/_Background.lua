--[=[
    @class Background
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
local Background = function()
    return {
        Blend.New "ImageLabel" {
            Name = "Body";
            LayoutOrder = 2;
            Position = UDim2.fromOffset(140, 76);
            Size = UDim2.fromOffset(1088, 650);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            Image = "rbxassetid://79435216687877";
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = -2;
        };
        Blend.New "ImageLabel" {
            Name = "Header";
            LayoutOrder = 3;
            Position = UDim2.fromOffset(122, 30);
            Size = UDim2.fromOffset(1123, 98);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            Image = "rbxassetid://113025866489361";
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = -1;
        };
    }
end

-- [ Types ] --
type Props = {
    
}
type ModuleData = {}

export type Module = typeof(Background) & ModuleData

return Background :: Module