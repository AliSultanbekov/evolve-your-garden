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
        Position = UDim2.fromScale(0.5, 0.5);
        AnchorPoint = Vector2.new(0.5, 0.5);
        Size = UDim2.fromScale(1, 1);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        Image = "rbxassetid://88190543344636";
        ScaleType = Enum.ScaleType.Slice;
        SliceCenter = Rect.new(Vector2.new(261, 190), Vector2.new(261, 712));
    };
end

-- [ Types ] --
type Props = {
    
}
type ModuleData = {}

export type Module = typeof(Background) & ModuleData

return Background :: Module