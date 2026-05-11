--[=[
    @class AnimatedFrame
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")

-- [ Components ] --
local ScalerComponent = require("ScalerComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local AnimatedFrameComponent = function(props: Props)
    local Scale = Blend.Spring(
        Blend.Computed(props.IsOpen, function(open: boolean)
            return if open then 1 else 0
        end),
        Blend.Computed(props.IsOpen, function(open: boolean)
            return if open then 35 else 50
        end),
        Blend.Computed(props.IsOpen, function(open: boolean)
            return if open then 1.5 else 1
        end)
    )

    return Blend.New "Frame" {
        Name = props.Name,
        Size = props.Size,
        Position = props.Position or UDim2.fromScale(0.5,0.5),
        AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
        BackgroundColor3 = props.BackgroundColor3,
        BackgroundTransparency = props.BackgroundTransparency or 1,
        Visible = Blend.Computed(Scale, function(scale: number)
            return if scale < 0.01 then false else true
        end),
        [Blend.Children] = {
            ScalerComponent({ Scale = Scale, ApplyDeviceScale = true }),
            props.Children :: any,
        }
    }
end

-- [ Types ] --
type Props = {
    Name: string,
    Size: UDim2,
    Position: UDim2?,
    AnchorPoint: Vector2?,
    BackgroundColor3: Color3?,
    BackgroundTransparency: number?,
    IsOpen: Observable.Observable<boolean>,
    Children: { Observable.Observable<Instance> }?,
}
type ModuleData = {}

export type Module = typeof(AnimatedFrameComponent) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return AnimatedFrameComponent :: Module