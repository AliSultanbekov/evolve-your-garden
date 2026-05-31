--[=[
    @class SpeechBubbleStory
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = (require :: any)(game:GetService("ServerScriptService"):FindFirstChild("LoaderUtils", true).Parent).bootstrapStory(script) :: typeof(require)

-- [ Imports ] --
local Maid = require("Maid")
local Blend = require("Blend")

-- [ Components ] --
local SpeechBubbleComponent = require("SpeechBubbleComponent")

-- [ Constants ] --

-- [ Variables ] --
local controls = {
    Text = "Snow Blossom";
    FillColor = Color3.fromRGB(95, 175, 240);
    OutlineColor = Color3.fromRGB(40, 100, 180);
}

-- [ Module Table ] --
local SpeechBubbleStory = {
    summary = "Speech bubble callout used over plants/slots in the world";
    controls = controls;
    render = function(props: { target: Instance, controls: typeof(controls), subscribe: any })
        local MaidObject = Maid.new()

        MaidObject:Add(Blend.mount(props.target, {
            SpeechBubbleComponent({
                Size = UDim2.fromOffset(320, 180);
                Position = UDim2.fromScale(0.5, 0.5);
                AnchorPoint = Vector2.new(0.5, 0.5);
                FillColor = props.controls.FillColor;
                OutlineColor = props.controls.OutlineColor;
                Children = {
                    Blend.New "TextLabel" {
                        Size = UDim2.fromScale(1, 1);
                        BackgroundTransparency = 1;
                        Text = props.controls.Text;
                        Font = Enum.Font.GothamBold;
                        TextSize = 28;
                        TextColor3 = Color3.new(1, 1, 1);
                        TextStrokeTransparency = 0.4;
                        TextWrapped = true;
                    };
                };
            });
        }))

        return function()
            MaidObject:Destroy()
        end
    end;
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(SpeechBubbleStory) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return SpeechBubbleStory :: Module
