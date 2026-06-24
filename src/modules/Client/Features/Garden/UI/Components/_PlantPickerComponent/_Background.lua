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
        Position = UDim2.fromOffset(9, 38);
        Size = UDim2.fromOffset(1086, 658);
        BackgroundTransparency = 1;
        Image = "rbxassetid://130761303210940";
        ScaleType = Enum.ScaleType.Fit;
    };
end

-- [ Types ] --
type Props = {
    
}
type ModuleData = {}

export type Module = typeof(Background) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Background :: Module