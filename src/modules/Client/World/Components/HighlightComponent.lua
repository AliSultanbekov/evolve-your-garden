--[=[
    @class HighlightComponent
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local ComponentTypes = require("ComponentTypes")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local HighlightComponent = function(props: Props)
    return Blend.New "Highlight" {
        Enabled = props.Enabled;
        FillColor = props.FillColor or Color3.new(1, 1, 1);
        FillTransparency = props.FillTransparency or 0;
        OutlineColor = props.OutlineColor or Color3.new(1, 1, 1);
        OutlineTransparency = props.OutlineTransparency or 0;
        Adornee = props.Adornee;
        Parent = props.Adornee;
    }
end

-- [ Types ] --
type Props = {
    Enabled: ComponentTypes.Prop<boolean>,
    Adornee: ComponentTypes.Prop<Instance>,
    FillColor: ComponentTypes.Prop<Color3>?,
    FillTransparency: ComponentTypes.Prop<number>?,
    OutlineColor: ComponentTypes.Prop<Color3>?,
    OutlineTransparency: ComponentTypes.Prop<number>?,
}
type ModuleData = {}

export type Module = typeof(HighlightComponent) & ModuleData

return HighlightComponent :: Module
