--[=[
    @class SearchBar
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Blend = require("Blend")

-- [ Components ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Functions ] --

-- [ Module Table ] --
local SearchBar = function(props: Props)
    return Blend.New "Frame" {
        Name = "SearchBar";
        LayoutOrder = 5;
        Position = UDim2.fromOffset(675, 61);
        Size = UDim2.fromOffset(350, 60);
        BackgroundColor3 = Color3.fromRGB(163, 162, 165);
        BackgroundTransparency = 1;
        ZIndex = 4;
        Blend.New "ImageLabel" {
            Name = "SearchBarBackground";
            Position = UDim2.fromOffset(-3, -3);
            Size = UDim2.fromOffset(356, 66);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            Image = "rbxassetid://106903151714909";
            ScaleType = Enum.ScaleType.Fit;
        };
        Blend.New "TextBox" {
            Name = "Text";
            LayoutOrder = 1;
            Position = UDim2.fromOffset(10, 9);
            Size = UDim2.fromOffset(330, 42);
            BackgroundColor3 = Color3.fromRGB(163, 162, 165);
            BackgroundTransparency = 1;
            CursorPosition = -1;
            Text = "";
            FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json");
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 32;
            TextWrapped = true;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 2;
            [Blend.OnChange "Text"] = function(text: string)
                props.OnSearch(text)
            end
        };
    }
end

-- [ Types ] --
type Props = {
    OnSearch: (text: string) -> (),
}
type ModuleData = {}

export type Module = typeof(SearchBar) & ModuleData

return SearchBar :: Module