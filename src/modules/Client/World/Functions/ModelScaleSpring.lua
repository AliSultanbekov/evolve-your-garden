--[=[
    @class ModelScaleSpring

    Springs a model's scale toward Target, relative to the scale it started at
    (Target 1 = as authored). Model:ScaleTo is absolute, so a model resized with
    the Scale tool would otherwise snap back to its pre-resize size.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local ComponentTypes = require("ComponentTypes")
local SpringAnimationPresets = require("SpringAnimationPresets")

-- [ Constants ] --
-- ScaleTo(0) errors, and a bouncy spring can swing below zero.
local MIN_SCALE = 0.01

-- [ Variables ] --

-- [ Module Table ] --
local ModelScaleSpring = function(props: Props)
    local BaseScale = props.Model:GetScale()

    return Blend.Spring(props.Target, props.Preset.Speed, props.Preset.Damper):Subscribe(function(scale: number)
        props.Model:ScaleTo(BaseScale * math.max(scale, MIN_SCALE))
    end)
end

-- [ Types ] --
type Props = {
    Model: Model,
    Target: ComponentTypes.Prop<number>,
    Preset: SpringAnimationPresets.SpringAnimationPreset,
}
type ModuleData = {}

export type Module = typeof(ModelScaleSpring) & ModuleData

return ModelScaleSpring :: Module
