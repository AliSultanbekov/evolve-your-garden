--[=[
    @class ResponseCard
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script:FindFirstAncestor("Components").loader).load(script) :: typeof(require)

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
        Size = UDim2.fromOffset(286, 56);
        BackgroundTransparency = 1;
        Image = "rbxassetid://86693117896157";
        ScaleType = Enum.ScaleType.Fit;
        Children = {
            Blend.New "TextLabel" {
                Name = "Number";
                Position = UDim2.fromOffset(6, 6);
                Size = UDim2.fromOffset(44, 44);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Italic);
                Text = props.Response.Id;
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 18;
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(43, 73, 112);
                    Thickness = 2;
                };
            };
            Blend.New "TextLabel" {
                Name = "Text";
                LayoutOrder = 1;
                Position = UDim2.fromOffset(55, 6);
                Size = UDim2.fromOffset(220, 44);
                BackgroundColor3 = Color3.fromRGB(163, 162, 165);
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Italic);
                Text = props.Response.Text;
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 16;
                TextWrapped = true;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 2;
                Blend.New "UIStroke" {
                    Color = Color3.fromRGB(43, 73, 112);
                    Thickness = 2;
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