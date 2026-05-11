--[=[
    @class Scaler
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")
local ScreenSizeUtils = require("ScreenSizeUtils")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ScalerComponent = function(props: Props)
    local DeviceScale = ScreenSizeUtils.ComputeScale()

    return Blend.New "UIScale" {
        Name = "Scaler",
        Scale = Blend.Computed(
            props.Scale,
            DeviceScale,
            function(scale: number, device: number)
                return scale * (if props.ApplyDeviceScale and props.ApplyDeviceScale == true then device else 1)
            end
        ),
    }
end

-- [ Types ] --
type Props = {
    Scale: Observable.Observable<number>,
    ApplyDeviceScale: boolean?,
}
type ModuleData = {}

export type Module = typeof(ScalerComponent) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return ScalerComponent :: Module