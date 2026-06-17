--[=[
    @class CloseButton
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ComponentTypes = require("ComponentTypes")

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
        Image = props.Image or "rbxassetid://102596582557061";
        BackgroundTransparency = props.BackgroundTransparency;
        ZIndex = props.ZIndex;
        OnPressed = props.OnClose
    })
end

-- [ Types ] --
type Props = {
    Position: ComponentTypes.Prop<UDim2>?,
    Size: ComponentTypes.Prop<UDim2>?,
    AnchorPoint: ComponentTypes.Prop<Vector2>?,
    BackgroundTransparency: ComponentTypes.Prop<number>?,
    ZIndex: ComponentTypes.Prop<number>?,
    Image: ComponentTypes.Prop<string>?,
    OnClose: () -> ()?,
}
type ModuleData = {}

export type Module = typeof(CloseButtonComponent) & ModuleData

return CloseButtonComponent :: Module