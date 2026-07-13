--[=[
    @class GenericButton
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local ValueObject = require("ValueObject")
local Observable = require("Observable")
local ComponentTypes = require("ComponentTypes")

-- [ Components ] --
local ScalerComponent = require("ScalerComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local GenericButtonComponent = function(props: Props)
    local IsPressed = ValueObject.new(false)
    local VisibleState = if props.Visible == nil then true else props.Visible

    local Scale = Blend.Spring(
        Blend.Computed(IsPressed, function(pressed: boolean)
            return if pressed then 0.9 else 1
        end),
        35
    )

    local ButtonInstance: GuiButton

    return Blend.New "ImageButton" {
        Name = props.Name,
        Position = props.Position;
        Size = props.Size;
        AnchorPoint = props.AnchorPoint;
        ZIndex = props.ZIndex,
        LayoutOrder = props.LayoutOrder;
        BackgroundColor3 = props.BackgroundColor3;
        BackgroundTransparency = props.BackgroundTransparency;
        Visible = VisibleState;
        Parent = props.Parent;
        Image = props.Image or "";
        [Blend.Instance] = function(inst: GuiButton)
            ButtonInstance = inst
        end;
        [Blend.OnEvent "Activated"] = function()
            if props.OnPressed then props.OnPressed(ButtonInstance) end
        end;
        [Blend.OnEvent "InputBegan"] = function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
               or input.UserInputType == Enum.UserInputType.Touch then
                IsPressed.Value = true

                local conn
                conn = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        IsPressed.Value = false
                        conn:Disconnect()
                    end
                end)
            end
        end;
        [Blend.OnEvent "MouseEnter"] = function()
            if props.OnHovered then
                props.OnHovered(ButtonInstance)
            end
        end;
        [Blend.OnEvent "MouseLeave"] = function()
            IsPressed.Value = false

            if props.OnUnhovered then
                props.OnUnhovered(ButtonInstance)
            end
        end;
        [Blend.OnEvent "Destroying"] = function()
            if props.OnDestroyed then
                props.OnDestroyed()
            end
        end;
        [Blend.Children] = {
            ScalerComponent({ Scale = Scale });
            props.Children :: any
        };
    }
end

-- [ Types ] --
type Props = {
    Name: ComponentTypes.Prop<string>?,
    Position: ComponentTypes.Prop<UDim2>?,
    Size: ComponentTypes.Prop<UDim2>?,
    AnchorPoint: ComponentTypes.Prop<Vector2>?,
    ZIndex: ComponentTypes.Prop<number>?,
    LayoutOrder: ComponentTypes.Prop<number>?,
    BackgroundColor3: ComponentTypes.Prop<Color3>?,
    BackgroundTransparency: ComponentTypes.Prop<number>?,
    Parent: ComponentTypes.Prop<Instance>?,
    Visible: ComponentTypes.Prop<boolean>?,
    Image: ComponentTypes.Prop<string>?,
    OnPressed: ((buttonInstance: GuiButton) -> ())?,
    OnHovered: ((buttonInstance: GuiButton) -> ())?,
    OnUnhovered: ((buttonInstance: GuiButton) -> ())?,
    OnDestroyed: (() -> ())?,
    Children: { Observable.Observable<Instance> }?,
}
type ModuleData = {}

export type Module = typeof(GenericButtonComponent) & ModuleData

return GenericButtonComponent :: Module
