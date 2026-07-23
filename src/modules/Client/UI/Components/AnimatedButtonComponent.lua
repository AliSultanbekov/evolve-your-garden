--[=[
    @class AnimatedButtonComponent

    A GenericButton wrapped in an AnimatedFrame so it can slide/fade in and out
    with an IsOpen observable, with a centered text label. Used by the tooltip
    action buttons (Harvest / Info / Dig up / Close / Open ...).
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local Observable = require("Observable")

-- [ Components ] --
local GenericButtonComponent = require("GenericButtonComponent")
local AnimatedFrameComponent = require("AnimatedFrameComponent")

-- [ Constants ] --
local DEFAULT_SIZE = UDim2.fromOffset(118, 48)

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local AnimatedButtonComponent = function(props: Props)
    local Size = props.Size or DEFAULT_SIZE

    return AnimatedFrameComponent({
        Name = props.Name;
        IsOpen = props.IsOpen;
        Size = Size;
        LayoutOrder = props.LayoutOrder;
        BackgroundTransparency = 1;
        Children = {
            GenericButtonComponent({
                Name = props.Name;
                Size = UDim2.fromScale(1, 1);
                Position = UDim2.fromScale(0.5, 0.5);
                AnchorPoint = Vector2.new(0.5, 0.5);
                BackgroundTransparency = 1;
                Image = props.Image;
                OnPressed = props.OnPressed;
                Children = {
                    Blend.New "TextLabel" {
                        Name = "Name";
                        Position = UDim2.fromOffset(4, 4);
                        Size = UDim2.fromOffset(Size.X.Offset - 8, 37);
                        BackgroundTransparency = 1;
                        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                        Text = props.Text;
                        TextColor3 = Color3.fromRGB(255, 255, 255);
                        TextSize = 18;
                        ZIndex = 2;
                        Blend.New "UIStroke" {
                            Color = props.StrokeColor;
                            LineJoinMode = Enum.LineJoinMode.Miter;
                            Thickness = 2;
                        };
                    };
                };
            });
        };
    })
end

-- [ Types ] --
type Props = {
    Name: string,
    IsOpen: Observable.Observable<boolean>,
    Image: string,
    Text: string,
    StrokeColor: Color3,
    OnPressed: (...any) -> ...any,
    Size: UDim2?,
    LayoutOrder: number?,
}
type ModuleData = {}

export type Module = typeof(AnimatedButtonComponent) & ModuleData

return AnimatedButtonComponent :: Module
