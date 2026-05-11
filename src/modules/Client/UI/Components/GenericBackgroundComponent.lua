--[=[
    @class InventoryBackground
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
local GenericBackgroundComponent = function()
    return Blend.New "ImageLabel" {
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "",
        BackgroundColor3 = Color3.fromRGB(64, 179, 255),
        BackgroundTransparency = 0,
        ZIndex = -100,

        [Blend.Children] = {
            Blend.New "UICorner" {
                CornerRadius = UDim.new(0, 10)
            },
            Blend.New "UIStroke" {
                Thickness = 4,
                Color = Color3.fromRGB(36, 66, 125)
            },
        },
    }
end

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(GenericBackgroundComponent) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return GenericBackgroundComponent :: Module