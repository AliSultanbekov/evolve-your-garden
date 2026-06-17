--[=[
    @class GenericText
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
local GenericTextComponent = function(props: Props)
    return Blend.New "TextLabel" {
        Name = props.Name or "TextLabel";
        Position = props.Position;
        Size = props.Size;
        AnchorPoint = props.AnchorPoint;
        BackgroundTransparency = 1;
        FontFace = Font.fromEnum(Enum.Font.FredokaOne);
        TextColor3 = props.TextColor or Color3.fromRGB(255, 255, 255);
        TextSize = props.TextSize;
        Text = props.Text or "";

        [Blend.Children] = {
            Blend.New "UIStroke" {
                Thickness = props.StrokeThickness;
                Color = props.StrokeColor or Color3.new();
            };
        }
    }
end

-- [ Types ] --
type Props = {
    Name: ComponentTypes.Prop<string>?,
    Position: ComponentTypes.Prop<UDim2>?,
    Size: ComponentTypes.Prop<UDim2>?,
    AnchorPoint: ComponentTypes.Prop<Vector2>?,
    TextSize: ComponentTypes.Prop<number>?,
    Text: ComponentTypes.Prop<string>?,
    TextColor: ComponentTypes.Prop<Color3>?,
    StrokeThickness: ComponentTypes.Prop<number>?,
    StrokeColor: ComponentTypes.Prop<Color3>?,
}
type ModuleData = {}

export type Module = typeof(GenericTextComponent) & ModuleData

return GenericTextComponent :: Module