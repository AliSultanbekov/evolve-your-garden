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

-- [ Module Table ] --
local Background = function()
    return {
        Blend.New "ImageLabel" {
            Name = "Header";
            Position = UDim2.fromOffset(-4, 29);
            Size = UDim2.fromOffset(1123, 98);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            Image = "rbxassetid://100380371914132";
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = -1;
        };
        Blend.New "ImageLabel" {
            Name = "Body";
            Position = UDim2.fromOffset(13, 108);
            Size = UDim2.fromOffset(1088, 650);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            Image = "rbxassetid://111287528532725";
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = -2;
        };
    }
end

-- [ Types ] --
type Props = {
    
}
type ModuleData = {}

export type Module = typeof(Background) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Background :: Module