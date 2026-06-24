--[=[
    @class AnimatedFrame
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")
local ComponentTypes = require("ComponentTypes")

-- [ Components ] --
local ScalerComponent = require("ScalerComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

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
        Name = props.Name;
        Size = props.Size;
        Position = props.Position;
        AnchorPoint = props.AnchorPoint;
        BackgroundColor3 = props.BackgroundColor3;
        BackgroundTransparency = props.BackgroundTransparency;
        AutomaticSize = props.AutomaticSize;
        ZIndex = props.ZIndex;
        Visible = Blend.Computed(Scale, function(scale: number)
            return if scale < 0.01 then false else true
        end);
        [Blend.Children] = {
            ScalerComponent({ Scale = Scale, ApplyDeviceScale = true });
            props.Children :: any;
        }
    }
end

-- [ Types ] --
type Props = {
    Name: ComponentTypes.Prop<string>?,
    Size: ComponentTypes.Prop<UDim2>?,
    Position: ComponentTypes.Prop<UDim2>?,
    AnchorPoint: ComponentTypes.Prop<Vector2>?,
    BackgroundColor3: ComponentTypes.Prop<Color3>?,
    BackgroundTransparency: ComponentTypes.Prop<number>?,
    ZIndex: ComponentTypes.Prop<number>?,
    AutomaticSize: ComponentTypes.Prop<Enum.AutomaticSize>?,
    Children: { Observable.Observable<Instance> }?,
    IsOpen: ComponentTypes.Prop<boolean>,
}
type ModuleData = {}

export type Module = typeof(AnimatedFrameComponent) & ModuleData

return AnimatedFrameComponent :: Module