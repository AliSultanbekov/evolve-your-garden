--[=[
    @class CloseButton
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Components ] --
local GenericButtonComponent = require("GenericButtonComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table 
local CloseButtonComponent = function(props: Props)
    return GenericButtonComponent({
        Position = props.Position;
        Size = props.Size;
        AnchorPoint = props.AnchorPoint;
        Image = "rbxassetid://102596582557061";
        BackgroundTransparency = props.BackgroundTransparency;
        ZIndex = props.ZIndex;
        OnPressed = props.OnClose
    })
end

-- [ Types ] --
type Props = {
    Position: UDim2?,
    Size: UDim2?,
    AnchorPoint: Vector2?,
    BackgroundTransparency: number?,
    ZIndex: number?,
    OnClose: () -> ()?,
}
type ModuleData = {}

export type Module = typeof(CloseButtonComponent) & ModuleData

return CloseButtonComponent :: Module