--[=[
    @class Scaler
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local ComponentTypes = require("ComponentTypes")
local ScreenSizeUtils = require("ScreenSizeUtils")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local ScalerComponent = function(props: Props)
    local DeviceScale = ScreenSizeUtils.ComputeScale()

    return Blend.New "UIScale" {
        Name = "Scaler";
        Scale = Blend.Computed(
            props.Scale or 1,
            DeviceScale,
            function(scale: number?, device: number)
                return (scale or 1) * (if props.ApplyDeviceScale == true then device else 1)
            end
        );
    }
end

-- [ Types ] --
type Props = {
    Scale: ComponentTypes.Prop<number>?,
    ApplyDeviceScale: boolean?,
}
type ModuleData = {}

export type Module = typeof(ScalerComponent) & ModuleData

return ScalerComponent :: Module