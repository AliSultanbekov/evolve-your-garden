--[=[
    @class CloseButton
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")

-- [ Components ] --
local GenericButtonComponent = require("GenericButtonComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CloseButtonComponent = function(props: Props)
    return GenericButtonComponent({
        Position = props.Position or UDim2.new(0.5, 0, 0.5, 0),
        Size = props.Size or UDim2.fromOffset(50,50),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundColor3 = Color3.fromRGB(255, 55, 59),
        BackgroundTransparency = 0,
        Children = {
            Blend.New "UICorner" {
                CornerRadius = UDim.new(0, 5)
            },
            Blend.New "UIStroke" {
                Thickness = 4,
                Color = Color3.fromRGB(137, 28, 28)
            },
        },
        OnPressed = props.OnClose
    })
end

-- [ Types ] --
type Props = {
    Position: UDim2?,
    Size: UDim2?,
    OnClose: () -> (),
}
type ModuleData = {}

export type Module = typeof(CloseButtonComponent) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return CloseButtonComponent :: Module