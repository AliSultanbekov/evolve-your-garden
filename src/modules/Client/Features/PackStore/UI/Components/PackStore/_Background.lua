--[=[
    @class Background
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
local Background = function()
    return {
        Blend.New "ImageLabel" {
            Name = "Background";
            Position = UDim2.fromOffset(-133, 0);
            Size = UDim2.fromOffset(1161, 768);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Image = "rbxassetid://125498616695817";
            ScaleType = Enum.ScaleType.Fit;
            ZIndex = 2;
        }
    }
end

-- [ Types ] --
type Props = {
    
}
type ModuleData = {}

export type Module = typeof(Background) & ModuleData

return Background :: Module