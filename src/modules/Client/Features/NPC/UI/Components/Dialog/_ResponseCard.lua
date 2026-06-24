--[=[
    @class ResponseCard
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")
local NPCTypesShared = require("NPCTypesShared")

-- [ Components ] --
local GenericButtonComponent = require("GenericButtonComponent")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ResponseCard = function(props: Props)
    return GenericButtonComponent({
        Name = "Response";
        Size = UDim2.fromOffset(303, 50);
        BackgroundTransparency = 1;
        Image = "rbxassetid://139632621327134";
        ScaleType = Enum.ScaleType.Fit;
        Children = {
            Blend.New "TextLabel" {
                Name = "Number";
                Position = UDim2.fromOffset(6, 6);
                Size = UDim2.fromOffset(39, 38);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal);
                Text = props.Response.Id;
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 18;
                TextWrapped = true;
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(43, 73, 112);
                    Thickness = 3;
                };
            };
            Blend.New "TextLabel" {
                Name = "Text";
                LayoutOrder = 1;
                Position = UDim2.fromOffset(45, 6);
                Size = UDim2.fromOffset(255, 38);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal);
                Text = props.Response.Text;
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 13;
                TextWrapped = true;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 2;
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(43, 73, 112);
                    Thickness = 3;
                };
            };
        };
        OnPressed = function()
            props.ChooseResponse(props.Response)
        end
    })
end

-- [ Types ] --
type Props = {
    Response: NPCTypesShared.Response,
    ChooseResponse: (response: NPCTypesShared.Response) -> (),
}
type ModuleData = {}

export type Module = typeof(ResponseCard) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return ResponseCard :: Module