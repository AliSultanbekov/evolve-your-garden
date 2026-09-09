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

-- [ Module Table ] --
local Background = function()
    return Blend.New "ImageLabel" {
        Name = "Background";
        LayoutOrder = 1;
        Position = UDim2.fromScale(-0.000085, 0.000128);
        Size = UDim2.new(-0.00031, 1162, 0.000256, 768);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ClipsDescendants = true;
        Image = "rbxassetid://120413715759124";
        ScaleType = Enum.ScaleType.Fit;
        ZIndex = 2;
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