--[=[
    @class SpeechBubbleComponent
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
local SpeechBubbleComponent = function(props: Props)
    return Blend.New "Frame" {
        Position = UDim2.fromScale(0.5, 0.5);
        AnchorPoint = Vector2.new(0, 1);
        Size = UDim2.fromOffset(250, 100);
        BackgroundTransparency = 1;
        [Blend.Children] = {
            Blend.New "Frame" {
                Position = UDim2.fromScale(1, 0);
                AnchorPoint = Vector2.new(1, 0);
                Size = UDim2.new(1, -20, 1, -20);
                BackgroundColor3 = Color3.fromRGB(64, 179, 255);
                ZIndex = 2;
                Blend.New "UICorner" {
                    CornerRadius = UDim.new(0, 15);
                };
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(36, 66, 125);
                    Thickness = 4;
                };
                [Blend.Children] = {
                    Blend.New "UIListLayout" {},
                    props.Children :: any
                }
            };
            Blend.New "Frame" {
                Position = UDim2.fromScale(0, 1);
                AnchorPoint = Vector2.new(0, 1);
                Size = UDim2.fromOffset(20, 20);
                BackgroundColor3 = Color3.fromRGB(64, 179, 255);
                Blend.New "UICorner" {
                    CornerRadius = UDim.new(0, 15);
                };
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(36, 66, 125);
                    Thickness = 4;
                };
            };
            Blend.New "Frame" {
                Position = UDim2.new(0, 10, 1, -10);
                AnchorPoint = Vector2.new(0, 1);
                Size = UDim2.fromOffset(30, 30);
                BackgroundColor3 = Color3.fromRGB(64, 179, 255);
                Blend.New "UICorner" {
                    CornerRadius = UDim.new(0, 15);
                };
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(36, 66, 125);
                    Thickness = 4;
                };
            };
        }
    }
end

-- [ Types ] --
type Props = {
    Children: { any }?,
}
type ModuleData = {}

export type Module = typeof(SpeechBubbleComponent) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return SpeechBubbleComponent :: Module
