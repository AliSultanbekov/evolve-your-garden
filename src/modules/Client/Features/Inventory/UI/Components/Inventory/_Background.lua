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
    return Blend.New "ImageLabel" {
        Name = "Background";
        Position = UDim2.fromOffset(137, -4);
        Size = UDim2.fromOffset(1086, 658);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        Image = "rbxassetid://76654083656418";
        ScaleType = Enum.ScaleType.Fit;
        ZIndex = 1;
    }
end

-- [ Types ] --
type Props = {
    
}
type ModuleData = {}

export type Module = typeof(Background) & ModuleData

return Background :: Module