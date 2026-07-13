--[=[
    @class TooltipBackgroundComponent

    Shared 9-sliced tooltip background. Fills its parent, so the tooltip frame
    decides the size.
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
local TooltipBackgroundComponent = function()
    return Blend.New "ImageLabel" {
        Name = "Background";
        Position = UDim2.fromScale(0.5, 0.5);
        AnchorPoint = Vector2.new(0.5, 0.5);
        Size = UDim2.fromScale(1, 1);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        Image = "rbxassetid://126179151125521";
        ScaleType = Enum.ScaleType.Slice;
        SliceCenter = Rect.new(Vector2.new(256, 162), Vector2.new(256, 634));
        SliceScale = 0.5;
    };
end

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(TooltipBackgroundComponent) & ModuleData

return TooltipBackgroundComponent :: Module
