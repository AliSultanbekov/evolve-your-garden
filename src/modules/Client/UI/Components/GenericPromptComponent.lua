--[=[
    @class Prompt
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
local ComponentTypes = require("ComponentTypes")
local BillboardComponent = require("BillboardComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Prompt = function(props: Props)
    return BillboardComponent({
        Adornee = props.Adornee,
        ReferenceDepth = 18,
        MinScale = 0,
        MaxScale = 1.5,
        Children = {
            AnimatedFrameComponent({
                Name = "Prompt";
                Position = UDim2.fromScale(0.5, 0.5);
                AnchorPoint = Vector2.new(0.5, 0.5);
                Size = UDim2.fromOffset(246, 111);
                BackgroundTransparency = 1;
                IsOpen = props.IsOpen;
                Children = {
                    GenericButtonComponent({
                        Name = "Background";
                        Position = UDim2.fromScale(0.5, 0.5);
                        Size = UDim2.fromScale(1, 1);
                        AnchorPoint = Vector2.new(0.5, 0.5);
                        BackgroundTransparency = 1;
                        Image = "rbxassetid://98507209981643";
                        ZIndex = 2;
                        OnPressed = function()
                            props.Use()
                        end;
                        Children = {
                            Blend.New "TextLabel" {
                                Name = "Title";
                                LayoutOrder = 2;
                                Position = UDim2.fromOffset(22, 30);
                                Size = UDim2.fromOffset(124, 50);
                                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                                BackgroundTransparency = 1;
                                FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal);
                                Text = props.Text;
                                TextColor3 = Color3.fromRGB(255, 255, 255);
                                TextScaled = true;
                                TextSize = 18;
                                TextWrapped = true;
                                ZIndex = 3;
                                Blend.New "UIStroke" {
                                    Color = Color3.fromRGB(43, 73, 112);
                                    Thickness = 3;
                                };
                            };
                            Blend.New "ImageLabel" {
                                Name = "Key";
                                Position = UDim2.fromOffset(151, 12);
                                Size = UDim2.fromOffset(81, 84);
                                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                                BackgroundTransparency = 1;
                                Image = "rbxassetid://84152304552849";
                                ZIndex = 4;
                                Blend.New "TextLabel" {
                                    Name = "Key";
                                    Position = UDim2.fromOffset(18, 15);
                                    Size = UDim2.fromOffset(44, 51);
                                    BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                                    BackgroundTransparency = 1;
                                    FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal);
                                    Text = "E";
                                    TextColor3 = Color3.fromRGB(255, 255, 255);
                                    TextSize = 40;
                                    ZIndex = 2;
                                    Blend.New "UIStroke" {
                                        Color = Color3.fromRGB(43, 73, 112);
                                        Thickness = 3;
                                    };
                                };
                            };
                        }
                    })
                }
            });
        }
    })
end

-- [ Types ] --
type Props = {
    Adornee: Observable.Observable<Instance?>,
    IsOpen: Observable.Observable<boolean>,
    Text: ComponentTypes.Prop<string>,
    Use: () -> (),
}
type ModuleData = {}

export type Module = typeof(Prompt) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return Prompt :: Module