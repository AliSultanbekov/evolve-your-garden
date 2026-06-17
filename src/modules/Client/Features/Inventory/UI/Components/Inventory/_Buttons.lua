--[=[
    @class Buttons
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")

-- [ Components ] --
local GenericButtonComponent = require("GenericButtonComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local Buttons = function(props: Props)
    return Blend.New "Frame" {
        Name = "Buttons";
        LayoutOrder = 4;
        Position = UDim2.fromOffset(137, 654);
        Size = UDim2.fromOffset(1086, 75);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ClipsDescendants = true;
        ZIndex = 5;
        GenericButtonComponent({
            Name = "DeleteMode";
            Position = UDim2.fromOffset(444+146/2, 7+59/2);
            Size = UDim2.fromOffset(146, 59);
            AnchorPoint = Vector2.new(0.5, 0.5);
            BackgroundTransparency = 1;
            Image = "rbxassetid://139153995388769";
            OnPressed = props.OnDeleteMode;
            Children = {
                Blend.New "TextLabel" {
                    Name = "DeleteMode";
                    Position = UDim2.fromOffset(6, 6);
                    Size = UDim2.fromOffset(134, 44);
                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                    BackgroundTransparency = 1;
                    FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal);
                    Text = "Delete Mode";
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    TextSize = 18;
                    TextWrapped = true;
                    Blend.New "UIStroke" {
                        Color = Color3.fromRGB(130, 40, 40);
                        LineJoinMode = Enum.LineJoinMode.Miter;
                        Thickness = 3;
                    };
                };
            }
        });
    }
end

-- [ Types ] --
type Props = {
    OnDeleteMode: () -> (),
}
type ModuleData = {}

export type Module = typeof(Buttons) & ModuleData

return Buttons :: Module
