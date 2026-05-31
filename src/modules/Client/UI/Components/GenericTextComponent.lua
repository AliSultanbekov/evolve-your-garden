--[=[
    @class GenericText
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --

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
    Name: string?,
    Position: UDim2?,
    Size: UDim2?,
    AnchorPoint: Vector2?,
    TextSize: number?,
    Text: any?,
    TextColor: Color3?,
    StrokeThickness: number?,
    StrokeColor: Color3?,
}
type ModuleData = {}

export type Module = typeof(GenericTextComponent) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return GenericTextComponent :: Module