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
            return if open then 0.4 else 1
        end)
    )

    local VisibleState = if props.Visible == nil then true else props.Visible

    return Blend.New "Frame" {
        Name = props.Name;
        Size = props.Size;
        Position = props.Position;
        AnchorPoint = props.AnchorPoint;
        BackgroundColor3 = props.BackgroundColor3;
        BackgroundTransparency = props.BackgroundTransparency;
        AutomaticSize = props.AutomaticSize;
        LayoutOrder = props.LayoutOrder;
        ZIndex = props.ZIndex;
        Parent = props.Parent;
        Visible = Blend.Computed(Scale, VisibleState, function(scale: number, visible: boolean)
            return visible and scale >= 0.01
        end);
        [Blend.Children] = {
            ScalerComponent({ Scale = Scale, ApplyDeviceScale = props.ApplyDeviceScale or false });
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
    LayoutOrder: ComponentTypes.Prop<number>?,
    AutomaticSize: ComponentTypes.Prop<Enum.AutomaticSize>?,
    Visible: ComponentTypes.Prop<boolean>?,
    Parent: ComponentTypes.Prop<Instance>?,
    Children: { Observable.Observable<Instance> }?,
    ApplyDeviceScale: boolean?,
    IsOpen: ComponentTypes.Prop<boolean>,
}
type ModuleData = {}

export type Module = typeof(AnimatedFrameComponent) & ModuleData

return AnimatedFrameComponent :: Module