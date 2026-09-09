--[=[
    @class AnimatedButtonComponent

    A GenericButton wrapped in an AnimatedFrame. Owns ALL button animation:
    slide/fade in-out via IsOpen, and the press-shrink spring fed into the
    inner button's Scale. GenericButton itself stays animation-free.

    Text is optional — when given, renders the centered label (tooltip action
    buttons); otherwise pass Children for custom layouts. ShouldAnimate = false
    turns it into a static button: no press shrink, always visible.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")
local ValueObject = require("ValueObject")

-- [ Components ] --
local GenericButtonComponent = require("GenericButtonComponent")
local AnimatedFrameComponent = require("AnimatedFrameComponent")

-- [ Constants ] --
local DEFAULT_SIZE = UDim2.fromOffset(118, 48)

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local AnimatedButtonComponent = function(props: Props)
    local ShouldAnimate = props.ShouldAnimate ~= false

    local IsPressed = ValueObject.new(false)
    local PressScale = Blend.Spring(
        Blend.Computed(IsPressed, function(pressed: boolean)
            return if pressed and ShouldAnimate then 0.9 else 1
        end),
        35,
        0.35
    )

    local ButtonChildren: { any } = {}

    if props.Text then
        table.insert(ButtonChildren, Blend.New "TextLabel" {
            Name = "Name";
            Position = UDim2.fromOffset(4, 4);
            Size = UDim2.new(1, -8, 0, 37);
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
            Text = props.Text;
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = props.TextSize or 18;
            ZIndex = 2;
            Blend.New "UIStroke" {
                Color = props.StrokeColor;
                LineJoinMode = Enum.LineJoinMode.Miter;
                Thickness = 2;
            };
        })
    end

    if props.Children then
        table.insert(ButtonChildren, props.Children)
    end

    return AnimatedFrameComponent({
        Name = props.Name;
        IsOpen = if not ShouldAnimate or props.IsOpen == nil then true else props.IsOpen;
        Size = props.Size or DEFAULT_SIZE;
        Position = props.Position;
        AnchorPoint = props.AnchorPoint;
        ZIndex = props.ZIndex;
        LayoutOrder = props.LayoutOrder;
        Visible = props.Visible;
        Parent = props.Parent;
        BackgroundTransparency = 1;
        Children = {
            GenericButtonComponent({
                Name = props.Name;
                Size = UDim2.fromScale(1, 1);
                Position = UDim2.fromScale(0.5, 0.5);
                AnchorPoint = Vector2.new(0.5, 0.5);
                ImageColor3 = props.ImageColor3,
                BackgroundTransparency = 1;
                Image = props.Image;

                Scale = PressScale;
                OnPressed = props.OnPressed;
                OnPressBegan = function()
                    IsPressed.Value = true
                end;
                OnPressEnded = function()
                    IsPressed.Value = false
                end;
                OnHovered = props.OnHovered;
                OnUnhovered = props.OnUnhovered;
                OnDestroyed = props.OnDestroyed;
                Children = ButtonChildren;
            });
        };
    })
end

-- [ Types ] --
type Props = {
    Name: string,
    IsOpen: Observable.Observable<boolean>?,
    ShouldAnimate: boolean?,
    Image: string?,
    ImageColor3: any?,
    Text: string?,
    TextSize: number?,
    StrokeColor: Color3?,
    Children: { any }?,
    OnPressed: (...any) -> ...any,
    OnHovered: ((buttonInstance: GuiButton) -> ())?,
    OnUnhovered: ((buttonInstance: GuiButton) -> ())?,
    OnDestroyed: (() -> ())?,
    Size: UDim2?,
    Position: UDim2?,
    AnchorPoint: Vector2?,
    ZIndex: number?,
    LayoutOrder: number?,
    Visible: any?,
    Parent: any?,
}
type ModuleData = {}

export type Module = typeof(AnimatedButtonComponent) & ModuleData

return AnimatedButtonComponent :: Module
